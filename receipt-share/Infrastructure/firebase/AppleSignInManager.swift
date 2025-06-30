import Foundation
import AuthenticationServices
import FirebaseAuth
import CryptoKit


class AppleSignInManager: NSObject {
    private var currentNonce: String?
    private var signInContinuation: CheckedContinuation<AuthUser, Error>?
    private var deleteAccountContinuation: CheckedContinuation<Void, Error>?
    private var operationMode: OperationMode = .signIn
    
    private enum OperationMode {
        case signIn
        case deleteAccount
    }
    
    func signIn() async throws -> AuthUser {
        return try await withCheckedThrowingContinuation { continuation in
            self.signInContinuation = continuation
            performAppleSignIn()
        }
    }
    
    // 🆕 Firebase公式ドキュメント準拠のアカウント削除
    func deleteUserAccount() async throws {
        return try await withCheckedThrowingContinuation { continuation in
            self.operationMode = .deleteAccount
            self.deleteAccountContinuation = continuation
            self.signInContinuation = nil
            performAppleSignInForDeletion()
        }
    }
    
    private func performAppleSignIn() {
        let nonce = randomNonceString()
        currentNonce = nonce
        
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    // 🆕 アカウント削除用のApple Sign In
    private func performAppleSignInForDeletion() {
        let nonce = randomNonceString()
        currentNonce = nonce
        
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    // MARK: - Helper Methods
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
        }
        
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        let nonce = randomBytes.map { byte in
            charset[Int(byte) % charset.count]
        }
        
        return String(nonce)
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
}

// MARK: - ASAuthorizationControllerDelegate

extension AppleSignInManager: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch operationMode {
        case .signIn:
            guard let continuation = signInContinuation else { return }
            signInContinuation = nil
            
            switch authorization.credential {
            case let appleIDCredential as ASAuthorizationAppleIDCredential:
                handleAppleIDCredential(appleIDCredential, continuation: continuation)
            default:
                continuation.resume(throwing: NSError(domain: "AppleSignIn", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unknown credential type"]))
            }
            
        case .deleteAccount:
            guard let continuation = deleteAccountContinuation else { return }
            deleteAccountContinuation = nil
            
            switch authorization.credential {
            case let appleIDCredential as ASAuthorizationAppleIDCredential:
                handleAppleIDCredentialForDeletion(appleIDCredential, continuation: continuation)
            default:
                continuation.resume(throwing: NSError(domain: "AppleSignIn", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unknown credential type"]))
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        switch operationMode {
        case .signIn:
            if let continuation = signInContinuation {
                signInContinuation = nil
                continuation.resume(throwing: error)
            }
            
        case .deleteAccount:
            if let continuation = deleteAccountContinuation {
                deleteAccountContinuation = nil
                continuation.resume(throwing: error)
            }
        }
    }
    
    private func handleAppleIDCredential(_ appleIDCredential: ASAuthorizationAppleIDCredential, continuation: CheckedContinuation<AuthUser, Error>) {
        guard let nonce = currentNonce else {
            continuation.resume(throwing: NSError(domain: "AppleSignIn", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid state: A login callback was received, but no login request was sent."]))
            return
        }
        
        guard let appleIDToken = appleIDCredential.identityToken else {
            continuation.resume(throwing: NSError(domain: "AppleSignIn", code: 2, userInfo: [NSLocalizedDescriptionKey: "Unable to fetch identity token"]))
            return
        }
        
        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            continuation.resume(throwing: NSError(domain: "AppleSignIn", code: 3, userInfo: [NSLocalizedDescriptionKey: "Unable to serialize token string from data"]))
            return
        }
        
        // Firebase推奨のappleCredentialを使用
        let credential = OAuthProvider.appleCredential(withIDToken: idTokenString,
                                                      rawNonce: nonce,
                                                      fullName: appleIDCredential.fullName)
        
        Task {
            do {
                let result = try await Auth.auth().signIn(with: credential)
                let user = result.user
                let authUser = AuthUser(id: user.uid, email: user.email ?? "")
                continuation.resume(returning: authUser)
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
    
    // 🆕 Firebase公式ドキュメント準拠のアカウント削除処理
    private func handleAppleIDCredentialForDeletion(_ appleIDCredential: ASAuthorizationAppleIDCredential, continuation: CheckedContinuation<Void, Error>) {
        print("🍎 Apple Sign In for deletion started")
        
        guard let appleAuthCode = appleIDCredential.authorizationCode else {
            print("❌ Apple authorization code is nil")
            continuation.resume(throwing: NSError(domain: "AppleSignIn", code: 2, userInfo: [NSLocalizedDescriptionKey: "Unable to fetch authorization code"]))
            return
        }
        
        guard let authCodeString = String(data: appleAuthCode, encoding: .utf8) else {
            print("❌ Failed to convert authorization code to string")
            continuation.resume(throwing: NSError(domain: "AppleSignIn", code: 3, userInfo: [NSLocalizedDescriptionKey: "Unable to serialize auth code string from data"]))
            return
        }
        
        print("✅ Apple authorization code obtained: \(authCodeString.prefix(10))...")
        print("🔄 Attempting to revoke token with Firebase...")
        
        Task {
            do {
                // 🔑 Firebase公式ドキュメント準拠: authorization_codeでトークンを取り消し
                print("🔑 Calling Firebase revokeToken...")
                do {
                    try await Auth.auth().revokeToken(withAuthorizationCode: authCodeString)
                    print("✅ Token revoked successfully")
                } catch {
                    print("⚠️ Token revoke failed (continuing with account deletion): \(error.localizedDescription)")
                    // トークン取り消しが失敗してもアカウント削除は続行
                }
                
                // 👤 ユーザーアカウントを削除
                print("👤 Deleting user account...")
                try await Auth.auth().currentUser?.delete()
                print("✅ User account deleted successfully")
                
                continuation.resume()
            } catch {
                print("❌ Apple account deletion failed: \(error.localizedDescription)")
                continuation.resume(throwing: error)
            }
        }
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding

extension AppleSignInManager: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            fatalError("No window found")
        }
        return window
    }
} 

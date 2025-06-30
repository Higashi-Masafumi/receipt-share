//
//  FirebaseAuthRepository.swift
//  receipt-share
//
//  Created by 東　真史 on 2025/06/12.
//

import Foundation
import FirebaseAuth
import FirebaseCore
import GoogleSignIn
import UIKit

class FirebaseAuthRepository: AuthRepositoryProtocol {
    private var listner: AuthStateDidChangeListenerHandle?
    private let appleSignInManager = AppleSignInManager()
    
    func signInWithEmail(email: String, password: String) async throws -> AuthUser {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        let user = result.user
        return AuthUser(id: user.uid, email: user.email ?? "")
    }
    
    func signUpWithEmail(email: String, password: String) async throws -> AuthUser {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        let user = result.user
        return AuthUser(id: user.uid, email: user.email ?? "")
    }
    
    @MainActor
    func signInWithGoogle(presentingViewController: UIViewController) async throws -> AuthUser {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            throw NSError(domain: "FirebaseAuthRepository", code: 0, userInfo: [NSLocalizedDescriptionKey: "Client ID not found"])
        }
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
        
        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController)
        
        guard let idToken = result.user.idToken?.tokenString else {
            throw NSError(domain: "FirebaseAuthRepository", code: 1, userInfo: [NSLocalizedDescriptionKey: "Google sign-in failed"])
        }
        
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: result.user.accessToken.tokenString)
        let authResult = try await Auth.auth().signIn(with: credential)
        let user = authResult.user
        return AuthUser(id: user.uid, email: user.email ?? "")
    }
    
    func signOut() async throws {
        try Auth.auth().signOut()
    }
    
    func getCurrentUser() -> AuthUser? {
        guard let user = Auth.auth().currentUser else { return nil }
        return AuthUser(id: user.uid, email: user.email ?? "")
    }
    
    func listenToAuthChanges(completion: @escaping (AuthUser?) -> Void) -> Any {
        listner = Auth.auth().addStateDidChangeListener { _, user in
            if let user = user {
                let currentUser = AuthUser(id: user.uid, email: user.email ?? "")
                completion(currentUser)
            } else {
                completion(nil)
            }
        }
        return listner!
    }
    
    func detachAuthListener() {
        if let listener = listner {
            Auth.auth().removeStateDidChangeListener(listener)
            listner = nil
        }
    }
    
    @MainActor
    func signInWithApple() async throws -> AuthUser {
        return try await appleSignInManager.signIn()
    }
    
    func sendPasswordResetEmail(email: String) async throws {
        // シンプルなFirebaseパスワードリセット
        // ユーザーはFirebaseの提供するWebUIでパスワード変更
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }
    
    func deleteAccount() async throws {
        guard let user = Auth.auth().currentUser else {
            throw NSError(domain: "FirebaseAuthRepository", code: 4, userInfo: [NSLocalizedDescriptionKey: "ユーザーが認証されていません"])
        }
        
        // プロバイダーごとの削除処理
        if let providerId = user.providerData.first?.providerID,
           providerId == "apple.com" {
            // 🍎 Apple Sign In: Firebase公式の方法でトークン取り消し + アカウント削除
            try await appleSignInManager.deleteUserAccount()
        } else {
            // 📧 その他のプロバイダー: 通常のアカウント削除
            try await user.delete()
        }
    }
    
    func reauthenticate(email: String, password: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw NSError(domain: "FirebaseAuthRepository", code: 4, userInfo: [NSLocalizedDescriptionKey: "ユーザーが認証されていません"])
        }
        
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        try await user.reauthenticate(with: credential)
    }
    
    @MainActor
    func reauthenticateWithGoogle(presentingViewController: UIViewController) async throws {
        guard let user = Auth.auth().currentUser else {
            throw NSError(domain: "FirebaseAuthRepository", code: 4, userInfo: [NSLocalizedDescriptionKey: "ユーザーが認証されていません"])
        }
        
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            throw NSError(domain: "FirebaseAuthRepository", code: 0, userInfo: [NSLocalizedDescriptionKey: "Client ID not found"])
        }
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
        
        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController)
        
        guard let idToken = result.user.idToken?.tokenString else {
            throw NSError(domain: "FirebaseAuthRepository", code: 1, userInfo: [NSLocalizedDescriptionKey: "Google sign-in failed"])
        }
        
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: result.user.accessToken.tokenString)
        try await user.reauthenticate(with: credential)
    }
    

    
    func getCurrentProviders() -> [String] {
        guard let user = Auth.auth().currentUser else { return [] }
        return user.providerData.map { $0.providerID }
    }
    
    // Apple Sign In 専用の削除メソッド（再認証込み）
    func deleteAppleAccountDirect() async throws {
        guard let user = Auth.auth().currentUser else {
            throw NSError(domain: "FirebaseAuthRepository", code: 4, userInfo: [NSLocalizedDescriptionKey: "ユーザーが認証されていません"])
        }
        
        // Apple Sign In の削除専用フローを実行
        try await appleSignInManager.deleteUserAccount()
    }
    

}

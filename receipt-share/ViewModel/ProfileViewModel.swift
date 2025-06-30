//
//  ProfileViewModel.swift
//  receipt-share
//
//  Created by 東　真史 on 2025/06/25.
//

import Foundation
import UIKit

@Observable
class ProfileViewModel {
    private let authRepository: AuthRepositoryProtocol
    private let userRepository: UserRepositoryProtocol
    private let storageRepository: StorageRepositoryProtocol
    private let currentUser: AuthUser
    
    var userProfile: User?
    var isLoading: Bool = false
    var errorMessage: String = ""
    
    init(authRepository: AuthRepositoryProtocol, userRepository: UserRepositoryProtocol, storageRepository: StorageRepositoryProtocol, currentUser: AuthUser) {
        self.authRepository = authRepository
        self.userRepository = userRepository
        self.storageRepository = storageRepository
        self.currentUser = currentUser
    }
    
    // プロフィール読み込み
    func loadUserProfile() {
        isLoading = true
        errorMessage = ""
        Task {
            do {
                // ユーザープロフィールを取得
                userProfile = try await userRepository.getUser(userId: currentUser.id)
            } catch {
                errorMessage = "プロフィールの読み込みに失敗しました: \(error.localizedDescription)"
            }
            isLoading = false
        }
    }
    
    // プロフィール更新
    func updateUserProfile(_ updatedUser: User) async {
        errorMessage = ""
        
        do {
            userProfile = try await userRepository.updateUser(updatedUser)
        } catch {
            errorMessage = "プロフィールの更新に失敗しました: \(error.localizedDescription)"
        }
    }
    
    // プロフィール画像付きでプロフィール更新
    func updateUserProfileWithImage(_ updatedUser: User, image: UIImage) async {
        errorMessage = ""
        
        do {
            // 画像をアップロード
            let imageURL = try await storageRepository.uploadProfileImage(userId: currentUser.id, image: image)
            
            // 画像URLを含むユーザー情報を更新
            let userWithNewImage = User(
                id: updatedUser.id,
                name: updatedUser.name,
                photoURL: imageURL,
                email: updatedUser.email
            )
            
            userProfile = try await userRepository.updateUser(userWithNewImage)
        } catch {
            errorMessage = "プロフィールの更新に失敗しました: \(error.localizedDescription)"
        }
    }
    
    // サインアウト
    func signOut() async {
        isLoading = true
        errorMessage = ""
        
        do {
            try await authRepository.signOut()
        } catch {
            errorMessage = "サインアウトに失敗しました: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    // アカウント削除
    func deleteAccount() async {
        isLoading = true
        errorMessage = ""
        
        do {
            try await authRepository.deleteAccount()
            // アカウント削除成功時はuserProfileをnilにする
            userProfile = nil
        } catch {
            errorMessage = "アカウントの削除に失敗しました: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    // Apple専用のアカウント削除（再認証込み）
    func deleteAccountWithApple() async throws {
        isLoading = true
        errorMessage = ""
        
        do {
            // Apple Sign Inの削除専用フローを実行
            if let firebaseAuthRepo = authRepository as? FirebaseAuthRepository {
                try await firebaseAuthRepo.deleteAppleAccountDirect()
                userProfile = nil
            } else {
                throw NSError(domain: "ProfileViewModel", code: 500, userInfo: [NSLocalizedDescriptionKey: "Firebase認証が必要です"])
            }
        } catch {
            errorMessage = "アカウントの削除に失敗しました: \(error.localizedDescription)"
            throw error
        }
        
        isLoading = false
    }
    
    // 再認証（メール・パスワード）
    func reauthenticate(email: String, password: String) async -> Bool {
        isLoading = true
        errorMessage = ""
        
        do {
            try await authRepository.reauthenticate(email: email, password: password)
            isLoading = false
            return true
        } catch {
            errorMessage = "再認証に失敗しました: \(error.localizedDescription)"
            isLoading = false
            return false
        }
    }
    
    // 再認証（Google）
    @MainActor
    func reauthenticateWithGoogle() async -> Bool {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            errorMessage = "Root view controller not found"
            return false
        }
        
        isLoading = true
        errorMessage = ""
        
        do {
            try await authRepository.reauthenticateWithGoogle(presentingViewController: rootViewController)
            isLoading = false
            return true
        } catch {
            errorMessage = "再認証に失敗しました: \(error.localizedDescription)"
            isLoading = false
            return false
        }
    }
    

    
    // プロバイダー取得
    func getCurrentProviders() -> [String] {
        return authRepository.getCurrentProviders()
    }
    
    // エラーメッセージクリア
    func clearError() {
        errorMessage = ""
    }
}

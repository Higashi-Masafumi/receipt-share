//
//  AuthViewModel.swift
//  receipt-share
//
//  Created by 東　真史 on 2025/06/12.
//

import Foundation
import UIKit
import GoogleSignIn
import AuthenticationServices

@Observable
class AuthViewModel {
    private let authRepository: AuthRepositoryProtocol
    
    var currentUser: AuthUser?
    var isLoading: Bool = false
    var errorMessage: String?
    var passwordResetEmailSent: Bool = false
    
    init(authRepository: AuthRepositoryProtocol) {
        self.authRepository = authRepository
    }
    
    func observeAuthChanges() {
        _ = authRepository.listenToAuthChanges { [weak self] user in
            self?.currentUser = user
        }
    }
    
    func signIn(email: String, password: String) async {
        isLoading = true
        do {
            currentUser = try await authRepository.signInWithEmail(email: email, password: password)
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
            currentUser = nil
        }
        isLoading = false
    }
    
    @MainActor
    func signInWithGoogle() async {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            errorMessage = "Root view controller not found"
            return
        }
        isLoading = true
        do {
            currentUser = try await authRepository.signInWithGoogle(presentingViewController: rootViewController)
            errorMessage = nil
        } catch {
            // Google Sign Inキャンセル時はエラーメッセージを表示しない
            if let gidError = error as? GIDSignInError, gidError.code == .canceled {
                errorMessage = nil
            } else {
                errorMessage = error.localizedDescription
            }
            currentUser = nil
        }
        isLoading = false
    }
    
    @MainActor
    func signInWithApple() async {
        isLoading = true
        do {
            currentUser = try await authRepository.signInWithApple()
            errorMessage = nil
        } catch {
            // Apple Sign Inキャンセル時はエラーメッセージを表示しない
            if let authError = error as? ASAuthorizationError, authError.code == .canceled {
                errorMessage = nil
            } else {
                errorMessage = error.localizedDescription
            }
            currentUser = nil
        }
        isLoading = false
    }
    
    func signUp(email: String, password: String) async {
        isLoading = true
        do {
            currentUser = try await authRepository.signUpWithEmail(email: email, password: password)
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
            currentUser = nil
        }
        isLoading = false
    }
    
    func signOut() async  {
        Task {
            do {
                try await authRepository.signOut()
                currentUser = nil
                errorMessage = nil
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    func sendPasswordResetEmail(email: String) async {
        isLoading = true
        passwordResetEmailSent = false
        do {
            try await authRepository.sendPasswordResetEmail(email: email)
            passwordResetEmailSent = true
            errorMessage = nil
        } catch {
            passwordResetEmailSent = false
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    func resetPasswordResetState() {
        passwordResetEmailSent = false
        errorMessage = nil
    }
    

}

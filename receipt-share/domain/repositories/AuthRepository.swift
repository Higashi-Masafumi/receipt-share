//
//  AuthRepository.swift
//  receipt-share
//
//  Created by 東　真史 on 2025/06/09.
//
import UIKit

protocol AuthRepositoryProtocol {
    func signInWithEmail(email: String, password: String) async throws -> AuthUser
    @MainActor func signInWithGoogle(presentingViewController: UIViewController) async throws -> AuthUser
    func signInWithApple() async throws -> AuthUser
    func signUpWithEmail(email: String, password: String) async throws -> AuthUser
    func signOut() async throws
    func getCurrentUser() -> AuthUser?
    func listenToAuthChanges(completion: @escaping (AuthUser?) -> Void) -> Any
    func detachAuthListener()
    func sendPasswordResetEmail(email: String) async throws
    func deleteAccount() async throws
    func reauthenticate(email: String, password: String) async throws
    @MainActor func reauthenticateWithGoogle(presentingViewController: UIViewController) async throws
    func getCurrentProviders() -> [String]
}

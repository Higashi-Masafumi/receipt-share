//
//  UserRepository.swift
//  receipt-share
//
//  Created by 東　真史 on 2025/06/08.
//
import Foundation

protocol UserRepositoryProtocol {
    func getUser(userId: String) async throws -> User
    func updateUser(_ user: User) async throws -> User
}

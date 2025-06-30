//
//  HardCodeUserRepository.swift
//  receipt-share
//
//  Created by 東　真史 on 2025/06/08.
//
import Foundation

var mockuser = User(id: "u1", name: "田中太郎", photoURL: URL(string: "https://picsum.photos/200/300?random=5")!, email: "tanaka@example.com")

final class HardCodedUserRepository: UserRepositoryProtocol {
    func getUser(userId: String) async throws -> User {
        // モックデータを返す
        return mockuser
    }
    func addUser(user: User) async throws -> User {
        // モックデータを返す
        return mockuser
    }
    func updateUser(_ user: User) async throws -> User {
        // モックとして更新されたユーザーを返す
        return user
    }
}

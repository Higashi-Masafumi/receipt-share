//
//  HardCodeGroupRepository.swift
//  receipt-share
//
//  Created by 東　真史 on 2025/06/08.
//
import Foundation

var mockGroups: [Group] = [
    Group(
        id: "1",
        name: "Family",
        photoURL: URL(string: "https://picsum.photos/200/300?random=1")!,
        members: [
            User(id: "u1", name: "田中太郎", photoURL: URL(string: "https://picsum.photos/200/300?random=5")!, email: "tanaka@example.com"),
            User(id: "u2", name: "山田花子", photoURL: URL(string: "https://picsum.photos/200/300?random=6")!, email: "yamada@example.com")
        ]
    ),
    Group(
        id: "2",
        name: "Friends",
        photoURL: URL(string: "https://picsum.photos/200/300?random=2")!,
        members: [
            User(id: "u3", name: "佐藤健", photoURL: URL(string: "https://picsum.photos/200/300?random=7")!, email: "sato@example.com"),
            User(id: "u4", name: "鈴木一郎", photoURL: URL(string: "https://picsum.photos/200/300?random=8")!, email: "suzuki@example.com"),
            User(id: "u5", name: "高橋めぐみ", photoURL: URL(string: "https://picsum.photos/200/300?random=9")!, email: "takahashi@example.com")
        ]
    )
]

final class HardCodeGroupRepository: GroupRepositoryProtocol {
    private var groups: [Group] = [
        Group(
            id: "1",
            name: "Family",
            photoURL: URL(string: "https://picsum.photos/200/300?random=1")!,
            members: [
                User(id: "u1", name: "田中太郎", photoURL: URL(string: "https://picsum.photos/200/300?random=5")!, email: "tanaka@example.com"),
                User(id: "u2", name: "山田花子", photoURL: URL(string: "https://picsum.photos/200/300?random=6")!, email: "yamada@example.com")
            ]
        ),
        Group(
            id: "2",
            name: "Friends",
            photoURL: URL(string: "https://picsum.photos/200/300?random=2")!,
            members: [
                User(id: "u3", name: "佐藤健", photoURL: URL(string: "https://picsum.photos/200/300?random=7")!, email: "sato@example.com"),
                User(id: "u4", name: "鈴木一郎", photoURL: URL(string: "https://picsum.photos/200/300?random=8")!, email: "suzuki@example.com"),
                User(id: "u5", name: "高橋めぐみ", photoURL: URL(string: "https://picsum.photos/200/300?random=9")!, email: "takahashi@example.com")
            ]
        ),
        Group(
            id: "3",
            name: "Work",
            photoURL: URL(string: "https://picsum.photos/200/300?random=3")!,
            members: [
                User(id: "u6", name: "伊藤誠", photoURL: URL(string: "https://picsum.photos/200/300?random=10")!, email: "ito@example.com"),
                User(id: "u7", name: "渡辺直美", photoURL: URL(string: "https://picsum.photos/200/300?random=11")!, email: "watanabe@example.com")
            ]
        ),
        Group(
            id: "4",
            name: "Travel",
            photoURL: URL(string: "https://picsum.photos/200/300?random=4")!,
            members: [
                User(id: "u1", name: "田中太郎", photoURL: URL(string: "https://picsum.photos/200/300?random=5")!, email: "tanaka@example.com"),
                User(id: "u3", name: "佐藤健", photoURL: URL(string: "https://picsum.photos/200/300?random=7")!, email: "sato@example.com"),
                User(id: "u5", name: "高橋めぐみ", photoURL: URL(string: "https://picsum.photos/200/300?random=9")!, email: "takahashi@example.com")
            ]
        )
    ]
    
    // Groupリストを返す旧メソッドは削除し、GroupWithoutMembersを返す新メソッドを実装
    func getGroupsWithoutMembers(userId: String) async throws -> [GroupWithoutMembers] {
        // ユーザーIDに基づいてグループを絞り込み、GroupWithoutMembersに変換
        return groups
            .filter { group in group.members.contains(where: { $0.id == userId }) }
            .map { group in
                GroupWithoutMembers(id: group.id, name: group.name, photoURL: group.photoURL)
            }
    }
    
    func observeGroupsWithoutMembers(userId: String) async throws -> AsyncThrowingStream<[GroupWithoutMembers], any Error> {
        // 非同期ストリームを使用して、グループの変更を監視
        return AsyncThrowingStream { continuation in
            // 初期データを送信
            Task {
                let groups = try await self.getGroupsWithoutMembers(userId: userId)
                continuation.yield(groups)
            }
        }
    }
    
    func getGroup(groupId: String) async throws -> Group {
        // IDに基づいてグループを検索して返却
        guard let group = groups.first(where: { $0.id == groupId }) else {
            throw NSError(domain: "GroupNotFound", code: 404, userInfo: [NSLocalizedDescriptionKey: "グループが見つかりませんでした"])
        }
        return group
    }
    
    // メソッドシグネチャを修正（createdByの型がUserからStringに変更）
    func addGroup(name: String, createdBy: String) async throws -> GroupWithoutMembers {
        // モックユーザーまたはデフォルトユーザーを作成者として設定
        let creator = groups.flatMap { $0.members }.first(where: { $0.id == createdBy }) ??
        User(id: createdBy, name: "新規ユーザー", photoURL: User.defaultPhotoURL(userId: createdBy), email: "user@example.com")
        
        let newId = UUID().uuidString
        let newGroup = Group(
            id: newId,
            name: name,
            photoURL: URL(string: "https://picsum.photos/200/300?random=\(Int.random(in: 20...100))")!,
            members: [creator]
        )
        groups.append(newGroup)
        
        // GroupWithoutMembersを返す
        return GroupWithoutMembers(id: newId, name: name, photoURL: newGroup.photoURL)
    }
    
    func observeGroupMembers(groupId: String) async throws -> AsyncThrowingStream<[User], any Error> {
        // グループのメンバーを監視する非同期ストリームを返す
        return AsyncThrowingStream { continuation in
            Task {
                guard let group = self.groups.first(where: { $0.id == groupId }) else {
                    continuation.finish(throwing: NSError(domain: "GroupNotFound", code: 404, userInfo: [NSLocalizedDescriptionKey: "グループが見つかりませんでした"]))
                    return
                }
                continuation.yield(group.members)
            }
        }
    }
}

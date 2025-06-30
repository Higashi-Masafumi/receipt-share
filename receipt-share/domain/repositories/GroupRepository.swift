//
//  GroupRepository.swift
//  receipt-share
//
//  Created by 東　真史 on 2025/06/08.
//
import Foundation

protocol GroupRepositoryProtocol {
    func getGroupsWithoutMembers(userId: String) async throws -> [GroupWithoutMembers]
    func observeGroupsWithoutMembers(userId: String) async throws -> AsyncThrowingStream<[GroupWithoutMembers], Error>
    func getGroup(groupId: String) async throws -> Group
    func addGroup(name: String, createdBy: String) async throws -> GroupWithoutMembers
    func observeGroupMembers(groupId: String) async throws -> AsyncThrowingStream<[User], Error>
}


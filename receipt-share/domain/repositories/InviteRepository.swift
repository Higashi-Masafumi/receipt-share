//
//  InviteRepository.swift
//  receipt-share
//
//  Created by 東　真史 on 2025/06/23.
//

protocol InviteRepositoryProtocol {
    func createInviteLink(groupId: String) async throws -> String
    func verifyInviteLink(token: String) async throws -> String
}

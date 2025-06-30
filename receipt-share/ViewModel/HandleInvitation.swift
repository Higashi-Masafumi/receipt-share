//
//  HandleInvitation.swift
//  receipt-share
//
//  Created by 東　真史 on 2025/06/19.
//

import Foundation

@Observable
class HandleInvitationViewModel {
    private let invitationRepository: InviteRepositoryProtocol
    var errorMessage: String?
    var notificationMessage: String?
    
    init(invitationRepository: InviteRepositoryProtocol) {
        self.invitationRepository = invitationRepository
    }
    
    func verifyInvitationLink(_ link: URL) async {
        let comonents = URLComponents(url: link, resolvingAgainstBaseURL: true)
        let queryItems = comonents?.queryItems
        guard let token = queryItems?.first(where: { $0.name == "token" })?.value else {
            errorMessage = "Invalid invitation link"
            return
        }
        do {
            let groupName = try await invitationRepository.verifyInviteLink(token: token)
            notificationMessage = "Invitation to join group '\(groupName)' is valid."
        } catch {
            errorMessage = "Failed to verify invitation link: \(error.localizedDescription)"
        }
    }
        
}

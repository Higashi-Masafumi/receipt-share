//
//  FirebaseToke.swift
//  receipt-share
//
//  Created by 東　真史 on 2025/06/23.
//

import FirebaseFunctions
import Foundation

class FirebaseInviteRepository: InviteRepositoryProtocol {
    
    func createInviteLink(groupId: String) async throws -> String {
        let functions = Functions.functions()
        
        return try await withCheckedThrowingContinuation { continuation in
            functions.httpsCallable("generateInvitationLink").call(["groupId": groupId]) { result, error in
                if let error = error as NSError? {
                    if error.domain == FunctionsErrorDomain {
                        let code = error.code
                        let message = error.localizedDescription
                        let details = error.userInfo[FunctionsErrorDetailsKey]
                        print("Error creating invite link: \(message), code: \(code), details: \(String(describing: details))")
                    }
                    continuation.resume(throwing: error)
                    return
                }
                
                if let data = result?.data as? [String: Any], let link = data["invitationLink"] as? String {
                    continuation.resume(returning: link)
                } else {
                    continuation.resume(throwing: NSError(
                        domain: "InviteError",
                        code: 1001,
                        userInfo: [NSLocalizedDescriptionKey: "Invalid response format or missing invitation link"]
                    ))
                }
            }
        }
    }
    
    func verifyInviteLink(token: String) async throws -> String {
        let functions = Functions.functions()
        
        return try await withCheckedThrowingContinuation { continuation in
            functions.httpsCallable("verifyInvitationToken").call(["token": token]) { result, error in
                if let error = error as NSError? {
                    if error.domain == FunctionsErrorDomain {
                        let code = error.code
                        let message = error.localizedDescription
                        let details = error.userInfo[FunctionsErrorDetailsKey]
                        print("Error verifying invite link: \(message), code: \(code), details: \(String(describing: details))")
                    }
                    continuation.resume(throwing: error)
                }
                else if let data = result?.data as? [String: Any], let _ = data["verified"] as? Bool, let groupName = data["groupName"] as? String {
                    continuation.resume(returning: groupName)
                } else {
                    continuation.resume(throwing: NSError(
                        domain: "InviteError",
                        code: 1002,
                        userInfo: [NSLocalizedDescriptionKey: "Invalid response format or missing validity status"]
                    ))
                }
            }
        }
    }
}

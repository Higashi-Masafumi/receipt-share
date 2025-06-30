//
//  GroupViewModel.swift
//  receipt-share
//
//  Created by 東　真史 on 2025/06/10.
//

import Foundation

@Observable
class GroupViewModel {
    
    var group : GroupWithoutMembers
    var receipts: [Receipt] = []
    var members: [User] = []
    private let receiptRepository: ReceiptRepositoryProtocol
    private let inviteRepository: InviteRepositoryProtocol = FirebaseInviteRepository()
    private let groupRepository: GroupRepositoryProtocol = FirebaseGroupRepository()
    private var receiptStream: Task<Void, Never>?
    private var groupMembersStream: Task<Void, Never>?
    
    init(group: GroupWithoutMembers, receiptRepository: ReceiptRepositoryProtocol) {
        self.group = group
        self.receiptRepository = receiptRepository
        observeReceipts() // レシートの監視を開始
        observeGroupMembers() // グループメンバーの監視を開始
    }
    
    func loadReceiptsAndMembers() {
        Task {
            do {
                // グループのレシートを取得
                self.receipts = try await receiptRepository.getGroupReceipts(groupId: group.id)
                self.members = try await groupRepository.getGroup(groupId: group.id).members
            } catch {
                print("Error loading receipts: \(error)")
            }
        }
    }
    
    func observeReceipts() {
        // レシートの変更を監視するためのストリームを開始
        receiptStream = Task {
            do {
                let stream = try await receiptRepository.observeReceipt(groupId: group.id)
                for try await newReceipts in stream {
                    self.receipts = newReceipts
                }
            } catch {
                print("Error observing receipts: \(error)")
            }
        }
    }
    
    func observeGroupMembers() {
        groupMembersStream = Task {
            do {
                let stream = try await groupRepository.observeGroupMembers(groupId: group.id)
                for try await newMembers in stream {
                    self.members = newMembers
                }
            } catch {
                print("Error observing group members: \(error)")
            }
        }
    }
    
    func updateReceipt(_ receipt: Receipt) {
        Task {
            do {
                let updatedReceipt = try await receiptRepository.updateReceipt(receipt)
                if let index = receipts.firstIndex(where: { $0.id == updatedReceipt.id }) {
                    receipts[index] = updatedReceipt
                }
            } catch {
                print("Error updating receipt: \(error)")
            }
        }
    }
    
    func publishInivitationLink() async throws -> String {
        // グループの招待リンクを生成
        let inviteLink = try await inviteRepository.createInviteLink(groupId: group.id)
        return inviteLink
    }
        
    // クリーンアップのため、ビューモデルが不要になったときにストリームをキャンセルするメソッド
    func cancelReceiptObservation() {
        receiptStream?.cancel()
        receiptStream = nil
    }
    
    // オブジェクトがメモリから解放される前に監視をキャンセル
    deinit {
        cancelReceiptObservation()
    }
}

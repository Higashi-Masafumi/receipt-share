//
//  NewReceiptViewModel.swift
//  receipt-share
//
//  Created by 東　真史 on 2025/06/11.
//

import Foundation
import UIKit

@Observable
class NewReceiptViewModel {
    private let storageRepository: StorageRepositoryProtocol
    private let receiptRepository: ReceiptRepositoryProtocol
    private let groupRepository: GroupRepositoryProtocol
    
    var currentUser: AuthUser
    var groups: [GroupWithoutMembers] = []
    var selectedGroup: GroupWithoutMembers?
    
    var isSaving: Bool = false
    var errorMessage: String?
    
    init(
        currentUser: AuthUser,
        selectedGroup: GroupWithoutMembers? = nil,
        groupRepository: GroupRepositoryProtocol = HardCodeGroupRepository(),
        storageRepository: StorageRepositoryProtocol = HardCodeStorageRepository(),
        receiptRepository: ReceiptRepositoryProtocol = HardCodeReceiptRepository(),
    ) {
        self.currentUser = currentUser
        self.selectedGroup = selectedGroup
        self.groupRepository = groupRepository
        self.storageRepository = storageRepository
        self.receiptRepository = receiptRepository
    }
    
    func reset() {
        selectedGroup = nil
        isSaving = false
        errorMessage = nil
    }
    
    func observeGroups() async {
        Task {
            do {
                let stream = try await groupRepository.observeGroupsWithoutMembers(userId: currentUser.id)
                for try await groups in stream {
                    self.groups = groups
                    // 最初のグループを選択状態にする
                    if self.selectedGroup == nil, let firstGroup = groups.first {
                        self.selectedGroup = firstGroup
                    }
                }
            } catch {
                print("グループの取得に失敗しました: \(error)")
                self.errorMessage = "グループの取得に失敗しました: \(error.localizedDescription)"
            }
        }
    }
    
    func save(scannedImages: [UIImage]) async throws {
        guard let group = selectedGroup, !scannedImages.isEmpty else {
            errorMessage = "グループが選択されていないか、画像がありません"
            throw NSError(domain: "NewReceiptViewModel", code: 1, userInfo: [NSLocalizedDescriptionKey: "必要な情報が不足しています"])
        }
        
        var savedReceipts: [Receipt] = []
        
        do {
            isSaving = true
            // スキャンした画像を順次処理
            for image in scannedImages {
                // 画像をストレージに保存
                let (url, path) = try await storageRepository.uploadImage(
                    receiptImage: ReceiptImage(image: image, userId: currentUser.id, groupId: group.id)
                )
                
                // レシートを作成
                let receipt = Receipt(
                    groupId: group.id,
                    userId: currentUser.id,
                    ocrStatus: .pending,
                    imageURL: url,
                    imageStoragePath: path
                )
                
                // レシートをリポジトリに保存
                let savedReceipt = try await receiptRepository.addReceipt(receipt)
                savedReceipts.append(savedReceipt)
            }
            
            isSaving = false
            print("保存完了: \(savedReceipts.count)件のレシートを保存しました")
            return
        } catch {
            print("エラー発生: \(error)")
            isSaving = false
            errorMessage = "レシートの保存に失敗しました: \(error.localizedDescription)"
            throw error
        }
    }
}

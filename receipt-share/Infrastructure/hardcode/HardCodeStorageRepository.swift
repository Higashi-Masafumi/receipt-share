//
//  HardCodeStorageRepository.swift
//  receipt-share
//
//  Created by 東　真史 on 2025/06/11.
//

import Foundation
import UIKit

final class HardCodeStorageRepository: StorageRepositoryProtocol {
    func uploadImage(receiptImage: ReceiptImage) async throws -> (URL, String) {
        let path = "\(receiptImage.groupId)/\(receiptImage.id)/receiptImage.jpg"
        let url  = URL(string: "https://picsum.photos/800/1200?random=\(Int.random(in:200...400))")!
        return (url, path)
    }
    
    func uploadProfileImage(userId: String, image: UIImage) async throws -> URL {
        // モックとしてダミーのプロフィール画像URLを返す
        let url = URL(string: "https://picsum.photos/200/200?random=\(Int.random(in: 100...300))")!
        
        // 実際のアップロード処理のシミュレーション（少し待機）
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1秒待機
        
        return url
    }
}


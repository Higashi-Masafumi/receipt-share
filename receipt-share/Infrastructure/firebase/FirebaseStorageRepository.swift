import Foundation
import FirebaseStorage
import UIKit

class FirebaseStorageRepository: StorageRepositoryProtocol {
    func uploadImage(receiptImage: ReceiptImage) async throws -> (URL, String) {
        // Firebase Storageの参照を取得
        let storage = Storage.storage()
        guard let imageData = receiptImage.image.jpegData(compressionQuality: 0.7) else {
            throw NSError(domain: "FirebaseStorageRepository", code: 400, userInfo: [NSLocalizedDescriptionKey: "画像データの変換に失敗しました"])
        }
        
        // Storage内のパスを作成: receipts/{groupId}/{receiptId}.jpg
        let storagePath = "receipts/\(receiptImage.groupId)/\(receiptImage.id).jpg"
        let storageRef = storage.reference().child(storagePath)
        
        // メタデータを設定
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        // アップロード実行
        let _ = try await storageRef.putDataAsync(imageData, metadata: metadata)
        
        // 公開ダウンロードURLを取得
        // この公開URLはセキュリティルールで保護されているが、
        // URLさえ知っていればウェブブラウザ等からの直接アクセスは可能
        let downloadURL = try await storageRef.downloadURL()
        
        return (downloadURL, storagePath)
    }
    
    func uploadProfileImage(userId: String, image: UIImage) async throws -> URL {
        let storage = Storage.storage()
        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            throw NSError(domain: "FirebaseStorageRepository", code: 400, userInfo: [NSLocalizedDescriptionKey: "画像データの変換に失敗しました"])
        }
        
        // Storage内のパスを作成: profile-images/{userId}.jpg
        let storagePath = "profiles/\(userId)/profile.jpg"
        let storageRef = storage.reference().child(storagePath)
        
        // メタデータを設定
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        // アップロード実行
        let _ = try await storageRef.putDataAsync(imageData, metadata: metadata)
        
        // 公開ダウンロードURLを取得
        let downloadURL = try await storageRef.downloadURL()
        
        return downloadURL
    }
} 

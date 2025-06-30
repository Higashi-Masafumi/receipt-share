import Foundation
import FirebaseFirestore

/// Firestore に保存するレシート情報
struct ReceiptDTO: Codable, Identifiable {
    @DocumentID var id: String?
    var groupId: String
    var userId: String
    var invoiceNumber: String?
    var purchaseDate: Date?
    var merchantName: String?
    var totalAmount: Int?              // 金額は cents で保存
    var paymentMethod: String?
    var items: [ReceiptItemDTO]?
    var ocrStatus: OCRStatus = .pending // OCRのステータスを管理するプロパティ
    var imageURL: String
    var imageStoragePath: String
    @ServerTimestamp var createdAt: Date?
    @ServerTimestamp var updatedAt: Date?
}

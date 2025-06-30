import Foundation
import FirebaseFirestore

/// Firestore に保存するレシート項目情報
/// ReceiptDTO の items フィールドに配列として保存
struct ReceiptItemDTO: Codable, Identifiable {
    var id: String?
    var productName: String
    var quantity: Int
    var price: Int                     // 単価（cents）
    var totalPrice: Int                // 合計金額（cents）
} 

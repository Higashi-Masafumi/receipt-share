import Foundation
import FirebaseFirestore

/// Firestore に保存するユーザー情報
struct UserDTO: Codable, Identifiable {
    @DocumentID var id: String?        // Firestore の docID (= uid)
    var name: String
    var email: String
    var photoURL: String               // URL を文字列で保持
    @ServerTimestamp var createdAt: Date?
    @ServerTimestamp var updatedAt: Date?
}

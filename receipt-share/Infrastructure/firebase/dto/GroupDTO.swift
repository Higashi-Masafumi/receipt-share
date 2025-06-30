import Foundation
import FirebaseFirestore

/// Firestore に保存するグループ情報
struct GroupDTO: Codable, Identifiable {
    @DocumentID var id: String?
    var name: String
    var createdBy: String // ユーザーID
    var photoURL: String
    @ServerTimestamp var createdAt: Date?
    @ServerTimestamp var updatedAt: Date?
}

import Foundation
import FirebaseFirestore

/// Firestore のグループメンバー情報
/// groups/{groupId}/members/{userId} に保存
struct MemberDTO: Codable, Identifiable {
    @DocumentID var id: String?        // = uid
    var userId: String // ユーザーID
    var role: MemberRole = .member // メンバーの役割
    @ServerTimestamp var joinedAt: Date?
}

enum MemberRole: String, Codable {
    case admin
    case member
}


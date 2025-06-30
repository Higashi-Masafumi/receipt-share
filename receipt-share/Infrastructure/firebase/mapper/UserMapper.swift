import Foundation
import FirebaseFirestore

/// UserDTOとUserエンティティ間の変換を担当するクラス
struct UserMapper {
    
    static func toDomain(dto: UserDTO, documentId: String) -> User {
        return User(
            id: dto.id ?? documentId,
            name: dto.name,
            photoURL: URL(string: dto.photoURL) ?? User.defaultPhotoURL(userId: documentId),
            email: dto.email
        )
    }
    
    static func toDTO(domain: User) -> UserDTO {
        return UserDTO(
            id: domain.id,
            name: domain.name,
            email: domain.email,
            photoURL: domain.photoURL.absoluteString,
        )
    }
}

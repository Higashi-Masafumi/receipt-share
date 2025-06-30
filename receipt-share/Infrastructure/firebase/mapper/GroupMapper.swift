import Foundation
import FirebaseFirestore

/// GroupDTOとGroupエンティティ間の変換を担当するクラス
struct GroupMapper {
    static func toDomain(dto: GroupDTO, documentId: String, members: [User]) -> Group {
        return Group(
            id: dto.id ?? documentId,
            name: dto.name,
            photoURL: URL(string: dto.photoURL) ?? Group.defaultPhotoURL(groupId: documentId),
            members: members
        )
    }
    
    static func toDTO(domain: Group, createdBy: String) -> GroupDTO {
        return GroupDTO(
            id: domain.id,
            name: domain.name,
            createdBy: createdBy,
            photoURL: domain.photoURL.absoluteString
        )
    }
}

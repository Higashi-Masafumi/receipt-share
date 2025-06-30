import Foundation
import FirebaseFirestore

class FirebaseUserRepository: UserRepositoryProtocol {
    private let usersCollection = FirestoreCollection.users
    
    func getUser(userId: String) async throws -> User {
        let db = Firestore.firestore()
        let docRef = db.collection(usersCollection).document(userId)
        let document = try await docRef.getDocument()
        
        guard let userDTO = try? document.data(as: UserDTO.self) else {
            throw NSError(domain: "FirebaseUserRepository", code: 404, userInfo: [NSLocalizedDescriptionKey: "ユーザーが見つかりませんでした"])
        }
        
        return UserMapper.toDomain(dto: userDTO, documentId: document.documentID)
    }
    
    func updateUser(_ user: User) async throws -> User {
        let db = Firestore.firestore()
        let docRef = db.collection(usersCollection).document(user.id)
        let userDTO = UserMapper.toDTO(domain: user)
        
        try docRef.setData(from: userDTO, merge: true)
        
        return user
    }
} 

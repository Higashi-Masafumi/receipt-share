import Foundation
import FirebaseFirestore

class FirebaseGroupRepository: GroupRepositoryProtocol {
    private let groupsCollection = FirestoreCollection.groups
    private let membersCollection = FirestoreCollection.members
    private let usersCollection = FirestoreCollection.users
    
    func getGroupsWithoutMembers(userId: String) async throws -> [GroupWithoutMembers] {
        let db = Firestore.firestore()
        
        // 1. groups/*/members から「自分」が入っているメンバー文書を横断検索
        let memberSnap = try await db
            .collectionGroup(membersCollection)              // ← collectionGroup を使う
            .whereField("userId", isEqualTo: userId)        // documentID ではなく userId フィールドで照合
            .getDocuments()
        
        // 2. その parent.parent が所属グループの docRef
        //    ※ parent = membersCol, parent.parent = groups/{groupId}
        let groupIds: [String] = memberSnap.documents.compactMap {
            $0.reference.parent.parent?.documentID
        }
        
        guard !groupIds.isEmpty else { return [] }
        
        // TaskGroupを使って並列でグループを取得
        return try await withThrowingTaskGroup(of: GroupWithoutMembers?.self) { group in
            for groupId in groupIds {
                group.addTask {
                    do {
                        let groupDoc = try await db.collection(self.groupsCollection)
                            .document(groupId)
                            .getDocument()
                        
                        if let groupDTO = try? groupDoc.data(as: GroupDTO.self) {
                            // GroupWithoutMembersに変換して返す
                            return GroupWithoutMembers(
                                id: groupId,
                                name: groupDTO.name,
                                photoURL: URL(string: groupDTO.photoURL) ?? Group.defaultPhotoURL(groupId: groupId),
                            )
                        }
                    } catch {
                        print("Error fetching group \(groupId): \(error.localizedDescription)")
                    }
                    return nil
                }
            }
            
            // 結果を収集
            var results: [GroupWithoutMembers] = []
            for try await groupResult in group {
                if let group = groupResult {
                    results.append(group)
                }
            }
            
            return results
        }
    }
    
    func observeGroupsWithoutMembers(userId: String) -> AsyncThrowingStream<[GroupWithoutMembers], Error> {
        return AsyncThrowingStream { continuation in
            Task {
                do {
                    // 初回データの取得
                    let groups = try await self.getGroupsWithoutMembers(userId: userId)
                    continuation.yield(groups) // 初回のグループリストを送信
                    
                    // Firestore リスナーを設定してリアルタイム更新を監視
                    let db = Firestore.firestore()
                    let query = db.collectionGroup(self.membersCollection)
                        .whereField("userId", isEqualTo: userId)
                    
                    let listener = query.addSnapshotListener { snapshot, error in
                        if let error = error {
                            continuation.finish(throwing: error) // エラーが発生した場合はストリームを閉じる
                            return
                        }
                        
                        // Firestore の変更があった場合、グループIDを再取得して更新
                        guard let snapshot = snapshot else { return }
                        
                        // 新たにグループを取得し、クライアントに通知
                        Task {
                            do {
                                let updatedGroups = try await self.getGroupsWithoutMembers(userId: userId)
                                continuation.yield(updatedGroups)
                            } catch {
                                continuation.finish(throwing: error) // 失敗した場合もストリームを終了
                            }
                        }
                    }
                    
                    // リスナーのキャンセル処理
                    continuation.onTermination = { _ in
                        listener.remove() // リスナーをクリーンアップ
                    }
                } catch {
                    continuation.finish(throwing: error) // 初期データ取得時のエラー処理
                }
            }
        }
    }
    
    
    func getGroup(groupId: String) async throws -> Group {
        let db = Firestore.firestore()
        let groupRef = db.collection(groupsCollection).document(groupId)
        
        // グループドキュメントを取得
        let groupSnapshot = try await groupRef.getDocument()
        
        guard groupSnapshot.exists else {
            throw NSError(domain: "GroupNotFound", code: 404, userInfo: nil)
        }
        
        // GroupDTOをデコード
        let groupDTO = try groupSnapshot.data(as: GroupDTO.self)
        
        // グループのメンバーを取得
        let membersSnapshot = try await groupRef.collection(membersCollection).getDocuments()
        
        var members: [User] = []
        for memberDoc in membersSnapshot.documents {
            if let memberDTO = try? memberDoc.data(as: MemberDTO.self) {
                // ユーザーデータを取得
                if let userSnapshot = try? await db.collection(usersCollection).document(memberDTO.userId).getDocument(),
                   let userDTO = try? userSnapshot.data(as: UserDTO.self) {
                    let user = UserMapper.toDomain(dto: userDTO, documentId: userSnapshot.documentID)
                    members.append(user)
                }
            }
        }
        // グループを返す
        return GroupMapper.toDomain(dto: groupDTO, documentId: groupId, members: members)
    }
    
    
    
    
    func addGroup(name: String, createdBy: String) async throws -> GroupWithoutMembers {
        let db = Firestore.firestore()
        // 新しいグループのドキュメントを作成
        let newGroupRef = db.collection(groupsCollection).document()
        let groupId = newGroupRef.documentID
        
        // GroupDTOの作成
        let groupDTO = GroupDTO(
            name: name,
            createdBy: createdBy,
            photoURL: Group.defaultPhotoURL(groupId: groupId).absoluteString,
        )
        
        // メンバーDTOの作成
        let memberDTO = MemberDTO(
            id: createdBy,
            userId: createdBy,
            role: .admin
        )
        
        // バッチ処理で原子性を保証
        let batch = db.batch()
        
        // グループドキュメントをバッチに追加
        try batch.setData(from: groupDTO, forDocument: newGroupRef)
        
        // メンバードキュメントをバッチに追加
        let memberRef = newGroupRef.collection(membersCollection).document(createdBy)
        try batch.setData(from: memberDTO, forDocument: memberRef)
        
        // バッチ処理を実行
        try await batch.commit()
        
        // 作成されたグループを返す
        return GroupWithoutMembers(
            id: groupId,
            name: name,
            photoURL: Group.defaultPhotoURL(groupId: groupId),
        )
    }
    
    func observeGroupMembers(groupId: String) async throws -> AsyncThrowingStream<[User], any Error> {
        let db = Firestore.firestore()
        let groupRef = db.collection(groupsCollection).document(groupId)
        let membersQuery = groupRef.collection(membersCollection)
        
        return AsyncThrowingStream { continuation in
            let listener = membersQuery.addSnapshotListener { snapshot, error in
                if let error = error {
                    continuation.finish(throwing: error)
                    return
                }
                
                guard let snapshot = snapshot else {
                    continuation.finish(throwing: NSError(domain: "NoSnapshot", code: 500))
                    return
                }
                
                Task {
                    do {
                        var users: [User] = []
                        
                        for memberDoc in snapshot.documents {
                            if let memberDTO = try? memberDoc.data(as: MemberDTO.self) {
                                // 各メンバーのユーザー情報を取得
                                let userSnapshot = try await db.collection(self.usersCollection)
                                    .document(memberDTO.userId)
                                    .getDocument()
                                
                                if let userDTO = try? userSnapshot.data(as: UserDTO.self) {
                                    let user = UserMapper.toDomain(dto: userDTO, documentId: userSnapshot.documentID)
                                    users.append(user)
                                }
                            }
                        }
                        
                        continuation.yield(users)
                    } catch {
                        continuation.finish(throwing: error)
                    }
                }
            }
            
            continuation.onTermination = { _ in
                listener.remove()
            }
        }
    }
}

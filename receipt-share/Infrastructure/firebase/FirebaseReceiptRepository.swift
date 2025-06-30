import Foundation
import FirebaseFirestore

class FirebaseReceiptRepository: ReceiptRepositoryProtocol {
    private let groupsCollection = FirestoreCollection.groups
    private let receiptsCollection = FirestoreCollection.receipts
    
    func getGroupReceipts(groupId: String) async throws -> [Receipt] {
        let db = Firestore.firestore()
        let receiptsRef = db.collection(groupsCollection).document(groupId).collection(receiptsCollection)
        let snapshot = try await receiptsRef.getDocuments()
        
        var receipts: [Receipt] = []
        
        for document in snapshot.documents {
            if let receiptDTO = try? document.data(as: ReceiptDTO.self) {
                // DTOのtoDomain()メソッドを使用して簡潔に変換
                receipts.append(ReceiptMapper.toDomain(dto: receiptDTO, documentId: document.documentID))
            }
        }
        
        return receipts
    }
    
    func addReceipt(_ receipt: Receipt) async throws -> Receipt {
        let db = Firestore.firestore()
        let receiptsRef = db.collection(groupsCollection)
            .document(receipt.groupId)
            .collection(receiptsCollection)
        
        let newDocReference = try receiptsRef.addDocument(from: ReceiptMapper.toDTO(domain: receipt))
        let newReceiptId = newDocReference.documentID
        
        var updatedReceipt = receipt
        updatedReceipt.id = newReceiptId
        
        return updatedReceipt
    }
    
    func removeReceipt(_ receipt: Receipt) async throws {
        let db = Firestore.firestore()
        let receiptRef = db.collection(groupsCollection)
            .document(receipt.groupId)
            .collection(receiptsCollection)
            .document(receipt.id)
        
        try await receiptRef.delete()
    }
    
    func updateReceipt(_ receipt: Receipt) async throws -> Receipt {
        let db = Firestore.firestore()
        let receiptRef = db.collection(groupsCollection)
            .document(receipt.groupId)
            .collection(receiptsCollection)
            .document(receipt.id)
        
        try receiptRef.setData(from: ReceiptMapper.toDTO(domain: receipt), merge: true)
        
        return receipt
    }
    
    func observeReceipt(groupId: String)
    -> AsyncThrowingStream<[Receipt], Error> {
        
        let db = Firestore.firestore()
        let query = db.collection(groupsCollection)
            .document(groupId)
            .collection(receiptsCollection)
        
        return AsyncThrowingStream { continuation in
            let listener = query.addSnapshotListener { snap, err in
                if let err {                                 // ← エラーは throw
                    continuation.finish(throwing: err)
                    return
                }
                
                guard let docs = snap?.documents else {
                    continuation.yield([])                  // ← 0 件でも送る
                    return
                }
                
                let list: [Receipt] = docs.compactMap { doc in
                    guard let dto = try? doc.data(as: ReceiptDTO.self) else { return nil }
                    return ReceiptMapper.toDomain(dto: dto,
                                                  documentId: doc.documentID)
                }
                continuation.yield(list)
            }
            
            // Task.cancel() 等でストリーム終了時に listener を解除
            continuation.onTermination = { _ in listener.remove() }
        }
    }
}

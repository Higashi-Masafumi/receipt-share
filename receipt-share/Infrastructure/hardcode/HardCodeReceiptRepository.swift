//
//  HardCodeReceiptRepository.swift
//  receipt-share
//
//  Created by 東　真史 on 2025/06/10.
//
import Foundation


final class HardCodeReceiptRepository: ReceiptRepositoryProtocol {
    var receipts: [Receipt] = [
        Receipt(
            id: "r1",
            groupId: "1", // Family グループ
            userId: "u1",
            invoiceNumber: "INV-001",
            purchaseDate: Calendar.current.date(byAdding: .day, value: -3, to: Date())!,
            merchantName: "イオンスーパー",
            totalAmount: 4850,
            paymentMethod: "クレジットカード",
            items: [
                ReceiptItem(productName: "牛乳", quantity: 1, price: 250, totalPrice: 250),
                ReceiptItem(productName: "卵", quantity: 2, price: 200, totalPrice: 400),
                ReceiptItem(productName: "バナナ", quantity: 1, price: 300, totalPrice: 300),
                ReceiptItem(productName: "鶏肉", quantity: 1, price: 800, totalPrice: 800),
                ReceiptItem(productName: "トイレットペーパー", quantity: 1, price: 500, totalPrice: 500),
                ReceiptItem(productName: "洗剤", quantity: 1, price: 800, totalPrice: 800),
                ReceiptItem(productName: "野菜セット", quantity: 1, price: 1800, totalPrice: 1800)
            ],
            ocrStatus: .completed,
            imageURL: URL(string: "https://picsum.photos/800/1200?random=101")!,
            imageStoragePath: "family/u1/receiptImage.jpg",
            createdAt: Calendar.current.date(byAdding: .day, value: -3, to: Date())!,
            updatedAt: Calendar.current.date(byAdding: .day, value: -3, to: Date())!
        ),
        Receipt(
            id: "r2",
            groupId: "1", // Family グループ
            userId: "u2",
            invoiceNumber: "INV-002",
            purchaseDate: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
            merchantName: "ドラッグストア",
            totalAmount: 3200,
            paymentMethod: "現金",
            items: [
                ReceiptItem(productName: "シャンプー", quantity: 1, price: 980, totalPrice: 980),
                ReceiptItem(productName: "歯磨き粉", quantity: 2, price: 320, totalPrice: 640),
                ReceiptItem(productName: "化粧水", quantity: 1, price: 1580, totalPrice: 1580)
            ],
            ocrStatus: .completed,
            imageURL: URL(string: "https://picsum.photos/800/1200?random=102")!,
            imageStoragePath: "family/u2/receiptImage.jpg",
            createdAt: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
            updatedAt: Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        ),
        Receipt(
            id: "r3",
            groupId: "2", // Friends グループ
            userId: "u3",
            invoiceNumber: "INV-003",
            purchaseDate: Calendar.current.date(byAdding: .day, value: -5, to: Date())!,
            merchantName: "居酒屋はなまる",
            totalAmount: 15800,
            paymentMethod: "クレジットカード",
            items: [
                ReceiptItem(productName: "ビール", quantity: 5, price: 580, totalPrice: 2900),
                ReceiptItem(productName: "唐揚げ", quantity: 2, price: 650, totalPrice: 1300),
                ReceiptItem(productName: "刺身盛り合わせ", quantity: 1, price: 1800, totalPrice: 1800),
                ReceiptItem(productName: "焼き鳥セット", quantity: 3, price: 1200, totalPrice: 3600),
                ReceiptItem(productName: "サラダ", quantity: 2, price: 580, totalPrice: 1160),
                ReceiptItem(productName: "ごはんセット", quantity: 5, price: 300, totalPrice: 1500),
                ReceiptItem(productName: "デザート", quantity: 3, price: 450, totalPrice: 1350)
            ],
            ocrStatus: .completed,
            imageURL: URL(string: "https://picsum.photos/800/1200?random=103")!,
            imageStoragePath: "friends/u3/receiptImage.jpg",
            createdAt: Calendar.current.date(byAdding: .day, value: -5, to: Date())!,
            updatedAt: Calendar.current.date(byAdding: .day, value: -5, to: Date())!
        ),
        Receipt(
            id: "r4",
            groupId: "3", // Work グループ
            userId: "u4",
            invoiceNumber: "INV-004",
            purchaseDate: Calendar.current.date(byAdding: .day, value: -2, to: Date())!,
            merchantName: "文房具店",
            totalAmount: 6500,
            paymentMethod: "法人カード",
            items: [
                ReceiptItem(productName: "コピー用紙", quantity: 5, price: 450, totalPrice: 2250),
                ReceiptItem(productName: "ボールペン(黒)", quantity: 10, price: 120, totalPrice: 1200),
                ReceiptItem(productName: "ノート", quantity: 5, price: 280, totalPrice: 1400),
                ReceiptItem(productName: "ファイル", quantity: 8, price: 150, totalPrice: 1200),
                ReceiptItem(productName: "付箋", quantity: 3, price: 150, totalPrice: 450)
            ],
            ocrStatus: .completed,
            imageURL: URL(string: "https://picsum.photos/800/1200?random=104")!,
            imageStoragePath: "work/u4/receiptImage.jpg",
            createdAt: Calendar.current.date(byAdding: .day, value: -2, to: Date())!,
            updatedAt: Calendar.current.date(byAdding: .day, value: -2, to: Date())!
        ),
        Receipt(
            id: "r5",
            groupId: "4", // Travel グループ
            userId: "u5",
            invoiceNumber: "INV-005",
            purchaseDate: Calendar.current.date(byAdding: .day, value: -10, to: Date())!,
            merchantName: "ホテルグランド",
            totalAmount: 45800,
            paymentMethod: "クレジットカード",
            items: [
                ReceiptItem(productName: "宿泊費（2泊）", quantity: 1, price: 38000, totalPrice: 38000),
                ReceiptItem(productName: "朝食", quantity: 2, price: 1800, totalPrice: 3600),
                ReceiptItem(productName: "スパ利用料", quantity: 2, price: 2100, totalPrice: 4200)
            ],
            ocrStatus: .completed,
            imageURL: URL(string: "https://picsum.photos/800/1200?random=105")!,
            imageStoragePath: "travel/u5/receiptImage.jpg",
            createdAt: Calendar.current.date(byAdding: .day, value: -10, to: Date())!,
            updatedAt: Calendar.current.date(byAdding: .day, value: -10, to: Date())!
        )
    ]
    
    func getGroupReceipts(groupId: String) async throws -> [Receipt] {
        // グループIDに基づいてレシートをフィルタリング
        return receipts.filter { $0.groupId == groupId }
    }
    
    func addReceipt(_ receipt: Receipt) async throws -> Receipt {
        var newReceipt = receipt
        if newReceipt.id.isEmpty {
            newReceipt.id = UUID().uuidString
        }
        receipts.append(newReceipt)
        return newReceipt
    }
    
    func removeReceipt(_ receipt: Receipt) async throws {
        if let index = receipts.firstIndex(where: { $0.id == receipt.id }) {
            receipts.remove(at: index)
        }
    }
    
    func updateReceipt(_ receipt: Receipt) async throws -> Receipt {
        if let index = receipts.firstIndex(where: { $0.id == receipt.id }) {
            receipts[index] = receipt
            return receipt
        } else {
            // レシートが見つからない場合は追加する
            return try await addReceipt(receipt)
        }
    }
    func observeReceipt(groupId: String) async throws -> AsyncThrowingStream<[Receipt], any Error> {
        return AsyncThrowingStream { continuation in
            // 最初のデータを即時提供
            let filteredReceipts = self.receipts.filter { $0.groupId == groupId }
            continuation.yield(filteredReceipts)
            
            // 実際のFirebaseではリスナーが設定されますが、ここではタイマーで模倣
            let timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
                // グループに対応するレシートを取得
                let updatedReceipts = self.receipts.filter { $0.groupId == groupId }
                continuation.yield(updatedReceipts)
            }
            
            // ストリームが終了したときにタイマーを無効化するためのコールバック
            continuation.onTermination = { @Sendable [weak timer] _ in
                timer?.invalidate()
            }
        }
    }
}

//
//  ReceiptRow.swift
//  receipt-share
//
//  Created by 東　真史 on 2025/06/10.
//

import SwiftUI

struct ReceiptRow: View {
    
    var receipt: Receipt
    
    var body: some View {
        HStack {
            AsyncImage(url: receipt.imageURL) { image in
                image.resizable()
                    .frame(width: 50, height: 50)
            } placeholder: {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                    .frame(width: 50, height: 50)
            }
            VStack(alignment: .leading) {
                Text(receipt.merchantName ?? "不明")
                    .font(.headline)
                Text(receipt.purchaseDate ?? Date(), style: .date)
            }
            Spacer()
            HStack() {
                statusIcon
                    .font(.title3)
            }
        }
    }
    
    // ステータスに応じたシステムアイコン
    // ステータスに応じたシステムアイコン
    private var statusIcon: Image {
        switch receipt.ocrStatus {
        case .pending:
            return Image(systemName: "clock")
        case .processing:
            return Image(systemName: "hourglass")
        case .completed:
            return Image(systemName: "checkmark.circle.fill")
        case .failed:
            return Image(systemName: "xmark.octagon.fill")
        }
    }
}

#Preview {
    let sampleReceipt = Receipt(
        groupId: "g1",
        userId: "u1",
        invoiceNumber: "INV-123",
        purchaseDate: Date(),
        merchantName: "スーパーマルシェ",
        totalAmount: 3580,
        paymentMethod: "クレジットカード",
        items: [
            ReceiptItem(productName: "牛乳", quantity: 1, price: 240, totalPrice: 240),
            ReceiptItem(productName: "食パン", quantity: 1, price: 350, totalPrice: 350),
            ReceiptItem(productName: "バナナ", quantity: 1, price: 280, totalPrice: 280)
        ],
        ocrStatus: .pending,
        imageURL: URL(string: "https://picsum.photos/800/1200?random=101")!,
        imageStoragePath: "g1/u1/receiptImage.jpg",
    )
    
    return ReceiptRow(receipt: sampleReceipt)
}

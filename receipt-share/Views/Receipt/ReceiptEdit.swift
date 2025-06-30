//
//  ReceiptEdit.swift
//  receipt-share
//
//  Created by 東　真史 on 2025/06/10.
//
import SwiftUI

struct ReceiptEdit: View {
    @Binding var receipt: Receipt
    @Binding var isPresented: Bool
    
    // 通貨フォーマッタ
    private let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter
    }()
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("基本情報")) {
                    TextField("登録番号", text: $receipt.invoiceNumber.boundString())
                    DatePicker("購入日時", selection: $receipt.purchaseDate.boundDate(), displayedComponents: .date)
                    TextField("店舗名", text: $receipt.merchantName.boundString())
                }
                Section(header: Text("支払い情報")) {
                    TextField("合計金額", value: $receipt.totalAmount.boundInt(), formatter: currencyFormatter)
                        .keyboardType(.decimalPad)
                    TextField("支払い方法", text: $receipt.paymentMethod.boundString())
                }
            }
            .navigationTitle("レシート編集")
            .navigationBarItems(
                trailing: Button("完了") {
                    isPresented = false
                }
            )
        }
    }
}

#Preview {
    ReceiptEdit(receipt: .constant(Receipt(
        id: "r1",
        groupId: "g1",
        userId: "u1",
        invoiceNumber: "INV-20250610-123",
        purchaseDate: Date(),
        merchantName: "スーパーマルシェ",
        totalAmount: 3580,
        paymentMethod: "クレジットカード",
        items: [
            ReceiptItem(productName: "牛乳", quantity: 1, price: 240, totalPrice: 240),
            ReceiptItem(productName: "食パン", quantity: 1, price: 350, totalPrice: 350),
            ReceiptItem(productName: "バナナ", quantity: 1, price: 280, totalPrice: 280),
            ReceiptItem(productName: "鶏肉", quantity: 2, price: 420, totalPrice: 840),
            ReceiptItem(productName: "トマト", quantity: 3, price: 180, totalPrice: 540)
        ],
        ocrStatus: .completed,
        imageURL: URL(string: "https://picsum.photos/800/1200?random=101")!,
        imageStoragePath: "g1/u1/receiptImage.jpg"
    )), isPresented: .constant(true))
}

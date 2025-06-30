//
//  ReceiptView.swift
//  receipt-share
//
//  Created by 東　真史 on 2025/06/10.
//

import SwiftUI

struct ReceiptView: View {
    var receipt: Receipt
    @Environment(GroupViewModel.self) private var groupViewModel: GroupViewModel
    @State private var isEditing: Bool = false
    @State private var draftReceipt: Receipt = Receipt.default
    
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // 画像
                AsyncImage(url: receipt.imageURL) {
                    image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity)
                        .cornerRadius(10)
                } placeholder: {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                        .frame(maxWidth: .infinity)
                }
                
                // ステータスに応じた表示
                switch receipt.ocrStatus {
                case .pending, .processing:
                    VStack(spacing: 10) {
                        ProgressView()
                        Text(receipt.ocrStatus == .pending ? "OCR待機中" : "OCR処理中")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.gray.opacity(0.1))
                    .cornerRadius(10)
                    
                case .completed:
                    VStack(alignment: .leading, spacing: 12) {
                        infoRow("店舗名", receipt.merchantName ?? "不明")
                        infoRow("購入日時", DateFormatter.localizedString(from: receipt.purchaseDate ?? Date(), dateStyle: .medium, timeStyle: .none))
                        infoRow("登録番号", receipt.invoiceNumber)
                        infoRow("支払方法", receipt.paymentMethod)
                        infoRow("合計金額", "¥\(receipt.totalAmount ?? 0)")
                        
                        if !receipt.items.isEmpty {
                            Text("商品リスト")
                                .font(.headline)
                                .padding(.top, 8)
                            
                            ForEach(receipt.items) { item in
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(item.productName)
                                        Text("数量: \(item.quantity)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    Text("¥\(item.totalPrice)")
                                }
                                Divider()
                            }
                        }
                    }
                    
                case .failed:
                    VStack(spacing: 10) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.orange)
                        Text("OCRに失敗しました")
                            .font(.headline)
                        Text("もう一度アップロードするか、手動で入力してください")
                            .font(.caption)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.orange.opacity(0.1))
                    .cornerRadius(10)
                }
            }
            .padding()
        }
        .navigationTitle("レシート詳細")
        .toolbar(content: {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    isEditing.toggle()
                }) {
                    Text(isEditing ? "完了" : "編集")
                }
            }
        })
        .sheet(isPresented: $isEditing) {
            ReceiptEdit(receipt: $draftReceipt, isPresented: $isEditing)
                .onAppear {
                    draftReceipt = receipt
                }
                .onDisappear {
                    groupViewModel.updateReceipt(draftReceipt)
                }
        }
    }
    
    // MARK: - Helper Views
    
    private func infoRow(_ label: String, _ value: String?) -> some View {
        HStack {
            Text(label)
                .font(.subheadline.bold())
                .frame(width: 100, alignment: .leading)
            Text(value ?? "-")
                .font(.body)
            Spacer()
        }
    }
}

//
//  GroupChart.swift
//  receipt-share
//
//  Created by 東　真史 on 2025/06/17.
//

import SwiftUI
import Charts

struct ExpenseData: Identifiable {
    let id = UUID()
    let name: String
    let amount: Int
    let color: Color
}

struct GroupChart: View {
    var members: [User]
    var receipts: [Receipt]
    
    // 支払い金額の合計を計算
    private var totalAmount: Int {
        receipts.reduce(0) { $0 + ($1.totalAmount ?? 0) }
    }
    
    // ユーザーごとの支払い金額を集計
    private var expensesByUser: [ExpenseData] {
        let userAmounts = Dictionary(grouping: receipts) { receipt in
            receipt.userId
        }.mapValues { receipts in
            receipts.reduce(0) { $0 + ($1.totalAmount ?? 0) }
        }
        
        // 固定の色リスト（色数が足りなければ繰り返し使用）
        let colors: [Color] = [.blue, .green, .orange, .red, .purple, .pink, .yellow, .cyan, .brown]
        
        // 既存メンバーの支出データを作成
        var expenseData = members.enumerated().compactMap { index, user in
            let amount = userAmounts[user.id] ?? 0
            return ExpenseData(
                name: user.name,
                amount: amount,
                color: colors[index % colors.count]
            )
        }
        
        // 削除されたユーザーの分（その他）を計算
        let memberIds = Set(members.map { $0.id })
        let otherAmount = userAmounts
            .filter { userId, _ in !memberIds.contains(userId) }
            .values
            .reduce(0, +)
        
        // その他の分がある場合は追加
        if otherAmount > 0 {
            expenseData.append(ExpenseData(
                name: "その他",
                amount: otherAmount,
                color: .gray
            ))
        }
        
        return expenseData.filter { $0.amount > 0 } // 支払いがない人は除外
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("グループの支出分析")
                .font(.headline)
            
            if expensesByUser.isEmpty {
                ContentUnavailableView(
                    "データがありません",
                    systemImage: "chart.pie",
                    description: Text("このグループにはまだ支出データがありません。")
                )
            } else {
                // 円グラフ
                Chart(expensesByUser) { expense in
                    SectorMark(
                        angle: .value("金額", expense.amount),
                        innerRadius: .ratio(0.3), // ドーナツグラフにする
                        angularInset: 1.5
                    )
                    .foregroundStyle(expense.color)
                    .annotation(position: .overlay) {
                        if shouldShowLabelInSlice(for: expense) {
                            Text("\(calculatePercentage(expense.amount))%")
                                .font(.caption)
                                .foregroundColor(.white)
                                .fontWeight(.bold)
                        }
                    }
                }
                .frame(height: 240)
                .chartBackground { chartProxy in
                    // 中央に合計金額を表示
                    VStack {
                        Text("合計")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("¥\(totalAmount)")
                            .font(.headline)
                    }
                    .position(
                        x: chartProxy.plotSize.width / 2,
                        y: chartProxy.plotSize.height / 2
                    )
                }
                
                // 凡例
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(expensesByUser.sorted { $0.amount > $1.amount }) { expense in
                            HStack(spacing: 12) {
                                Circle()
                                    .fill(expense.color)
                                    .frame(width: 16, height: 16)
                                
                                Text(expense.name)
                                    .fontWeight(.medium)
                                
                                Spacer()
                                
                                VStack(alignment: .trailing) {
                                    Text("¥\(expense.amount)")
                                        .font(.callout)
                                    Text("\(calculatePercentage(expense.amount))%")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
        }
        .padding()
    }
    
    // パーセンテージを計算（切り捨て）
    private func calculatePercentage(_ amount: Int) -> Int {
        guard totalAmount > 0 else { return 0 }
        return Int((Double(amount) / Double(totalAmount)) * 100)
    }
    
    // スライスが大きいかどうかチェック（小さすぎるとラベルを表示しない）
    private func shouldShowLabelInSlice(for expense: ExpenseData) -> Bool {
        let percentage = calculatePercentage(expense.amount)
        return percentage >= 10 // 10%以上のスライスにのみラベルを表示
    }
}

#Preview {
    // プレビュー用のサンプルデータ
    let sampleGroup = mockGroups[0] // Family
    let sampleReceipts: [Receipt] = [
        Receipt(
            id: "r1",
            groupId: "1",
            userId: "u1",
            merchantName: "スーパー",
            totalAmount: 5000,
            items: [],
            ocrStatus: .completed,
            imageURL: URL(string: "https://example.com")!,
            imageStoragePath: ""
        ),
        Receipt(
            id: "r2",
            groupId: "1",
            userId: "u2",
            merchantName: "レストラン",
            totalAmount: 3000,
            items: [],
            ocrStatus: .completed,
            imageURL: URL(string: "https://example.com")!,
            imageStoragePath: ""
        ),
        Receipt(
            id: "r3",
            groupId: "1",
            userId: "u1",
            merchantName: "薬局",
            totalAmount: 2000,
            items: [],
            ocrStatus: .completed,
            imageURL: URL(string: "https://example.com")!,
            imageStoragePath: ""
        )
    ]
    
    GroupChart(members: sampleGroup.members, receipts: sampleReceipts)
}

//
//  receipt.swift
//  receipt-share
//
//  Created by 東　真史 on 2025/06/09.
//
import Foundation

struct Receipt: Identifiable, Codable, Hashable {
    var id: String = UUID().uuidString
    var groupId: String
    var userId: String
    var invoiceNumber: String?
    var purchaseDate: Date?
    var merchantName: String?
    var totalAmount: Int?
    var paymentMethod: String?
    var items: [ReceiptItem] = []
    
    // OCRのステータスを管理するプロパティ
    var ocrStatus: OCRStatus = .pending
    
    // 画像のURLを保存するプロパティ
    var imageURL: URL
    var imageStoragePath: String
    
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    
    static let `default` = Receipt(
        groupId: "defaultGroup",
        userId: "defaultUser",
        imageURL: URL(string: "https://picsum.photos/800/1200?random=1")!,
        imageStoragePath: "default/path/to/image.jpg"
    )
}


struct ReceiptItem: Identifiable, Codable, Hashable {
    var id: String = UUID().uuidString
    var productName: String
    var quantity: Int
    var price: Int
    var totalPrice: Int
}

enum OCRStatus: String, Codable, Hashable {
    case pending
    case processing
    case completed
    case failed
}
    

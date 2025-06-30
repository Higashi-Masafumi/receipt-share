//
//  ReceiptMapper.swift
//  receipt-share
//
//  Created by 東　真史 on 2025/06/15.
//

import Foundation
import FirebaseFirestore

/// DTOとドメインモデル間のマッピングを担当するクラス
struct ReceiptMapper {
    static func toDomain(dto: ReceiptDTO, documentId: String) -> Receipt {
        
        return Receipt(
            id: dto.id ?? documentId,
            groupId: dto.groupId,
            userId: dto.userId,
            invoiceNumber: dto.invoiceNumber,
            purchaseDate: dto.purchaseDate,
            merchantName: dto.merchantName,
            totalAmount: dto.totalAmount,
            paymentMethod: dto.paymentMethod,
            items: dto.items?.map { toDomain(dto: $0) } ?? [],
            ocrStatus: dto.ocrStatus,
            imageURL: URL(string: dto.imageURL)!,
            imageStoragePath: dto.imageStoragePath,
            createdAt: dto.createdAt ?? Date(),
            updatedAt: dto.updatedAt ?? Date(),
        )
    }
    static func toDTO(domain: Receipt) -> ReceiptDTO {
        return ReceiptDTO(
            id: domain.id,
            groupId: domain.groupId,
            userId: domain.userId,
            invoiceNumber: domain.invoiceNumber,
            purchaseDate: domain.purchaseDate,
            merchantName: domain.merchantName,
            totalAmount: domain.totalAmount,
            paymentMethod: domain.paymentMethod,
            items: domain.items.map { toDTO(domain: $0) },
            ocrStatus: domain.ocrStatus,
            imageURL: domain.imageURL.absoluteString,
            imageStoragePath: domain.imageStoragePath,
            createdAt: domain.createdAt,
            updatedAt: domain.updatedAt,
        )
    }
    static func toDomain(dto: ReceiptItemDTO) -> ReceiptItem {
        let id = dto.id ?? UUID().uuidString
        
        return ReceiptItem(
            id: id,
            productName: dto.productName,
            quantity: dto.quantity,
            price: dto.price,
            totalPrice: dto.totalPrice
        )
    }
    static func toDTO(domain: ReceiptItem) -> ReceiptItemDTO {
        return ReceiptItemDTO(
            id: domain.id,
            productName: domain.productName,
            quantity: domain.quantity,
            price: domain.price,
            totalPrice: domain.totalPrice
        )
    }
}

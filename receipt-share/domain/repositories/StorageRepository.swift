//
//  StorageRepository.swift
//  receipt-share
//
//  Created by 東　真史 on 2025/06/11.
//
import Foundation
import UIKit

protocol StorageRepositoryProtocol {
    func uploadImage(receiptImage: ReceiptImage) async throws -> (URL, String)
    func uploadProfileImage(userId: String, image: UIImage) async throws -> URL
}
    

//
//  receiptImage.swift
//  receipt-share
//
//  Created by 東　真史 on 2025/06/11.
//
import Foundation
import UIKit

struct ReceiptImage: Identifiable {
    var id: String = UUID().uuidString
    var image: UIImage
    var userId: String
    var groupId: String
}

//
//  ReceiptRepository.swift
//  receipt-share
//
//  Created by 東　真史 on 2025/06/10.
//

protocol ReceiptRepositoryProtocol {
    func getGroupReceipts(groupId: String) async throws -> [Receipt]
    func addReceipt(_ receipt: Receipt) async throws -> Receipt
    func removeReceipt(_ receipt: Receipt) async throws -> Void
    func updateReceipt(_ receipt: Receipt)  async throws -> Receipt
    func observeReceipt(groupId: String) async throws -> AsyncThrowingStream<[Receipt], Error>
}

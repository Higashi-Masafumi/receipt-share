//
//  ReceiptList.swift
//  receipt-share
//
//  Created by 東　真史 on 2025/06/10.
//

import SwiftUI

struct ReceiptList: View {
    var receipts: [Receipt]
    @Environment(GroupViewModel.self) private var groupviewModel
    
    var body: some View {
        List(receipts) { receipt in
            NavigationLink {
                ReceiptView(receipt: receipt)
                .environment(groupviewModel)
                
            } label: {
                ReceiptRow(receipt: receipt)
            }
        }
        .navigationTitle("Receipts")
    }
}



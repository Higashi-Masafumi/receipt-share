//
//  SaveButton.swift
//  receipt-share
//
//  Created by 東　真史 on 2025/06/17.
//

// --- 4. 保存ボタン -----------------------------------
import SwiftUI

struct SaveButton: View {
    // Bindingを使わず、直接条件を計算できるようにする
    var isDisabled: () -> Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("保存")
                .font(.headline)
                .frame(maxWidth: .infinity)
        }
        .padding()
        .background(isDisabled() ? Color.gray.opacity(0.5) : Color.blue)
        .foregroundColor(.white)
        .cornerRadius(10)
        .disabled(isDisabled())
        .listRowInsets(EdgeInsets())
        .listRowBackground(Color.clear)
    }
}

#Preview {
    SaveButton(
        isDisabled: { true }, // ここでは常に無効化されるように設定
        action: {}
    )
}

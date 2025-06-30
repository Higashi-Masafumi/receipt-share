//
//  NewGroup.swift
//  receipt-share
//
//  Created by 東　真史 on 2025/06/09.
//

import SwiftUI

struct NewGroup: View {
    @Binding var isPresented: Bool
    @State private var groupName: String = ""
    var onSave: (String) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("グループ情報")) {
                    TextField("グループ名", text: $groupName)
                        .disableAutocorrection(true)
                }
            }
            .navigationTitle("新規グループ")
            .navigationBarItems(
                leading: Button("キャンセル") {
                    isPresented = false
                },
                trailing: Button("保存") {
                    onSave(groupName)
                    isPresented = false
                }
                    .disabled(groupName.isEmpty)
            )
        }
    }
}

#Preview {
    NewGroup(isPresented: .constant(true), onSave: { _ in })
}

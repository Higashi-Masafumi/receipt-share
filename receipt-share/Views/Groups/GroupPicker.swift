//
//  GroupPicker.swift
//  receipt-share
//
//  Created by 東　真史 on 2025/06/11.
//
import SwiftUI

struct GroupPickerSheet: View {
    
    var groups: [GroupWithoutMembers]
    var selected: GroupWithoutMembers?
    var onSelect: (GroupWithoutMembers?) -> Void
    
    var body: some View {
        NavigationStack {
            List(groups) { group in
                Button {
                    onSelect(group)
                } label: {
                    HStack {
                        if selected?.id == group.id {
                            GroupRow(group: group)
                                .foregroundColor(.blue)
                        } else {
                            GroupRow(group: group)
                                .foregroundColor(.primary)
                        }
                    }
                }
            }
            .navigationTitle("グループを選択")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") {
                        onSelect(selected) // no change
                    }
                }
            }
        }
    }
}

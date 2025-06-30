//
//  GroupList.swift
//  receipt-share
//
//  Created by 東　真史 on 2025/06/09.
//

import SwiftUI

struct GroupList: View {

    @Environment(GroupListViewModel.self) private var groupListViewModel
    @State private var showingNewGroup = false
    
    var body: some View {
        NavigationStack {
            List(groupListViewModel.groups) { group in
                NavigationLink {
                    GroupView(group: group)
                } label: {
                    GroupRow(group: group)
                }
            }
            .navigationTitle("Groups")
            .toolbar {
                Button {
                    showingNewGroup = true
                } label: {
                    Label("Add Group", systemImage: "plus")
                }
            }
            .sheet(isPresented: $showingNewGroup) {
                NewGroup(isPresented: $showingNewGroup) { groupName in
                    groupListViewModel.createGroup(name: groupName)
                }
            }
        }
        .onAppear {
            groupListViewModel.loadGroups()
        }
    }
}

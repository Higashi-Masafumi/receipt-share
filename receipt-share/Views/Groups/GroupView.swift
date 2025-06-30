//
//  GroupView.swift
//  receipt-share
//
//  Created by 東　真史 on 2025/06/08.
//
import SwiftUI

struct GroupView: View {
    @State private var groupViewModel: GroupViewModel
    @State private var inviteLink: String = ""
    @State private var showShareSheet: Bool = false
    @State private var errorMessage: String = ""
    @State private var isGeneratingLink: Bool = false
    private var group: GroupWithoutMembers
    
    init(group: GroupWithoutMembers) {
        self.group = group
        _groupViewModel = State(initialValue: GroupViewModel(group: group, receiptRepository: FirebaseReceiptRepository()))
    }
    
    var body: some View {
        List {
            GroupChart(members: groupViewModel.members, receipts: groupViewModel.receipts)
            NavigationLink {
                UserList(users: groupViewModel.members)
            } label: {
                Label {
                    Text("Members")
                        .font(.headline)
                        .foregroundColor(.primary)
                } icon: {
                    Image(systemName: "person.3.fill")
                        .foregroundColor(.blue)
                        .frame(width: 32, height: 32)
                }
            }
            NavigationLink {
                ReceiptList(receipts: groupViewModel.receipts)
                    .environment(groupViewModel)
            } label: {
                Label {
                    Text("Receipts")
                        .font(.headline)
                        .foregroundColor(.primary)
                } icon: {
                    Image(systemName: "receipt.fill")
                        .foregroundColor(.green)
                        .frame(width: 32, height: 32)
                }
            }
            
            Button(action: {
                // 同期関数内でTaskを使って非同期処理を行う
                isGeneratingLink = true
                Task {
                    do {
                        let link = try await groupViewModel.publishInivitationLink()
                        inviteLink = link
                        isGeneratingLink = false
                        showShareSheet = true
                    } catch {
                        errorMessage = "招待リンクの生成に失敗しました: \(error.localizedDescription)"
                        isGeneratingLink = false
                    }
                }
            }) {
                Label {
                    Text("Invite Members")
                        .font(.headline)
                        .foregroundColor(.primary)
                } icon: {
                    if isGeneratingLink {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .frame(width: 32, height: 32)
                    } else {
                        Image(systemName: "person.badge.plus.fill")
                            .foregroundColor(.purple)
                            .frame(width: 32, height: 32)
                    }
                }
            }
            .disabled(isGeneratingLink)
        }
        .animation(.default, value: groupViewModel.members)
        .navigationTitle(groupViewModel.group.name)
        .onAppear {
            groupViewModel.loadReceiptsAndMembers()
        }
        .sheet(isPresented: $showShareSheet) {
            if !inviteLink.isEmpty {
                ShareSheet(activityItems: [inviteLink])
            }
        }
        .alert("エラー", isPresented: .constant(!errorMessage.isEmpty)) {
            Button("OK") { errorMessage = "" }
        } message: {
            Text(errorMessage)
        }
    }
}

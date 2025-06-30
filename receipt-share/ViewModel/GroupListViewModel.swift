//
//  GroupListViewModel.swift
//  receipt-share
//
//  Created by 東　真史 on 2025/06/12.
//

import Foundation

@Observable
class GroupListViewModel {
    private let groupRepository: GroupRepositoryProtocol
    private let user : AuthUser
    var groups: [GroupWithoutMembers] = []
    
    init(groupRepository: GroupRepositoryProtocol, user: AuthUser) {
        self.groupRepository = groupRepository
        self.user = user
        observeGroups()
    }
    
    func loadGroups()  {
        Task {
            do {
                groups = try await groupRepository.getGroupsWithoutMembers(userId: user.id)
            } catch {
                print("Error loading groups: \(error)")
            }
        }
    }
    
    func observeGroups() {
        Task {
            do {
                let stream = try await groupRepository.observeGroupsWithoutMembers(userId: user.id)
                for try await newGroups in stream {
                    self.groups = newGroups
                }
            } catch {
                print("Error observing groups: \(error)")
            }
        }
    }
    
    func createGroup(name: String) {
        Task {
            do {
                _ = try await groupRepository.addGroup(name: name, createdBy: user.id)
            } catch {
                print("Error creating group: \(error)")
            }
        }
    }
}
        

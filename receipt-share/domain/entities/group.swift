import Foundation

struct Group: Hashable, Codable, Identifiable {
    var id: String
    var name: String
    var photoURL: URL
    var members: [User]
    
    static func defaultPhotoURL(groupId: String) -> URL {
        return URL(string: "https://picsum.photos/seed/\(groupId)/200/200")!
    }
}

struct GroupWithoutMembers: Hashable, Codable, Identifiable {
    var id: String
    var name: String
    var photoURL: URL
}

import Foundation
import SwiftUI

struct User: Hashable, Codable, Identifiable {
    var id: String
    var name: String
    var photoURL: URL
    var email: String
    
    static func defaultPhotoURL(userId: String) -> URL {
        return URL(string: "https://picsum.photos/seed/\(userId)/200/200")!
    }
}

struct AuthUser: Hashable, Codable, Identifiable {
    var id: String
    var email: String
}

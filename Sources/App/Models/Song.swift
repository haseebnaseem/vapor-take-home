import Vapor

struct Song: Codable {
    let id: Int
    let title: String
    let label: String?
    let thumb: String?

    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case thumb
        case label
    }
}

/// Allows `Song` to be encoded to and decoded from HTTP messages.
extension Song: Content { }

import Vapor
import FluentPostgreSQL

/// A single entry of a User list.
final class Playlist: PostgreSQLModel {
    typealias Database = PostgreSQLDatabase
    
    /// The unique identifier for this `User`.
    var id: Int?

    /// A title describing what this `User` entails.
    var name: String
    var description: String
    var songs: [Int]?
    /// Creates a new `User`.
    init(id: Int? = nil, name: String, description: String) {
        self.id = id
        self.name = name
        self.description = description
        self.songs = []
    }

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case songs
    }
}

/// Allows `User` to be encoded to and decoded from HTTP messages.
extension Playlist: Content { }

/// Allows `User` to be used as a dynamic parameter in route definitions.
extension Playlist: Parameter { }

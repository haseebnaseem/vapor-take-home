import Vapor
import FluentPostgreSQL

final class Playlist: PostgreSQLModel {
    typealias Database = PostgreSQLDatabase
    
    var id: Int?

    var name: String
    var description: String
    var songs: [Int]?
    var song_details: [Song]?

    init(id: Int? = nil, name: String, description: String) {
        self.id = id
        self.name = name
        self.description = description
    }

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case songs
        case song_details
    }
}

extension Playlist: Content { }

extension Playlist: Parameter { }

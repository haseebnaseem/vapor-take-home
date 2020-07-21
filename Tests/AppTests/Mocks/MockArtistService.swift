import Foundation
import Vapor
@testable import App

class MockArtistService: ArtistService, Service {
    
    
    var artistsToReturn: [Artist] = []
    var searchedArtists: [String] = []
    var searchedSongs: [Song] = [];
    func reset() {
        artistsToReturn = []
        searchedArtists = []
        searchedSongs = []
    }

    // MARK - ArtistService
    func searchArtist(artist: String, on req: Request) throws -> EventLoopFuture<[Artist]> {
        searchedArtists.append(artist)
        return req.future(artistsToReturn)
    }
    func songSearch(artist: Int, song: String, on req: Request) throws -> EventLoopFuture<[Song]> {
        return req.future(searchedSongs)
    }
    
    func getSong(songIds: [Int], on req: Request) throws -> EventLoopFuture<[Song]> {
        return req.future(searchedSongs)
    }
}

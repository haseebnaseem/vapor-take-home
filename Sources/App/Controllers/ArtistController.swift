import Vapor

final class ArtistController {
    
    /// Searches for artists
    func searchArtist(_ req: Request) throws -> Future<[Artist]> {
        let artistString = try req.query.get(String.self, at: "q")
        let service = try req.make(ArtistService.self)
        return try service.searchArtist(artist: artistString, on: req)
    }
    
    func searchSong(_ req: Request) throws ->  Future<[Song]> {
        let songString = try req.query.get(String.self, at: "q")
        let service = try req.make(ArtistService.self)
        let artistId = try req.parameters.next(Int.self);
        return try service.songSearch(artist: artistId, song: songString, on: req);
    }
}

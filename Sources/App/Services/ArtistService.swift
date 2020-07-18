import Foundation
import Vapor

protocol ArtistService: Service {
    func searchArtist(artist: String, on req: Request) throws -> Future<[Artist]>
    func songSearch(artist: Int, song: String, on req:Request) throws -> Future<[Song]>
    func getSong(songIds: [Int], on req: Request) throws -> Future<[Song]>
}

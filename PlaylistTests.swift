@testable import App
import FluentPostgreSQL
@testable import Vapor
import XCTest

class PlaylistTest: XCTestCase {

    var app: Application!
    var connection: PostgreSQLConnection!
    var request: Request!
    var mockArtistService: MockArtistService!

    override func setUp() {
        do {
            try Application.reset()
            app = try Application.testable()
            connection = try self.app.newConnection(to: .psql).wait()
        }
        catch {
            fatalError(error.localizedDescription)
        }

        request = Request(using: self.app)
        mockArtistService = try! request.make(MockArtistService.self)
        mockArtistService.reset()
    }

    override func tearDown() {
        connection?.close()
        try? app.syncShutdownGracefully()
    }

    func testCreatePlaylist() throws {
        let newPlaylist = Playlist(name: "workout", description: "my workout playlist")
        let playlist = try self.app.getResponse(to: "/playlists", method: .POST, data: newPlaylist, decodeTo: Playlist.self)

        XCTAssertTrue(playlist.id != nil)
        XCTAssertEqual(playlist.name, "workout")
        XCTAssertEqual(playlist.description, "my workout playlist")
    }

    func testGetPlaylist() throws {
        let newPlaylist = Playlist(name: "cooking", description: "cooking playlist")
        let playlist = try self.app.getResponse(to: "/playlists", method: .POST, data: newPlaylist, decodeTo: Playlist.self)

        let playlistID = try playlist.requireID()
        let updatedPlaylist = try self.app.getResponse(to: "/playlists/\(playlistID)", decodeTo: Playlist.self)

        XCTAssertEqual(updatedPlaylist.id, playlistID)
        XCTAssertEqual(updatedPlaylist.name, "cooking")
        XCTAssertEqual(updatedPlaylist.description, "cooking playlist")

    }

    func testUpdatePlaylist() throws {
        let newPlaylist = Playlist(name: "party", description: "Party songs")
        let playlist = try self.app.getResponse(to: "/playlists", method: .POST, data: newPlaylist, decodeTo: Playlist.self)

        XCTAssertTrue(playlist.id != nil)
        XCTAssertEqual(playlist.name, "party")

        playlist.name = "Game night"
        playlist.description = "game night tunes"

        let playlistID = try playlist.requireID()
        let updatedPlaylist = try self.app.getResponse(to: "/playlists/\(playlistID)", method: .PUT, data: playlist, decodeTo: Playlist.self)

        XCTAssertEqual(updatedPlaylist.id, playlistID)
        XCTAssertEqual(updatedPlaylist.name, "Game night")
        XCTAssertEqual(updatedPlaylist.description, "game night tunes")

    }

    func testDeletePlaylist() throws {
        let newPlaylist = Playlist(name: "workout", description: "my workout playlist")
        let playlist = try self.app.getResponse(to: "/playlists", method: .POST, data: newPlaylist, decodeTo: Playlist.self)

        
        let playlistID = try playlist.requireID()
        let retrievedPlaylist = try self.app.getResponse(to: "/playlists/\(playlistID)", decodeTo: Playlist.self)

        XCTAssertEqual(retrievedPlaylist.id, playlistID)

        let deleteResponse = try self.app.sendRequest(to: "/playlists/\(playlistID)", method: .DELETE)
        XCTAssertEqual(deleteResponse.http.status, .noContent)

        let notFoundResponse = try self.app.sendRequest(to: "/playlists/\(playlistID)", method: .GET)
        XCTAssertEqual(notFoundResponse.http.status, .notFound)
    }
    
    func testAddSong() throws {
        let newPlaylist = Playlist(name: "workout", description: "my workout playlist")
        let playlist = try self.app.getResponse(to: "/playlists", method: .POST, data: newPlaylist, decodeTo: Playlist.self)
        
        let playlistID = try playlist.requireID()
        let retrievedPlaylist = try self.app.getResponse(to: "/playlists/\(playlistID)", decodeTo: Playlist.self)

        XCTAssertEqual(retrievedPlaylist.id, playlistID)
        
        let songToAdd = Song(id: 155876, title: "Insomnia", label: nil, thumb: "https://img.discogs.com/UbGgg61B8Lbo-nJC9-Kr44agCOY=/fit-in/150x150/filters:strip_icc():format(jpeg):mode_rgb():quality(40)/discogs-images/R-155876-1278467866.jpeg.jpg")
        
        
        let withSongPlaylist = try self.app.getResponse(to: "/playlists/\(playlistID)/songs/\(songToAdd.id)", method: .POST, decodeTo: Playlist.self)
        XCTAssertEqual(withSongPlaylist.id, playlistID)
        XCTAssertEqual(withSongPlaylist.songs![0], songToAdd.id)

        // Ensure a song is not added twice
        
        let withSameSongPlaylist = try self.app.getResponse(to: "/playlists/\(playlistID)/songs/\(songToAdd.id)", method: .POST, decodeTo: Playlist.self)
        XCTAssertEqual(withSameSongPlaylist.id, playlistID)
        XCTAssertEqual(withSameSongPlaylist.songs!.count, 1);
    }
    
    func testRemoveSong() throws {
        let newPlaylist = Playlist(name: "workout", description: "my workout playlist")
        let playlist = try self.app.getResponse(to: "/playlists", method: .POST, data: newPlaylist, decodeTo: Playlist.self)
        
        let playlistID = try playlist.requireID()
        let retrievedPlaylist = try self.app.getResponse(to: "/playlists/\(playlistID)", decodeTo: Playlist.self)

        XCTAssertEqual(retrievedPlaylist.id, playlistID)
        
        let songToAdd = Song(id: 155876, title: "Insomnia", label: nil, thumb: "https://img.discogs.com/UbGgg61B8Lbo-nJC9-Kr44agCOY=/fit-in/150x150/filters:strip_icc():format(jpeg):mode_rgb():quality(40)/discogs-images/R-155876-1278467866.jpeg.jpg")
        
        
        let withSongPlaylist = try self.app.getResponse(to: "/playlists/\(playlistID)/songs/\(songToAdd.id)", method: .POST, decodeTo: Playlist.self)
        XCTAssertEqual(withSongPlaylist.id, playlistID)
        XCTAssertEqual(withSongPlaylist.songs![0], songToAdd.id)
        
        let playlistWithSongRemoved = try self.app.getResponse(to: "/playlists/\(playlistID)/songs/\(songToAdd.id)", method: .DELETE, decodeTo: Playlist.self)
        XCTAssertEqual(playlistWithSongRemoved.id, playlistID)
        XCTAssertEqual(playlistWithSongRemoved.songs!.count, 0);
        
    }
    
    func testSongDetailsInResponse() throws {
        let newPlaylist = Playlist(name: "workout", description: "my workout playlist")
        let playlist = try self.app.getResponse(to: "/playlists", method: .POST, data: newPlaylist, decodeTo: Playlist.self)
        
        let playlistID = try playlist.requireID()
        //let retrievedPlaylist = try self.app.getResponse(to: "/playlists/\(playlistID)", decodeTo: Playlist.self)

        //XCTAssertEqual(retrievedPlaylist.id, playlistID)
        
        let songToAdd = Song(id: 155876, title: "Insomnia", label: nil, thumb: "https://img.discogs.com/UbGgg61B8Lbo-nJC9-Kr44agCOY=/fit-in/150x150/filters:strip_icc():format(jpeg):mode_rgb():quality(40)/discogs-images/R-155876-1278467866.jpeg.jpg")
        
        
        let withSongPlaylist = try self.app.getResponse(to: "/playlists/\(playlistID)/songs/\(songToAdd.id)", method: .POST, decodeTo: Playlist.self)
        XCTAssertEqual(withSongPlaylist.id, playlistID)
        XCTAssertEqual(withSongPlaylist.songs![0], songToAdd.id);
        
        mockArtistService.searchedSongs = [ songToAdd ]
        let completePlaylist = try self.app.getResponse(to: "/playlists/\(playlistID)", decodeTo: Playlist.self);
        
        XCTAssertEqual(completePlaylist.id, playlistID)
        XCTAssertEqual(completePlaylist.songs!.count, 1)
        
        
        XCTAssertEqual(completePlaylist.song_details!.count, 1)
        XCTAssertEqual(completePlaylist.song_details![0].id, songToAdd.id)
        XCTAssertEqual(completePlaylist.song_details![0].title, songToAdd.title)
        XCTAssertEqual(completePlaylist.song_details![0].thumb, songToAdd.thumb)
 


    }
}

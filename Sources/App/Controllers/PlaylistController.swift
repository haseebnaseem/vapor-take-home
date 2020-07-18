import Vapor

final class PlaylistController {

    func create(_ req: Request) throws -> Future<Playlist> {
        return try req.content.decode(Playlist.self).flatMap { playlist in
            return playlist.save(on: req)
        }
    }

    func index(_ req: Request) throws -> Future<[Playlist]> {
       return Playlist.query(on: req).all()
    }

    func find(_ req: Request) throws -> Future<Playlist> {
        return try req.parameters.next(Playlist.self).flatMap { playlist in
            if playlist.songs == nil || playlist.songs?.count == 0 {
                return req.future(playlist)
            } else {
                let service = try req.make(ArtistService.self);
                return try service.getSong(songIds: (playlist.songs)!, on: req).flatMap { songs in
                    playlist.song_details = songs;
                    playlist.
                    return req.future(playlist);
                }
            }
        }
    }
    
    func delete(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(Playlist.self).flatMap { playlist in
            return playlist.delete(on: req)
        }.transform(to: .noContent)
    }
    func addSong(_ req: Request) throws -> Future<Playlist> {
        return try req.parameters.next(Playlist.self).flatMap { playlist in
            let songId = try req.parameters.next(Int.self);
            var songArray = playlist.songs;
            if songArray != nil {
                if songArray?.contains(songId) == false {
                    songArray?.append(songId);
                }
            } else {
                songArray = [songId];
            }
            playlist.songs = songArray;
            return playlist.update(on: req);
        }
    }
    
    func removeSong(_ req: Request) throws -> Future<Playlist> {
        return try req.parameters.next(Playlist.self).flatMap { playlist in
            let songId = try req.parameters.next(Int.self);
            playlist.songs = playlist.songs?.filter(){ $0 != songId}
            return playlist.update(on: req);
        }
    }
}

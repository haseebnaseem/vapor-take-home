import Vapor

struct DiscogService: ArtistService {
    private let searchURL = "https://api.discogs.com/database/search"
    private let headers: HTTPHeaders = [
        "Authorization": "Discogs token=\(Environment.apiToken)"
    ]

    func searchArtist(artist: String, on req: Request) throws -> Future<[Artist]> {
        var components = URLComponents(string: searchURL)
        components?.queryItems = [URLQueryItem(name: "q", value: artist)]

        guard let url = components?.url else {
            fatalError("Couldn't create search URL")
        }

        return try req.client().get(url, headers: headers).flatMap({ response in
            return try response.content.decode(ArtistSearchResponse.self).flatMap({ artistSearch in
                return req.future(artistSearch.results)
            })
        })
    }
    
    func songSearch(artist: Int, song: String, on req:Request) throws -> Future<[Song]> {
        let songsURL = "https://api.discogs.com/artists/" + String(artist) + "/releases";

        return try req.client().get(songsURL, headers: headers).flatMap({ response in
            return try response.content.decode(SongSearchResult.self).flatMap({ songSearch in
                var filteredSong: [Song] = [];
                
                for thisSong in songSearch.releases {
                    let name = thisSong.title;
                    if name == song {
                        filteredSong.append(thisSong)
                    }
                }
                return req.future(filteredSong);
            })
        })
    }
}

//
//  MusicData.swift
//  Music
//
//  Created by Rotem Peer on 01/01/2020.
//

import UIKit

class MusicData {
    
    private init(){}
    static let shared = MusicData()
    
    private var songsArray: Songs?
    private var artist: Artist?
    
    var coversCache = [String: UIImage]()
    
    func artistSearch(searchText: String, _ completion: @escaping (Artist? ,Error?) -> Void) {
        let text = searchText.replacingOccurrences(of: " ", with: "+")
        let urlString = "https://deezerdevs-deezer.p.rapidapi.com/search/artist?rapidapi-key=0553c29e4bmsh3a239d5a07dbdb4p1e9ae1jsnc9399dacde13&q=" + text
        
        getRequest(from: urlString) { (data, error) in
            if error != nil {
                completion(nil, error)
                return
            }
            self.createArtist(data: data!) { (artist, error) in
                completion(artist, error)
            }
        }
    }
    
    private func createArtist(data: Data, _ completion: @escaping (Artist?, Error?) -> Void) {
        
        guard let searchResults = try? JSONDecoder().decode(SearchResults.self, from: data), searchResults.data.count > 0 else {
            completion(nil, MyError.artistNotFound)
            return
        }
        let firstResult = searchResults.data[0]
        
        artist = Artist()
        artist?.name = firstResult.name
        
        downloadImage(from: firstResult.picture_medium) { (image) in
            artist?.image = image
        }
        
        getRequest(from: firstResult.tracklist) { (data, error) in
            print(firstResult.tracklist)
            if error != nil {
                completion(self.artist, error)
                return
            }
            guard let data = data, let songsArray = try? JSONDecoder().decode(Songs.self, from: data) else {
                completion(self.artist, error)
                return
            }
            self.artist?.songs = songsArray.data
            completion(self.artist, nil)
        }
    }
    
    private func getRequest(from urlString: String, _ completion: @escaping (Data?, Error?) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(nil, MyError.artistNotFound)
            return
        }
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("error: \(error)")
                completion(nil, error)
                return
            }
            if let response = response as? HTTPURLResponse {
                print("statusCode: \(response.statusCode)")
            }
            if let data = data {
                completion(data, nil)
            }
            
        }
        task.resume()
    }
    
    func downloadImage(from urlString: String, _ completion: (UIImage?) -> Void) {
        
        if let image = coversCache[urlString] {
            completion(image)
            return
        }
        let url = URL(string: urlString)!
        guard let data = try? Data(contentsOf: url) else {
            completion(nil)
            return
        }
        coversCache[urlString] = UIImage(data: data)
        completion(coversCache[urlString])
    }
}

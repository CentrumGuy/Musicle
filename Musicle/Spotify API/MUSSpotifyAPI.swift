//
//  MUSSpotifyAPI.swift
//  SpotifyAPI
//
//  Created by Viren Mirchandani on 3/10/22.
//

import Foundation

class MUSSpotifyAPI {
    
    static let shared = MUSSpotifyAPI()
    
    private var token: String?
    
    private init() {}
    
    func generateToken(clientID: String, clientSecret: String, completion: @escaping () -> ()) {
        let tokenURL = "https://accounts.spotify.com/api/token"
        let utf8TokenInput = "\(clientID):\(clientSecret)".data(using: .utf8)
        
        guard let base64EncodedString = utf8TokenInput?.base64EncodedString(), let url = URL(string: tokenURL) else { return }
        
        var request = URLRequest(url: url)
        let parameters = "grant_type=client_credentials"
        
        request.httpMethod = "POST"
        request.addValue("Basic \(base64EncodedString)", forHTTPHeaderField: "Authorization")
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = parameters.data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,
                  let readableJSON = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any],
                  let token = readableJSON["access_token"] as? String else { return }
            
            self.token = token
            completion()
        }
        
        task.resume()
    }
    
    func searchCatalog(searchQuery: String, completion: @escaping ([MUSSong]?) -> ()) {
        guard let formattedSearchQuery = searchQuery.addingPercentEncoding(withAllowedCharacters: .alphanumerics), let token = token else {
            completion(nil)
            return
        }
        
        let searchURL = "https://api.spotify.com/v1/search?q=\(formattedSearchQuery)&type=track&market=US&limit=10"
        
        guard let url = URL(string: searchURL) else { return }
        var request = URLRequest(url: url)
        
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,
                  let readableJSON = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] else {
                      completion(nil)
                      return
                  }
            
            let snapshot = JSONSnapshot(readableJSON)
            let items = snapshot.child("tracks").child("items")
            
            let songArray = items.children.map { item -> MUSSong in
                let id = item.child("id").val as? String
                let title = item.child("name").val as? String
                let artist = item.child("artists").children.first?.child("name").val as? String
                let album = item.child("album").child("name").val as? String
                let previewURL = item.child("preview_url").val as? String
                return MUSSong(
                    id: id ?? "0",
                    title: title ?? "unknown",
                    artist: artist ?? "unknown",
                    album: album ?? "unknown",
                    previewURL: URL(string: previewURL ?? "unknown")!
                )
            }
            
            completion(songArray)
        }
        
        task.resume()
    }

    
}

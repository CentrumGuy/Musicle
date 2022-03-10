//
//  MUSSong.swift
//  SpotifyAPI
//
//  Created by Viren Mirchandani on 3/10/22.
//

import Foundation

class MUSSong {
    
    let id: String
    let title: String
    let artist: String
    let album: String
    let previewURL: URL
    
    init (id: String, title: String, artist: String, album: String, previewURL: URL) {
        self.id = id
        self.title = title
        self.artist = artist
        self.album = album
        self.previewURL = previewURL
    }
    
}

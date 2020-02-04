//
//  Artist.swift
//  Music
//
//  Created by Rotem Peer on 01/01/2020.
//

import UIKit

struct SearchResults: Codable {
    let data: [SearchArtist]
}

struct SearchArtist: Codable {
    let id: Int
    let name: String
    let tracklist: String
    let picture_medium: String
}

struct Songs: Codable {
    let data: [Song]
}

struct Song: Codable {
    
    let title: String
    let album: Album
    let preview: String
}

struct Album: Codable {
    let title: String
    let cover_medium: String
}

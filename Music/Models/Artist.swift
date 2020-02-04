//
//  Artist.swift
//  Music
//
//  Created by Rotem Peer on 01/01/2020.
//

import UIKit

class Artist {
    
    var name: String?
    var image: UIImage?
    var songs: [Song]?
}

enum MyError: Error {
    case artistNotFound
}

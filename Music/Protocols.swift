//
//  Protocols.swift
//  Music
//
//  Created by Rotem Peer on 01/01/2020.
//

import Foundation

protocol PlaylistDelegate {
    func nextTrack(_ index: Int) -> Int
    func prevTrack(_ index: Int) -> Int
}

protocol RefreshDelegate {
    func refresh()
}

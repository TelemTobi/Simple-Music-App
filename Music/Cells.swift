//
//  Cells.swift
//  Music
//
//  Created by Rotem Peer on 01/01/2020.
//

import UIKit

class SongCell: UICollectionViewCell {
    
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    func setUpElements() {
        coverImage.layer.cornerRadius = 5
        coverImage.layer.masksToBounds = true
    }
}

class SavedSongCell: UITableViewCell {
    
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var heartButton: UIButton!
    
    var currentSong: CoreSong!
    var refreshDelegate: RefreshDelegate!
    
    func setUpElements() {
        coverImage.layer.cornerRadius = 5
        coverImage.layer.masksToBounds = true
    }
    
    @IBAction func heartTapped(_ sender: UIButton) {
        CoreDB.shared.removeSong(currentSong)
        refreshDelegate.refresh()
    }
}

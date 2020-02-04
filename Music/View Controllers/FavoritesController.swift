//
//  FavoritesController.swift
//  Music
//
//  Created by Rotem Peer on 01/01/2020.
//

import UIKit

var savedSongs = [String: CoreSong]()

class FavoritesController: UIViewController {
    
    var savedKeys: [String]!
    var playerController: PlayerController!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playerController = storyboard?.instantiateViewController(identifier: "PlayerVC")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        CoreDB.shared.fetchSavedSongs()
        savedKeys = Array(savedSongs.keys)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}


extension FavoritesController: PlaylistDelegate {
    func nextTrack(_ index: Int) -> Int {
        let index = (index == savedKeys.count - 1) ? 0 : index + 1
        playerController.coreSong = savedSongs[savedKeys[index]]
        return index
    }
    
    func prevTrack(_ index: Int) -> Int {
        let index = (index == 0) ? savedKeys.count - 1 : index - 1
        playerController.coreSong = savedSongs[savedKeys[index]]
        return index
    }
}

extension FavoritesController: RefreshDelegate {
    func refresh() {
        savedKeys = Array(savedSongs.keys)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}


extension FavoritesController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(savedKeys.count)
        return savedKeys.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SavedSongCell") as! SavedSongCell
        cell.setUpElements()
        cell.refreshDelegate = self
        
        let song = savedSongs[savedKeys[indexPath.row]]!
        cell.currentSong = song
        
        cell.titleLabel.text = song.title
        cell.artistLabel.text = song.artist_name
        cell.heartButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        
        guard let coverImage = song.cover_image else { return cell }
        MusicData.shared.downloadImage(from: coverImage, { (image) in
            cell.coverImage.image = image
        })
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        playerController.coreSong = savedSongs[savedKeys[indexPath.row]]
        playerController.index = indexPath.row
        playerController.playlistDelegate = self
        
        present(playerController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        80
    }
}

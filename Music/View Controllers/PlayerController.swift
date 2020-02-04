//
//  PlayerController.swift
//  Music
//
//  Created by Rotem Peer on 01/01/2020.
//

import UIKit
import AVKit

class PlayerController: UIViewController {
    
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var songName: UILabel!
    @IBOutlet weak var artistName: UILabel!
    
    @IBOutlet weak var heartButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    
    var artist: Artist!
    var song: Song!
    
    var coreSong: CoreSong?
    
    var player: AVPlayer!
    var isPlaying = false
    
    var playlistDelegate: PlaylistDelegate!
    var index: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpElements()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setSong()
    }
    
    @IBAction func playTapped(_ sender: UIButton) {
        if isPlaying {
            stopPlaying()
            
        } else {
            sender.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            player.play()
            isPlaying = true
        }
    }
    
    @IBAction func nextTapped(_ sender: Any) {
        index = playlistDelegate.nextTrack(index)
        stopPlaying()
        setSong()
        
    }
    
    @IBAction func prevTapped(_ sender: Any) {
        index = playlistDelegate.prevTrack(index)
        stopPlaying()
        setSong()
    }
    
    func stopPlaying() {
        playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        player.pause()
        isPlaying = false
    }
    
    @IBAction func heartTapped(_ sender: UIButton) {
        let songTitle = coreSong?.title ?? song.title
        
        if savedSongs[songTitle] != nil {
            sender.setImage(UIImage(systemName: "heart"), for: .normal)
            guard let coreSong = savedSongs[songTitle] else { return }
            CoreDB.shared.removeSong(coreSong)
            
        } else {
            sender.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            if coreSong != nil {
                CoreDB.shared.saveSong(artistName: artist.name!, core: coreSong)
            } else {
                CoreDB.shared.saveSong(song, artistName: artist.name!)
            }
        }
    }
    
    func setUpElements() {
        coverImage.layer.cornerRadius = 10
        coverImage.layer.masksToBounds = true
    }
    
    func setSong() {
        DispatchQueue.main.async {
            if savedSongs[self.coreSong?.title ?? self.song.title] != nil {
                self.heartButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            } else {
                self.heartButton.setImage(UIImage(systemName: "heart"), for: .normal)
            }
            self.coverImage.image = MusicData.shared.coversCache[self.coreSong?.cover_image ?? self.song.album.cover_medium]
            self.songName.text = self.coreSong?.title ?? self.song.title
            self.artistName.text = self.coreSong?.artist_name ?? self.artist.name
        }

        let url = URL(string: coreSong?.preview ?? song.preview)!
        player = AVPlayer(url: url)
    }
}

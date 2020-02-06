//
//  PlayerController.swift
//  Music
//
//  Created by Telem Tobi on 01/01/2020.
//

import UIKit
import AVKit

class PlayerController: UIViewController {
    
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var songName: UILabel!
    @IBOutlet weak var artistName: UILabel!
    
    @IBOutlet weak var heartButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var playerSlider: UISlider!
    
    
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    var artist: Artist!
    var song: Song!
    
    var coreSong: CoreSong?
    
    var timer: Timer?
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
        setUpTimer()
    }
    
    func setUpTimer(){
        NotificationCenter.default.addObserver(self, selector: #selector(nextTrack), name: .AVPlayerItemDidPlayToEndTime, object: nil)
        timer = Timer(timeInterval: 0.001, target: self, selector: #selector(tick), userInfo: nil, repeats: true)
        RunLoop.current.add(timer!, forMode: RunLoop.Mode.common)
    }
    
    @IBAction func sliderValueChange(_ sender: UISlider) {
        let seconds : Int64 = Int64(sender.value)
        let targetTime:CMTime = CMTimeMake(value: seconds, timescale: 1)
        player.seek(to: targetTime)
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
        nextTrack()
    }
    
    @IBAction func prevTapped(_ sender: Any) {
        prevTrack()
    }
    
    @objc func nextTrack() {
        player.pause()
        index = playlistDelegate.nextTrack(index)
        setSong()
        player.play()
    }
    
    @objc func prevTrack() {
        player.pause()
        index = playlistDelegate.prevTrack(index)
        setSong()
        player.play()
    }
    
    func stopPlaying() {
        playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        player.pause()
        isPlaying = false
    }
    
    
    @objc func tick(){
        
        if isPlaying, player.rate == 0{
            player.play()
        }
        
        if player.currentItem?.asset.duration != nil {
            guard let _ = player.currentItem?.asset.duration else { return }
            guard let _ = player.currentItem?.currentTime() else { return }
            
            let currentTime1 : CMTime = (player.currentItem?.asset.duration)!
            let seconds1 : Float64 = CMTimeGetSeconds(currentTime1)
            let time1 : Float = Float(seconds1)
            
            playerSlider.minimumValue = 0
            playerSlider.maximumValue = time1
            
            let currentTime : CMTime = player.currentTime()
            let seconds : Float64 = CMTimeGetSeconds(currentTime)
            let time : Float = Float(seconds)
            self.playerSlider.value = time
            
            timeLabel.text =  Utilities.shared.formatTimeFromSeconds(totalSeconds: Int32(Float(Float64(CMTimeGetSeconds((player.currentItem?.asset.duration)!)))))
            currentTimeLabel.text = Utilities.shared.formatTimeFromSeconds(totalSeconds: Int32(Float(Float64(CMTimeGetSeconds((player.currentItem?.currentTime())!)))))
        }else{
            playerSlider.value = 0
            playerSlider.minimumValue = 0
            playerSlider.maximumValue = 0
            timeLabel.text = Utilities.shared.formatTimeFromSeconds(totalSeconds: Int32(CMTimeGetSeconds((player.currentItem?.currentTime())!)))
        }
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
        }
        self.coverImage.image = MusicData.shared.coversCache[self.coreSong?.cover_image ?? self.song.album.cover_medium]
        self.songName.text = self.coreSong?.title ?? self.song.title
        self.artistName.text = self.coreSong?.artist_name ?? self.artist.name
    
        playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)

        let url = URL(string: coreSong?.preview ?? song.preview)!
        player = AVPlayer(url: url)
    }
}

//
//  ViewController.swift
//  Music
//
//  Created by Telem Tobi on 01/01/2020.
//

import UIKit

class SearchController: UIViewController {

    @IBOutlet weak var topStackView: UIStackView!
    @IBOutlet weak var bottomStackView: UIStackView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var artistImage: UIImageView!
    @IBOutlet weak var artistName: UILabel!
    
    @IBOutlet weak var songsCV: UICollectionView!
    
    var artist: Artist?
    var playerController: PlayerController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpElements()
        playerController = storyboard?.instantiateViewController(identifier: "PlayerVC")
    }
    
    func setUpElements() {
        topStackView.alpha = 0
        bottomStackView.alpha = 0
        artistImage.layer.cornerRadius = artistImage.frame.height / 2
        artistImage.layer.masksToBounds = true
        searchBar.tintColor = .white
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}

extension SearchController: PlaylistDelegate {
    func nextTrack(_ index: Int) -> Int {
        let index = (index == (artist?.songs?.count ?? 0) - 1) ? 0 : index + 1
        playerController.song = artist?.songs?[index]
        return index
    }
    
    func prevTrack(_ index: Int) -> Int {
        let index = (index == 0) ? ((artist?.songs?.count ?? 0) - 1) : index - 1
        playerController.song = artist?.songs?[index]
        return index
    }
}

extension SearchController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(artist?.songs?.count ?? 0)
        return artist?.songs?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SongCell", for: indexPath) as! SongCell
        cell.setUpElements()
        
        let song = artist?.songs?[indexPath.row]
        
        cell.titleLabel.text = song?.title
        if let urlString = song?.album.cover_medium {
            MusicData.shared.downloadImage(from: urlString) { (image) in
                cell.coverImage.image = image
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    
        playerController.artist = artist
        playerController.song = artist?.songs?[indexPath.item]
        playerController.index = indexPath.item
        playerController.playlistDelegate = self
        
        present(playerController, animated: true)
    }
}


extension SearchController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        guard let searchText = searchBar.text, searchText != "" else { return }
        
        MusicData.shared.artistSearch(searchText: searchText) { (artist, error) in
            if error != nil {
                DispatchQueue.main.async {
                    self.artistName.text = "Artist not found.. 🤷‍♀️"
                    self.artistImage.alpha = 0
                    self.topStackView.alpha = 1
                    self.bottomStackView.alpha = 0
                }
                
                print(error!)
                return
            }
            
            DispatchQueue.main.async {
                self.artist = artist
                self.artistImage.image = artist?.image
                self.artistName.text = artist?.name
                
                self.topStackView.alpha = 1
                self.bottomStackView.alpha = 1
                self.artistImage.alpha = 1
                
                self.songsCV.reloadData()
            }
        }
    }
}

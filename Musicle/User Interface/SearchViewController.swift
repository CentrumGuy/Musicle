//
//  SearchViewController.swift
//  Musicle
//
//  Created by Ethan Fox on 2/24/22.
//

import UIKit
import Card

class SearchViewController: UIViewController {
    
    var cardAnimator: CardAnimator?
    
    @IBOutlet weak var tableView: UITableView!
    var songs:[MUSSong] = []
    
    
    @IBOutlet weak var songsTable: UITableView!
    @IBOutlet weak var songInputTextField: UITextField!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let nib = UINib(nibName: "SongTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "SongTableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 100
        // Do any additional setup after loading the view.
        // Messing with the card styling
        cardAnimator?.pullTabEnabled = true
        cardAnimator?.cornerRadius = 16
        cardAnimator?.shouldHandleScrollViews = true
        
        songInputTextField.isEnabled = true
        self.songInputTextField.delegate = self
    }
    
    func cardAnimator(_ cardAnimator: CardAnimator, willApplyNewOffset newOffset: StickyOffset, withAnimationParameters animationParameters: inout SpringAnimationContext) {
        print("New offset is being applied:")
        print(newOffset)
        if newOffset == .init(distanceFromTop: 0) {
            print("Can edit the textfield")
            songInputTextField.isEnabled = true
        } else {
            print("Cannot edit the textfield")
            songInputTextField.isEnabled = false
            self.view.endEditing(true)
            songInputTextField.text = ""
        }
    }
    
    func search() {
        let newSongSearchString = songInputTextField.text
        
        MUSSpotifyAPI.shared.searchCatalog(searchQuery: newSongSearchString!, completion: { queriedSongs in
//            guard let queriedSongs = queriedSongs else { return }
//            self.songs = queriedSongs
//            DispatchQueue.main.async {
//                self.tableView.reloadData()
//            }
        })
        
    }
    
}


extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SongTableViewCell", for: indexPath) as! SongTableViewCell
        let currentSong = songs[indexPath.row]
        
        // Configuring cell
        cell.songTitleLabel.text = currentSong.title
        print(currentSong.id)
        cell.albumCover.backgroundColor = .red // Can there be a field for the song's album art cover
        cell.artistTitleAlbum.text = currentSong.artist + " / " + currentSong.album
        return cell
    }
    
    // Function after a user has selected a specific cell in the tableView. Will match with
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        MUSGame.userSelectedSong = songs[indexPath.row]
    }
}

extension SearchViewController: Card {
    
    func stickyOffsets(forOrientation orientation: CardAnimator.CardOrientation) -> [StickyOffset] {
        return [
            StickyOffset(percent: 0.1),
            StickyOffset(distanceFromTop: 0)
        ]
    }
    
}

extension SearchViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        search()
        return true
    }
    
}

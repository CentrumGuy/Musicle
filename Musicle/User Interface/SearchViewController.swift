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
    var numGuesses = 0
    
    
    
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
    
    func search() {
        let newSongSearchString = songInputTextField.text
        
        MUSSpotifyAPI.shared.searchCatalog(searchQuery: newSongSearchString!, completion: { queriedSongs in
            guard let queriedSongs = queriedSongs else { return }
            self.songs = queriedSongs
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        })
    }
    
    @IBAction func textFieldWasTapped(_ sender: Any) {
        
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
        currentSong.albumArt.getArtwork { image in
            cell.albumCover.image = image // Can there be a field for the song's album art cover
        }
        
        cell.artistTitleAlbum.text = currentSong.artist + " / " + currentSong.album
        return cell
    }
    
    // Function after a user has selected a specific cell in the tableView. Will match with
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedSong = songs[indexPath.row]
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let secondController = storyboard.instantiateViewController(withIdentifier: "game_over_controller") as! GameOverViewController
        
        numGuesses = numGuesses + 1
        print("guessed")
        secondController.loadViewIfNeeded()
        if selectedSong.id == MUSGame.current.dailySong?.id {
            secondController.configureViewWithCorrectInfo(correct: true, guessCount: numGuesses)
            self.navigationController?.pushViewController(secondController, animated: true)
        } else if numGuesses > 5 {
            secondController.configureViewWithCorrectInfo(correct: false, guessCount: numGuesses)
            self.navigationController?.pushViewController(secondController, animated: true)
        } else {
            let alert = UIAlertController( title: "Guess again", message: "", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
                 print("Ok button tapped")
              })
            alert.addAction(ok)
            
            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension SearchViewController: Card {
    
    func stickyOffsets(forOrientation orientation: CardAnimator.CardOrientation) -> [StickyOffset] {
        return [
            StickyOffset(distanceFromBottom: 120),
            StickyOffset(distanceFromTop: 0)
        ]
    }
    
    func cardAnimator(_ cardAnimator: CardAnimator, willApplyNewOffset newOffset: StickyOffset, withAnimationParameters animationParameters: inout SpringAnimationContext) {
        if newOffset == cardAnimator.stickyOffsets.first { songInputTextField.endEditing(true) }
    }
    
}

extension SearchViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        search()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        guard let cardAnimator = cardAnimator else { return }
        cardAnimator.setOffset(cardAnimator.stickyOffsets.last!, animated: true)
    }
    
}

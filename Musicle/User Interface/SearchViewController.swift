//
//  SearchViewController.swift
//  Musicle
//
//  Created by Ethan Fox on 2/24/22.
//

import UIKit
import Card

protocol SearchViewControllerDelegate: AnyObject {
    func didGuess(hasMoreGuesses: Bool)
}

class SearchViewController: UIViewController {
    
    var cardAnimator: CardAnimator?
    weak var delegate: SearchViewControllerDelegate?
    
    private var songs:[MUSSong] = []
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var songInputTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let nib = UINib(nibName: "SongTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "SongTableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 100
        
        // Messing with the card styling
        cardAnimator?.pullTabEnabled = true
        cardAnimator?.cornerRadius = 16
        cardAnimator?.shouldHandleScrollViews = true
        
        songInputTextField.delegate = self
    }
    
    func search() {
        let newSongSearchString = songInputTextField.text!
        
        MUSSpotifyAPI.shared.searchCatalog(searchQuery: newSongSearchString, completion: { queriedSongs in
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { songs.count }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SongTableViewCell", for: indexPath) as! SongTableViewCell
        let currentSong = songs[indexPath.row]
        cell.song = currentSong
        return cell
    }
    
    // Function after a user has selected a specific cell in the tableView. Will match with
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedSong = songs[indexPath.row]
        
        let hasMoreGuesses = MUSGame.current.didGuess(song: selectedSong)
        cardAnimator?.setOffset(cardAnimator!.stickyOffsets[0], animated: true)
        delegate?.didGuess(hasMoreGuesses: hasMoreGuesses)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension SearchViewController: Card {
    
    func stickyOffsets(forOrientation orientation: CardAnimator.CardOrientation) -> [StickyOffset] {
        return [
            StickyOffset(distanceFromBottom: 100),
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

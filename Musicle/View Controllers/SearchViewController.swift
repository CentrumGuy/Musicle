//
//  SearchViewController.swift
//  Musicle
//
//  Created by Ethan Fox on 2/24/22.
//

import UIKit
import Card

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var cardAnimator: CardAnimator?
    
    @IBOutlet weak var tableView: UITableView!
    let songs = ["a", "bunch", "of", "strings", "that", "are", "song","names"]
    
    
    @IBOutlet weak var songsTable: UITableView!
    @IBOutlet weak var songInputTextField: UITextField!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let nib = UINib(nibName: "SongTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "SongTableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
        // Do any additional setup after loading the view.
        // Messing with the card styling
        cardAnimator?.pullTabEnabled = true
        cardAnimator?.cornerRadius = 16
        cardAnimator?.shouldHandleScrollViews = true
        
        songInputTextField.isEnabled = true
    }
    
    // Table View Functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SongTableViewCell", for: indexPath) as! SongTableViewCell
        cell.textLabel?.text = songs[indexPath.row]
        
        // Figuring out how to connect the UI part to the results given from firebase
        cell.albumCover.backgroundColor = .red
        cell.songTitleLabel.text = songs[indexPath.row]
        cell.artistTitleAlbum.text = "Hello"
        return cell
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

}


extension SearchViewController: Card {
    
    func stickyOffsets(forOrientation orientation: CardAnimator.CardOrientation) -> [StickyOffset] {
        return [
            StickyOffset(percent: 0.1),
            StickyOffset(distanceFromTop: 0)
        ]
    }
    
    
}

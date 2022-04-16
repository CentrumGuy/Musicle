//
//  GameOverViewController.swift
//  Musicle
//
//  Created by Ethan Fox on 3/31/22.
//

import UIKit

class GameOverViewController: UIViewController {

    @IBOutlet weak var correctLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var songNameLabel: UILabel!
    @IBOutlet weak var CoverImageView: UIImageView!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var guessText: UILabel!
    @IBOutlet weak var shareButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [
            UIColor.systemPink.cgColor,
            UIColor.systemPurple.cgColor
        ]
        view.layer.insertSublayer(gradientLayer, at: 0)
        
        
        // Configuring Info Card
        guard let dailySong = MUSGame.current.dailySong else { return }
        
        
        artistNameLabel.text = "\(dailySong.artist) • \(dailySong.album)"
        songNameLabel.text = dailySong.title
        dailySong.albumArt.getArtwork { image in
            self.CoverImageView.image = image
        }
        
        
        
        let defaults = UserDefaults()
        defaults.set(Date(), forKey: "dateLastPlayed")
    }
    
    func configureViewWithCorrectInfo(correct: Bool, guessCount: Int) {
        if correct {
            correctLabel.text = "Correct!"
        } else {
            correctLabel.text = "Incorrect..."
        }
        if guessCount > 5 {
            guessText.text = "Come back tomorrow and try again!"
        } else {
            guessText.text = "Guesses: \(guessCount). Good job! Come back tomorrow and try again!"
        }
    }
    func bragToFriends() {
        let date = Date()
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        
        let items = ["Musicle \(dateFormatter.string(from: date)) \nGuessed in \(MUSGame.current.currentGuessCount) attempts"]
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(ac, animated: true)
    }
    @IBAction func shareButtonWasTapped(_ sender: Any) {
        bragToFriends()
    }
}

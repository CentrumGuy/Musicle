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
    @IBOutlet weak var closeButton: UIButton!
    
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
        guard let dailySong = MUSGame.dailySong else { return }
        
        
        artistNameLabel.text = "\(dailySong.artist) • \(dailySong.album)"
        songNameLabel.text = dailySong.title
        dailySong.albumArt.getArtwork { image in
            self.CoverImageView.image = image
        }
        
        
        
        let defaults = UserDefaults()
        var newPoints = defaults.integer(forKey: "points")
        newPoints = newPoints + 1
        defaults.set(newPoints, forKey: "points")
        defaults.set(Date(), forKey: "dateLastPlayed")
    }
    
//    @IBAction func closeButtonWasTapped(_ sender: Any) {
//        self.navigationController?.popToRootViewController(animated: true)
//    }
    
    func configureViewWithCorrectInfo(correct: Bool, guessCount: Int) {
        if correct {
            correctLabel.text = "Correct!"
        } else {
            correctLabel.text = "Incorrect..."
        }
        pointsLabel.text = String(MUSGame.userPoints!)
        if guessCount > 5 {
            guessText.text = "After \(guessCount) guesses, you were still unable to guess today's song... Come back tomorrow and try again!"
        } else {
            guessText.text = "Guesses: \(guessCount)"
        }
    }
    
}

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
    @IBOutlet weak var albumNameLabel: UILabel!
    @IBOutlet weak var CoverImageView: UIImageView!
    @IBOutlet weak var pointsLabel: UILabel!
    
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
        
        
        artistNameLabel.text = dailySong.artist
        songNameLabel.text = dailySong.title
        albumNameLabel.text = dailySong.album
        dailySong.albumArt.getArtwork { image in
            self.CoverImageView.image = image
        }
        pointsLabel.text = "Points: " + String(MUSGame.userPoints!)
        
        let defaults = UserDefaults()
        var newPoints = defaults.integer(forKey: "points")
        newPoints = newPoints + 1
        defaults.set(newPoints, forKey: "points")
        defaults.set(Date(), forKey: "dateLastPlayed")
    }
    
    @IBAction func closeButtonWasTapped(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func markAsCorrect(correct: Bool) {
        if correct {
            correctLabel.text = "Correct!"
        } else {
            correctLabel.text = "Incorrect..."
        }
        
    }
    
}

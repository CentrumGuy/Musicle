//
//  GameOverViewController.swift
//  Musicle
//
//  Created by Ethan Fox on 3/31/22.
//

import UIKit

class GameOverViewController: UIViewController {

    // Top bubble outlet
    @IBOutlet weak var correctLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var songNameLabel: UILabel!
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var guessText: UILabel!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var songView: UIView!
    
    // Statistics Outlets
    @IBOutlet weak var statisticsPlayedLabel: UILabel!
    @IBOutlet weak var statisticsWinPercentLabel: UILabel!
    @IBOutlet weak var statisticsCurrentStreakLabel: UILabel!
    @IBOutlet weak var statisticsMaxStreakLabel: UILabel!
    
    // Bar Graph
    @IBOutlet var barGraphConstraints: [NSLayoutConstraint]!
    @IBOutlet var barGraphGuessLabels: [UILabel]!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.isModalInPresentation = true
        
        songView.layer.shadowOffset = CGSize(width: 0, height: 4)
        songView.layer.shadowRadius = 15
        songView.layer.shadowOpacity = 0.2

        // Do any additional setup after loading the view.
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [
            UIColor.systemPink.cgColor,
            UIColor.systemPurple.cgColor
        ]
        view.layer.insertSublayer(gradientLayer, at: 0)
        
        
        // Configuring Info Card
        MUSGame.current.getDailySong { song in
            DispatchQueue.main.async {
                guard let song = song else { return }
                self.artistNameLabel.text = "\(song.artist) • \(song.album)"
                self.songNameLabel.text = song.title
                song.albumArt.getArtwork { image in
                    self.coverImageView.image = image
                }
            }
        }
        
        
        // Configuring statistics
        let game = MUSGame.current
        let stats = game.statistics
        
        switch game.gameState {
        case .win:
            correctLabel.text = "Correct!"
            guessText.text = "You identified the song in \(Int(game.previewDuration(forGuessCount: game.currentGuessCount-1))) seconds after \(game.currentGuessCount) tries! Come back tomorrow to play again!"
        case .lose:
            correctLabel.text = "Incorrect"
            guessText.text = "Today's song was \(game.dailySong!.title). Come back tomorrow to try again!"
        default: break
        }
        
        
        let percentWin = Float(stats.totalWinCount) / Float(stats.totalGameCount) * 100
        statisticsPlayedLabel.text = "\(stats.totalGameCount)"
        statisticsWinPercentLabel.text = "\(Int(percentWin.rounded()))"
        statisticsCurrentStreakLabel.text = "\(stats.currentWinStreak)"
        statisticsMaxStreakLabel.text = "\(stats.maxWinStreak)"
        
        for i in 0 ..< barGraphGuessLabels.count {
            let guessCount = stats.guessDistribution[i+1]
            barGraphGuessLabels[i].text = String(guessCount)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let stats = MUSGame.current.statistics
        let maxGuesses = max(1, stats.guessDistribution.max() ?? 0)
        for i in 0 ..< barGraphGuessLabels.count {
            let guessCount = stats.guessDistribution[i+1]
            let constraintMultiplier = max(CGFloat(guessCount)/CGFloat(maxGuesses), 0.001)
            let oldConstraint = self.barGraphConstraints[i]
            let newConstraint = oldConstraint.constraintWithMultiplier(constraintMultiplier)
            let parent = oldConstraint.secondItem as! UIView
            self.barGraphConstraints[i] = newConstraint
            UIView.animate(withDuration: 0.2, delay: TimeInterval(i)/TimeInterval(barGraphGuessLabels.count), options: .allowUserInteraction) {
                parent.removeConstraint(oldConstraint)
                parent.addConstraint(newConstraint)
                parent.layoutIfNeeded()
            }
        }
    }
    
    func bragToFriends() {
        let date = Date()
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        
        let items: [Any]
        switch MUSGame.current.gameState {
        case .win: items = ["Musicle \(dateFormatter.string(from: date))\nGuessed in \(MUSGame.current.currentGuessCount)/\(Constants.allowedNumberOfGuesses) attempts!"]
        case .lose: items = ["Musicle \(dateFormatter.string(from: date))\nCouldn't guess it today 😩"]
        default: items = []
        }
        
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(ac, animated: true)
    }
    @IBAction func shareButtonWasTapped(_ sender: Any) {
        bragToFriends()
    }
}


private extension NSLayoutConstraint {
    func constraintWithMultiplier(_ multiplier: CGFloat) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: self.firstItem!, attribute: self.firstAttribute, relatedBy: self.relation, toItem: self.secondItem, attribute: self.secondAttribute, multiplier: multiplier, constant: self.constant)
        constraint.priority = self.priority
        return constraint
    }
}

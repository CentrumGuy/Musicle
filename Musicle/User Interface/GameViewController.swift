//
//  GameViewController.swift
//  Musicle
//
//  Created by Ethan Fox on 2/24/22.
//

import UIKit
import Card
import AVFAudio

class GameViewController: UIViewController {

    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var waveView: SwiftSiriWaveformView!
    @IBOutlet weak var playPauseButton: UIButton!
    var displayLink: CADisplayLink!
    var cardAnimator: CardAnimator?
    var isPaused = false
//    let audioPlayer = try! AVAudioPlayer(contentsOf: URL(string: "https://p.scdn.co/mp3-preview/b51d0ed637d2e5cb3eb27565cce9a06f95599077")!)
    let audioPlayer = AVAudioPlayer()

    
     // TEMP AUDIO PLAYER that DOESNT WORK bc I removed the file in the final version
    
    // Frank Ocean Lost - 3GZD6HmiNUhxXYf8Gch723
    
    
    func downloadFileFromUILIfNeeded(urlString: String, completion: @escaping (URL?) -> ()) {
        guard let inputURL = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        let downloadTask = URLSession.shared.downloadTask(with:inputURL, completionHandler: { (newURL, response, error) in
            completion(newURL)
            return
        })
        
        downloadTask.resume()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("view did load")
        
        MUSFireBaseID.shared.getDailySong { songID in
            print(songID)
        }
        
        // Do any additional setup after loading the view.
        // Creating gradient background
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [
            UIColor.systemPurple.cgColor,
            UIColor.systemPink.cgColor
        ]
        view.layer.insertSublayer(gradientLayer, at: 0)
        
        // Adding transition to the card view
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let cardController = storyboard.instantiateViewController(withIdentifier: "search_view") as! SearchViewController
        self.presentCard(cardController, animated: true)
        
        // Wave View Timer
        displayLink = CADisplayLink(target: self, selector: #selector(updateWave))
        displayLink.add(to: .main, forMode: .default)
        
        
        
        // Configuring button
        playPauseButton.setTitle("Play", for: .selected)
        playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .selected)
        
        
        
    }
    
//    @objc func updateWave() {
//        guard let audioPlayer = self.audioPlayer else { return }
//
////        let smoothingValue = 0.6
//        let beforeAverage = (audioPlayer.averagePower(forChannel: 0) + audioPlayer.averagePower(forChannel: 1)) / 2
//
//        audioPlayer.updateMeters()
//
//        let average = (audioPlayer.averagePower(forChannel: 0) + audioPlayer.averagePower(forChannel: 1)) / 2
//
//        let power = 0.4 * pow(10, beforeAverage / 20) + 0.6 * pow(10, average / 20)
////        print(power)
//        waveView.amplitude = CGFloat(power)
//    }
    @objc func updateWave() {
        let power:Float
        
        if playPauseButton.isSelected {
            power = 0.0
        } else {
            let beforeAverage = (audioPlayer.averagePower(forChannel: 0) + audioPlayer.averagePower(forChannel: 1)) / 2
            
            audioPlayer.updateMeters()
            
            let average = (audioPlayer.averagePower(forChannel: 0) + audioPlayer.averagePower(forChannel: 1)) / 2
            
            power = 0.4 * pow(10, beforeAverage / 20) + 0.6 * pow(10, average / 20)
        }
        waveView.amplitude = CGFloat(power)
        
    }
    @IBAction func playPauseButtonWasPressed(_ sender: UIButton) {
        playPauseButton.isSelected.toggle()
    }
    @IBAction func rewindButtonWasPressed(_ sender: Any) {
        if playPauseButton.isSelected {
            audioPlayer.pause()
        } else {
            audioPlayer.play()
        }
    }
    
}


extension GameViewController: CardParent {
    
    func cardAnimatorWillPresentCard(_ cardAnimator: CardAnimator, withAnimationParameters animationParameters: inout SpringAnimationContext) {
        cardAnimator.pullTabEnabled = true
        cardAnimator.cornerRadius = 16
    }
}

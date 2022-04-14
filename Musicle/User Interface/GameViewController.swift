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
    var audioPlayer: AVAudioPlayer? = nil
    
     // TEMP AUDIO PLAYER that DOESNT WORK bc I removed the file in the final version
    
    // Frank Ocean Lost - 3GZD6HmiNUhxXYf8Gch723
    
    
    private func downloadFileFromURLIfNeeded(urlString: String, completion: @escaping (URL?) -> ()) {
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
        
        MUSFireBaseID.shared.getDailySong(completion: { firebase_song in
           print("Today's song is: ", firebase_song)
//            MUSSpotifyAPI.shared.getSong(songID: firebase_song!) { song in
            MUSSpotifyAPI.shared.getSong(songID: firebase_song!) { song in
                MUSGame.dailySong = song
                guard let songURL = song?.previewURL else { return }
                
                self.downloadFileFromURLIfNeeded(urlString: songURL.absoluteString) { fileURL in
                    guard let fileURL = fileURL else { return }
                    print(fileURL, " ABSOLUTE URL")
                    
                    self.audioPlayer = try? AVAudioPlayer(contentsOf: fileURL)
                    self.audioPlayer?.play()
                    print(self.audioPlayer, ": IS PLAYING A SONG")
                    self.audioPlayer?.isMeteringEnabled = true
                }
            }
        })
        
        
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

    @objc func updateWave() {
        guard let audioPlayer = audioPlayer else { return }
            
        let beforeAverage = (audioPlayer.averagePower(forChannel: 0) + audioPlayer.averagePower(forChannel: 1)) / 2
        audioPlayer.updateMeters()
        let average = (audioPlayer.averagePower(forChannel: 0) + audioPlayer.averagePower(forChannel: 1)) / 2
        let power = 0.4 * pow(10, beforeAverage / 20) + 0.6 * pow(10, average / 20)
        
        waveView.amplitude = CGFloat(power)
        
    }
    
    func audioPauserFunction() {
        let timePlayed = audioPlayer?.currentTime
        
        if timePlayed == 5 {
            audioPlayer?.pause()
        }
    }
    
    @IBAction func playPauseButtonWasPressed(_ sender: UIButton) {
        playPauseButton.isSelected.toggle()
        guard let audioPlayer = audioPlayer else { return }
        if playPauseButton.isSelected {
            audioPlayer.pause()
        } else {
            audioPlayer.play()
        }
    }
    
    @IBAction func rewindButtonWasPressed(_ sender: Any) {
        
    }
    
}


extension GameViewController: CardParent {
    
    func cardAnimatorWillPresentCard(_ cardAnimator: CardAnimator, withAnimationParameters animationParameters: inout SpringAnimationContext) {
        cardAnimator.pullTabEnabled = true
        cardAnimator.cornerRadius = 16
    }
}

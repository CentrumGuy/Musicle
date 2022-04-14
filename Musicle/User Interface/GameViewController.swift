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

    @IBOutlet private weak var pointsLabel: UILabel!
    @IBOutlet private weak var waveView: SwiftSiriWaveformView!
    @IBOutlet private weak var playPauseButton: UIButton!
    
    private let audioPlayer = MUSAudioPlayer()
    private var displayLink: CADisplayLink?
    var cardAnimator: CardAnimator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        MUSRemoteHandler.shared.getDailySong { [weak this = self] dailySong in
            this?.audioPlayer.setSong(dailySong) { _ in
                guard let this = this else { return }
                let player = this.audioPlayer
                player.playbackDeadline = 5
                player.shouldLoop = true
                player.isPlaying = true
            }
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
        
        // Configuring button
        playPauseButton.setTitle("Play", for: .selected)
        playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .selected)
    }

    @objc func updateWave() {
        let beforeAverage = audioPlayer.getPower(shouldUpdate: false)
        let average = audioPlayer.getPower(shouldUpdate: true)
        let power = 0.4 * pow(10, beforeAverage/20) + 0.6 * pow(10, average/20)
        waveView.amplitude = CGFloat(power)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        displayLink = CADisplayLink(target: self, selector: #selector(updateWave))
        displayLink?.add(to: .main, forMode: .default)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        displayLink?.invalidate()
        audioPlayer.invalidateTimer()
    }
    
    @IBAction func playPauseButtonWasPressed(_ sender: UIButton) {
        playPauseButton.isSelected.toggle()
        audioPlayer.isPlaying = !playPauseButton.isSelected
    }
    
    @IBAction func rewindButtonWasPressed(_ sender: Any) {
        audioPlayer.rewind()
    }
    
}


extension GameViewController: CardParent {
    func cardAnimatorWillPresentCard(_ cardAnimator: CardAnimator, withAnimationParameters animationParameters: inout SpringAnimationContext) {
        cardAnimator.pullTabEnabled = true
        cardAnimator.cornerRadius = 16
    }
}

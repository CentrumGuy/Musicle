//
//  GameViewController.swift
//  Musicle
//
//  Created by Ethan Fox on 2/24/22.
//

import UIKit
import Card
import AVFAudio

class GameViewController: UIViewController, TimeSliderDelegate {

    @IBOutlet private weak var waveView: SwiftSiriWaveformView!
    @IBOutlet private weak var playPauseButton: UIButton!
    @IBOutlet private weak var timeSlider: TimeSlider!
    @IBOutlet private weak var loadingView: UIActivityIndicatorView!
    @IBOutlet private weak var guessCountLabel: UILabel!
    @IBOutlet private weak var previewDurationLabel: UILabel!
    
    private let audioPlayer = MUSAudioPlayer()
    private var displayLink: CADisplayLink?
    var cardAnimator: CardAnimator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        waveView.isHidden = true
        loadingView.startAnimating()
        
        MUSGame.current.getDailySong { [weak this = self] dailySong in
            this?.audioPlayer.setSong(dailySong) { _ in
                guard let this = this else { return }
                let player = this.audioPlayer
                player.playbackDeadline = MUSGame.current.currentPreviewDuration
                player.isPlaying = true
                DispatchQueue.main.async {
                    self.loadingView.stopAnimating()
                    self.waveView.isHidden = false
                }
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
        cardController.delegate = self
        self.presentCard(cardController, animated: true)
        
        audioPlayer.delegate = self
        timeSlider.mediaDuration = MUSGame.current.currentPreviewDuration
        
        // Configuring button
        playPauseButton.setTitle("Play", for: .selected)
        playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .selected)
        
        didGuess(hasMoreGuesses: true)
        didUpdateIsPlaying(isPlaying: audioPlayer.isPlaying)
    }

    @objc func onScreenUpdate() {
        let beforeAverage = audioPlayer.getPower(shouldUpdate: false)
        let average = audioPlayer.getPower(shouldUpdate: true)
        let power = 0.4 * pow(10, beforeAverage/20) + 0.6 * pow(10, average/20)
        waveView.amplitude = CGFloat(power)
        
        let currentTime = audioPlayer.currentTime
        let progress = currentTime/MUSGame.current.currentPreviewDuration
        timeSlider.setProgress(to: progress)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        displayLink = CADisplayLink(target: self, selector: #selector(onScreenUpdate))
        displayLink?.add(to: .main, forMode: .default)
        
        timeSlider.delegate = self
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        displayLink?.invalidate()
        audioPlayer.invalidateTimer()
    }
    
    @IBAction func playPauseButtonWasPressed(_ sender: UIButton) {
        audioPlayer.isPlaying = !audioPlayer.isPlaying
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

extension GameViewController: SearchViewControllerDelegate {
    func didGuess(hasMoreGuesses: Bool) {
        if !hasMoreGuesses {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "game_over_controller") as! GameOverViewController
            present(controller, animated: true)
        }
        
        let game = MUSGame.current
        audioPlayer.playbackDeadline = game.currentPreviewDuration
        timeSlider.mediaDuration = MUSGame.current.currentPreviewDuration
        guessCountLabel.text = "\(game.currentGuessCount)/\(Constants.allowedNumberOfGuesses)"
        previewDurationLabel.text = "0:" + String(format: "%0.2d", Int(MUSGame.current.currentPreviewDuration))
    }
}

extension GameViewController: MUSAudioPlayerDelegate {
    func didUpdateIsPlaying(isPlaying: Bool) {
        DispatchQueue.main.async {
            self.playPauseButton.isSelected = !isPlaying
        }
    }
}

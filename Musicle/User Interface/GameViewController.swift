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
    @IBOutlet private weak var incorrectView: UIView!
    
    private let audioPlayer = MUSAudioPlayer()
    private var displayLink: CADisplayLink?
    var cardAnimator: CardAnimator?
    var averagePowerBefore: Float = 0
    
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
        
        didUpdateIsPlaying(isPlaying: audioPlayer.isPlaying)
        updateStats()
        
        incorrectView.alpha = 0
        incorrectView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
    }

    @objc func onScreenUpdate() {
        let average: Float = audioPlayer.isPlaying ? 1 : 0
        let weight: Float = 0.9
        let power = weight*averagePowerBefore + (1-weight)*average
        waveView.amplitude = CGFloat(power)
        averagePowerBefore = power
        
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
    
    private func updateStats() {
        let game = MUSGame.current
        audioPlayer.playbackDeadline = game.currentPreviewDuration
        timeSlider.mediaDuration = MUSGame.current.currentPreviewDuration
        guessCountLabel.text = "\(game.currentGuessCount)/\(Constants.allowedNumberOfGuesses)"
        previewDurationLabel.text = "0:" + String(format: "%0.2d", Int(MUSGame.current.currentPreviewDuration))
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
            return
        }
        
        updateStats()
        
        UIView.animate(withDuration: 0.5, delay: 0.3, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: .allowUserInteraction) {
            self.incorrectView.alpha = 1
            self.incorrectView.transform = .identity
        } completion: { _ in
            UIView.animate(withDuration: 0.2, delay: 0.8, options: .allowUserInteraction) {
                self.incorrectView.alpha = 0
                self.incorrectView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            }
        }
    }
}

extension GameViewController: MUSAudioPlayerDelegate {
    func didUpdateIsPlaying(isPlaying: Bool) {
        DispatchQueue.main.async {
            self.playPauseButton.isSelected = !isPlaying
        }
    }
}

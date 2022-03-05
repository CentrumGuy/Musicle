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
    
    let audioPlayer = try! AVAudioPlayer(contentsOf: Bundle.main.url(forResource: "Jake Chudnow - Moon Men (Instrumental)", withExtension: "mp3")!)
    var displayLink: CADisplayLink!
    var cardAnimator: CardAnimator?
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("view did load")
        
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
        
        audioPlayer.isMeteringEnabled = true
        audioPlayer.play()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @objc func updateWave() {
//        let smoothingValue = 0.6
        let beforeAverage = (audioPlayer.averagePower(forChannel: 0) + audioPlayer.averagePower(forChannel: 1)) / 2
        
        audioPlayer.updateMeters()
        
        let average = (audioPlayer.averagePower(forChannel: 0) + audioPlayer.averagePower(forChannel: 1)) / 2

        let power = 0.4 * pow(10, beforeAverage / 20) + 0.6 * pow(10, average / 20)
//        print(power)
        waveView.amplitude = CGFloat(power)
    }
}


extension GameViewController: CardParent {
    
    func cardAnimatorWillPresentCard(_ cardAnimator: CardAnimator, withAnimationParameters animationParameters: inout SpringAnimationContext) {
        cardAnimator.pullTabEnabled = true
        cardAnimator.cornerRadius = 16
    }
}

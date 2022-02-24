//
//  GameViewController.swift
//  Musicle
//
//  Created by Ethan Fox on 2/24/22.
//

import UIKit
import Card

class GameViewController: UIViewController {

    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var waveView: SwiftSiriWaveformView!
    
    var cardAnimator: CardAnimator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        // Creating gradient background
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [
            UIColor.systemPurple.cgColor,
            UIColor.systemPink.cgColor
        ]
        view.layer.insertSublayer(gradientLayer, at: 0)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let cardController = storyboard.instantiateViewController(withIdentifier: "search_view") as! SearchViewController
        self.presentCard(cardController, animated: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


extension GameViewController: CardParent {
    
    func cardAnimatorWillPresentCard(_ cardAnimator: CardAnimator, withAnimationParameters animationParameters: inout SpringAnimationContext) {
        cardAnimator.pullTabEnabled = true
        cardAnimator.cornerRadius = 16
    }
    
    func cardAnimator(_ cardAnimator: CardAnimator, willApplyNewOffset newOffset: StickyOffset, withAnimationParameters animationParameters: inout SpringAnimationContext) {
        cardAnimator.cornerRadius = 16
    }
    
}

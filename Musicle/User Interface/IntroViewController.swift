//
//  IntroViewController.swift
//  Musicle
//
//  Created by Shahar Ben-Dor on 2/17/22.
//

import UIKit

class IntroViewController: UIViewController {

    @IBOutlet weak var startGameButton: UIButton!
    @IBOutlet weak var playerTotalPoints: UILabel!
    @IBOutlet weak var onboardingTextLabel: UILabel!
    @IBOutlet weak var pointsStack: UIStackView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Adding the background Gradient
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [
            UIColor.systemPink.cgColor,
            UIColor.systemPurple.cgColor
        ]
        view.layer.insertSublayer(gradientLayer, at: 0)
        
        // Styling the points stack
        pointsStack.backgroundColor = .white.withAlphaComponent(CGFloat(0.30))
        pointsStack.layer.cornerRadius = 15
        
        
    }

    @IBAction func playGameButtonPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let secondController = storyboard.instantiateViewController(withIdentifier: "game_controller")
        self.navigationController?.pushViewController(secondController, animated: true)
    }
}

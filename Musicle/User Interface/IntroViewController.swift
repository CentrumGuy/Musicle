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
        //Placing the users current points on display
        guard let points = MUSGame.userPoints else { return }
        playerTotalPoints.text = String(points)
        onboardingTextLabel.font = .rounded(ofSize: onboardingTextLabel.font.pointSize, weight: .regular)
        
    }

    @IBAction func playGameButtonPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let secondController = storyboard.instantiateViewController(withIdentifier: "game_controller")
        self.navigationController?.pushViewController(secondController, animated: true)
    }
}

extension UIFont {
    class func rounded(ofSize size: CGFloat, weight: UIFont.Weight) -> UIFont {
        let systemFont = UIFont.systemFont(ofSize: size, weight: weight)
        let font: UIFont
        
        if let descriptor = systemFont.fontDescriptor.withDesign(.rounded) {
            font = UIFont(descriptor: descriptor, size: size)
        } else {
            font = systemFont
        }
        return font
    }
}

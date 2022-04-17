//
//  IntroViewController.swift
//  Musicle
//
//  Created by Shahar Ben-Dor on 2/17/22.
//

import UIKit

class IntroViewController: UIViewController {

    @IBOutlet weak var startGameButton: UIButton!
    @IBOutlet weak var onboardingTextLabel: UILabel!
    
    
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
        
        if !MUSGame.current.canPlay {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "game_over_controller") as! GameOverViewController
            present(controller, animated: true)
        }
        
    }

    @IBAction func playGameButtonPressed(_ sender: Any) {
        if MUSGame.current.canPlay {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let secondController = storyboard.instantiateViewController(withIdentifier: "game_controller")
            self.navigationController?.pushViewController(secondController, animated: true)
        }
    }
    

}

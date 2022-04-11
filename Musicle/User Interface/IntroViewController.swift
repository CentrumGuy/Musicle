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
        
        //Placing the users current points on display
        guard let points = MUSGame.userPoints else { return }
        playerTotalPoints.text = String(points)
        
    }

    @IBAction func playGameButtonPressed(_ sender: Any) {
        
        if MUSGame.canPlayToday! {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let secondController = storyboard.instantiateViewController(withIdentifier: "game_controller")
            self.navigationController?.pushViewController(secondController, animated: true)
        } else {
            // Display alert that user has already played today.
            var alert = UIAlertController(title: "Cannot play today's game", message: "You have already played today! Come back tomorrow", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
                 print("Ok button tapped")
              })
            alert.addAction(ok)
            
            self.present(alert, animated: true, completion: nil)
            print("Game already played today")
        }
        
    }
    
    @IBAction func unwindToIntroView(segue: UIStoryboardSegue) {}
}

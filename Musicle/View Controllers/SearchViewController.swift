//
//  SearchViewController.swift
//  Musicle
//
//  Created by Ethan Fox on 2/24/22.
//

import UIKit
import Card

class SearchViewController: UIViewController {
    
    var cardAnimator: CardAnimator?
    
    
    
    @IBOutlet weak var songsTable: UITableView!
    @IBOutlet weak var songTextInputField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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


extension SearchViewController: Card {
    
    func stickyOffsets(forOrientation orientation: CardAnimator.CardOrientation) -> [StickyOffset] {
        return [
            StickyOffset(percent: 0.1),
            StickyOffset(distanceFromTop: 0)
        ]
    }
    
    
}

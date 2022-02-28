//
//  SongTableViewCell.swift
//  Musicle
//
//  Created by Ethan Fox on 2/26/22.
//

import UIKit

class SongTableViewCell: UITableViewCell {

    @IBOutlet weak var albumCover: UIImageView!
    
    @IBOutlet weak var songTitleLabel: UILabel!
    @IBOutlet weak var artistTitleAlbum: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

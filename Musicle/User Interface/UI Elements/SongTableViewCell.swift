//
//  SongTableViewCell.swift
//  Musicle
//
//  Created by Ethan Fox on 2/26/22.
//

import UIKit

class SongTableViewCell: UITableViewCell {

    @IBOutlet private weak var albumCover: UIImageView!
    @IBOutlet private weak var songTitleLabel: UILabel!
    @IBOutlet private weak var artistTitleAlbum: UILabel!
    
    var song: MUSSong? {
        didSet {
            guard let song = song else { return }
            songTitleLabel.text = song.title
            artistTitleAlbum.text = "\(song.artist) • \(song.album)"
            song.albumArt.getArtwork { [weak oldSong = song, weak this = self] artworkImg in
                guard oldSong?.id == this?.song?.id else { return }
                this?.albumCover.image = artworkImg
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        albumCover.clipsToBounds = true
        albumCover.layer.cornerRadius = 8
    }
    
}

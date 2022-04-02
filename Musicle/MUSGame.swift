//
//  MUSGame.swift
//  Musicle
//
//  Created by Ethan Fox on 3/29/22.
//

import Foundation
// Static global class to record data like today's song ID as well as what song the user has chosen, this is needed to allow the SearchViewController and GameViewController to communicate
class MUSGame {
    static var dailySong:MUSSong?
    static var userSelectedSong:MUSSong?
}

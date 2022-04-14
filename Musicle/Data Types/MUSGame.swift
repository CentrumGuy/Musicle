//
//  MUSGame.swift
//  Musicle
//
//  Created by Ethan Fox on 3/29/22.
//

import Foundation
// Static global class to record data like today's song ID as well as what song the user has chosen, this is needed to allow the SearchViewController and GameViewController to communicate
class MUSGame {
    
    static let current = MUSGame()
    private init () {}
    
    var dailySong: MUSSong?
    var totalPoints: Int?
    
    var guessCount = 0
    
    func didGuess() {
        guessCount += 1
    }
    
    private func pointsFromGuessCount() -> Int {
        let dailyPoints: Int
        switch guessCount {
        case 1: dailyPoints = 10
        case 2: dailyPoints = 8
        case 3: dailyPoints = 6
        case 4: dailyPoints = 4
        case 5: dailyPoints = 2
        default: dailyPoints = 0
        }
        
        return dailyPoints
    }
    
    private func previewDuration(forGuess guess: Int) -> TimeInterval {
        var time: TimeInterval
        switch guess {
        case 0: time = 2
        case 1: time = 5
        case 2: time = 8
        case 3: time = 11
        case 4: time = 15
        case 5: time = 20
        default: time = 30
        }
        
        return time
    }
    
}

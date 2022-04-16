//
//  MUSStatistics.swift
//  Musicle
//
//  Created by Shahar Ben-Dor on 4/16/22.
//

import Foundation

struct MUSStatistics: Codable {
    
    var totalGameCount: Int
    var totalWinCount: Int
    var currentWinStreak: Int { didSet { _maxWinStreak = max(_maxWinStreak, currentWinStreak) } }
    var guessDistribution: [Int]
    var dateBeganPlaying: Date
   
    private var _maxWinStreak: Int
    var maxWinStreak: Int { _maxWinStreak }
    
    init() {
        totalGameCount = 0
        totalWinCount = 0
        currentWinStreak = 0
        _maxWinStreak = 0
        guessDistribution = [Int](repeating: 0, count: Constants.allowedNumberOfGuesses + 1)
        dateBeganPlaying = Date(timeIntervalSince1970: 0)
    }
    
    func toData() -> Data {
        let encoder = JSONEncoder()
        return try! encoder.encode(self)
    }
    
}

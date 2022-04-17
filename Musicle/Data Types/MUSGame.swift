//
//  MUSGame.swift
//  Musicle
//
//  Created by Ethan Fox on 3/29/22.
//

import Foundation
import FirebaseFirestore

enum MUSGameState: Int {
    case playing, win, lose
}

class MUSGame {
    static let current = MUSGame()
    
    private let database = Firestore.firestore()
    private var dailySongCompletions = [() -> ()]()
    private var loadingDailySong = false
    
    private var _dailySong: MUSSong?
    
    private var _gameState: MUSGameState {
        didSet { UserDefaults.standard.set(_gameState.rawValue, forKey: "game_state") }
    }
    
    private var _statistics: MUSStatistics {
        didSet { saveStatistics() }
    }
    
    private var _currentGuessCount: Int {
        didSet { UserDefaults.standard.set(_currentGuessCount, forKey: "current_guess_count") }
    }
    
    var dailySong: MUSSong? { _dailySong }
    var statistics: MUSStatistics { _statistics }
    var canPlay: Bool { _gameState == .playing }
    var gameState: MUSGameState { _gameState }
    var currentGuessCount: Int { _currentGuessCount }
    
    var currentPreviewDuration: TimeInterval { previewDuration(forGuessCount: _currentGuessCount) }
    
    private init () {
        let uDefaults = UserDefaults.standard
        
        // Statistics
        let decoder = JSONDecoder()
        if let statisticsData = uDefaults.object(forKey: "statistics") as? Data, let statistics = try? decoder.decode(MUSStatistics.self, from: statisticsData) {
            self._statistics = statistics
        } else { self._statistics = MUSStatistics() }
        
        // Game State
        let calendar = Calendar.current
        if !Constants.debugMode && calendar.isDate(_statistics.dateBeganPlaying, inSameDayAs: Date()) {
            _gameState = MUSGameState(rawValue: uDefaults.integer(forKey: "game_state")) ?? .playing
            _currentGuessCount = uDefaults.integer(forKey: "current_guess_count")
        } else {
            if !calendar.isDateInYesterday(_statistics.dateBeganPlaying) { _statistics.currentWinStreak = 0 }
            let oldGameState = MUSGameState(rawValue: uDefaults.integer(forKey: "game_state")) ?? .playing
            
            _gameState = .playing
            _currentGuessCount = Constants.debugMode && oldGameState == .playing ? uDefaults.integer(forKey: "current_guess_count") : 0
            _statistics.dateBeganPlaying = Date()
            saveAll()
        }
    }
    
    private func saveStatistics() {
        let statisticsData = _statistics.toData()
        UserDefaults.standard.set(statisticsData, forKey: "statistics")
    }
    
    private func saveAll() {
        saveStatistics()
        UserDefaults.standard.set(_gameState.rawValue, forKey: "game_state")
        UserDefaults.standard.set(_currentGuessCount, forKey: "current_guess_count")
    }
    
    func didGuess(song: MUSSong) -> Bool {
        if song.id == dailySong?.id {
            didGuessCorrectly()
            return false
        } else {
            return didGuessIncorrectly()
        }
    }
    
    private func didGuessIncorrectly() -> Bool {
        guard _gameState == .playing else { return false }
        
        _currentGuessCount += 1
        if _currentGuessCount < Constants.allowedNumberOfGuesses { return true }
        
        _gameState = .lose
        _statistics.totalGameCount += 1
        _statistics.currentWinStreak = 0
        return false
    }
    
    private func didGuessCorrectly() {
        guard _gameState == .playing else { return }
        
        if _currentGuessCount >= Constants.allowedNumberOfGuesses { _ = didGuessIncorrectly() }
        _currentGuessCount += 1
        _gameState = .win
        _statistics.totalGameCount += 1
        _statistics.totalWinCount += 1
        _statistics.currentWinStreak += 1
        _statistics.guessDistribution[_currentGuessCount] += 1
    }
    
    func getDailySong(completion: @escaping (MUSSong?) -> ()) {
        if let dailySong = self._dailySong {
            completion(dailySong)
            return
        } else if loadingDailySong {
            dailySongCompletions.append { [weak this = self] in completion(this?._dailySong) }
            return
        }
        
        loadingDailySong = true
        let docRef = database.document("main/daily_tracks")
        docRef.getDocument { (document, error) in
            guard let document = document, document.exists, let data = document.data() else {
                completion(nil)
                return
            }
            
            let tracks = data["tracks"] as! [String]
            
            let calendar = Calendar.current
            let fromComponents = DateComponents(calendar: nil, timeZone: nil, era: nil, year: 2000, month: 1, day: 1, hour: 0, minute: 0, second: 0, nanosecond: 0, weekday: nil, weekdayOrdinal: nil, quarter: nil, weekOfMonth: nil, weekOfYear: nil, yearForWeekOfYear: nil)
            let fromDate = calendar.date(from: fromComponents)
            let currentDate = Date()
            let numberOfDays = calendar.dateComponents([.day], from: fromDate!, to: currentDate)
            let dayNumber = Constants.debugMode && Constants.debugRandomDailySong ? Int.random(in: 0 ..< tracks.count) : (numberOfDays.day ?? 0)
            let trackID = tracks[dayNumber % tracks.count]
            
            MUSSpotifyAPI.shared.getSong(songID: trackID) { song in
                self._dailySong = song
                completion(song)
                
                self.dailySongCompletions.forEach { $0() }
                self.dailySongCompletions = []
                self.loadingDailySong = false
                
                if let song = song {
                    print("Today's song is \(song.title) with ID = \(trackID):\(song.id) and preview URL = \(song.previewURL)")
                }
            }
        }
    }
    
    func previewDuration(forGuessCount guessCount: Int) -> TimeInterval {
        let time: TimeInterval
        switch guessCount {
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

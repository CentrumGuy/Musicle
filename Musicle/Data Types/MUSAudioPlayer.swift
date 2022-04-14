//
//  MUSAudioPlayer.swift
//  Musicle
//
//  Created by Shahar Ben-Dor on 4/14/22.
//

import Foundation
import AVFAudio

class MUSAudioPlayer {
    
    private var _currentSong: MUSSong?
    private var _player: AVAudioPlayer?
    private lazy var listener: Timer = Timer.scheduledTimer(timeInterval: 0.02, target: self, selector: #selector(invokeTimer), userInfo: nil, repeats: true)
    
    var currentSong: MUSSong? { _currentSong }
    var didLoad: Bool { _player != nil }
    var playbackDeadline: TimeInterval = 0
    var shouldLoop: Bool = false
    var currentTime: TimeInterval { _player?.currentTime ?? 0 }
    
    func setSong(_ song: MUSSong?, completion: ((Bool) -> ())?) {
        _currentSong = song
        guard let song = song else {
            completion?(false)
            _player = nil
            return
        }
        
        downloadFileFromURL(url: song.previewURL) { [weak this = self] fileURL in
            guard let fileURL = fileURL else {
                this?._player = nil
                completion?(false)
                return
            }
            
            this?._player = try? AVAudioPlayer(contentsOf: fileURL)
            completion?(this?._player != nil)
        }
    }
    
    @objc private func invokeTimer() {
        guard let player = _player, player.isPlaying else { return }
        if player.currentTime >= playbackDeadline {
            if shouldLoop { player.currentTime = 0 }
            else {
                player.currentTime = 0
                player.pause()
            }
        }
    }
    
    
    
    
    
    private func downloadFileFromURL(url: URL, completion: @escaping (URL?) -> ()) {
        let downloadTask = URLSession.shared.downloadTask(with: url, completionHandler: { (newURL, response, error) in
            completion(newURL)
            return
        })
        
        downloadTask.resume()
    }
    
}

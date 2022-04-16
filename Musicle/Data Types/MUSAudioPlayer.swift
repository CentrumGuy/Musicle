//
//  MUSAudioPlayer.swift
//  Musicle
//
//  Created by Shahar Ben-Dor on 4/14/22.
//

import Foundation
import AVFAudio

protocol MUSAudioPlayerDelegate: AnyObject {
    func didUpdateIsPlaying(isPlaying: Bool)
}

class MUSAudioPlayer {
    
    private var _currentSong: MUSSong?
    private var _player: AVAudioPlayer?
    private lazy var timer: Timer = Timer.scheduledTimer(timeInterval: 0.02, target: self, selector: #selector(invokeTimer), userInfo: nil, repeats: true)
    
    weak var delegate: MUSAudioPlayerDelegate?
    
    var currentSong: MUSSong? { _currentSong }
    var didLoad: Bool { _player != nil }
    var playbackDeadline: TimeInterval = 0
    var shouldLoop: Bool = false
    var currentTime: TimeInterval { _player?.currentTime ?? 0 }
    
    var isPlaying: Bool {
        set {
            if newValue { _player?.play() }
            else { _player?.pause() }
            delegate?.didUpdateIsPlaying(isPlaying: isPlaying)
        }
        get { _player?.isPlaying ?? false }
    }
    
    init() { timer.fire() }
    
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
            this?._player?.isMeteringEnabled = true
            completion?(this?._player != nil)
        }
    }
    
    func getPower(shouldUpdate: Bool) -> Float {
        guard let player = _player else { return -160 }
        if shouldUpdate { player.updateMeters() }
        let left = player.averagePower(forChannel: 0)
        let right = player.averagePower(forChannel: 1)
        return (left+right)/2
    }
    
    func rewind() {
        _player?.currentTime = 0
    }
    
    func invalidateTimer() {
        timer.invalidate()
    }
    
    @objc private func invokeTimer() {
        guard let player = _player, player.isPlaying else { return }
        if player.currentTime >= playbackDeadline {
            if shouldLoop { player.currentTime = 0 }
            else {
                player.currentTime = 0
                player.pause()
                delegate?.didUpdateIsPlaying(isPlaying: false)
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

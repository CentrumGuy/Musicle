//
//  MUSArtwork.swift
//  Musicle
//
//  Created by Viren Mirchandani on 3/29/22.
//

import Foundation
import UIKit

class MUSArtwork {
   
    var lowQuality: UIImage?
    var mediumQuality: UIImage?
    var highQuality: UIImage?
    let lowQualityUrl: URL!
    let mediumQualityUrl: URL!
    let highQualityUrl: URL!
    
    init (lowQualityUrl: URL, mediumQualityUrl: URL, highQualityUrl: URL) {
        self.lowQualityUrl = lowQualityUrl
        self.mediumQualityUrl = mediumQualityUrl
        self.highQualityUrl = highQualityUrl
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func getArtwork(callback: @escaping (UIImage?) -> ()) {
        if let highQuality = self.highQuality {
            callback(highQuality)
            return
        }
        if let mediumQuality = self.mediumQuality {
            callback(mediumQuality)
            return
        }
        if let lowQuality = self.lowQuality {
            callback(lowQuality)
            return
        }
        getData(from: lowQualityUrl) { data, response, error in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async {
                let image = UIImage(data: data)
                self.lowQuality = image
                guard self.mediumQuality == nil && self.highQuality == nil else {
                    return
                }
                callback(image)
            }
        }
        getData(from: mediumQualityUrl) { data, response, error in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async {
                let image = UIImage(data: data)
                self.mediumQuality = image
                guard self.highQuality == nil else {
                    return
                }
                callback(image)
            }
        }
        getData(from: highQualityUrl) { data, response, error in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async {
                let image = UIImage(data: data)
                self.highQuality = image
                callback(image)
            }
        }
    }
    
}

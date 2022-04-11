//
//  AppDelegate.swift
//  Musicle
//
//  Created by Shahar Ben-Dor on 2/17/22.
//

import UIKit
import Firebase
import AVFAudio

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        MUSSpotifyAPI.shared.generateToken(clientID: "bc1a9db6ac2246ffb4d6ba5b8e52014c", clientSecret: "9485c02a32224359b3e4f047b33c27e3") {}
        
        let defaults = UserDefaults()
        
        MUSGame.userPoints = defaults.integer(forKey: "points")
        
        let testingMode = true // CHANGE THIS IF YOU WANT TESTING OR NOT
        
        if testingMode {
            MUSGame.canPlayToday = true
        } else {
            var dateLastPlayed:Date
            if defaults.object(forKey: "dateLastPlayed") == nil {
                dateLastPlayed = Date(timeIntervalSince1970: 5)
            } else {
                dateLastPlayed = defaults.object(forKey: "dateLastPlayed") as! Date
            }
            
            dateLastPlayed = Calendar.current.startOfDay(for: dateLastPlayed)
            let today = Calendar.current.startOfDay(for: Date())
            if dateLastPlayed == today {
                MUSGame.canPlayToday = false
            } else {
                MUSGame.canPlayToday = true
            }
        }
        
        
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}


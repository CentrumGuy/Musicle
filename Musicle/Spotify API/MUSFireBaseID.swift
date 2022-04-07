//
//  FireBase.swift
//  FireBaseTutorial
//
//  Created by Amit Kulkarni on 4/5/22.
//

import FirebaseFirestore
import UIKit

class MUSFireBaseID {
    static let shared = MUSFireBaseID()
    
    let database = Firestore.firestore()
    private var todaySong: String?
    
    private init() {}
    
    func getDailySong(completion: @escaping (String?) -> ()) {
        let docRef = database.document("main/daily_tracks")
        docRef.getDocument { (document, error) in
            if let document = document, document.exists, let data = document.data() {
                let calendar = Calendar.current
                let fromComponents = DateComponents(calendar: nil, timeZone: nil, era: nil, year: 2000, month: 1, day: 1, hour: 0, minute: 0, second: 0, nanosecond: 0, weekday: nil, weekdayOrdinal: nil, quarter: nil, weekOfMonth: nil, weekOfYear: nil, yearForWeekOfYear: nil)
                let fromDate = calendar.date(from: fromComponents)
                let currentDate = Date()
                let numberOfDays = calendar.dateComponents([.day], from: fromDate!, to: currentDate)
                
                
                let tracks = data["tracks"] as! [String]
//                var i = 0
//                for track in tracks {
//                    print("Track", i, track)
//                    i += 1
//                }
                
                print("The current track to choose", (numberOfDays.day ?? 0) % tracks.count)
                print(tracks[(numberOfDays.day ?? 0) % tracks.count])
                
                self.todaySong = tracks[(numberOfDays.day ?? 0) % tracks.count]
                completion(self.todaySong)
            } else {
                print("Document does not exist")
            }
            
        }
    }
}



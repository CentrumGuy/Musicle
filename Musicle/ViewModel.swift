//
//  ViewModel.swift
//  Musicle
//
//  Created by Yisu on 3/10/22.
//

import Foundation
import Firebase

class ViewModel: ObservableObject {
    
    @Published var list = [Track]()
    
    
    
    func deleteData(trackToDelete: Track) {
        //get db reference
        let db = Firestore.firestore()
        db.collection("daily_tracks").document(trackToDelete.id).delete { error in
            //check for errors
            if error == nil {
                //update UI
                DispatchQueue.main.async {
                    self.list.removeAll { track in
                        return track.id == trackToDelete.id
                    }
                }
                
            }
        }
    }
    
    func addData(name: String, artist: String, id: String) {
        let db = Firestore.firestore()
        db.collection("daily_tracks").document(id).setData(["name" : name, "artist" : artist]) { error in
            
            if error == nil {
                self.getData()
            }
            else {
                // nothing
            }
            
        }
        
        //db.collection("daily_tracks").addDocument(data: <#T##[String : Any]#>, completion: <#T##((Error?) -> Void)?##((Error?) -> Void)?##(Error?) -> Void#>)
        
    }
    
    
    
    func getData() {
        // Get the referrence of database
        let db = Firestore.firestore()
        
        //strat to fetch the dialy_tracks collection
        db.collection("daily_tracks").getDocuments { snapshot, error in
            
            //check for errors
            if error == nil {
                // No errors
                
                if let snapshot = snapshot {
                    
                    DispatchQueue.main.async {
                        self.list = snapshot.documents.map{ d in
                            // create Tracks
                            return Track(id: d.documentID,
                                         name: d["name"] as? String ?? "",
                                         artist: d["artist"] as? String ?? "")
                        }
                    }
                    
                    
                    // get one song document
                    //let docs = snapshot.documents
                    //var random = Int.random(in: 0...docs.count)
                    //return
                }
            }
            else {
                //nothing
            }
        }
    }
}


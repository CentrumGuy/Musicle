//
//  JSTools.swift
//  Aux Plz
//
//  Created by Shahar Ben-Dor on 12/12/18.
//  Copyright © 2018 Spectre. All rights reserved.
//

import Foundation
import WebKit

class JSTools {
    class func parse(jsonData: Any) -> JSONSnapshot {
        return JSONSnapshot(convertToDictionary(text: String(describing: jsonData)))
    }
    
    private class func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        
        return nil
    }
}

class JSONSnapshot: CustomStringConvertible {
    var description: String {
        return "\(val ?? "nil")"
    }
    
    private let data: Any?
    var key: String?
    var val: Any? {
        get {
            return data
        }
    }
    
    var children: [JSONSnapshot] {
        var toReturn = [JSONSnapshot]()
        if let data = data as? [[String: Any]] {
            for child in data {
                let snapshot = JSONSnapshot(child)
                toReturn.append(snapshot)
            }
        }
        
        return toReturn
    }
    
    init (_ data: Any?) {
        self.data = data
    }
    
    func child(_ key: String) -> JSONSnapshot {
        if let data = data as? [String: Any?], let dataToReturn = data[key] as Any? {
            let snapshot = JSONSnapshot(dataToReturn)
            snapshot.key = key
            return snapshot
        }
        
        let snapshot = JSONSnapshot(nil)
        snapshot.key = key
        return snapshot
    }
    
    func exists() -> Bool {
        return !(val == nil || String(describing: val) == "Optional(nil)" || String(describing: val) == "Optional(Optional(<null>))")
    }
}

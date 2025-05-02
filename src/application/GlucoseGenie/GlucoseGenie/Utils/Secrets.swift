//
//  Secrets.swift
//  GlucoseGenie
//
//  Created by Hristova,Krisi on 4/3/25.
//

import Foundation

struct Secrets {
    static var appId: String {
        return getValue(forKey: "APP_ID")
    }
    
    static var appKey: String {
        return getValue(forKey: "APP_KEY")
    }
    
    private static func getValue(forKey key: String) -> String {
        guard let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: path),
              let value = plist[key] as? String else {
            fatalError("Missing \(key) in Secrets.plist")
        }
        return value
    }
}

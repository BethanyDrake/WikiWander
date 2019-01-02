//
//  KnownWord.swift
//  WikiWander
//
//  Created by Bethany Anne Drake on 20/12/18.
//  Copyright © 2018 WordWatch. All rights reserved.
//

import Foundation

class KnownWord: NSObject, NSCoding{
    func encode(with aCoder: NSCoder) {
        aCoder.encode(word, forKey: "word")
        aCoder.encode(pronounciation, forKey: "pronounciation")
        aCoder.encode(definition, forKey: "definition")
        aCoder.encode(timesSeen, forKey: "timesSeen")
        aCoder.encode(lastSeenTime, forKey: "lastSeenTime")
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let word = aDecoder.decodeObject(forKey: "word") as! String
        let pronounciation = aDecoder.decodeObject(forKey: "pronounciation") as! String
        let definition = aDecoder.decodeObject(forKey: "definition") as! String
        let timesSeen = aDecoder.decodeInteger(forKey: "timesSeen")
        let lastSeenTime = aDecoder.decodeDouble(forKey: "lastSeenTime") as TimeInterval
        self.init(word: word, pronounciation: pronounciation, definition: definition, timesSeen:timesSeen, lastSeenTime:lastSeenTime)
    
    }
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("knownWords")
    
    var word:String
    var pronounciation:String
    //var tapCount = 1
    //var familiarty = 0
    var definition:String
    var timesSeen:Int
    var lastSeenTime:TimeInterval

    
    init(word: String, pronounciation:String, definition:String, timesSeen:Int = 1, lastSeenTime:TimeInterval? = nil) {
        print("initialising! time last seen = ", lastSeenTime ?? -2)
        self.word = word
        self.pronounciation = pronounciation
        self.definition = definition
        self.timesSeen = timesSeen
        
        self.lastSeenTime = lastSeenTime ?? Date().timeIntervalSince1970
        
        
    }
}

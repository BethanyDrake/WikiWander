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
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let word = aDecoder.decodeObject(forKey: "word") as! String
        let pronounciation = aDecoder.decodeObject(forKey: "pronounciation") as! String
        let definition = aDecoder.decodeObject(forKey: "definition") as! String
        self.init(word: word, pronounciation: pronounciation, definition: definition)
    
    }
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("knownWords")
    
    var word:String
    var pronounciation:String
    //var tapCount = 1
    //var familiarty = 0
    var definition:String
    
    init(word: String, pronounciation:String, definition:String) {
        self.word = word
        self.pronounciation = pronounciation
        self.definition = definition
    }
}

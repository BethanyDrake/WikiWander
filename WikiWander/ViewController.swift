//
//  ViewController.swift
//  WikiWander
//
//  Created by Bethany Anne Drake on 13/12/18.
//  Copyright © 2018 WordWatch. All rights reserved.
//

import UIKit
import Foundation

class ViewController: UIViewController, URLSessionTaskDelegate {

    @IBOutlet weak var articleTextBox: UITextView!
    @IBOutlet weak var wordTextBox: UITextView!
    @IBOutlet weak var definitionTextBox: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        
        articleTextBox.addGestureRecognizer(tap)
        
        articleTextBox.isUserInteractionEnabled = true
        
        self.view.addSubview(articleTextBox)
        
    }
    
    func selectCharacter (_ sender: UITapGestureRecognizer) {
        let loc = sender.location(in: articleTextBox)
        //print("touch loc: ", loc)
        
        let i = articleTextBox.closestPosition(to: loc)
        if let i = i {
          //  print("A")
            let realPos = articleTextBox.position(from: i, offset: -1) ?? articleTextBox.beginningOfDocument
            //print("B")
            let range = articleTextBox.textRange(from: realPos, to: articleTextBox.endOfDocument)
            //print(" C")
            if range === nil { return }
            //print("D")
           // let closestChar = articleTextBox.text(in:range!)
            //print("E")
            //print(closestChar ?? "no char found")
            let location = (articleTextBox as UITextInput).offset(from: articleTextBox.beginningOfDocument, to: i)
            //print("F")
            let nsRange = NSRange(location: location, length: 1)
            //print("G")
            if let selectedRange = selectedRange{
                if (selectedRange.lowerBound < 0 || selectedRange.upperBound > articleTextBox.text.count){
                    
                    print ("old selected range out of bounds")
                }else{
                   articleTextBox.textStorage.addAttribute(.backgroundColor, value: UIColor.white, range: selectedRange)
                }
                
            }
            
            //print("H")
            if (nsRange.lowerBound < 0 || nsRange.upperBound > articleTextBox.text.count){
                print ("out of bounds")
                return
            }
            articleTextBox.textStorage.addAttribute(.backgroundColor, value: UIColor.lightGray, range: nsRange)
           // print("I")
            selectedRange = nsRange
            //print("J")
        }
    }
    
    
    var selectedRange: NSRange!
    
    // function which is triggered when handleTap is called
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        let startTime = NSDate().timeIntervalSince1970
        
        
        print("A", NSDate().timeIntervalSince1970 - startTime)
        selectCharacter(sender)
        print("B", NSDate().timeIntervalSince1970 - startTime)
        lookUpSelectedText()
        print("C", NSDate().timeIntervalSince1970 - startTime)
        
        
    }
    
    struct Definition {
        var word: String
        var pronounciation: String
        var definition: String
    }
    
    var definitions:[Definition] = []
    
    func lookUpSelectedText() {
        print("looking up selected text")
        let d = getDictionary()
        print("dictionary has \(d) entries")
        
        var wordToLookUp:String? = nil
        var index:String.Index? = nil
        var touchedChar:Character? = nil
        if let selectedRange = selectedRange, let range = Range(selectedRange, in: articleTextBox.text){
            if (selectedRange.lowerBound < 0 || selectedRange.upperBound > articleTextBox.text.count){
                print ("old selected range out of bounds")
            }else{
                
                index = range.lowerBound
                touchedChar = articleTextBox.text[index!]
                wordToLookUp = String(articleTextBox.text[range])
                print("word", wordToLookUp ?? "")
            }
        }
        
        
        
        
        
        if var possibleWords = charToWords[touchedChar ?? " "], let touchedChar = touchedChar, let index = index{
            possibleWords = possibleWords.filter { (word) -> Bool in
                let posOfCharInWord = word.firstIndex(of: touchedChar)!
                let textStart = articleTextBox.text.prefix(upTo: index)
                let textEnd = articleTextBox.text.suffix(from: index)
                let wordStart = word.prefix(upTo: posOfCharInWord)
                let wordEnd = word.suffix(from: posOfCharInWord)
                
                return (textStart.hasSuffix(wordStart) && textEnd.hasPrefix(wordEnd))
            }
            print("possible words", possibleWords)
            definitions = []
            
            for word in possibleWords{
                if let definitionsForWord = wordToDefinitions[word]{
                    for definition in definitionsForWord{
                        definitions.append(Definition(word:word, pronounciation: "bah", definition:definition))
                    }
                }
            }
            print("Definitions:", definitions)
            print("num Definitions:", definitions.count)
        }
    
        
        
        if let word = wordToLookUp, let definitions = wordToDefinitions[word] {
            wordTextBox.text = word
            definitionTextBox.text = definitions.joined(separator: "\n")
            print(definitions)
        }else{
            print("no value found")
        }
        

    }
    
    
    // Convert the number in the string to the corresponding
    // Unicode character, e.g.
    //    decodeNumeric("64", 10)   --> "@"
    //    decodeNumeric("20ac", 16) --> "€"
    func decodeNumeric(string : String, base : Int32) -> Character? {
        let code = UInt32(strtoul(string, nil, base))
        
        if let c = UnicodeScalar(code){
            return Character(c)
        }
        return "~"
        
    }
    
    
    func nextInt(text:String)->String{
        if let index = text.firstIndex(of:";"){
            let result = text.prefix(upTo: index)
            return String(result)
        }
        return ""
    }
    
    func getMainLable(tag:String)->String{
        if let index = tag.firstIndex(of:" "){
            let result = tag.prefix(upTo: index)
            return String(result)
        }
        return tag
    }
    func getToNextSpecialChar(text:String, specialChars:String)->String.SubSequence{
        
        var i = text.startIndex
        while (i < text.endIndex && !specialChars.contains(text[i])) {
            i = text.index(after: i)
        }
        return text.prefix(upTo: i)
    }
    
    var dictionary:[String:String] = [:]
    var charToWords:[Character:[String]] = [:]
    var wordToDefinitions:[String:[String]] = [:]
    var wordToPronunciation:[String:String] = [:]
    var gotDictionary = false
    func getDictionary()->Int {
        if gotDictionary {
            return 0
        }
        //at this point, just read the dictionary and return the number of entries.
        if let path = Bundle.main.path(forResource: "cc-cedict", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let json = try? JSONSerialization.jsonObject(with: data, options: [])
                
                if let array = json as? [Any] {
                    var count = 0
                    for entry in array {
                        if let entry = entry as? [String:Any]{
                            if let word:String = entry["s"] as? String {
                                //for each character in that word, add it
                                for c in word {
                                    charToWords[c] = (charToWords[c] ?? []) + [word]
                                    
                                }
                                if let values:[String] = entry["d"] as? [String]{
                                    let value = values.first
                                    dictionary[word] = value
                                    wordToDefinitions[word] = values
                                    if count < 10 {
                                        print(wordToDefinitions)
                                        count += 1
                                }
                                
                                
                                }
                            }else{
                                if count < 10 {
                                    print ("couldn't find the key 's'")
                                    count += 1
                                }
                                
                            }
                        }else {
                            if count < 10 {
                                print ("couldn't convert to dictionary")
                                count+=1
                            }
                            
                        }
                        
                    }
                    gotDictionary = true
                    return array.count
                }
                else {
                    return 0
                }
                
                
            } catch {
                return 0
            }
            
        }
        return 0
    }
    
    
    func getArticalContent(text: String)->String {
        //first off, lets just get the <p>s. Then we can add headings.
        let startTime = NSDate().timeIntervalSince1970
        print("starting to getArticalContent")
        var plainText = ""
        
        var toRead = text
        
        var tags = [""]
        
        let followWithBreak = ["h1", "h2"]
        
        while (toRead.count > 0) {
            //let loopStart = NSDate().timeIntervalSince1970
            if toRead.prefix(2) == "</" {
                //then we gotta see if we can close the last open tag
                toRead = String(toRead.dropFirst(2))
                if let idx = toRead.firstIndex(of:">") {
                    
                    let closingTag = String(toRead.prefix(upTo: idx))
                    toRead = String(toRead.dropFirst(closingTag.count + 1))
                    //we only want upto the first space, if there is one.
                    let header = getMainLable(tag: closingTag)
                    if tags.last == header {
                        tags.removeLast()
                        if header == "p" {
                            plainText += "\n"
                            //print("para break")
                        }
                        if followWithBreak.contains(header){
                            plainText += "\n"
                            //print("add break for: " + header)
                        }
                        
                    }
                    
                }
                continue
            }
           if toRead.prefix(1) == "<" {
                //then see if we can open a new tag
                toRead = String(toRead.dropFirst(1))
                if let idx = toRead.firstIndex(of:">") {
                    let openingTag = String(toRead.prefix(upTo: idx))
                    
                    let header = getMainLable(tag: openingTag)
                    toRead = String(toRead.dropFirst(openingTag.count + 1))
                    if openingTag.last == "/" {
                        
                        continue
                    }
                    tags.append(header)
                    
                }
                continue
                
            }
            
            
            let toInclude = ["p", "a", "b", "i", "h1", "h2", "h3", "span"]
            
            if (tags.contains("p") || tags.contains("h2") || tags.contains("h1")) && !tags.contains("sup")  {
                if let lastTag = tags.last {
                    if toInclude.contains(lastTag) {
                        
                        //print("appending!")
                        if toRead.prefix(2) == "&#" {
                            toRead = String(toRead.dropFirst(2))
                            let nextIntString = nextInt(text: toRead)
                            toRead = String(toRead.dropFirst(nextIntString.count+1))
                            if let actualChar = decodeNumeric(string: nextIntString, base: 10) {
                                plainText += String(actualChar)
                            }
                            //print("loop end: D", NSDate().timeIntervalSince1970 - loopStart)
                            continue
                        }
                        let nextChunk = getToNextSpecialChar(text: toRead, specialChars: "<>&")
                        if (nextChunk.count < 1) {
                            plainText += toRead.prefix(1)
                            toRead = String(toRead.dropFirst(1))
                            continue
                        }
                        plainText += nextChunk
                        toRead = String(toRead.dropFirst(nextChunk.count))
                        continue
                        
                    }
                }
                
                
            }
            
            let nextChunk = getToNextSpecialChar(text: toRead, specialChars: "<>&")
            if (nextChunk.count < 1) {
                //print("loop end: H", NSDate().timeIntervalSince1970 - loopStart)
                toRead = String(toRead.dropFirst(1))
                continue
            }
            toRead = String(toRead.dropFirst(nextChunk.count))
            //print("loop end: E", NSDate().timeIntervalSince1970 - loopStart)
        }
        
        print("done gettingArticalContent", NSDate().timeIntervalSince1970 - startTime)
        
        return plainText
    }

    
    let longArticalUrl = URL(string: "https://zh.wikipedia.org/wiki/%E6%B3%A2%E5%85%B0%E8%AF%AD")!
    @IBAction func nextButton(_ sender: UIButton) {
        articleTextBox.text = "loading..."
        let startTime = NSDate().timeIntervalSince1970
        
        //let url = longArticalUrl
        let url = URL(string: "https://zh.wikipedia.org/zh-cn/Special:Random")!
        let task = URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            guard let data = data else { return }
            
            let text = String(data: data, encoding: .utf8)!
            print("got Data", NSDate().timeIntervalSince1970 - startTime)
            
            let articalContent = self.getArticalContent(text: text)
            
            
            
            DispatchQueue.main.async {
                self.articleTextBox.text = articalContent
            }
            //print(articalContent)
            print("finished")
            print("finished whole thing", NSDate().timeIntervalSince1970 - startTime)
        }
        
        task.resume()
        
        
    
    }
    
}


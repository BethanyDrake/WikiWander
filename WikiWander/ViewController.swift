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
//    @IBOutlet weak var wordTextBox: UITextView!
   
    @IBOutlet weak var colorIndicator: UIButton!
    @IBOutlet weak var definitionTextBox: UITextField!
    @IBOutlet weak var characterTextBox: UITextField!
    @IBAction func colorButton(_ sender: UIButton) {
        print("button clicked!")
        let currWord = knownWordsDictionary[definitions[currentDefinition].word]
        currWord?.familiarity = (currWord!.familiarity + 1)%3
        colorIndicator.backgroundColor =  familiarityToColor[currWord?.familiarity ?? -1]
        
     
    }
    
    let familiarityToColor:[Int:UIColor] = [
        -1:UIColor(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 1.0),
        0:UIColor(red: 255/255.0, green: 0/255.0, blue: 0/255.0, alpha: 1.0),
        1:UIColor(red: 255/255.0, green: 255/255.0, blue: 0/255.0, alpha: 1.0),
        2:UIColor(red: 0/255.0, green: 255/255.0, blue: 0/255.0, alpha: 1.0)
    ]
    
    let TAB = "    "
    
    override func viewWillAppear(_ animated: Bool) {
        knownWords = loadKnownWords() ?? []
        knownWordsDictionary = convertKnownwordsToDictionary(words:knownWords)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        saveKnownWords()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        
        articleTextBox.addGestureRecognizer(tap)
        
        articleTextBox.isUserInteractionEnabled = true
        
        self.view.addSubview(articleTextBox)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.nextDefinition(_:)))
        swipeRight.direction = UISwipeGestureRecognizer.Direction.right
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.previousDefinition(_:)))
        swipeRight.direction = UISwipeGestureRecognizer.Direction.left
    
//
        definitionTextBox.addGestureRecognizer(swipeRight)
        definitionTextBox.addGestureRecognizer(swipeLeft)
        
//
        definitionTextBox.isUserInteractionEnabled = true
//
        self.view.addSubview(definitionTextBox)
        definitionTextBox.delegate = plainTextFieldDelegate
        characterTextBox.delegate = plainTextFieldDelegate
        //knownWords = []
        //knownWords = loadKnownWords() ?? []
        //knownWordsDictionary = convertKnownwordsToDictionary(words:knownWords)
        
    }
    var knownWordsDictionary:[String:KnownWord]  = [:]
    let plainTextFieldDelegate = PlainTextFieldDelegate()
    
    class PlainTextFieldDelegate : UIViewController, UITextFieldDelegate {
        func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool{
            return false
        }
        
    }
    
    func convertKnownwordsToDictionary(words:[KnownWord])->[String:KnownWord]{
        var knownWordsDictionary:[String:KnownWord] = [:]
        for word in words {
            if knownWordsDictionary[word.word] != nil {
                print ("already there, uh oh")
            }
            else {
                print ("adding " + word.word + " to knownWordsDictionary (" + String(knownWordsDictionary.count) + ")")
                knownWordsDictionary[word.word] = word
            }
        }
        return knownWordsDictionary
    }
    
    func incrementTaps(word: String){
        if knownWordsDictionary[word] != nil {
            knownWordsDictionary[word]?.timesSeen += 1
        }
        else {
            print("havent seen that one yet, but don't worry, you will." )
        }
    }
    
    
    func addOrUpdateKnownWord(word: String, pronounciation: String, definition: String){
        if knownWordsDictionary[word] != nil {
            print ("updating " + word + " in knownWordsDictionary (" + String(knownWordsDictionary.count) + ")")
            let entry = knownWordsDictionary[word]
            entry?.timesSeen += 1
            entry?.lastSeenTime = Date().timeIntervalSince1970
            
            
            
            
        }
        else {
            print ("adding " + word + " to knownWordsDictionary (" + String(knownWordsDictionary.count) + ")")
            knownWordsDictionary[word] = KnownWord(word: word, pronounciation: pronounciation, definition: definition)
        }
        
    }
    

    

    
    var currentDefinition = 0;
    fileprivate func updateDefinition() {
        print("updating definition")
        let newDefinition = definitions[currentDefinition]
        definitionTextBox.text = definitions[currentDefinition].definition
        characterTextBox.text = definitions[currentDefinition].word + TAB + definitions[currentDefinition].pronounciation
        selectRange(newRange: NSRange(location: definitions[currentDefinition].startIndex.encodedOffset, length: definitions[currentDefinition].word.count))
        addOrUpdateKnownWord(word: newDefinition.word, pronounciation: newDefinition.pronounciation, definition: newDefinition.definition)
        let currWord = knownWordsDictionary[definitions[currentDefinition].word]
        colorIndicator.backgroundColor =  familiarityToColor[currWord?.familiarity ?? -1]
//        knownWords += [KnownWord(word: newDefinition.word, pronounciation: newDefinition.pronounciation, definition: newDefinition.definition)]
        saveKnownWords()
    }
    
    @objc func nextDefinition(_ sender: UISwipeGestureRecognizer) {
        print("swiped right!", sender)
        if definitions.count == 0 {
            print("no more definitions")
            return
        }
        currentDefinition = (currentDefinition + 1) % definitions.count
        updateDefinition()
        
        
    }
    @objc func previousDefinition(_ sender: UISwipeGestureRecognizer) {
        print("swiped left!", sender)
        if definitions.count == 0 {
            print("no more definitions")
            return
        }
        currentDefinition = (currentDefinition - 1 + definitions.count) % definitions.count
        updateDefinition()
        
        
    }
    
    
    func selectRange(newRange: NSRange){
        print("updating selected range", newRange)
        articleTextBox.textStorage.addAttribute(.backgroundColor, value: UIColor.white, range: selectedRange)
        articleTextBox.textStorage.addAttribute(.backgroundColor, value: UIColor.lightGray, range: newRange)
        selectedRange = newRange
    }
    
    
    func selectCharacter (_ sender: UITapGestureRecognizer) {
        let loc = sender.location(in: articleTextBox)
        let i = articleTextBox.closestPosition(to: loc)
        if let i = i {
            let realPos = articleTextBox.position(from: i, offset: -1) ?? articleTextBox.beginningOfDocument
            let range = articleTextBox.textRange(from: realPos, to: articleTextBox.endOfDocument)
            if range === nil { return }
            let location = (articleTextBox as UITextInput).offset(from: articleTextBox.beginningOfDocument, to: i)
            let nsRange = NSRange(location: location, length: 1)
            if let selectedRange = selectedRange{
                if (selectedRange.lowerBound < 0 || selectedRange.upperBound > articleTextBox.text.count){
                    
                    print ("old selected range out of bounds")
                }else{
                   articleTextBox.textStorage.addAttribute(.backgroundColor, value: UIColor.white, range: selectedRange)
                }
            }
            
            if (nsRange.lowerBound < 0 || nsRange.upperBound > articleTextBox.text.count){
                print ("out of bounds")
                return
            }
            articleTextBox.textStorage.addAttribute(.backgroundColor, value: UIColor.lightGray, range: nsRange)
            selectedRange = nsRange
        }
    }
    
    
    var selectedRange: NSRange!
    
    // function which is triggered when handleTap is called
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        selectCharacter(sender)
        lookUpSelectedText()
    }
    
    
    struct Definition {
        var word: String
        var pronounciation: String
        var definition: String
        var startIndex: String.Index
        
        static func ==(lhs: Definition, rhs: Definition) -> Bool {
            return (
                lhs.word == rhs.word &&
                lhs.pronounciation == rhs.pronounciation &&
                lhs.definition == rhs.definition)
        }
    }
    
    var definitions:[Definition] = []
    
    fileprivate func unique(array: [Definition]) -> [Definition] {
        var uniqueItems:[Definition] = []
        for item in array {
            var unique = true
            for u in uniqueItems {
                if u == item {
                    unique = false
                    break
                }
            }
            if unique
            {
                uniqueItems.append(item)
            }
        }
        return uniqueItems
    }
    
    func lookUpSelectedText() {
        getDictionary()

        
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
                incrementTaps(word:word)
                if let definitionsForWord = wordToDefinitions[word]{
                    for definition in definitionsForWord{
                        let posOfCharInWord = word.firstIndex(of: touchedChar)!
                        let textStart = articleTextBox.text.prefix(upTo: index)
                        let wordStart = word.prefix(upTo: posOfCharInWord)
                        
                        let posOfWordInChar = textStart.index(index, offsetBy: -1 * wordStart.count)
                            //textStart.prefix(textStart.count-wordStart.count).endIndex
                        let newDefinition = Definition(word:word, pronounciation: wordToPronunciation[word] ?? "", definition:definition, startIndex: posOfWordInChar)
                        definitions.append(newDefinition)
                        
                    }
                }
            }
            print("num Definitions:", definitions.count)
        }
        
        definitions.sort(by: {$0.word.count > $1.word.count})
      
        print("num before remove dupes", definitions.count)
        
        definitions = unique(array: definitions)
        
        //definitions = Array(NSOrderedSet(array: definitions)) as! [ViewController.Definition]
        print("num after remove dupes", definitions.count)
        
        if definitions.count > 0 {
            currentDefinition = 0
            definitionTextBox.text = definitions[currentDefinition].definition
            updateDefinition()
            
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
    func getDictionary()->Void {
        if gotDictionary {
            return
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
                                if let values:[String] = entry["d"] as? [String], let pronounciation:String = entry["p"] as? String{
                                    let value = values.first
                                    dictionary[word] = value
                                    wordToDefinitions[word] = values
                                    wordToPronunciation[word] = pronounciation
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
                    return
                }
                else {
                    return
                }
                
                
            } catch {
                return
            }
            
        }
        return
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

    
    
    let oilPaintingUrl = URL(string: "https://zh.wikipedia.org/wiki/%E6%B2%B9%E7%94%BB")!
    let longArticalUrl = URL(string: "https://zh.wikipedia.org/wiki/%E6%B3%A2%E5%85%B0%E8%AF%AD")!
    @IBAction func nextButton(_ sender: UIButton) {
        articleTextBox.text = "loading..."
        let startTime = NSDate().timeIntervalSince1970
        
        let url = oilPaintingUrl
        //let url = longArticalUrl
        //let url = URL(string: "https://zh.wikipedia.org/zh-cn/Special:Random")!
        let task = URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            guard let data = data else { return }
            
            let text = String(data: data, encoding: .utf8)!
            print("got Data", NSDate().timeIntervalSince1970 - startTime)
            
            let articalContent = self.getArticalContent(text: text)
            
            
           
            let nsText = articalContent as NSString
            var textRange = NSMakeRange(0, nsText.length)
            let attributedString = NSMutableAttributedString(string:articalContent)
            
            let range1 = nsText.range(of:"画", range:textRange)
            textRange = NSMakeRange(range1.upperBound, nsText.length - range1.upperBound)
            print(textRange)
//
            let range2 = nsText.range(of: "画", range: textRange)
//
            
            
            attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.red, range: range1)
            attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.blue, range: range2)
            DispatchQueue.main.async {
                //self.articleTextBox.text = articalContent
                self.articleTextBox.attributedText = attributedString
            }
            //print(articalContent)
            print("finished")
            print("finished whole thing", NSDate().timeIntervalSince1970 - startTime)
        }
        
        task.resume()
    }
    

    
    var knownWords = [KnownWord]()
    
    private func addToKnowWords(word:String){
        knownWords += [KnownWord(word: word, pronounciation: "wooo!", definition: "hey!")]
        
    }
    
    private func saveKnownWords() {
        print("saving known words...")
        
        knownWords = Array(knownWordsDictionary.values)
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(knownWords, toFile: KnownWord.ArchiveURL.path)
        print("saved =", isSuccessfulSave)
    }
    private func loadKnownWords() -> [KnownWord]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: KnownWord.ArchiveURL.path) as? [KnownWord]
    }
    
}


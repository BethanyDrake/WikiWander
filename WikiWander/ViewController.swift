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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        
        articleTextBox.addGestureRecognizer(tap)
        
        articleTextBox.isUserInteractionEnabled = true
        
        self.view.addSubview(articleTextBox)
        
    }
    
    func doStuff (_ sender: UITapGestureRecognizer) throws {
        let loc = sender.location(in: articleTextBox)
        print("touch loc: ", loc)
        
        let i = articleTextBox.closestPosition(to: loc)
        if let i = i {
            print("A")
            let realPos = articleTextBox.position(from: i, offset: -1) ?? articleTextBox.beginningOfDocument
            print("B")
            let range = articleTextBox.textRange(from: realPos, to: articleTextBox.endOfDocument)
            print(" C")
            if range === nil { return }
            print("D")
            let closestChar = articleTextBox.text(in:range!)
            print("E")
            print(closestChar ?? "no char found")
            let location = (articleTextBox as UITextInput).offset(from: articleTextBox.beginningOfDocument, to: i)
            print("F")
            let nsRange = NSRange(location: location, length: 1)
            print("G")
            if let selectedRange = selectedRange{
                articleTextBox.textStorage.addAttribute(.backgroundColor, value: UIColor.white, range: selectedRange)
            }
            print("H")
            if (nsRange.lowerBound < 0 || nsRange.upperBound > articleTextBox.text.count){
                print ("out of bounds")
                return
            }
            articleTextBox.textStorage.addAttribute(.backgroundColor, value: UIColor.lightGray, range: nsRange)
            print("I")
            selectedRange = nsRange
            print("J")
        }
    }
    
    
    var selectedRange: NSRange!
    
    // function which is triggered when handleTap is called
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        
        do {
            try doStuff(sender)
        }
        catch{
            print(error)
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
        //get up to the first space, if there is one
        var toRead = text
        var result = ""
        while (toRead.count > 0) {
            if toRead.prefix(1) == ";"{
                return result
            }
            result += toRead.prefix(1)
            toRead = String(toRead.dropFirst())
        }
        
        return result
        
        
    }
    
    func getMainLable(tag:String)->String{
        //get up to the first space, if there is one
        var toRead = tag
        var result = ""
        while (toRead.count > 0) {
            if toRead.prefix(1) == " "{
                return result
            }
            result += toRead.prefix(1)
            toRead = String(toRead.dropFirst())
        }
        
        return result
        
        
    }
    
    func getDictionary()->Int {
        //at this point, just read the dictionary and return the number of entries.
        if let path = Bundle.main.path(forResource: "cc-cedict", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let json = try? JSONSerialization.jsonObject(with: data, options: [])
                
                if let array = json as? [Any] {
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
  
        var plainText = ""
        
        var toRead = text
        
        var tags = [""]
        
        let followWithBreak = ["h1", "h2"]
        
        while (toRead.count > 0) {
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
                            print("para break")
                        }
                        if followWithBreak.contains(header){
                            plainText += "\n"
                            print("add break for: " + header)
                        }
                        
                    }
                    print("dropped tag: " + closingTag + " (" + header + ")")
                    //print(tags)
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
                    print("oppened tag: " + openingTag + " (" + header + ")")
                    //print(tags)
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
                            continue
                        }
                        plainText += toRead.prefix(1)
                        
                    }
                }
                
                
            }
            
            toRead = String(toRead.dropFirst(1))
        }
        
        return plainText
    }

    @IBAction func nextButton(_ sender: UIButton) {
        articleTextBox.text = "loading..."
        
        
        let url = URL(string: "https://zh.wikipedia.org/wiki/Special:Random")!
        let task = URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            guard let data = data else { return }
            
            let text = String(data: data, encoding: .utf8)!
            
            let articalContent = self.getArticalContent(text: text)
            
            
            
            DispatchQueue.main.async {
                self.articleTextBox.text = articalContent
            }
            print(articalContent)
            print("finished")
        }
        
        task.resume()
        
        
    
    }
    
}


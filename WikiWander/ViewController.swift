//
//  ViewController.swift
//  WikiWander
//
//  Created by Bethany Anne Drake on 13/12/18.
//  Copyright © 2018 WordWatch. All rights reserved.
//

import UIKit

class ViewController: UIViewController, URLSessionTaskDelegate {

    @IBOutlet weak var articleTextBox: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
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
    
    func getArticalContent(text: String)->String {
        //first off, lets just get the <p>s. Then we can add headings.
        //let index = text.index(after: "<p>")
        //var index = 0;
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


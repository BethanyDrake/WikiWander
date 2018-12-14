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
                    tags.append(header)
                    print("oppened tag: " + openingTag + " (" + header + ")")
                    //print(tags)
                }
                continue
                
            }
            
            
            let toInclude = ["p", "a", "b", "i"]
            
            if tags.contains("p") {
                if let lastTag = tags.last {
                    if toInclude.contains(lastTag) {
                        plainText += toRead.prefix(1)
                        print("appending!")
                    }
                }
                
                
            }
            
            toRead = String(toRead.dropFirst(1))
        }
        
        return plainText
    }

    @IBAction func nextButton(_ sender: UIButton) {
        articleTextBox.text = "loading..."
        
        
        let url = URL(string: "https://zh.wikipedia.org/zh-cn/%E6%9B%B2%E5%A5%87")!
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


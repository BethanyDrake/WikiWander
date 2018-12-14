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
    
    
    
    func getArticalContent(text: String)->String {
        //first off, lets just get the <p>s. Then we can add headings.
        //let index = text.index(after: "<p>")
        //var index = 0;
        var open = false
        var plainText = ""
        
        var toRead = text
        
        var tags = [""]
        
        while (toRead.count > 0) {
            if !open && toRead.prefix(3) == "<p>"{
                print (text)
                toRead = String(toRead.dropFirst(3))
                open = true
                continue
            }
            
            if open && toRead.prefix(3) == "</p>"{
                toRead = String(toRead.dropFirst(4))
                plainText += "\n\n"
                open = false
                continue
            }
            
            if open {
                plainText += toRead.prefix(1)
            }
            
            toRead = String(toRead.dropFirst(1))
        }
        
        return plainText
    }

    @IBAction func nextButton(_ sender: UIButton) {
        articleTextBox.text = "loading..."
        
        
        let url = URL(string: "https://en.wikipedia.org/wiki/Cookie")!
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


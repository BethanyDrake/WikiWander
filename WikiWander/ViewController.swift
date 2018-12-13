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
    
//    func urlSession(_ session: URLSession, task: URLSessionTask, didRecieve: Data) {
//        print("recieved" + String(data: didRecieve, encoding: .utf8)!)
//
//    }

    @IBAction func nextButton(_ sender: UIButton) {
        articleTextBox.text = "loading..."
        
        
        let url = URL(string: "https://en.wikipedia.org/w/api.php")!
        let task = URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            guard let data = data else { return }
            
            let newText = String(data: data, encoding: .utf8)!
            DispatchQueue.main.async {
                self.articleTextBox.text = newText
            }
            print(newText)
            print("finished")
        }
        
        task.resume()
        
        
    
    }
    
}


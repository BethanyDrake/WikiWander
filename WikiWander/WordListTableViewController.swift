//
//  WordListTableViewController.swift
//  WikiWander
//
//  Created by Bethany Anne Drake on 20/12/18.
//  Copyright © 2018 WordWatch. All rights reserved.
//

import UIKit

class WordListTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        loadSampleWords()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    
    struct KnownWord {
        var word:String
        var pronounciation:String
        //var tapCount = 1
        //var familiarty = 0
        var definition:String
    }
    
    var knownWords = [KnownWord]()
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func loadSampleWords() {
        knownWords += [KnownWord(word:"語種", pronounciation:"bah", definition: "who knows?")]
        knownWords += [KnownWord(word:"語種ii", pronounciation:"bahjjjjj", definition: "who knjjjjjows?")]
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return knownWords.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("AAAAAAAA")

        let cellIdentifier = "KnownWordTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? KnownWordTableViewCell else {
            print("BBBBBB")
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
            print("DDDDDD")
            return cell
        }
        
        
         print("CCCCCCCC")
        let knownWord = knownWords[indexPath.row]
        cell.charsLabel.text = knownWord.word
        cell.definitionTextBox.text = knownWord.definition
        cell.pinyinLabel.text = knownWord.pronounciation

        return cell
    }
 

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

//
//  WordListTableViewController.swift
//  WikiWander
//
//  Created by Bethany Anne Drake on 20/12/18.
//  Copyright © 2018 WordWatch. All rights reserved.
//

import UIKit

class WordListTableViewController: UITableViewController {
   
    
    @IBAction func exportCards(_ sender: UIButton) {
        print("exporting!")
        print(getCSV())
        //writeToFile(text: getCSV())
    }
    
//    func writeToFile(text:String){
//        let fileName = "flashcards.csv"
//
//        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
//
//            let fileURL = dir.appendingPathComponent(fileName)
//
//            //writing
//            do {
//                try text.write(to: fileURL, atomically: false, encoding: .utf8)
//                print("wrote it!")
//            }
//            catch {
//                print("could not write to file")
//            }
//
//        }
//    }
    
    func getCSV()->String {
        var csv = ""
        for word in knownWords {
            csv += word.word + "," + word.pronounciation + "," + word.definition + "," + "\n"
        }
        return csv
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let savedKnownWords = loadKnownWords() {
            knownWords += savedKnownWords
            //knownWords += [KnownWord(word:"語種", pronounciation:"bah", definition: "brought those back after saving!")]
        }else{
            loadSampleWords()
        }
        saveKnownWords()
        
        knownWords = knownWords.sorted(by: {$0.lastSeenTime > $1.lastSeenTime })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //clearKnownWords()
        
        
        

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    func clearKnownWords(){
        knownWords = []
        saveKnownWords()
    }

    // MARK: - Table view data source

    
    
    var knownWords = [KnownWord]()
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    private func saveKnownWords() {
        print("saving known words...")
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(knownWords, toFile: KnownWord.ArchiveURL.path)
        print("saved =", isSuccessfulSave)
    }
    private func loadKnownWords() -> [KnownWord]? {
        //return []
        return NSKeyedUnarchiver.unarchiveObject(withFile: KnownWord.ArchiveURL.path) as? [KnownWord]
    }
    func loadSampleWords() {
        knownWords += [KnownWord(word:"語種", pronounciation:"bah", definition: "who knows?")]
        knownWords += [KnownWord(word:"語種ii", pronounciation:"bahjjjjj", definition: "who knjjjjjows?")]
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return knownWords.count
    }
    
    func formatTime(duration: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day, .hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        formatter.maximumUnitCount = 1
        
        return formatter.string(from: duration)!
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
        
        
        
        
        cell.charsLabel.text =  knownWord.word + "\t" +
                                knownWord.pronounciation + "\t" +
                                String(knownWord.timesSeen) + "\t" +
            formatTime(duration: knownWord.lastSeenTime.distance(to: Date().timeIntervalSince1970))
        cell.definitionTextBox.text = knownWord.definition
        //cell.pinyinLabel.text = knownWord.pronounciation

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

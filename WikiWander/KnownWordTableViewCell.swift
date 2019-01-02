//
//  KnownWordTableViewCell.swift
//  WikiWander
//
//  Created by Bethany Anne Drake on 20/12/18.
//  Copyright © 2018 WordWatch. All rights reserved.
//

import UIKit

class KnownWordTableViewCell: UITableViewCell {
    
    @IBOutlet weak var colourIndicator: UIButton!
    @IBOutlet weak var charsLabel: UITextField!
    //@IBOutlet weak var pinyinLabel: UILabel!
    
    @IBOutlet weak var definitionTextBox: UITextField!
    var word:KnownWord?
    
    
    func setWord(word:KnownWord){
        self.word = word
        colourIndicator.backgroundColor =  familiarityToColor[word.familiarity]
        
            charsLabel.text =  word.word + "\t" +
            word.pronounciation + "\t" +
            String(word.timesSeen) + "\t" +
            formatTime(duration: word.lastSeenTime.distance(to: Date().timeIntervalSince1970))
            definitionTextBox.text = word.definition
        //cell.pinyinLabel.text = knownWord.pronounciation
    }
    
    func formatTime(duration: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day, .hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        formatter.maximumUnitCount = 1
        
        return formatter.string(from: duration)!
    }
    
//    @IBOutlet weak var tapCountTextBox: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    let familiarityToColor:[Int:UIColor] = [
        -1:UIColor(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 1.0),
        0:UIColor(red: 255/255.0, green: 0/255.0, blue: 0/255.0, alpha: 1.0),
        1:UIColor(red: 255/255.0, green: 255/255.0, blue: 0/255.0, alpha: 1.0),
        2:UIColor(red: 0/255.0, green: 255/255.0, blue: 0/255.0, alpha: 1.0)
    ]
    
    
    @IBAction func toggleColour(_ sender: UIButton) {
        print("button clicked!")
        
        word?.familiarity = (word!.familiarity + 1)%3
        colourIndicator.backgroundColor =  familiarityToColor[word?.familiarity ?? -1]
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

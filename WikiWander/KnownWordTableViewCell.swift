//
//  KnownWordTableViewCell.swift
//  WikiWander
//
//  Created by Bethany Anne Drake on 20/12/18.
//  Copyright © 2018 WordWatch. All rights reserved.
//

import UIKit

class KnownWordTableViewCell: UITableViewCell {

    @IBOutlet weak var charsLabel: UILabel!
    @IBOutlet weak var pinyinLabel: UILabel!
    
    @IBOutlet weak var definitionTextBox: UITextField!
    
//    @IBOutlet weak var tapCountTextBox: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

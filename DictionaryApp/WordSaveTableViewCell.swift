//
//  WordSaveTableViewCell.swift
//  DictionaryApp
//
//  Created by Christopher Teddy on 12/02/21.
//  Copyright © 2021 Christopher Teddy. All rights reserved.
//

import UIKit

class WordSaveTableViewCell: UITableViewCell {

    @IBOutlet weak var lblTypeSave: UILabel!
    @IBOutlet weak var lblDefinitionSave: UITextView!
    @IBOutlet weak var ivWordSave: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

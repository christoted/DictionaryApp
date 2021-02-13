//
//  WordTableViewCell.swift
//  DictionaryApp
//
//  Created by Christopher Teddy on 10/02/21.
//  Copyright © 2021 Christopher Teddy. All rights reserved.
//

import UIKit

class WordTableViewCell: UITableViewCell {

    @IBOutlet weak var ivWord: UIImageView!
    @IBOutlet weak var lblDefinition: UITextView!
    @IBOutlet weak var lblType: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

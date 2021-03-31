//
//  TextFieldCell.swift
//  AreveaTV
//
//  Created by apple on 3/18/21.
//  Copyright © 2021 apple. All rights reserved.
//

import UIKit

class TextFieldCell: UITableViewCell {
    @IBOutlet var txtAnswer: ACFloatingTextfield!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

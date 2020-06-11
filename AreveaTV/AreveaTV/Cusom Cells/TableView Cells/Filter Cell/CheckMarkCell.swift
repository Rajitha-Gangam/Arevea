//
//  CheckMarkCell.swift
//  AreveaTV
//
//  Created by apple on 6/9/20.
//  Copyright © 2020 apple. All rights reserved.
//

import UIKit

class CheckMarkCell: UITableViewCell {
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var imgCheck: UIImageView!


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

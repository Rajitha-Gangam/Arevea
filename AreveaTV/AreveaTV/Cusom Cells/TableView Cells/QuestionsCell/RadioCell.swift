//
//  RadioCell.swift
//  AreveaTV
//
//  Created by apple on 3/17/21.
//  Copyright © 2021 apple. All rights reserved.
//

import UIKit

class RadioCell: UITableViewCell {
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

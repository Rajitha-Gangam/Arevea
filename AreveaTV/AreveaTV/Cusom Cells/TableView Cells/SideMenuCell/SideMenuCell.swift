//
//  SideMenuCell.swift
//  AreveaTV
//
//  Created by apple on 4/22/20.
//  Copyright © 2020 apple. All rights reserved.
//

import UIKit

class SideMenuCell: UITableViewCell {
    @IBOutlet weak var lblName: UILabel!
@IBOutlet weak var imgItem: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
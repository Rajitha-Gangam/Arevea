//
//  CharityCell.swift
//  AreveaTV
//
//  Created by apple on 5/5/20.
//  Copyright © 2020 apple. All rights reserved.
//

import UIKit

class CharityCell: UITableViewCell {
    @IBOutlet weak var btnDonate: UIButton!
    @IBOutlet weak var lblCharityName: UILabel!
    @IBOutlet weak var lblCharityDesc: UILabel!
    @IBOutlet weak var imgCharity: UIImageView!


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

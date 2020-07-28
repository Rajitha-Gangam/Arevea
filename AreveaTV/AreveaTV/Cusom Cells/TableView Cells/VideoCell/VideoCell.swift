//
//  VideoCell.swift
//  AreveaTV
//
//  Created by apple on 4/29/20.
//  Copyright © 2020 apple. All rights reserved.
//

import UIKit

class VideoCell: UITableViewCell {
    @IBOutlet weak var btnVideo:UIButton!
    @IBOutlet weak var btnVideo1:UIButton!
    @IBOutlet weak var lblTitle:UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

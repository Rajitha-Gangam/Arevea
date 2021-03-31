//
//  SpeakersCell.swift
//  AreveaTV
//
//  Created by apple on 2/19/21.
//  Copyright © 2021 apple. All rights reserved.
//

import UIKit

class SpeakersCell: UITableViewCell {
    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var btnUser: UIButton!

    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var txtDesc: UITextView!

    @IBOutlet weak var viewContent: UIView!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

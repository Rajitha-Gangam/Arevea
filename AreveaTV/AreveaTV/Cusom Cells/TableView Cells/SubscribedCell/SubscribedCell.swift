//
//  SubscribedCell.swift
//  AreveaTV
//
//  Created by apple on 12/3/20.
//  Copyright © 2020 apple. All rights reserved.
//

import UIKit

class SubscribedCell: UITableViewCell {
    @IBOutlet weak var viewContent:UIView!
    @IBOutlet weak var viewHeader:UIView!

    @IBOutlet weak var lbl1:UILabel!
    @IBOutlet weak var lbl2:UILabel!
    @IBOutlet weak var lbl3:UILabel!
    @IBOutlet weak var lbl4:UILabel!
    @IBOutlet weak var lblAmount:UILabel!
    @IBOutlet weak var lblAmountMode:UILabel!
    @IBOutlet weak var imgUser:UIImageView!
    @IBOutlet weak var lblChannelName:UILabel!
    @IBOutlet weak var lblTierName:UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

//
//  UpcomingCell.swift
//  AreveaTV
//
//  Created by apple on 4/29/20.
//  Copyright © 2020 apple. All rights reserved.
//

import UIKit

class UpcomingCell: UITableViewCell {
    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var lblSession:UILabel!
    @IBOutlet weak var lblDate:UILabel!
    @IBOutlet weak var lblPayment:UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

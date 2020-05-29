//
//  PaymentHistoryCell.swift
//  AreveaTV
//
//  Created by apple on 5/18/20.
//  Copyright © 2020 apple. All rights reserved.
//

import UIKit

class PaymentHistoryCell: UITableViewCell {
    @IBOutlet weak var lblDonatedTo:UILabel!
       @IBOutlet weak var lblTypeOfDonation:UILabel!
       @IBOutlet weak var lblDate:UILabel!
       @IBOutlet weak var lblAmount:UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

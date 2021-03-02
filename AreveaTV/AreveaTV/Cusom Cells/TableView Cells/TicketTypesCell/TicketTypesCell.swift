//
//  TicketTypesCell.swift
//  AreveaTV
//
//  Created by apple on 12/22/20.
//  Copyright © 2020 apple. All rights reserved.
//

import UIKit

class TicketTypesCell: UITableViewCell {
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblAmount: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblSaleEnds: UILabel!
    @IBOutlet weak var txtDesc: UITextView!

    @IBOutlet weak var imgCheck: UIImageView!
    @IBOutlet weak var btnSelect: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

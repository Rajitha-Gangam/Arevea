//
//  CommentsCell.swift
//  AreveaTV
//
//  Created by apple on 4/26/20.
//  Copyright © 2020 apple. All rights reserved.
//

import UIKit

class CommentsCell: UITableViewCell {
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblDesc: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

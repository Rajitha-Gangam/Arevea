//
//  ContactsCell.swift
//  AreveaTV
//
//  Created by apple on 1/6/21.
//  Copyright © 2021 apple. All rights reserved.
//

import UIKit

class ContactsCell: UITableViewCell {
    @IBOutlet weak var profileContainerView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userName: UIButton!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var btnAdd: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

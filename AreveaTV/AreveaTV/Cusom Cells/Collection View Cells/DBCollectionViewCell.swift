//
//  DBCollectionViewCell.swift
//  AreveaTV
//
//  Created by apple on 4/26/20.
//  Copyright © 2020 apple. All rights reserved.
//

import UIKit

class DBCollectionViewCell: UICollectionViewCell {
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var imgCategory: UIImageView!
    @IBOutlet var btnLeft: UIButton!
    @IBOutlet var btnRight: UIButton!
    @IBOutlet var lblHeader: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}

//
//  FilterCVCell.swift
//  AreveaTV
//
//  Created by apple on 5/3/20.
//  Copyright © 2020 apple. All rights reserved.
//

import UIKit

class FilterCVCell: UICollectionViewCell {
    @IBOutlet weak var btn: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func configureCell(name: String) {
        self.btn.setTitle(name, for: .normal)
    }
}

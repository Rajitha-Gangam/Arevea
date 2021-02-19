//
//  dateCVC.swift
//  AreveaTV
//
//  Created by apple on 2/19/21.
//  Copyright © 2021 apple. All rights reserved.
//

import UIKit

class DateCVC: UICollectionViewCell {
    @IBOutlet weak var btnDate: UIButton!
    @IBOutlet weak var viewBG:UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func configureCell(name: String) {
        
        self.btnDate.setTitle(name, for: .normal)
    }
}

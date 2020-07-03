//
//  ButtonsCVC.swift
//  AreveaTV
//
//  Created by apple on 4/26/20.
//  Copyright © 2020 apple. All rights reserved.
//

import UIKit

class ButtonsCVC: UICollectionViewCell {
    @IBOutlet weak var btn: UIButton!
    @IBOutlet weak var lblLine:UILabel!
    @IBOutlet weak var viewBG:UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func configureCell(name: String) {
        
        self.btn.setTitle(name, for: .normal)
    }

}

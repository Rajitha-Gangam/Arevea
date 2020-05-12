//
//  AudioCell.swift
//  AreveaTV
//
//  Created by apple on 4/27/20.
//  Copyright © 2020 apple. All rights reserved.
//

import UIKit

class AudioCell: UITableViewCell {
    @IBOutlet weak var audioView: UIView!
    @IBOutlet weak var btnPlayOrPause: UIButton!
    @IBOutlet weak var audioSlider: UISlider!
    @IBOutlet weak var lblDuration: UILabel!
    @IBOutlet weak var btnVolume:UIButton!
    @IBOutlet weak var lblTitle:UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

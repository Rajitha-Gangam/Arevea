//
//  ScheduleCell.swift
//  AreveaTV
//
//  Created by apple on 2/19/21.
//  Copyright © 2021 apple. All rights reserved.
//

import UIKit

class ScheduleCell: UITableViewCell,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout  {
    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var lblStartTime: UILabel!
    @IBOutlet weak var lblEndTime: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var txtDesc: UITextView!
    @IBOutlet var collectionView: UICollectionView!
    var rowWithItems = [Any]()
    var COLORLIST = [
        "#44d7b6",
        "#FF8935",
        "#f3af5a",
        "#846aa4",
        "#bf6780",
        "#b47f60",
        "#21accf",
        "#3d7dca",
        "#ed6c82",
        "#ee91a4",
        "#787ca9",
        "#5b868d",
        "#98bfaa",
        "#55d951",
        "#d0b2a0",
        "#44d7b6",
        "#FF8935",
        "#f3af5a",
        "#846aa4",
        "#bf6780",
        "#b47f60",
        "#21accf",
        "#3d7dca",
        "#ed6c82",
        "#ee91a4",
        "#787ca9",
        "#5b868d",
        "#98bfaa",
        "#55d951",
        "#d0b2a0"
    ];
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.collectionView.showsHorizontalScrollIndicator = false
        // Comment if you set Datasource and delegate in .xib
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        // Register the xib for collection view cell
        let cellNib = UINib(nibName: "ScheduleUserCVC", bundle: nil)
        self.collectionView.register(cellNib, forCellWithReuseIdentifier: "ScheduleUserCVC")
 
    }
    func updateCellWith(row: [Any]) {
        self.rowWithItems = row
        self.collectionView.reloadData()
        let indexPath = IndexPath(row: 0, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
            //self.collectionView.direc
            if let layout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                layout.scrollDirection = .horizontal  // .horizontal
            }
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.rowWithItems.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    // Set the data for each cell (color and color name)
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ScheduleUserCVC", for: indexPath) as? ScheduleUserCVC {
            // cell.colorView.backgroundColor = self.rowWithItems?[indexPath.item].color ?? UIColor.black
            let guestObj = rowWithItems[indexPath.row] as! [String: Any]
            if(rowWithItems.count <= COLORLIST.count){
                let color = COLORLIST[indexPath.row]
                cell.btnUserNameShort.backgroundColor = hexStringToUIColor(hex: color)
            }

            let fn = guestObj["first_name"] as? String ?? ""
            let ln = guestObj["last_name"]as? String ?? ""
            let userName =  fn + " " + ln
            cell.btnUserName.setTitle(userName, for: .normal)
            cell.btnUserName.sizeToFit()
            //cell.btnUserName.backgroundColor = UIColor.red
            var firstChar = ""
            if (ln == ""){
                firstChar = String(fn.first?.uppercased() ?? "A")
            }else{
                firstChar = String(fn.first?.uppercased() ?? "A") + String(ln.first?.uppercased() ?? " ")
            }
            cell.btnUserNameShort.setTitle(firstChar, for: .normal)
            return cell
        }
        return UICollectionViewCell()
    }
    
    // Add spaces at the beginning and the end of the collection view
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
    }
    // Add spaces at the beginning and the end of the collection view
    func widthForLabel(text:String) -> CGFloat{
        let screenRect = UIScreen.main.bounds

        let width = screenRect.size.width - 100
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = UIFont.systemFont(ofSize: 18.0)
        label.text = text
        label.sizeToFit()
        return label.intrinsicContentSize.width
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        ////print("width:",width)
        let guestObj = rowWithItems[indexPath.row] as! [String: Any]
        let fn = guestObj["first_name"] as? String ?? ""
        let ln = guestObj["last_name"]as? String ?? ""
        let userName =  fn + " " + ln
        let width = widthForLabel(text: userName)
        let screenRect = UIScreen.main.bounds
        _ = screenRect.size.width
        let size = userName.size(withAttributes:[.font: UIFont.systemFont(ofSize: 18.0)])
        return CGSize(width: (size.width) * 2, height: 50)
    }
    
    
}

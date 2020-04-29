//
//  DashBoardCell.swift
//  AreveaTV
//
//  Created by apple on 4/21/20.
//  Copyright © 2020 apple. All rights reserved.
//

import UIKit
struct CollectionViewCellModel {
    var organization_id: Int
    var organization_name: String
    var organization_logo: String
}
protocol CollectionViewCellDelegate: class {
    func collectionView(collectionviewcell: DBCollectionViewCell?, index: Int, didTappedInTableViewCell: DashBoardCell)
    // other delegate methods that you can define to perform action in viewcontroller
}


class DashBoardCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
     //weak var cellDelegate: CollectionViewCellDelegate?
    var rowWithItems = [Any]()
    var strController = "";
    weak var cellDelegate: CollectionViewCellDelegate?

    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet weak var lbl1: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.collectionView.showsHorizontalScrollIndicator = false
        
        // Comment if you set Datasource and delegate in .xib
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
        // Register the xib for collection view cell
        let cellNib = UINib(nibName: "DBCollectionViewCell", bundle: nil)
        self.collectionView.register(cellNib, forCellWithReuseIdentifier: "DBCollectionViewCell")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    // The data we passed from the TableView send them to the CollectionView Model
    func updateCellWith(row: [Any],controller:String) {
        self.rowWithItems = row
        self.strController = controller;
        self.collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? DBCollectionViewCell
        //print("I'm tapping the \(indexPath.item)")
        self.cellDelegate?.collectionView(collectionviewcell: cell, index: indexPath.item, didTappedInTableViewCell: self)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.rowWithItems.count ?? 0
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    // Set the data for each cell (color and color name)
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DBCollectionViewCell", for: indexPath) as? DBCollectionViewCell {
           // cell.colorView.backgroundColor = self.rowWithItems?[indexPath.item].color ?? UIColor.black
            let arySub = rowWithItems[indexPath.row] as! [String: Any]
            if (strController == "dashboard"){
                cell.nameLabel.text = arySub["organization_name"]as! String;

            }else if (strController == "channels"){
                cell.nameLabel.text = arySub["performer_display_name"]as! String;

            }else if (strController == "channel_detail"){
                cell.imgCategory.layer.cornerRadius = 80;
                cell.nameLabel.text = arySub["name"]as! String;
            }
            let imageArr = ["channel1.png","channel2.png","channel3.png","channel4.png"]
               let RandomNumber = Int(arc4random_uniform(UInt32(imageArr.count)))
               //imageArr is array of images
                let image = UIImage.init(named: "\(imageArr[RandomNumber])")

               cell.imgCategory.image = image
            
            return cell
        }
        return UICollectionViewCell()
    }
    
    // Add spaces at the beginning and the end of the collection view
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
    }
    
}

//
//  MyEventsCell.swift
//  AreveaTV
//
//  Created by apple on 7/31/20.
//  Copyright © 2020 apple. All rights reserved.
//

import UIKit
protocol CollectionViewCellDelegateMyEvents: class {
    func collectionView(collectionviewcell: DBCollectionViewCell?, index: Int, didTappedInTableViewCell: MyEventsCell)
    // other delegate methods that you can define to perform action in viewcontroller
}
class MyEventsCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    //weak var cellDelegate: CollectionViewCellDelegate?
    var rowWithItems = [Any]()
    weak var cellDelegate: CollectionViewCellDelegateMyEvents?
    
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
        let cellNib = UINib(nibName: "MyEventsCVC", bundle: nil)
        self.collectionView.register(cellNib, forCellWithReuseIdentifier: "MyEventsCVC")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    // The data we passed from the TableView send them to the CollectionView Model
    func updateCellWith(row: [Any]) {
        self.rowWithItems = row
        self.collectionView.reloadData()
        let indexPath = IndexPath(row: 0, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
            //self.collectionView.direc
            if let layout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                layout.scrollDirection = .vertical  // .horizontal
            }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? DBCollectionViewCell
        ////print("I'm tapping the \(indexPath.item)")
        self.cellDelegate?.collectionView(collectionviewcell: cell, index: indexPath.item, didTappedInTableViewCell: self)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.rowWithItems.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    // Set the data for each cell (color and color name)
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyEventsCVC", for: indexPath) as? MyEventsCVC {
            // cell.colorView.backgroundColor = self.rowWithItems?[indexPath.item].color ?? UIColor.black
            let arySub = rowWithItems[indexPath.row] as! [String: Any]
            let thumbNail = UIImage.init(named: "sample-event")
            cell.imgCategory.image = thumbNail
            cell.imgCategory.contentMode = .scaleAspectFill
                cell.nameLabel.text = arySub["stream_video_title"]as? String;
                let strURL = arySub["video_thumbnail_image"]as? String ?? "";
                if let url = URL(string: strURL){
                    //cell.imgCategory.sd_setImage(with: url, placeholderImage: UIImage(named: "sample-event"))
                    cell.imgCategory.downloaded(from: url)

                }
            return cell
        }
        return UICollectionViewCell()
    }
    
    // Add spaces at the beginning and the end of the collection view
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    // Add spaces at the beginning and the end of the collection view
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        ////print("width:",width)
        let screenRect = UIScreen.main.bounds
        let screenWidth = screenRect.size.width
        let screenHeight = screenRect.size.height/2 - 34
       
        return CGSize(width: screenWidth, height: screenHeight)
    }
    
   
    
}

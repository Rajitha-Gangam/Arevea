//
//  SponsorsCell.swift
//  AreveaTV
//
//  Created by apple on 2/19/21.
//  Copyright © 2021 apple. All rights reserved.
//

import UIKit
protocol SponsorsCVCDelegate: class {
    func collectionView(collectionviewcell: SponsorsCVC?, index: Int, didTappedInTableViewCell: SponsorsCell)
    // other delegate methods that you can define to perform action in viewcontroller
}
class SponsorsCell: UITableViewCell , UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
   
    var rowWithItems = [Any]()
    @IBOutlet var collectionView: UICollectionView!
    weak var cellDelegate: SponsorsCVCDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.collectionView.showsHorizontalScrollIndicator = false
        //for disable scroll
        self.collectionView.isScrollEnabled = true
        // Comment if you set Datasource and delegate in .xib
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
        
        // Register the xib for collection view cell
        let cellNib = UINib(nibName: "SponsorsCVC", bundle: nil)
        self.collectionView.register(cellNib, forCellWithReuseIdentifier: "SponsorsCVC")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    // The data we passed from the TableView send them to the CollectionView Model
    func updateCellWith(row: [Any]) {
        self.rowWithItems = row
        self.collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? SponsorsCVC
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
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SponsorsCVC", for: indexPath) as? SponsorsCVC {
            cell.backgroundColor = UIColor.clear
            let charity = self.rowWithItems[indexPath.row] as? [String : Any];
            
            let strURL = charity?["advertiser_logo"]as? String ?? ""
            if let urlCharity = URL(string: strURL){
                cell.imgSponsor.sd_setImage(with: urlCharity, placeholderImage: UIImage(named: "charity-img.png"))
            }
            
            return cell
        }
        return UICollectionViewCell()
    }
    
    // Add spaces at the beginning and the end of the collection view
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5)
    }
    // Add spaces at the beginning and the end of the collection view
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenRect = UIScreen.main.bounds
        let screenWidth = screenRect.size.width/2 - 10

        return CGSize(width: screenWidth, height: 60)
    }
    
    
    
}

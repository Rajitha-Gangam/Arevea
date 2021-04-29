//
//  SponsorsCell.swift
//  AreveaTV
//
//  Created by apple on 2/19/21.
//  Copyright © 2021 apple. All rights reserved.
//

import UIKit
import EasyTipView

protocol SponsorsCVCDelegate: class {
    func collectionView(collectionviewcell: SponsorsCVC?, index: Int, didTappedInTableViewCell: SponsorsCell)
    // other delegate methods that you can define to perform action in viewcontroller
}
class SponsorsCell: UITableViewCell , UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    var toolTipPreferences = EasyTipView.Preferences()

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
        toolTipPreferences.drawing.font = UIFont(name: "Poppins-Regular", size: 13)!
        toolTipPreferences.drawing.foregroundColor = UIColor.white
        toolTipPreferences.drawing.backgroundColor = UIColor.init(red: 255, green: 127, blue: 80)
        toolTipPreferences.drawing.arrowPosition = EasyTipView.ArrowPosition.top
        //toolTipPreferences.animating.showDuration = 1.5
        // toolTipPreferences.animating.dismissDuration = 1.5
        toolTipPreferences.animating.dismissOnTap = true
        toolTipPreferences.drawing.arrowWidth = 2
        toolTipPreferences.drawing.arrowHeight = 2
        toolTipPreferences.drawing.arrowPosition = .bottom
        toolTipPreferences.animating.dismissTransform = CGAffineTransform(translationX: 0, y: -15)
        toolTipPreferences.animating.showInitialTransform = CGAffineTransform(translationX: 0, y: -15)
        toolTipPreferences.animating.showInitialAlpha = 0
        toolTipPreferences.animating.showDuration = 1.5
        toolTipPreferences.animating.dismissDuration = 1.5
        EasyTipView.globalPreferences = toolTipPreferences
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
    func delay(_ delay:Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? SponsorsCVC
            
            let sponsorsObj = self.rowWithItems[indexPath.row] as? [String : Any] ?? [:];
            let name = sponsorsObj["advertiser_name"] as? String ?? ""
            let toolTipView = EasyTipView(text: name, preferences: toolTipPreferences)
            
        toolTipView.show(forView: cell!.imgSponsor, withinSuperview: cell?.contentView)
            
            self.delay(2.0){
                toolTipView.dismiss()
            }
            
        //self.cellDelegate?.collectionView(collectionviewcell: cell, index: indexPath.item, didTappedInTableViewCell: self)
        
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

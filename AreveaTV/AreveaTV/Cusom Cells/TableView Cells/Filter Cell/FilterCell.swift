//
//  FilterCell.swift
//  AreveaTV
//
//  Created by apple on 4/30/20.
//  Copyright © 2020 apple. All rights reserved.
//

import UIKit

class FilterCell: UITableViewCell, UICollectionViewDataSource {
    // MARK: - Properties
    
    var rowWithItems = [Any]()
    @IBOutlet var collectionView: UICollectionView!
    var strController = "";
    fileprivate let CellIdentifier = "Cell"
    fileprivate let HeaderIdentifier = "Header"
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        // Comment if you set Datasource and delegate in .xib
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        // Register the xib for collection view cell
        let cellNib = UINib(nibName: "FilterCVCell", bundle: nil)
        self.collectionView.register(cellNib, forCellWithReuseIdentifier: "FilterCVCell");
        
        let XIB = UINib.init(nibName: "SectionHeader", bundle: nil)
        collectionView.register(XIB, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HeaderIdentifier)
        collectionView.showsHorizontalScrollIndicator = true;
        
        
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    // The data we passed from the TableView send them to the CollectionView Model
    func updateCellWith(row: [Any],item:String) {
        self.rowWithItems = row
        self.strController = item;
        self.collectionView.reloadData()
    }
    // MARK: - Collection View Data Source Methods
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        // Dequeue Reusable Supplementary View
        if let supplementaryView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HeaderIdentifier, for: indexPath) as? SectionHeader {
            // Configure Supplementary View
            supplementaryView.titleLabel.text = ""
            
            return supplementaryView
        }
        
        fatalError("Unable to Dequeue Reusable Supplementary View")
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.rowWithItems.count
    }
    
    // Set the data for each cell (color and color name)
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterCVCell", for: indexPath) as? FilterCVCell {
            // cell.colorView.backgroundColor = self.rowWithItems?[indexPath.item].color ?? UIColor.black
            if (self.strController == "category"){
                let selectedItem = rowWithItems[indexPath.row] as!  [String : Any];
                let strValue = selectedItem["category"] as? String;
                cell.btn.setTitle(strValue, for: .normal);
            }else if (self.strController == "sub-category"){
                let selectedItem = rowWithItems[indexPath.row] as! [String : Any];
                let strValue = selectedItem["subCategory"] as! String;
                cell.btn.setTitle(strValue, for: .normal);
            }else if (self.strController == "genres"){
                let selectedItem = rowWithItems[indexPath.row] as! [String : Any];
                let strValue = selectedItem["genres"] as! String;
                cell.btn.setTitle(strValue, for: .normal);
            }
           cell.btn.sizeToFit()
            return cell
        }
        return UICollectionViewCell()
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        _ = collectionView.cellForItem(at: indexPath) as? DBCollectionViewCell
        //print("I'm tapping the \(indexPath.item)")
        
    }
    
    
}
extension FilterCell: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    // MARK: - Collection View Delegate Flow Layout Methods
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //let btnTitle = rowWithItems[indexPath.row] as! String
        return CGSize(width: 150.0, height: 44.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    /*func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
     return 2.0
     }
     
     func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
     return 0.0
     }
     
     func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
     return CGSize(width: collectionView.bounds.width, height: 80.0)
     }*/
    
}

//
//  MultiStreamGuestsCell.swift
//  AreveaTV
//
//  Created by apple on 10/5/20.
//  Copyright © 2020 apple. All rights reserved.
//

import UIKit

class MultiStreamGuestsCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    //weak var cellDelegate: CollectionViewCellDelegate?
    var rowWithItems = [Any]()
    var strController = "";
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
        let cellNib = UINib(nibName: "MultiStreamGuestsCVC", bundle: nil)
        self.collectionView.register(cellNib, forCellWithReuseIdentifier: "MultiStreamGuestsCVC")
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
        let indexPath = IndexPath(row: 0, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
        if let layout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection =  .horizontal
        }
    }
    
   
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.rowWithItems.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    // Set the data for each cell (color and color name)
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MultiStreamGuestsCVC", for: indexPath) as? MultiStreamGuestsCVC {
            // cell.colorView.backgroundColor = self.rowWithItems?[indexPath.item].color ?? UIColor.black
            
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
        var screenHeight = screenRect.size.height/2 - 20
        
        return CGSize(width: screenWidth, height: screenHeight)
    }
    
    @objc func btnLeftPress(_ sender: UIButton) {
//        //print("btnLeftPress called")
//        //print("sender.tag",sender.tag)
        if (sender.tag == 0){
            let indexPath = IndexPath(row: rowWithItems.count - 1, section: 0)
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }else{
            let indexPath = IndexPath(row: sender.tag - 1, section: 0)
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
        
    }
    @objc func btnRightPress(_ sender: UIButton) {
        ////print("btnRightPress called")
       // //print("sender.tag",sender.tag)
        ////print("last index",rowWithItems.count - 1)
        if (sender.tag < rowWithItems.count - 1){
            let indexPath = IndexPath(row: sender.tag  + 1, section: 0)
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }else{
            let indexPath = IndexPath(row: 0, section: 0)
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }
    
}


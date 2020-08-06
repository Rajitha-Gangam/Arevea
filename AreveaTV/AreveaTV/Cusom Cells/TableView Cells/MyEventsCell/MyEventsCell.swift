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
        let cellNib = UINib(nibName: "MyEventsCVC", bundle: nil)
        self.collectionView.register(cellNib, forCellWithReuseIdentifier: "MyEventsCVC")
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
        if(strController == "my_events" || strController == "channels"){
            //self.collectionView.direc
            if let layout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                layout.scrollDirection = .vertical  // .horizontal
            }
        }else{
            if let layout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                layout.scrollDirection =  .horizontal
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? DBCollectionViewCell
        //print("I'm tapping the \(indexPath.item)")
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
            if (strController == "dashboard" || strController == "dashboard_my_list" || strController == "my_events"){
                cell.nameLabel.text = arySub["stream_video_title"]as? String;
                let strURL = arySub["video_thumbnail_image"]as? String ?? "";
                if (strURL != "" && strURL != "NO LOGO" && strURL.range(of:"null") == nil ){
                    if let url = URL(string: strURL){
                        cell.imgCategory.downloaded(from: url)
                    }
                }
                cell.btnLeft.addTarget(self, action: #selector(btnLeftPress(_:)), for: .touchUpInside)
                cell.btnRight.addTarget(self, action: #selector(btnRightPress(_:)), for: .touchUpInside)

                cell.btnLeft.tag = indexPath.row
                cell.btnRight.tag = indexPath.row
                

            }
           else if(strController == "dashboard_search"){
                cell.nameLabel.text = arySub["name"]as? String;
                
            }else if (strController == "channels" || strController == "dashboard_trending_channels"){
                // //print("arySub:",arySub)
                cell.nameLabel.text = arySub["performer_display_name"]as? String ?? "";
                let strURL = arySub["performer_profile_pic"]as? String ?? "";
                if (strURL != "" && strURL != "NO LOGO" && strURL.range(of:"null") == nil ){
                    if let url = URL(string: strURL){
                        cell.imgCategory.downloaded(from: url)
                    }
                }
                cell.btnLeft.addTarget(self, action: #selector(btnLeftPress(_:)), for: .touchUpInside)
                cell.btnRight.addTarget(self, action: #selector(btnRightPress(_:)), for: .touchUpInside)

                cell.btnLeft.tag = indexPath.row
                cell.btnRight.tag = indexPath.row
                
                
            }else if (strController == "channel_detail"){
//                cell.imgCategory.layer.cornerRadius = 80;
//                cell.nameLabel.text = arySub["name"]as? String;
//                cell.nameLabel.textAlignment = .center;
            }
            if(strController == "my_events" || strController == "dashboard_search"  || strController == "channels" ){
                cell.btnLeft.isHidden = true
                cell.btnRight.isHidden = true
            }else{
                cell.btnLeft.isHidden = false
                cell.btnRight.isHidden = false
            }
           if(strController == "dashboard"){
                cell.lblHeader.text = "LIVE EVENTS"
            }else if(strController == "dashboard_my_list"){
                cell.lblHeader.text = "MY LIST"
            }else if(strController == "dashboard_trending_channels"){
                if(indexPath.row == 0){
                    cell.lblHeader.text = "TRENDING CHANNELS"
                }else{
                    cell.lblHeader.text = ""
                }
            }else{
                cell.lblHeader.text = ""
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
        //print("width:",width)
        let screenRect = UIScreen.main.bounds
        let screenWidth = screenRect.size.width
        var screenHeight = screenRect.size.height/2 - 90
        if (strController == "my_events"){
             screenHeight = screenRect.size.height/2 - 34
        }
        return CGSize(width: screenWidth, height: screenHeight)
    }
    
     @objc func btnLeftPress(_ sender: UIButton) {
        print("btnLeftPress called")
        print("sender.tag",sender.tag)
        if (sender.tag == 0){
            let indexPath = IndexPath(row: rowWithItems.count - 1, section: 0)
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }else{
            let indexPath = IndexPath(row: sender.tag - 1, section: 0)
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
        
    }
    @objc func btnRightPress(_ sender: UIButton) {
        print("btnRightPress called")
        print("sender.tag",sender.tag)
        print("last index",rowWithItems.count - 1)
        if (sender.tag < rowWithItems.count - 1){
            let indexPath = IndexPath(row: sender.tag  + 1, section: 0)
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }else{
            let indexPath = IndexPath(row: 0, section: 0)
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }
    
}

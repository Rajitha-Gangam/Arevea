//
//  DashBoardCell.swift
//  AreveaTV
//
//  Created by apple on 4/21/20.
//  Copyright © 2020 apple. All rights reserved.
//

import UIKit

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
        return self.rowWithItems.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    // Set the data for each cell (color and color name)
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DBCollectionViewCell", for: indexPath) as? DBCollectionViewCell {
            // cell.colorView.backgroundColor = self.rowWithItems?[indexPath.item].color ?? UIColor.black
            let arySub = rowWithItems[indexPath.row] as! [String: Any]
            
            let thumbNail = UIImage.init(named: "default-img1.jpg")
            cell.imgCategory.image = thumbNail
            cell.imgCategory.contentMode = .scaleAspectFill
            
            if (strController == "dashboard_live"){
                cell.nameLabel.text = arySub["stream_video_title"]as? String;
                let strURL = arySub["video_thumbnail_image"]as? String ?? "";
                if (strURL != "" && strURL != "NO LOGO" && strURL.range(of:"null") == nil ){
                    if let url = URL(string: strURL){
                        downloadImage(from:url, imageView: cell.imgCategory)
                    }
                }
            }
            else if (strController == "dashboard"){
                cell.nameLabel.text = arySub["organization_name"]as? String;
                let strURL = arySub["organization_logo"]as? String ?? "";
                if (strURL != "" && strURL != "NO LOGO" && strURL.range(of:"null") == nil ){
                    if let url = URL(string: strURL){
                        downloadImage(from:url, imageView: cell.imgCategory)
                    }
                }
            }else if(strController == "dashboard_search"){
                
                cell.nameLabel.text = arySub["name"]as? String;
                
            }else if (strController == "channels"){
                // //print("arySub:",arySub)
                cell.nameLabel.text = arySub["performer_display_name"]as? String ?? "";
                let strURL = arySub["performer_profile_pic"]as? String ?? "";
                if (strURL != "" && strURL != "NO LOGO" && strURL.range(of:"null") == nil ){
                    if let url = URL(string: strURL){
                        downloadImage(from:url, imageView: cell.imgCategory)
                    }
                }
            }else if (strController == "channel_detail"){
//                cell.imgCategory.layer.cornerRadius = 80;
//                cell.nameLabel.text = arySub["name"]as? String;
//                cell.nameLabel.textAlignment = .center;
            }
            return cell
        }
        return UICollectionViewCell()
    }
    
    // Add spaces at the beginning and the end of the collection view
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
    }
    // Add spaces at the beginning and the end of the collection view
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //print("width:",width)
        if(UIDevice.current.userInterfaceIdiom == .pad){
            return CGSize(width: 250.0, height: 250.0)
        }else{
            return CGSize(width: 180.0, height: 180.0)
        }
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    func downloadImage(from url: URL,imageView:UIImageView) {
        //print("Download Started")
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else {
                return
            }
            //print(response?.suggestedFilename ?? url.lastPathComponent)
            // //print("Download Finished")
            DispatchQueue.main.async() { [weak self] in
                imageView.image = UIImage(data: data)
            }
        }
    }
    
}

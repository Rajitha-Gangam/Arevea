//
//  ChannelsVC.swift
//  AreveaTV
//
//  Created by apple on 4/23/20.
//  Copyright © 2020 apple. All rights reserved.
//

import UIKit
import Alamofire
import MaterialComponents.MaterialCollections

class ChannelsVC: UIViewController,UITableViewDelegate,UITableViewDataSource,CollectionViewCellDelegate,OpenChanannelChatDelegate{
    @IBOutlet weak var tblMain: UITableView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    @IBOutlet weak var btnUserName: UIButton!
    @IBOutlet weak var topConstaintTblMain: NSLayoutConstraint?
    @IBOutlet weak var mdChipCard:MDCCard!
    var strSelectedCategory = "";
    @IBOutlet weak var collectionViewFilter: UICollectionView!
    var aryFilterCategoriesData = [Any]();
    var aryFilterSubCategoriesData = [Any]();
    var aryFilterGenresData = [Any]();
    private let chipIdentifier = "Chip"
       fileprivate let HeaderIdentifier = "Header"
    var sectionFilters = ["Categories","Sub Categories","Genres"]
    @IBOutlet weak var lblNoData: UILabel!

    var aryChannels = [Any]();
    var orgId = 0;
    var organizationName = "Organization Name";
    var aryMainMenu :[[String: String]] = [["name":"House","icon":"channel1.png"],["name":"Bass","icon":"channel2.png"],["name":"Bass","icon":"channel4.png"],["name":"House","icon":"channel3.png"],["name":"House","icon":"channel4.png"],
                                           ["name":"Bass","icon":"channel1.png"],
                                           ["name":"Bass","icon":"channel2.png"],
                                           ["name":"House","icon":"channel3.png"],
                                           ["name":"Bass","icon":"channel2.png"],
                                           ["name":"House","icon":"channel3.png"]];
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationController?.isNavigationBarHidden = true
        tblMain.register(UINib(nibName: "DashBoardCell", bundle: nil), forCellReuseIdentifier: "DashBoardCell")
        lblTitle.text = organizationName;
        organizationChannels(inputData: ["category":self.strSelectedCategory]);
        //filterAPI()
        filterCVSetup()
        lblNoData.isHidden = true;
        mdChipCard.isHidden = true;
        topConstaintTblMain?.constant = 1;
        tblMain.layoutIfNeeded()

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        self.btnUserName.setTitle(appDelegate.USER_NAME, for: .normal)
    }
    func filterCVSetup(){
        self.collectionViewFilter.dataSource = self
        self.collectionViewFilter.delegate = self
        
        self.collectionViewFilter.register(MDCChipCollectionViewCell.self, forCellWithReuseIdentifier: self.chipIdentifier)
        let chipsLayout = self.collectionViewFilter.collectionViewLayout as! MDCChipCollectionViewFlowLayout
        chipsLayout.minimumInteritemSpacing = 10.0
        chipsLayout.estimatedItemSize = CGSize(width: 60, height: 40)
        let XIB = UINib.init(nibName: "SectionHeader", bundle: nil)
        collectionViewFilter.register(XIB, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HeaderIdentifier)
    }
    func showAlert(strMsg: String){
        let alert = UIAlertController(title: "Alert", message: strMsg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    // MARK: Handler for organizationChannels API

    func organizationChannels(inputData:[String: Any]){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let url: String = appDelegate.baseURL +  "/organizationChannels"
        let params: [String: Any] = ["organization_id": orgId]
        print("organizationChannels params:",params)
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        AF.request(url, method: .post,  parameters: params, encoding: JSONEncoding.default)
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any] {
                        self.aryChannels = [Any]()
                        let aryData = json["Data"] as? [Any] ?? [Any]();
                        for (index,_) in aryData.enumerated(){
                            let arySub = aryData[index] as? [String: Any]
                            let arrayCategories = arySub?["channels"] as? [Any] ?? [Any]()
                            self.aryChannels += arrayCategories
                        }
                        if (aryData.count > 0){
                            self.lblNoData.isHidden = true;
                        }else{
                            self.aryChannels = [Any]()
                            self.lblNoData.isHidden = false;
                        }
                       
                        self.activityIndicator.isHidden = true;
                        self.activityIndicator.stopAnimating();
                        self.tblMain.reloadData()
                        
                    }
                case .failure(let error):
                    print(error)
                    self.activityIndicator.isHidden = true;
                    self.activityIndicator.stopAnimating();
                    self.showAlert(strMsg: error.localizedDescription)
                }
        }
    }
    
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true);
    }
    // MARK: Filter Events
    @IBAction func openFilter(_ sender: Any) {
//        if (mdChipCard.isHidden){
//            strSelectedCategory = "";
//            collectionViewFilter.reloadData()
//            mdChipCard.isHidden = false;
//            topConstaintTblMain?.constant = 236;
//            tblMain.layoutIfNeeded()
//        }else{
//            mdChipCard.isHidden = true;
//            topConstaintTblMain?.constant = 1;
//            tblMain.layoutIfNeeded()
//        }
       
    }
    @IBAction func clearFilter(_ sender: Any) {
        mdChipCard.isHidden = true;
        topConstaintTblMain?.constant = 1;
        tblMain.layoutIfNeeded()
        organizationChannels(inputData: ["category":""]);
    }
    @IBAction func applyFilter(_ sender: Any) {
        mdChipCard.isHidden = true;
        topConstaintTblMain?.constant = 1;
        tblMain.layoutIfNeeded()
        if (strSelectedCategory != ""){
            organizationChannels(inputData: ["category":self.strSelectedCategory]);
        }
    }
    // MARK: Handler for allCategories API, using for filters
    func filterAPI(){
        let url: String = appDelegate.baseURL +  "/categories"
        let params: [String: Any] = [:]
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        AF.request(url, method: .post,  parameters: params, encoding: JSONEncoding.default)
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any] {
                        if (json["statusCode"]as? String == "200"){
                            print(json["message"] as? String ?? "")
                            self.aryFilterCategoriesData = json["Data"] as? [Any] ?? [Any]();
                            print("--ary:",self.aryFilterCategoriesData.count)
                            //self.tblFilter.reloadData();
                            let indexSet = IndexSet(integer: 0)//reloading first section
                            self.collectionViewFilter.reloadSections(indexSet)
                            self.activityIndicator.isHidden = true;
                            self.activityIndicator.stopAnimating();
                        }else{
                            let strError = json["message"] as? String
                            print(strError ?? "")
                            self.showAlert(strMsg: strError ?? "")
                            self.activityIndicator.isHidden = true;
                            self.activityIndicator.stopAnimating();
                        }
                        
                    }
                case .failure(let error):
                    print(error)
                    self.activityIndicator.isHidden = true;
                    self.activityIndicator.stopAnimating();
                    self.showAlert(strMsg: error.localizedDescription)
                }
        }
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    //MARK:Tableview Delegates and Datasource Methods
    
    func numberOfSections(in tableView: UITableView) ->  Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return aryChannels.count;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) ->  CGFloat {
        return 180
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DashBoardCell", for: indexPath) as! DashBoardCell
        let rowArray = aryChannels;
        cell.updateCellWith(row: rowArray,controller: "channels")
        cell.cellDelegate = self
        return cell
    }
    func getColorByHex(rgbHexValue:UInt32, alpha:Double = 1.0) -> UIColor {
        let red = Double((rgbHexValue & 0xFF0000) >> 16) / 256.0
        let green = Double((rgbHexValue & 0xFF00) >> 8) / 256.0
        let blue = Double((rgbHexValue & 0xFF)) / 256.0
        
        return UIColor(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: CGFloat(alpha))
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let storyboard = UIStoryboard(name: "Main", bundle: nil);
//        let vc = storyboard.instantiateViewController(withIdentifier: "ChannelDetailVC") as! ChannelDetailVC
//        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    func collectionView(collectionviewcell: DBCollectionViewCell?, index: Int, didTappedInTableViewCell: DashBoardCell) {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        
        let orgsList = didTappedInTableViewCell.rowWithItems
        let selectedOrg = orgsList[index] as? [String: Any]
        print("selected channel:",selectedOrg)
          let storyboard = UIStoryboard(name: "Main", bundle: nil);
           let vc = storyboard.instantiateViewController(withIdentifier: "ChannelDetailVC") as! ChannelDetailVC
        vc.delegate = self
        vc.orgId = orgId;
//        print("userId:",selectedOrg?["user_id"] as Any)
        if (selectedOrg?["user_id"] as? Int) != nil {
            vc.performerId = selectedOrg?["user_id"] as! Int
        }
        else {
            vc.performerId = 1;
        }
           self.navigationController?.pushViewController(vc, animated: true)
       }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent // .default
    }
    
}
//MARK: Filter Collection View Data source and delegate methods

extension ChannelsVC: UICollectionViewDataSource , UICollectionViewDelegateFlowLayout{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: 100, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        // Dequeue Reusable Supplementary View
        if let supplementaryView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HeaderIdentifier, for: indexPath) as? SectionHeader {
            // Configure Supplementary View
            supplementaryView.titleLabel.text = sectionFilters[indexPath.section]
            return supplementaryView
        }
        
        fatalError("Unable to Dequeue Reusable Supplementary View")
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return self.aryFilterCategoriesData.count
        case 1:
            return self.aryFilterSubCategoriesData.count
        case 2:
            return self.aryFilterGenresData.count
            
        default:
            print("")
        }
        return 0;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.chipIdentifier, for: indexPath) as! MDCChipCollectionViewCell
        var selectedItem = [String : Any]()
        switch indexPath.section {
        case 0:
            selectedItem = self.aryFilterCategoriesData[indexPath.row] as?  [String : Any] ?? [:];
            cell.chipView.titleLabel.text = selectedItem["category"] as? String

        case 1:
            selectedItem = self.aryFilterSubCategoriesData[indexPath.row] as?  [String : Any] ?? [:];
            cell.chipView.titleLabel.text = selectedItem["subCategory"] as? String

        case 2:
            selectedItem = self.aryFilterGenresData[indexPath.row] as?  [String : Any] ?? [:];
            cell.chipView.titleLabel.text = selectedItem["genres"] as? String

        default:
            print("")
        }
        
        //        cell.chipView.titleLabel.font = UIFont.boldSystemFont(ofSize: 15)
        //        cell.chipView.titleLabel.textColor = .white
        let darkGreen = UIColor(red: 1, green: 29, blue: 39);
        cell.chipView.setBackgroundColor(darkGreen, for: .normal)
        let lightGreen = UIColor(red: 44, green: 66, blue: 74);
        cell.chipView.setBackgroundColor(lightGreen, for: .selected)
        cell.chipView.setBorderColor(.white, for: .normal)
        cell.chipView.setBorderWidth(0.5, for: .normal)
        cell.chipView.setTitleColor(.white, for: .normal)
        cell.chipView.titleFont = UIFont.boldSystemFont(ofSize: 15)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("section:",indexPath.section)
        print("row:",indexPath.row)
        if (indexPath.section == 0){
            let selectedItem = self.aryFilterCategoriesData[indexPath.row] as? [String : Any];
            let strValue = selectedItem?["category"] as? String;
            print("strValue cat:",strValue ?? "")
            self.strSelectedCategory = strValue ?? ""
            self.aryFilterSubCategoriesData = selectedItem?["subcategory"] as? [Any] ?? [Any]();
            self.aryFilterGenresData = selectedItem?["genre"] as? [Any] ?? [Any]();
            let indexSet = IndexSet(integersIn: 1...2)//reload 1,2 sections
            collectionViewFilter.reloadSections(indexSet)
        }else if (indexPath.section == 1){
            let selectedItem = aryFilterSubCategoriesData[indexPath.row] as? [String : Any];
            let strValue = selectedItem?["subCategory"] as? String;
            print("strValue sub:",strValue ?? "")
            self.strSelectedCategory = strValue ?? ""
        }
    }
    
    
    @objc func categoryPress(_ sender: UIButton) {
        print("tag:",sender.tag)
        //        if (self.aryFilterCategoriesData.count > sender.tag){
        //            let selectedItem = self.aryFilterCategoriesData[sender.tag] as? [String : Any];
        //            self.aryFilterSubCategoriesData = selectedItem?["subcategory"] as? [Any] ?? [Any]();
        //            self.aryFilterGenresData = selectedItem?["genre"] as? [Any] ?? [Any]();
        //        }
    }
}

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

class ChannelsVC: UIViewController,UITableViewDelegate,UITableViewDataSource,CollectionViewCellDelegate,OpenChanannelChatDelegate,UISearchBarDelegate{
    
    
    // MARK: - Variables Declaration
    @IBOutlet weak var tblMain: UITableView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    @IBOutlet weak var btnUserName: UIButton!
    @IBOutlet weak var topConstaintTblMain: NSLayoutConstraint?
    @IBOutlet weak var heightTopView: NSLayoutConstraint?
    @IBOutlet weak var viewTop: UIView!

    @IBOutlet weak var mdChipCard:MDCCard!
    var strSelectedCategory = "";
    @IBOutlet weak var collectionViewFilter: UICollectionView!
    var aryFilterCategoriesData = [Any]();
    var aryFilterSubCategoriesData = [Any]();
    var aryFilterGenresData = [Any]();
    private let chipIdentifier = "Chip"
    fileprivate let HeaderIdentifier = "Header"
    var sectionFilters = ["Sub Categories","Genres"]
    @IBOutlet weak var lblNoData: UILabel!
    
    var aryChannels = [Any]();
    var arySearchChannels = [Any]();
    var aryFilterChannels = [Any]();
    var orgId = 0;
    var organizationName = "Organization Name";
    var aryMainMenu :[[String: String]] = [["name":"House","icon":"channel1.png"],["name":"Bass","icon":"channel2.png"],["name":"Bass","icon":"channel4.png"],["name":"House","icon":"channel3.png"],["name":"House","icon":"channel4.png"],
                                           ["name":"Bass","icon":"channel1.png"],
                                           ["name":"Bass","icon":"channel2.png"],
                                           ["name":"House","icon":"channel3.png"],
                                           ["name":"Bass","icon":"channel2.png"],
                                           ["name":"House","icon":"channel3.png"]];
    @IBOutlet weak var viewActivity: UIView!
    var searchActive : Bool = false
    var searchToggle : Bool = false
    @IBOutlet weak var searchBar: UISearchBar!
    var strFilterValue = ""
    var subCategoryId = 0;
    var genreId = 0;
    var isFilter = false;
    // MARK: - View Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        viewActivity.isHidden = true
        self.searchBar.delegate = self
        searchBar.isHidden = true;
        topConstaintTblMain?.constant = 1;
        // Do any additional setup after loading the view.
        self.navigationController?.isNavigationBarHidden = true
        tblMain.register(UINib(nibName: "DashBoardCell", bundle: nil), forCellReuseIdentifier: "DashBoardCell")
        lblTitle.text = organizationName;
        let netAvailable = appDelegate.isConnectedToInternet()
        organizationChannels(inputData: ["category":self.strSelectedCategory]);
        //filterAPI()
        filterCVSetup()
        lblNoData.isHidden = true;
        mdChipCard.isHidden = true;
        topConstaintTblMain?.constant = 1;
        tblMain.layoutIfNeeded()
        
        searchBar.placeholder = "Search"
        searchBar.set(textColor: .white)
        searchBar.setTextField(color: UIColor.white.withAlphaComponent(0.3))
        searchBar.setPlaceholder(textColor: .white)
        searchBar.setSearchImage(color: .white)
        searchBar.setClearButton(color: .white)
        if(UIDevice.current.userInterfaceIdiom == .pad){
            let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 25.0), NSAttributedString.Key.foregroundColor: UIColor.white]
            UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = attributes
            heightTopView?.constant = 60;
            viewTop.layoutIfNeeded()
            btnUserName.layer.cornerRadius = btnUserName.frame.size.width/2
        }
        if(!netAvailable){
            showAlert(strMsg: "Please check your internet connection!")
            return
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        self.btnUserName.setTitle(appDelegate.USER_NAME, for: .normal)
        AppDelegate.AppUtility.lockOrientation(.portrait)

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
        ////print("organizationChannels params:",params)
        viewActivity.isHidden = false
        let headers: HTTPHeaders
        headers = [appDelegate.x_api_key: appDelegate.x_api_value]
        
        AF.request(url, method: .post,  parameters: params, encoding: JSONEncoding.default,headers:headers)
            .responseJSON { response in
                self.viewActivity.isHidden = true
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any] {
                        self.aryChannels = [Any]()
                        let aryData = json["Data"] as? [Any] ?? [Any]();
                        for (index,_) in aryData.enumerated(){
                            let arySub = aryData[index] as? [String: Any]
                            let arrayChannels = arySub?["channels"] as? [Any] ?? [Any]()
                            self.aryChannels += arrayChannels
                            let arrayCategories = arySub?["categories"] as? [Any] ?? [Any]()
                            self.aryFilterSubCategoriesData += arrayCategories
                            
                            let arrayGenres = arySub?["genres"] as? [Any] ?? [Any]()
                            self.aryFilterGenresData += arrayGenres
                        }
                        ////print("aryData:",aryData)
                        if (aryData.count > 0){
                            self.lblNoData.isHidden = true;
                        }else{
                            self.aryChannels = [Any]()
                            self.lblNoData.isHidden = false;
                        }
                        
                        ////print("subcate:",self.aryFilterSubCategoriesData.count)
                        ////print("genre:",self.aryFilterGenresData.count)
                        
                        self.collectionViewFilter.reloadData()
                        self.tblMain.reloadData()
                        
                    }
                case .failure(let error):
                  let errorDesc = error.localizedDescription.replacingOccurrences(of: "URLSessionTask failed with error:", with: "")
                    self.showAlert(strMsg: errorDesc)
                            self.viewActivity.isHidden = true

                }
        }
    }
    
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true);
    }
    // MARK: Filter Events
    @IBAction func openFilter(_ sender: Any) {
        searchBar.isHidden = true;
        searchToggle = false;
        searchActive = false;
        if (mdChipCard.isHidden){
            strSelectedCategory = "";
            collectionViewFilter.reloadData()
            mdChipCard.isHidden = false;
            topConstaintTblMain?.constant = mdChipCard.frame.size.height + 10;
            tblMain.layoutIfNeeded()
        }else{
            mdChipCard.isHidden = true;
            topConstaintTblMain?.constant = 1;
            tblMain.layoutIfNeeded()
        }
        
    }
    @IBAction func clearFilter(_ sender: Any) {
        let netAvailable = appDelegate.isConnectedToInternet()
        if(!netAvailable){
            showAlert(strMsg: "Please check your internet connection!")
            return
        }
        mdChipCard.isHidden = true;
        topConstaintTblMain?.constant = 1;
        tblMain.layoutIfNeeded()
        if(isFilter == true)
        {
            isFilter = false;
            tblMain.reloadData()
        }
        //organizationChannels(inputData: ["category":""]);
    }
    @IBAction func applyFilter(_ sender: Any) {
        let netAvailable = appDelegate.isConnectedToInternet()
        if(!netAvailable){
            showAlert(strMsg: "Please check your internet connection!")
            return
        }
        mdChipCard.isHidden = true;
        topConstaintTblMain?.constant = 1;
        isFilter = true;
        reloadFilterData()
        tblMain.layoutIfNeeded()
    }
    func reloadFilterData()
    {
        aryFilterChannels = [Any]()
        for (index,_) in aryChannels.enumerated(){
            let channelObj = aryChannels[index] as? [String: Any]
            if (strFilterValue == "subcategory"){
                let aryCatIds = channelObj?["category_ids"] as? [Any] ?? [Any]();
                
                for (index1,_) in aryCatIds.enumerated(){
                    let categoryId = aryCatIds[index1] as? Int ?? 0
                    if(subCategoryId == categoryId){
                        aryFilterChannels.append(channelObj ?? [:])
                        break
                    }
                }
            }else{
                let aryGenreIds = channelObj?["genre_ids"] as? [Any] ?? [Any]();
                for (index1,_) in aryGenreIds.enumerated(){
                   // ////print("--for 2")
                    let genreId = aryGenreIds[index1] as? Int ?? 0
                    if(self.genreId == genreId){
                        aryFilterChannels.append(channelObj ?? [:])
                       // ////print("--for 2 break")
                        break
                    }
                }
            }
            
        }
        ////print("aryFilteredChannels:",aryFilteredChannels)
        ////print("aryFilterChannels count:",aryFilterChannels.count)
        tblMain.reloadData()
    }
    // MARK: Handler for allCategories API, using for filters
    func filterAPI(){
        let url: String = appDelegate.baseURL +  "/categories"
        let params: [String: Any] = [:]
        viewActivity.isHidden = false
        let headers: HTTPHeaders
        headers = [appDelegate.x_api_key: appDelegate.x_api_value]
        
        AF.request(url, method: .post,  parameters: params, encoding: JSONEncoding.default,headers:headers)
            .responseJSON { response in
                self.viewActivity.isHidden = true
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any] {
                        if (json["statusCode"]as? String == "200"){
                            ////print(json["message"] as? String ?? "")
                            self.aryFilterCategoriesData = json["Data"] as? [Any] ?? [Any]();
                            ////print("--ary:",self.aryFilterCategoriesData.count)
                            //self.tblFilter.reloadData();
                            let indexSet = IndexSet(integer: 0)//reloading first section
                            self.collectionViewFilter.reloadSections(indexSet)
                            
                        }else{
                            let strError = json["message"] as? String
                            ////print(strError ?? "")
                            self.showAlert(strMsg: strError ?? "")
                        }
                        
                    }
                case .failure(let error):
                  let errorDesc = error.localizedDescription.replacingOccurrences(of: "URLSessionTask failed with error:", with: "")
                    self.showAlert(strMsg: errorDesc)
                            self.viewActivity.isHidden = true

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
        if (searchActive && arySearchChannels.count == 0){
            lblNoData.isHidden = false
        }else if(!searchActive && aryChannels.count == 0){
            lblNoData.isHidden = false
        }else{
            lblNoData.isHidden = true
        }
        return 1;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) ->  CGFloat {
        let screenRect = UIScreen.main.bounds
        let screenHeight = screenRect.size.height //for trending channels
        return screenHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DashBoardCell", for: indexPath) as! DashBoardCell
        if (searchActive){
            let rowArray = arySearchChannels;
            cell.updateCellWith(row: rowArray,controller: "channels")
        }else if (isFilter){
            let rowArray = aryFilterChannels;
            cell.updateCellWith(row: rowArray,controller: "channels")
        }else{
            let rowArray = aryChannels;
            cell.updateCellWith(row: rowArray,controller: "channels")
        }
        
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
    func collectionView(collectionviewcell: DBCollectionViewCell?, index: Int, title: String, didTappedInTableViewCell: DashBoardCell) {
        viewActivity.isHidden = false
        
        let orgsList = didTappedInTableViewCell.rowWithItems
        let selectedOrg = orgsList[index] as? [String: Any]
        ////print("selected channel:",selectedOrg)
        let storyboard = UIStoryboard(name: "Main", bundle: nil);
        let vc = storyboard.instantiateViewController(withIdentifier: "ChannelDetailVC") as! ChannelDetailVC
        vc.delegate = self
        vc.orgId = orgId;
        appDelegate.isLiveLoad = "1"
        //        ////print("userId:",selectedOrg?["user_id"] as Any)
        if (selectedOrg?["user_id"] as? Int) != nil {
            vc.performerId = selectedOrg?["user_id"] as! Int
        }
        else {
            vc.performerId = 1;
        }
        vc.strTitle = selectedOrg?["performer_display_name"] as? String ?? "Channel Details"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent // .default
    }
    override func viewDidDisappear(_ animated: Bool) {
        viewActivity.isHidden = true
    }
    
}
//MARK: Filter Collection View Data source and delegate methods

extension ChannelsVC: UICollectionViewDataSource , UICollectionViewDelegateFlowLayout{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sectionFilters.count
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
            return self.aryFilterSubCategoriesData.count
        case 1:
            return self.aryFilterGenresData.count
        default:
            break
        }
        return 0;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.chipIdentifier, for: indexPath) as! MDCChipCollectionViewCell
        var selectedItem = [String : Any]()
        switch indexPath.section {
        case 0:
            selectedItem = self.aryFilterSubCategoriesData[indexPath.row] as?  [String : Any] ?? [:];
            cell.chipView.titleLabel.text = selectedItem["category_name"] as? String
            
        case 1:
            selectedItem = self.aryFilterGenresData[indexPath.row] as?  [String : Any] ?? [:];
            cell.chipView.titleLabel.text = selectedItem["genre_name"] as? String
            
        default:
            ////print("")
            break
        }
        
        //        cell.chipView.titleLabel.font = UIFont.boldSystemFont(ofSize: 15)
        //        cell.chipView.titleLabel.textColor = .white
        //let darkGreen = UIColor(red: 1, green: 29, blue: 39);
        cell.chipView.setBackgroundColor(.darkGray, for: .normal)
        //let lightGreen = UIColor(red: 44, green: 100, blue: 74);
        cell.chipView.setBackgroundColor(.lightGray, for: .selected)
        cell.chipView.setBorderColor(.white, for: .normal)
        cell.chipView.setBorderWidth(0.5, for: .normal)
        cell.chipView.setTitleColor(.white, for: .normal)
        if(UIDevice.current.userInterfaceIdiom == .pad){
                   cell.chipView.titleFont = UIFont.boldSystemFont(ofSize: 25)
               }else{
                   cell.chipView.titleFont = UIFont.boldSystemFont(ofSize: 15)
               }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        ////print("section:",indexPath.section)
        ////print("row:",indexPath.row)
        if (indexPath.section == 0){
            let selectedItem = aryFilterSubCategoriesData[indexPath.row] as? [String : Any];
            let catId = selectedItem?["id"] as? Int ?? 0;
            _ = selectedItem?["category_name"] as? String ?? ""
            strFilterValue = "subcategory"
            self.subCategoryId = catId;
        }else if (indexPath.section == 1){
            let selectedItem = aryFilterGenresData[indexPath.row] as? [String : Any];
            let genreId = selectedItem?["id"] as? Int ?? 0;
            _ = selectedItem?["genre_name"] as? String ?? ""
            strFilterValue = "genre"
            self.genreId = genreId;
        }
    }
    
    
    @objc func categoryPress(_ sender: UIButton) {
        ////print("tag:",sender.tag)
        //        if (self.aryFilterCategoriesData.count > sender.tag){
        //            let selectedItem = self.aryFilterCategoriesData[sender.tag] as? [String : Any];
        //            self.aryFilterSubCategoriesData = selectedItem?["subcategory"] as? [Any] ?? [Any]();
        //            self.aryFilterGenresData = selectedItem?["genre"] as? [Any] ?? [Any]();
        //        }
    }
    //MARK: UISearchbar delegate
    @IBAction func searchTapped(_ sender: UIButton){
        searchToggle = !searchToggle
        searchBar.text = "";
        if(!mdChipCard.isHidden){
            mdChipCard.isHidden = true;
        }
        //isFilter = false;
        if (searchToggle){
            searchBar.isHidden = false;
            topConstaintTblMain?.constant = 60;
            tblMain.layoutIfNeeded()
        }else{
            searchBar.isHidden = true;
            topConstaintTblMain?.constant = 1;
            tblMain.layoutIfNeeded()
            if (searchActive){
                searchActive = false;
                tblMain.reloadData()
            }
        }
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchActive = false;
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = "";
        searchBar.resignFirstResponder()
        searchActive = false;
        self.tblMain.reloadData()
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            //when user press X icon
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                searchBar.resignFirstResponder()
            }
            searchActive = false;
            self.tblMain.reloadData()
            
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        let searchString = searchBar.text!
        if (searchString.count > 0){
            searchActive = true;
            let namePredicate = NSPredicate(format: "performer_display_name contains[c] %@",searchString);
            if (isFilter){
                arySearchChannels = aryFilterChannels.filter { namePredicate.evaluate(with: $0) };
            }else{
                arySearchChannels = aryChannels.filter { namePredicate.evaluate(with: $0) };
            }
            tblMain.reloadData()
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        AppDelegate.AppUtility.lockOrientation(.all)
    }
    
    

}

//
//  SearchViewController.swift
//  AreveaTV
//
//  Created by apple on 6/5/20.
//  Copyright © 2020 apple. All rights reserved.
//

import UIKit
import Alamofire

import MaterialComponents.MaterialCollections

class SearchViewController: UIViewController , UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource,CollectionViewCellDelegate{
    // MARK: - Variables Declaration
    
    var searchActive : Bool = false
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var viewActivity: UIView!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var searchList = [Any]()
    var aryCategories = Array<Any>()
    var arySubCategories = [Any]()
    var aryGenres = [Any]()
    @IBOutlet weak var lblNoData: UILabel!
    var aryFilterCategoriesData = [Any]();
    var aryFilterSubCategoriesData = [Any]();
    var aryFilterGenresData = [Any]();
    @IBOutlet weak var tblMain: UITableView!
    @IBOutlet weak var mdChipCard:MDCCard!
    @IBOutlet weak var topConstaintTblMain: NSLayoutConstraint?
    var sectionFilters = ["Categories","Sub Categories","Genres"]
    private let chipIdentifier = "Chip"
    fileprivate let HeaderIdentifier = "Header"
    @IBOutlet weak var collectionViewFilter: UICollectionView!
    
    // MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        viewActivity.isHidden = true
        // Do any additional setup after loading the view.
        self.navigationController?.isNavigationBarHidden = true
        self.searchBar.delegate = self
        tblMain.register(UINib(nibName: "DashBoardCell", bundle: nil), forCellReuseIdentifier: "DashBoardCell")
        topConstaintTblMain?.constant = 1;
        tblMain.layoutIfNeeded()
        getSearchResults()
        filterCVSetup()
        
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
        collectionViewFilter.showsVerticalScrollIndicator = true
    }
    func showAlert(strMsg: String){
        let alert = UIAlertController(title: "Alert", message: strMsg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    //MARK:Tableview Delegates and Datasource Methods
    
    func numberOfSections(in tableView: UITableView) ->  Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (searchList.count > 0){
            lblNoData.isHidden = true;
            return 1;
        }else{
            lblNoData.isHidden = false;
            return 0;
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) ->  CGFloat {
        return 180;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // let cell = myTableView.dequeueReusableCell(withIdentifier: "DashBoardCell", for: indexPath) as! DashBoardCell
        let cell = tblMain.dequeueReusableCell(withIdentifier: "DashBoardCell", for: indexPath) as! DashBoardCell
        cell.updateCellWith(row: searchList,controller: "dashboard_search")
        cell.cellDelegate = self
        return cell
    }
    func collectionView(collectionviewcell: DBCollectionViewCell?, index: Int, didTappedInTableViewCell: DashBoardCell) {
        
        let orgsList = didTappedInTableViewCell.rowWithItems
        let selectedOrg = orgsList[index] as? [String: Any]
        print("item:\(String(describing: selectedOrg))")
    }
    // MARK: Handler for getCategoryOrganisations API
    func getSearchResults(){
        let url: String = "https://3ptsrb2obj.execute-api.us-east-1.amazonaws.com/dev/?q=red*"
        viewActivity.isHidden = false
        //print("getCategoryOrganisations input:",inputData)
        let headers: HTTPHeaders
        headers = [appDelegate.securityKey: appDelegate.securityValue]
        AF.request(url, method: .get,encoding: JSONEncoding.default,headers:headers)
            .responseJSON { response in
                self.viewActivity.isHidden = true
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any] {
                        print("getSearchResults json:",json)
                        let resultObj = json["hits"] as? [String: Any]
                        let hitArray = resultObj?["hit"] as? [Any] ?? [Any]();
                        print("--count:",self.searchList.count )
                        
                        self.searchList = []
                        self.aryGenres = []
                        self.aryCategories = []
                        self.arySubCategories = []
                        for (index,_) in hitArray.enumerated(){
                            let element = hitArray[index] as? [String: Any]
                            let fields = element?["fields"]
                            self.searchList.append(fields ?? [Any]())
                        }
                        for (index,_) in self.searchList.enumerated(){
                            let element = self.searchList[index] as? [String: Any]
                            let category = element?["category"] as? [Any]
                            let subCategory = element?["subcategories"]as? [Any]
                            let genre = element?["genres"]as? [Any]
                            self.aryFilterCategoriesData.append(category ?? Array<Any>())
                            self.aryFilterSubCategoriesData.append(subCategory ?? [Any]())
                            self.aryFilterGenresData.append(genre ?? [Any]())
                        }
                        print("searchList count:",self.searchList.count)
                        //                        print("aryCategories count:",self.aryCategories.count)
                        //                        print("arySubCategories count:",self.arySubCategories.count)
                        //                        print("aryGenres count:",self.aryGenres.count)
                        //
                        //                        print("aryCategories:",self.aryCategories)
                        //                        print("arySubCategories:",self.arySubCategories)
                        //                        print("aryGenres:",self.aryGenres)
                        
                        let array = ["one", "one", "two", "two", "three", "three"]
                        let unique1 = Array(Set(array))
                        print("unique1:",unique1)
                        self.tblMain.reloadData()
                        self.collectionViewFilter.reloadData()
                        
                    }
                //searchList
                case .failure(let error):
                    //print(error)
                    self.showAlert(strMsg: error.localizedDescription)
                }
        }
    }
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true);
    }
    // MARK: Filter Events
    @IBAction func openFilter(_ sender: Any) {
        if (mdChipCard.isHidden){
            mdChipCard.isHidden = false
            topConstaintTblMain?.constant = 236;
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
        //getCategoryOrganisations(inputData: ["category":""]);
    }
    @IBAction func applyFilter(_ sender: Any) {
        let netAvailable = appDelegate.isConnectedToInternet()
        if(!netAvailable){
            showAlert(strMsg: "Please check your internet connection!")
            return
        }
        
        mdChipCard.isHidden = true;
        topConstaintTblMain?.constant = 1;
        tblMain.layoutIfNeeded()
        //        if (strSelectedCategory != ""){
        //            getCategoryOrganisations(inputData: ["category":self.strSelectedCategory]);
        //        }
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    //MARK: UISearchbar delegate
    @IBAction func searchTapped(_ sender: UIButton){
        
        //https://3ptsrb2obj.execute-api.us-east-1.amazonaws.com/dev/?q=red*
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
        //self.tblMain.reloadData()
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            //when user press X icon
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                searchBar.resignFirstResponder()
            }
            searchActive = false;
            //self.tblMain.reloadData()
        }
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        let searchString = searchBar.text!
        if (searchString.count > 0){
            searchActive = true;
            let namePredicate = NSPredicate(format: "stream_video_title contains[c] %@",searchString);
            //print("--count:",aryFilteredSubCategories.count)
            // tblMain.reloadData()
            
        }
        
        
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent // .default
    }
    
}
//MARK: Filter Collection View Data source and delegate methods

extension SearchViewController: UICollectionViewDataSource , UICollectionViewDelegateFlowLayout{
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
        var selectedItem = [Any]()
        switch indexPath.section {
        case 0:
            selectedItem = self.aryFilterCategoriesData[indexPath.row] as?  [Any] ?? [Any]();
            cell.chipView.titleLabel.text = selectedItem[0] as? String
            
        case 1:
            selectedItem = self.aryFilterSubCategoriesData[indexPath.row] as?  [Any] ?? [Any]();
            cell.chipView.titleLabel.text = selectedItem[0] as? String
        case 2:
            selectedItem = self.aryFilterGenresData[indexPath.row] as?  [Any] ?? [Any]();
            cell.chipView.titleLabel.text = selectedItem[0] as? String
            
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
        cell.chipView.isMultipleTouchEnabled = true;
        //cell.chipView.showChipsDeleteButton = true
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("section:",indexPath.section)
        print("row:",indexPath.row)
        
    }
}

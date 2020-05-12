//
//  DashBoard.swift
//  AreveaTV
//
//  Created by apple on 4/18/20.
//  Copyright © 2020 apple. All rights reserved.
//

import UIKit
import AWSMobileClient
import Alamofire
import MaterialComponents.MaterialCollections


extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}
class DashBoardVC: UIViewController,UITableViewDelegate,UITableViewDataSource,CollectionViewCellDelegate,UITextFieldDelegate{
    //MARK: Variables Declaration
    
    private let chipIdentifier = "Chip"
    fileprivate let HeaderIdentifier = "Header"
    @IBOutlet weak var tblMain: UITableView!
    @IBOutlet weak var tblSide: UITableView!
    @IBOutlet weak var viewSideMenu: UIView!
    @IBOutlet weak var txtCategory: UITextField!
    @IBOutlet weak var txtSubCategory: UITextField!
    @IBOutlet weak var txtGenres: UITextField!
    @IBOutlet weak var btnUserName: UIButton!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var mdChipCard:MDCCard!
    @IBOutlet weak var topConstaintTblMain: NSLayoutConstraint?
    @IBOutlet weak var leftConstraintLeftMenu: NSLayoutConstraint?
    
    @IBOutlet weak var lblNoData: UILabel!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var pickerView :UIPickerView!
    var aryData = [Any]();
    var arySubCategories = [Any]();
    var aryChannelData = [Any]();
    var aryFilterCategoriesData = [Any]();
    var aryFilterSubCategoriesData = [Any]();
    var aryFilterGenresData = [Any]();
    var isCategory = false;
    var isSubCategory = false;
    var isGenre = false;
    var strSelectedCategory = "";
    @IBOutlet weak var collectionViewFilter: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var arySideMenu : [[String: String]] = [["name":"Home","icon":"house.fill"],["name":"My Profile","icon":"person.circle.fill"],["name":"Logout","icon":"logout-icon.png"]];
    
    var aryMainMenu :[[String: String]] = [["name":"House","icon":"channel1.png"],["name":"Bass","icon":"channel1.png"],["name":"Artists","icon":"channel1.png"],["name":"Faq","icon":"channel1.png"],["name":"Logout","icon":"channel1.png"]];
    
    var arySections = [["name":"Live Events"],["name":"Artists"],["name":"Channels"],["name":"Continue Watching"]];
    
    
    //var aryFilterSections = ["Categories","Sub Categories","Genres"];
    var buttonNames = ["Comments", "Info", "Tip", "Share","Profile","Upcoming", "Videos", "Audios", "Followers"]
    
    var sectionFilters = ["Categories","Sub Categories","Genres"]
    //MARK:View Life Cycle Methods
    var chips = ["Section 0","test","hi","how r u","ghfyjgujhikn","bcuyjhbkjhuyfdtxesdfyt"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationController?.isNavigationBarHidden = true
        
        tblMain.register(UINib(nibName: "DashBoardCell", bundle: nil), forCellReuseIdentifier: "DashBoardCell")
        tblSide.register(UINib(nibName: "SideMenuCell", bundle: nil), forCellReuseIdentifier: "SideMenuCell")
        self.viewSideMenu.isHidden = true
        assignbackground();
        _ = Testbed.sharedInstance
        _ = Testbed.dictionary
        _ = Testbed.testAtIndex(index: 0)
        getCategoryOrganisations(inputData: ["":""]);
        filterAPI();
        self.lblUserName.text = self.appDelegate.USER_NAME_FULL
        self.btnUserName.setTitle(self.appDelegate.USER_NAME, for: .normal)
        //organizationChannels();
        filterCVSetup()
        lblNoData.isHidden = true;
        
        mdChipCard.isHidden = true;
        topConstaintTblMain?.constant = 1;
        tblMain.layoutIfNeeded()
        
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
    func assignbackground(){
        let background = UIImage(named: "sidemenu-bg")
        self.viewSideMenu.backgroundColor = UIColor(patternImage:background!)
    }
    override func viewWillDisappear(_ animated: Bool) {
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        self.btnUserName.setTitle(appDelegate.USER_NAME, for: .normal)
    }
    func showAlert(strMsg: String){
        let alert = UIAlertController(title: "Alert1", message: strMsg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    // MARK: Handler for getCategoryOrganisations API
    func getCategoryOrganisations(inputData:[String: Any]){
        let url: String = appDelegate.baseURL +  "/getCategoryOrganisations"
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        print("getCategoryOrganisations input:",inputData)
        
        AF.request(url, method: .post,  parameters: inputData, encoding: JSONEncoding.default)
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any] {
                        if (json["statusCode"]as? String == "200"){
                            print(json["message"] as? String ?? "")
                            self.arySubCategories = [Any]()
                            self.aryData = json["Data"] as? [Any] ?? [Any]();
                            for (index,_) in self.aryData.enumerated(){
                                let arySub = self.aryData[index] as? [String: Any]
                                let arrayCategories = arySub?["subCategories"] as? [Any] ?? [Any]()
                                self.arySubCategories += arrayCategories
                            }
                            if (self.aryData.count > 0){
                                self.lblNoData.isHidden = true;
                            }else{
                                self.arySubCategories = [Any]()
                                self.lblNoData.isHidden = false;
                            }
                            self.tblMain.reloadData();
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
    
    func logout()
    {
        AWSMobileClient.sharedInstance().signOut() { error in
            if let error = error {
                print(error)
                return
            }
        }
        var isLoginExists = false
        for controller in self.navigationController!.viewControllers as Array {
            if controller.isKind(of: LoginVC.self) {
                self.navigationController!.popToViewController(controller, animated: true)
                isLoginExists = true;
                break
            }
        }
        if (!isLoginExists){
            let storyboard = UIStoryboard(name: "Main", bundle: nil);
            let vc = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    func showConfirmation(strMsg: String){
        let alert = UIAlertController(title: "Alert", message: strMsg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            self.hideSideMenu()
            self.logout();
        }))
        DispatchQueue.main.async {
            self.present(alert, animated: true)
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
        if (tableView == tblMain){
            return arySubCategories.count;
        }
        return 1;
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (tableView == tblMain){
            return 44
        }
        return 0;
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if (tableView == tblMain){
            let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 44))
            let darkGreen = UIColor(red: 1, green: 29, blue: 39);
            view.backgroundColor = darkGreen;
            let label = UILabel(frame: CGRect(x: 15, y: 0, width: tableView.bounds.width - 30, height: 44))
            label.font = UIFont.boldSystemFont(ofSize: 15)
            label.textColor = UIColor.white
            if(tableView == tblMain){
                let section = self.arySubCategories[section] as? [String : Any];
                let categoryName = section?["parent_category_name"] as? String;
                let name = section?["subCategory"] as? String;
                label.text = (categoryName ?? "") + " - " + (name ?? "");
                view.addSubview(label)
            }
            return view
        }
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 0))
        return view
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tableView == tblMain){
            return 1;
        }
        return arySideMenu.count;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) ->  CGFloat {
        if (tableView == tblMain){
            return 180;
        }
        return 44;
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // let cell = myTableView.dequeueReusableCell(withIdentifier: "DashBoardCell", for: indexPath) as! DashBoardCell
        if (tableView == tblMain){
            let cell = tblMain.dequeueReusableCell(withIdentifier: "DashBoardCell", for: indexPath) as! DashBoardCell
            let arySub = arySubCategories[indexPath.section] as? [String: Any]
            let organizations = arySub?["organizations"] as? [Any]
            _ = indexPath.row;
            
            guard let rowArray = organizations else { return cell };
            cell.updateCellWith(row: rowArray,controller: "dashboard")
            cell.cellDelegate = self
            return cell
        }
        else{
            let cell = tblSide.dequeueReusableCell(withIdentifier: "SideMenuCell", for: indexPath) as! SideMenuCell
            let selectedItem = arySideMenu[indexPath.row];
            cell.lblName.text =  selectedItem["name"];
            let imageNamed = selectedItem["icon"];
            if (indexPath.row == 0 || indexPath.row == 1){
                if #available(iOS 13.0, *) {
                    cell.imgItem.image = UIImage(systemName: imageNamed!)
                } else {
                    // Fallback on earlier versions
                };
                cell.imgItem.tintColor = .white;
            }else{
                cell.imgItem.image = UIImage(named:imageNamed!)
                
            }
            cell.backgroundColor = .clear
            return cell;
        }
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if (tableView == tblMain){
            
        }
        else{
            let selectedItem = arySideMenu[indexPath.row];
            let name = selectedItem["name"];
            switch  name{
            case "Logout":
                showConfirmation(strMsg: "Are you sure you want to logout?")
            case "My Profile":
                hideSideMenu()
                let storyboard = UIStoryboard(name: "Main", bundle: nil);
                let vc = storyboard.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
                self.navigationController?.pushViewController(vc, animated: true)
            default:
                hideSideMenu()
                print ("default")
            }
            
        }
        
    }
    func showSideMenu(){
        viewSideMenu.isHidden = false;
        
        self.leftConstraintLeftMenu?.constant = -(self.view.frame.size.width-70);
        self.viewSideMenu.layoutIfNeeded()
        
        let movementDistance:CGFloat = (self.view.frame.size.width-70);
        var movement:CGFloat = 0
        movement = movementDistance
        UIView.animate(withDuration: 1.0, animations: {
            self.viewSideMenu.frame = self.viewSideMenu.frame.offsetBy(dx: movement, dy: 0)
        })
        
    }
    func hideSideMenu(){
        let movementDistance:CGFloat = (self.view.frame.size.width-70);
        var movement:CGFloat = 0
        movement = -movementDistance
        UIView.animate(withDuration: 1.0, animations: {
            self.viewSideMenu.frame = self.viewSideMenu.frame.offsetBy(dx: movement, dy: 0)
        })
    }
    @IBAction func sideMenuToggle(_ sender: Any) {
        showSideMenu();
    }
    @IBAction func viewBGTapped(_ sender: Any) {
        hideSideMenu()
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent // .default
    }
    
    func collectionView(collectionviewcell: DBCollectionViewCell?, index: Int, didTappedInTableViewCell: DashBoardCell) {
        hideSideMenu()
        let orgsList = didTappedInTableViewCell.rowWithItems
        let selectedOrg = orgsList[index] as? [String: Any]
        print("item:\(String(describing: selectedOrg))")
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil);
        let vc = storyboard.instantiateViewController(withIdentifier: "ChannelsVC") as! ChannelsVC
        vc.orgId = selectedOrg?["id"] as? Int ?? 0
        if (selectedOrg?["organization_name"]as? String != nil){
            vc.organizationName = selectedOrg?["organization_name"] as! String
        }
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    // MARK: Filter Events
    @IBAction func openFilter(_ sender: Any) {
        if (mdChipCard.isHidden){
            strSelectedCategory = "";
            aryFilterGenresData = [Any]()
            aryFilterSubCategoriesData = [Any]()
            collectionViewFilter.reloadData()
            mdChipCard.isHidden = false;
            topConstaintTblMain?.constant = 236;
            tblMain.layoutIfNeeded()
        }else{
            mdChipCard.isHidden = true;
            topConstaintTblMain?.constant = 1;
            tblMain.layoutIfNeeded()
        }
        
    }
    @IBAction func clearFilter(_ sender: Any) {
        mdChipCard.isHidden = true;
        topConstaintTblMain?.constant = 1;
        tblMain.layoutIfNeeded()
        getCategoryOrganisations(inputData: ["category":""]);
    }
    @IBAction func applyFilter(_ sender: Any) {
        mdChipCard.isHidden = true;
        topConstaintTblMain?.constant = 1;
        tblMain.layoutIfNeeded()
        if (strSelectedCategory != ""){
            getCategoryOrganisations(inputData: ["category":self.strSelectedCategory]);
        }
    }
    
    // MARK: Handler for allCategories API, using for filters
    func filterAPI(){
        let url: String = appDelegate.baseURL +  "/allCategories"
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
    
    
}
//MARK: Filter Collection View Data source and delegate methods

extension DashBoardVC: UICollectionViewDataSource , UICollectionViewDelegateFlowLayout{
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

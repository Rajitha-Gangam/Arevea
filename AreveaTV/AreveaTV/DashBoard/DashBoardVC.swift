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
class DashBoardVC: UIViewController,UITableViewDelegate,UITableViewDataSource,CollectionViewCellDelegate,UITextFieldDelegate,OpenChanannelChatDelegate,UISearchBarDelegate{
    
    //MARK: Variables Declaration
    private let chipIdentifier = "Chip"
    fileprivate let HeaderIdentifier = "Header"
    @IBOutlet weak var tblMain: UITableView!
    @IBOutlet weak var tblSide: UITableView!
    @IBOutlet weak var viewSideMenu: UIView!
    
    @IBOutlet weak var btnUserName: UIButton!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var mdChipCard:MDCCard!
    @IBOutlet weak var topConstaintTblMain: NSLayoutConstraint?
    @IBOutlet weak var leftConstraintLeftMenu: NSLayoutConstraint?
    
    @IBOutlet weak var lblNoData: UILabel!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var aryData = [Any]();
    var arySubCategories = [Any]();
    var aryChannelData = [Any]();
    var aryLiveChannelsData = [Any]();
    
    var aryFilterCategoriesData = [Any]();
    var aryFilterSubCategoriesData = [Any]();
    var aryFilterGenresData = [Any]();
    var isCategory = false;
    var isSubCategory = false;
    var isGenre = false;
    var strSelectedCategory = "";
    var isProfileLoaded = false;
    @IBOutlet weak var collectionViewFilter: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet var imgProfilePic: UIImageView!
    var aryFilteredLiveEvents = [Any]();
    var aryFilteredSubCategories = [Any]();
    
    var arySideMenu : [[String: String]] = [["name":"Home","icon":"home.png"],["name":"My Profile","icon":"user.png"],["name":"Payment History","icon":"donation-icon.png"],["name":"Help","icon":"help-icon.png"],["name":"Logout","icon":"logout-icon.png"]];
    
    var sectionFilters = ["Categories","Sub Categories","Genres"]
    var genreId = 0;
    var isSelectedGenre = false;
    //MARK:View Life Cycle Methods
    var searchActive : Bool = false
    var searchToggle : Bool = false
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var viewActivity: UIView!
    
    // MARK: - View Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        viewActivity.isHidden = true
        // Do any additional setup after loading the view.
        self.navigationController?.isNavigationBarHidden = true
        
        tblMain.register(UINib(nibName: "DashBoardCell", bundle: nil), forCellReuseIdentifier: "DashBoardCell")
        tblSide.register(UINib(nibName: "SideMenuCell", bundle: nil), forCellReuseIdentifier: "SideMenuCell")
        self.searchBar.delegate = self
        self.viewSideMenu.isHidden = true
        assignbackground();
        _ = Testbed.sharedInstance
        _ = Testbed.dictionary
        _ = Testbed.testAtIndex(index: 0)
        
        filterAPI();
        ongoingEvents()
        
        
        //organizationChannels();
        filterCVSetup()
        lblNoData.isHidden = true;
        mdChipCard.isHidden = true;
        searchBar.isHidden = true;
        topConstaintTblMain?.constant = 1;
        tblMain.layoutIfNeeded()
        UserDefaults.standard.set("false", forKey: "is_profile_pic_loaded_left_menu")
        
        let netAvailable = appDelegate.isConnectedToInternet()
        if(!netAvailable){
            showAlert(strMsg: "Please check your internet connection!")
            return
        }
        
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
        self.lblUserName.text = self.appDelegate.USER_NAME_FULL
        self.btnUserName.setTitle(appDelegate.USER_NAME, for: .normal)
        getCategoryOrganisations(inputData: ["":""]);
        let is_profile_pic_loaded_left_menu = UserDefaults.standard.string(forKey: "is_profile_pic_loaded_left_menu");
        if(is_profile_pic_loaded_left_menu == "false"){
            getProfile()
        }
        
    }
    func showAlert(strMsg: String){
        let alert = UIAlertController(title: "Alert", message: strMsg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    // MARK: Handler for ongoingEvents(Live Events) API
    func ongoingEvents(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let url: String = appDelegate.baseURL +  "/ongoingEvents"
        viewActivity.isHidden = false
        let headers: HTTPHeaders
        headers = [appDelegate.securityKey: appDelegate.securityValue]
        
        AF.request(url, method: .get, encoding: JSONEncoding.default,headers:headers)
            .responseJSON { response in
                self.viewActivity.isHidden = true
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any] {
                        //print("ongoingEvents JSON:",json)
                        self.aryLiveChannelsData  = json["Data"] as? [Any] ?? [Any]();
                        print("ongoingEvents count:",self.aryLiveChannelsData.count)
                        self.tblMain.reloadData()
                    }
                case .failure(let error):
                    //print(error)
                    self.showAlert(strMsg: error.localizedDescription)
                }
        }
    }
    // MARK: Handler for getCategoryOrganisations API
    func getCategoryOrganisations(inputData:[String: Any]){
        let url: String = appDelegate.baseURL +  "/getCategoryOrganisations"
        viewActivity.isHidden = false
        //print("getCategoryOrganisations input:",inputData)
        let headers: HTTPHeaders
        headers = [appDelegate.securityKey: appDelegate.securityValue]
        AF.request(url, method: .post,  parameters: inputData,encoding: JSONEncoding.default, headers:headers)
            .responseJSON { response in
                self.viewActivity.isHidden = true

                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any] {
                        //print("getCategoryOrganisations json:",json)
                        if (json["statusCode"]as? String == "200"){
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
                               // self.lblNoData.isHidden = false;
                            }
                            if (self.isSelectedGenre){
                                self.reloadFilterGenreData()
                            }else{
                                self.tblMain.reloadData();
                            }
                        }else{
                            let strError = json["message"] as? String
                            //print(strError ?? "")
                            self.showAlert(strMsg: strError ?? "")
                        }
                        
                    }
                case .failure(let error):
                    //print(error)
                    self.showAlert(strMsg: error.localizedDescription)
                }
        }
    }
    func reloadFilterGenreData()
       {
        var aryFilterOrgs = [Any]()
        var dicSubCategory = [String:Any]()
          for (index,_) in self.arySubCategories.enumerated(){
              let arySub = arySubCategories[index] as? [String: Any]
              let organizations = arySub?["organizations"] as? [Any] ?? [Any]()
            for (j,_)in organizations.enumerated(){
                let org = organizations[j] as? [String: Any] ?? [:]
                let genreIds = org["genres"] as? [Any] ?? [Any]()
                let genrePredicate = NSPredicate(format: "SELF == %d",self.genreId);
                
                let arySubCategories1 = genreIds.filter { genrePredicate.evaluate(with: $0) };
                if (arySubCategories1.count > 0){
                    aryFilterOrgs.append(org)
                }
            }
            dicSubCategory =  ["organizations":aryFilterOrgs,"parent_category_name":arySub?["parent_category_name"] as? String ?? "",
            "subCategory":arySub?["subCategory"] as? String ?? ""] as [String : Any]
          }
        self.arySubCategories = [Any]()
        self.arySubCategories.append(dicSubCategory);
        self.tblMain.reloadData()

       }
    // MARK: Handler for performerEvents API, using for upcoming schedules
    func getProfile(){
        let netAvailable = appDelegate.isConnectedToInternet()
        if(!netAvailable){
            showAlert(strMsg: "Please check your internet connection!")
            return
        }
        viewActivity.isHidden = false
        let httpMethodName = "POST"
        let URLString: String = "/getProfile"
        let user_id = UserDefaults.standard.string(forKey: "user_id");
        let user_type = UserDefaults.standard.string(forKey: "user_type");
        let params: [String: Any] = ["user_id":user_id ?? "","user_type":user_type ?? ""]
        
        let headerParameters = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        // Construct the request object
        let apiRequest = AWSAPIGatewayRequest(httpMethod: httpMethodName,
                                              urlString: URLString,
                                              queryParameters: [:],
                                              headerParameters: headerParameters,
                                              httpBody: params)
        // Fetch the Cloud Logic client to be used for invocation
        let invocationClient = AreveaAPIClient.client(forKey:appDelegate.AWSCognitoIdentityPoolId)
        invocationClient.invoke(apiRequest).continueWith { (task: AWSTask) -> Any? in
            if let error = task.error {
                print("Error occurred: \(error)")
                self.showAlert(strMsg: error as? String ?? error.localizedDescription)
                // Handle error here
                return nil
            }
            // Handle successful result here
            let result = task.result!
            let responseString = String(data: result.responseData!, encoding: .utf8)
            let data = responseString!.data(using: .utf8)!
            do {
                let resultObj = try JSONSerialization.jsonObject(with: data, options : .allowFragments)
                DispatchQueue.main.async {
                    
                    //print(resultObj)
                    if let json = resultObj as? [String: Any] {
                        print("getProfile:",json)
                        if (json["status"]as? Int == 0){
                            // //print(json["message"] ?? "")
                            let profile_data = json["profile_data"] as? [String:Any] ?? [:]
                            let fn = profile_data["user_first_name"] as? String
                            let ln = profile_data["user_last_name"]as? String
                            let strName = String((fn?.first ?? "A")) + String((ln?.first ?? "B"))
                            self.appDelegate.USER_NAME = strName;
                            self.appDelegate.USER_NAME_FULL = (fn ?? "") + " " + (ln ?? "")
                            UserDefaults.standard.set(self.appDelegate.USER_NAME, forKey: "USER_NAME")
                            UserDefaults.standard.set(self.appDelegate.USER_NAME_FULL, forKey: "USER_NAME_FULL")
                            self.lblUserName.text = self.appDelegate.USER_NAME_FULL
                            self.btnUserName.setTitle(self.appDelegate.USER_NAME, for: .normal)
                            
                            let strURL = profile_data["profile_pic"]as? String ?? ""
                                if let url = URL(string: strURL){
                                    self.downloadImage(from: url as URL, imageView: self.imgProfilePic)
                                }else{
                                    self.viewActivity.isHidden = true
                                    self.imgProfilePic.image = UIImage.init(named: "default.png")
                                }
                                
                        }else{
                            let strError = json["message"] as? String
                            //print(strError ?? "")
                            self.showAlert(strMsg: strError ?? "")
                            self.viewActivity.isHidden = true
                        }
                        
                    }
                }
                
            } catch let error as NSError {
                //print(error)
                self.showAlert(strMsg: error.localizedDescription)
                self.viewActivity.isHidden = true

            }
            return nil
        }
    }
    func logout()
    {
        let netAvailable = appDelegate.isConnectedToInternet()
        if(!netAvailable){
            showAlert(strMsg: "Please check your internet connection!")
            return
        }
        
        AWSMobileClient.default().signOut() { error in
            if let error = error {
                //print(error)
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
            self.viewSideMenu.isHidden = true
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
            if (searchActive){
                return aryFilteredSubCategories.count + 1;
            }
            else{
                return arySubCategories.count + 1;
            }
        }
        return 1;
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (tableView == tblMain){
            var height = 44;
            if(searchActive && aryFilteredLiveEvents.count == 0 && section == 0){
                height = 90
            }
            return CGFloat(height)
        }
        return 0;
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if (tableView == tblMain){
            var height = 44;
            if(searchActive && aryFilteredLiveEvents.count == 0 && section == 0){
                height = 90
            }
            let view = UIView(frame: CGRect(x: 0, y: 0, width: Int(tableView.bounds.width), height: height))
            let darkGreen = UIColor(red: 1, green: 29, blue: 39);
            view.backgroundColor = darkGreen;
            let label = UILabel(frame: CGRect(x: 15, y: 0, width: tableView.bounds.width - 30, height: 44))
            label.font = UIFont.boldSystemFont(ofSize: 15)
            label.textColor = UIColor.white
            if (height == 90 && section == 0){
                let lightGreen = UIColor(red: 10, green: 72, blue: 88);
                let labelNoData = UILabel(frame: CGRect(x: 0, y: 45, width: tableView.bounds.width, height: 44))
                labelNoData.font = UIFont.boldSystemFont(ofSize: 15)
                labelNoData.textColor = UIColor.white
                labelNoData.text = "No results found";
                labelNoData.textAlignment = .center
                labelNoData.backgroundColor = lightGreen
                view.addSubview(labelNoData)
            }
            if(tableView == tblMain){
                if (section == 0){
                    label.text = "Live Events";
                }else{
                    var sectionObj = [String:Any]()
                    if (searchActive){
                        if (self.aryFilteredSubCategories.count > 0){
                            sectionObj = self.aryFilteredSubCategories[section-1] as! [String : Any]
                        }
                    }else{
                        if (self.arySubCategories.count > 0){
                            sectionObj = self.arySubCategories[section-1] as! [String : Any]
                        }
                    }
                    let categoryName = sectionObj["parent_category_name"] as? String;
                    let name = sectionObj["subCategory"] as? String;
                    label.text = (categoryName ?? "") + " - " + (name ?? "");
                }
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
            if (indexPath.section == 0){
                if(searchActive && aryFilteredLiveEvents.count == 0){
                    return 0;
                }else if(!searchActive && aryLiveChannelsData.count == 0){
                    return 0;
                }
            }
            return 180;
        }
        return 44;
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // let cell = myTableView.dequeueReusableCell(withIdentifier: "DashBoardCell", for: indexPath) as! DashBoardCell
        if (tableView == tblMain){
            if (indexPath.section == 0){
                let cell = tblMain.dequeueReusableCell(withIdentifier: "DashBoardCell", for: indexPath) as! DashBoardCell
                if(searchActive){
                    cell.updateCellWith(row: aryFilteredLiveEvents,controller: "dashboard_live")
                }
                else{
                    cell.updateCellWith(row: aryLiveChannelsData,controller: "dashboard_live")
                }
                cell.cellDelegate = self
                
                return cell
                
            }else{
                let cell = tblMain.dequeueReusableCell(withIdentifier: "DashBoardCell", for: indexPath) as! DashBoardCell
                if (searchActive){
                    let arySub = aryFilteredSubCategories[indexPath.section-1] as? [String: Any]
                    let organizations = arySub?["organizations"] as? [Any]
                    _ = indexPath.row;
                    guard let rowArray = organizations else { return cell };
                    cell.updateCellWith(row: rowArray,controller: "dashboard")
                }else{
                    let arySub = arySubCategories[indexPath.section-1] as? [String: Any]
                    let organizations = arySub?["organizations"] as? [Any]
                    _ = indexPath.row;
                    guard let rowArray = organizations else { return cell };
                    cell.updateCellWith(row: rowArray,controller: "dashboard")
                }
                cell.cellDelegate = self
                
                return cell
            }
        }
        else{
            let cell = tblSide.dequeueReusableCell(withIdentifier: "SideMenuCell", for: indexPath) as! SideMenuCell
            let selectedItem = arySideMenu[indexPath.row];
            cell.lblName.text =  selectedItem["name"];
            let imageNamed = selectedItem["icon"];
            cell.imgItem.image = UIImage(named:imageNamed!)
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
            case "Payment History":
                hideSideMenu()
                let storyboard = UIStoryboard(name: "Main", bundle: nil);
                let vc = storyboard.instantiateViewController(withIdentifier: "PaymentHistoryVC") as! PaymentHistoryVC
                self.navigationController?.pushViewController(vc, animated: true)
            case "Help":
                let storyboard = UIStoryboard(name: "Main", bundle: nil);
                let vc = storyboard.instantiateViewController(withIdentifier: "HelpVC") as! HelpVC
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
    // MARK: Download Image from URL
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    func downloadImage(from url: URL, imageView: UIImageView) {
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            DispatchQueue.main.async() { [weak self] in
                imageView.contentMode = .scaleAspectFill
                imageView.image = UIImage(data: data)
                self?.viewActivity.isHidden = true
                self?.isProfileLoaded = true
                UserDefaults.standard.set("true", forKey: "is_profile_pic_loaded_left_menu")
            }
        }
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
        
        if (selectedOrg?["parent_category_id"]as? Int != nil){
            let storyboard = UIStoryboard(name: "Main", bundle: nil);
            let vc = storyboard.instantiateViewController(withIdentifier: "ChannelDetailVC") as! ChannelDetailVC
            vc.orgId = selectedOrg?["organization_id"] as? Int ?? 0
            vc.delegate = self
            appDelegate.isLiveLoad = "1"
            //        print("userId:",selectedOrg?["user_id"] as Any)
            if (selectedOrg?["performer_id"] as? Int) != nil {
                vc.performerId = selectedOrg?["performer_id"] as! Int
            }
            else {
                vc.performerId = 1;
            }
            vc.strTitle = selectedOrg?["user_display_name"] as? String ?? "Channel Details"
            
            
            self.navigationController?.pushViewController(vc, animated: true)
        }else{
            let storyboard = UIStoryboard(name: "Main", bundle: nil);
            let vc = storyboard.instantiateViewController(withIdentifier: "ChannelsVC") as! ChannelsVC
            vc.orgId = selectedOrg?["id"] as? Int ?? 0
            if (selectedOrg?["organization_name"]as? String != nil){
                vc.organizationName = selectedOrg?["organization_name"] as! String
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        
        
    }
    // MARK: Filter Events
    @IBAction func openFilter(_ sender: Any) {
        isSelectedGenre = false;
        searchBar.isHidden = true;
        searchToggle = false;
        searchActive = false;
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
        let netAvailable = appDelegate.isConnectedToInternet()
        if(!netAvailable){
            showAlert(strMsg: "Please check your internet connection!")
            return
        }
        
        mdChipCard.isHidden = true;
        topConstaintTblMain?.constant = 1;
        tblMain.layoutIfNeeded()
        getCategoryOrganisations(inputData: ["category":""]);
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
        if (strSelectedCategory != ""){
            getCategoryOrganisations(inputData: ["category":self.strSelectedCategory]);
        }
    }
    
    // MARK: Handler for allCategories API, using for filters
    func filterAPI(){
        let url: String = appDelegate.baseURL +  "/allCategories"
        let params: [String: Any] = [:]
        viewActivity.isHidden = false
        let headers: HTTPHeaders
        headers = [appDelegate.securityKey: appDelegate.securityValue]
        AF.request(url, method: .post,  parameters: params, encoding: JSONEncoding.default,headers:headers)
            .responseJSON { response in
                self.viewActivity.isHidden = true
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any] {
                        //print("filterAPI:",json)
                        if (json["statusCode"]as? String == "200"){
                            //print(json["message"] as? String ?? "")
                            self.aryFilterCategoriesData = json["Data"] as? [Any] ?? [Any]();
                            //self.tblFilter.reloadData();
                            let indexSet = IndexSet(integer: 0)//reloading first section
                            self.collectionViewFilter.reloadSections(indexSet)
                        }else{
                            let strError = json["message"] as? String
                            //print(strError ?? "")
                            self.showAlert(strMsg: strError ?? "")
                        }
                        
                    }
                case .failure(let error):
                    //print(error)
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
        }else if (indexPath.section == 2){
            let selectedItem = aryFilterGenresData[indexPath.row] as? [String : Any];
            let strValue = selectedItem?["genres"] as? String;
            print("strValue genre:",strValue ?? "")
            let selectedGenreId = selectedItem?["id"] as? Int;
            self.genreId = selectedGenreId ?? 0
            print("selectedGenreId:",selectedGenreId)
            isSelectedGenre = true;
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
    
    //MARK: UISearchbar delegate
    @IBAction func searchTapped(_ sender: UIButton){
        let storyboard = UIStoryboard(name: "Main", bundle: nil);
        let vc = storyboard.instantiateViewController(withIdentifier: "SearchViewController") as! SearchViewController
        self.navigationController?.pushViewController(vc, animated: true)
        /*searchToggle = !searchToggle
        searchBar.text = "";
        if(!mdChipCard.isHidden){
            mdChipCard.isHidden = true;
        }
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
        }*/
        
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
            let namePredicate = NSPredicate(format: "stream_video_title contains[c] %@",searchString);
            
            aryFilteredLiveEvents = aryLiveChannelsData.filter { namePredicate.evaluate(with: $0) };
            aryFilteredSubCategories = []
            
            for (index,_) in self.arySubCategories.enumerated(){
                let arySub = arySubCategories[index] as? [String: Any]
                let organizations = arySub?["organizations"] as? [Any]
                searchActive = true;
                let namePredicate = NSPredicate(format: "organization_name contains[c] %@",searchString);
                
                let arySubCategories1 = organizations?.filter { namePredicate.evaluate(with: $0) };
                if (arySubCategories1!.count > 0){
                    let dict =
                        ["organizations": arySubCategories1 ?? [Any](),
                         "parent_category_name":arySub?["parent_category_name"] as? String ?? "",
                         "subCategory":arySub?["subCategory"] as? String ?? ""] as [String : Any]
                    aryFilteredSubCategories.append(dict)
                    //print("arySub:",dict)
                    
                }
            }
            //print("--count:",aryFilteredSubCategories.count)
            tblMain.reloadData()
            
        }
        
        
    }
    @IBAction func helpPressed(_ sender: Any){
        let storyboard = UIStoryboard(name: "Main", bundle: nil);
                   let vc = storyboard.instantiateViewController(withIdentifier: "HelpVC") as! HelpVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

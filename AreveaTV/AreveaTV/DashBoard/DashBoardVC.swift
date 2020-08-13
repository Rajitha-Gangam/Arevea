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
class DashBoardVC: UIViewController,UITableViewDelegate,UITableViewDataSource,CollectionViewCellDelegate,UITextFieldDelegate,OpenChanannelChatDelegate{
    
    //MARK: Variables Declaration
    
    @IBOutlet weak var tblMain: UITableView!
    @IBOutlet weak var tblSide: UITableView!
    @IBOutlet weak var viewSideMenu: UIView!
    
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var leftConstraintLeftMenu: NSLayoutConstraint?
    
    @IBOutlet weak var lblNoData: UILabel!
    @IBOutlet weak var lblVersion: UILabel!

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var aryData = [Any]();
    
    var aryLiveChannelsData = [Any]();
    var aryUpcomingData = [Any]();
    var aryMyListData = [Any]();
    var aryTrendingChannelsData = [Any]();
    
    
    var isProfileLoaded = false;
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet var imgProfilePic: UIImageView!
    
    var arySideMenu : [[String: String]] = [["name":"Home","icon":"home"],["name":"My Profile","icon":"user-white"],["name":"My Events","icon":"event"],["name":"My Payments","icon":"donation"],["name":"My Purchases","icon":"purchase"],["name":"Help","icon":"help"],["name":"Logout","icon":"logout"]];
    var sectionTitles = ["Live Events","My List","Trending Channels"]
    //MARK:View Life Cycle Methods
    
    @IBOutlet weak var viewActivity: UIView!
    @IBOutlet weak var heightTopView: NSLayoutConstraint?
    @IBOutlet weak var viewTop: UIView!
    // MARK: - View Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        viewActivity.isHidden = true
        // Do any additional setup after loading the view.
        self.navigationController?.isNavigationBarHidden = true
        
        tblMain.register(UINib(nibName: "DashBoardCell", bundle: nil), forCellReuseIdentifier: "DashBoardCell")
        tblSide.register(UINib(nibName: "SideMenuCell", bundle: nil), forCellReuseIdentifier: "SideMenuCell")
        self.viewSideMenu.isHidden = true
        _ = Testbed.sharedInstance
        _ = Testbed.dictionary
        _ = Testbed.testAtIndex(index: 0)
        
        lblNoData.isHidden = true;
        
        UserDefaults.standard.set("false", forKey: "is_profile_pic_loaded_left_menu")
        
        let netAvailable = appDelegate.isConnectedToInternet()
        if(!netAvailable){
            showAlert(strMsg: "Please check your internet connection!")
            return
        }
        if(UIDevice.current.userInterfaceIdiom == .pad){
            heightTopView?.constant = 60;
            viewTop.layoutIfNeeded()
        }
        tblMain.layoutIfNeeded()
        
        UIDevice.current.setValue(self.preferredInterfaceOrientationForPresentation.rawValue, forKey: "orientation")
        
        lblVersion.text = "v" + getAppversion()
        
    }
    func getAppversion() -> String {
                  let dictionary = Bundle.main.infoDictionary!
                  let version = dictionary["CFBundleShortVersionString"] as! String
                  let build = dictionary["CFBundleVersion"] as! String
                  return "\(version).\(build)"
    }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        self.viewSideMenu.isHidden = true
        self.tblMain.reloadData()
        if UIDevice.current.orientation.isLandscape {
            print("DB Landscape")
        } else {
            print("DB Portrait")
        }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        appDelegate.strCategory = "";
        appDelegate.genreId = 0;
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let indexPath = IndexPath(row: 0, section: 0)
        tblSide.selectRow(at: indexPath, animated: true, scrollPosition: .bottom)
        //tblSide.delegate?.tableView!(myTableView, didSelectRowAt: indexPath)

        self.lblUserName.text = self.appDelegate.USER_NAME_FULL
        
        //if user comes from search by selecting  type "genre"
        if (appDelegate.genreId != 0){
            
        }
        //if user comes from search by selecting  type "subCategory"
        //default empty, by search value will be there
        if (appDelegate.strCategory != ""){
            getEvents(inputData: ["category_name":appDelegate.strCategory]);
        }else{
            // onGoingEvents()
            getEvents(inputData: [:]);
        }
        
        myList()
        trendingChannels()
        
        appDelegate.detailToShow = "stream"
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
    // MARK: Handler for onGoingEvents(Live Events) API
    func onGoingEvents(){
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
                        //print("onGoingEvents JSON:",json)
                        self.aryLiveChannelsData  = json["Data"] as? [Any] ?? [Any]();
                        print("live count:",self.aryLiveChannelsData.count)
                        self.tblMain.reloadSections([0], with: .none)
                    }
                case .failure(let error):
                    //print(error)
                    self.showAlert(strMsg: error.localizedDescription)
                }
        }
    }
    // MARK: Handler for myList(myList) API
    func myList(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let url: String = appDelegate.baseURL +  "/myList"
        viewActivity.isHidden = false
        let headers: HTTPHeaders
        headers = [appDelegate.securityKey: appDelegate.securityValue]
        let user_id = UserDefaults.standard.string(forKey: "user_id");
        let params: [String: Any] = ["userid":user_id ?? ""]
        
        AF.request(url, method: .post,  parameters: params, encoding: JSONEncoding.default,headers:headers)
            .responseJSON { response in
                self.viewActivity.isHidden = true
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any] {
                        if (json["statusCode"]as? String == "200"){
                            ////print(json["message"] ?? "")
                            print("Mylist JSON:",json)
                            self.aryMyListData  = json["Data"] as? [Any] ?? [Any]();
                            print("Mylist count:",self.aryMyListData.count)
                            self.tblMain.reloadSections([1], with: .none)
                            
                        }
                        else{
                            let strError = json["message"] as? String
                            ////print(strError ?? "")
                            self.showAlert(strMsg: strError ?? "")
                        }
                    }
                case .failure(let error):
                    //print(error)
                    self.showAlert(strMsg: error.localizedDescription)
                }
        }
    }
    // MARK: Handler for myList(myList) API
    func trendingChannels(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let url: String = appDelegate.baseURL +  "/trendingChannels"
        viewActivity.isHidden = false
        let headers: HTTPHeaders
        headers = [appDelegate.securityKey: appDelegate.securityValue]
        let params: [String: Any] = ["":""]
        
        AF.request(url, method: .post,  parameters: params, encoding: JSONEncoding.default,headers:headers)
            .responseJSON { response in
                self.viewActivity.isHidden = true
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any] {
                        if (json["statusCode"]as? String == "200"){
                            ////print(json["message"] ?? "")
                            print("trendingChannels JSON:",json)
                            self.aryTrendingChannelsData  = json["Data"] as? [Any] ?? [Any]();
                            print("trendingChannels count:",self.aryTrendingChannelsData.count)
                            self.tblMain.reloadSections([2], with: .none)
                            
                        }
                        else{
                            let strError = json["message"] as? String
                            ////print(strError ?? "")
                            self.showAlert(strMsg: strError ?? "")
                        }
                    }
                case .failure(let error):
                    //print(error)
                    self.showAlert(strMsg: error.localizedDescription)
                }
        }
    }
    // MARK: Handler for events(events) API
    func getEvents(inputData:[String: Any]){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let url: String = appDelegate.baseURL +  "/events"
        viewActivity.isHidden = false
        let headers: HTTPHeaders
        headers = [appDelegate.securityKey: appDelegate.securityValue]
        AF.request(url, method: .post,parameters: inputData, encoding: JSONEncoding.default,headers:headers)
            .responseJSON { response in
                self.viewActivity.isHidden = true
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any] {
                        print("getEvents JSON:",json)
                        let data  = json["Data"] as? [String:Any];
                        self.aryLiveChannelsData = data?["live_events"] as? [Any] ?? [Any]();
                        self.aryUpcomingData = data?["upcoming_events"] as? [Any] ?? [Any]();
                        print("live count:",self.aryLiveChannelsData.count)
                        print("upcoming count:",self.aryUpcomingData.count)
                        self.tblMain.reloadSections([0], with: .none)
                        // self.tblMain.reloadData()
                    }
                case .failure(let error):
                    //print(error)
                    self.showAlert(strMsg: error.localizedDescription)
                }
        }
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
                //print("Error occurred: \(error)")
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
                        if (json["status"]as? Int == 0){
                            // //print(json["message"] ?? "")
                            let profile_data = json["profile_data"] as? [String:Any] ?? [:]
                            let fn = profile_data["user_first_name"] as? String
                            let ln = profile_data["user_last_name"]as? String
                            let strName = String((fn?.first ?? "A")) + String((ln?.first ?? "B"))
                            
                            let dob = profile_data["date_of_birth"]as? String ?? ""
                            //self.txtDOB.text = dob;
                            
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "YYYY-MM-dd"
                            let date = dateFormatter.date(from: dob)
                            
                            let dateFormatterYear = DateFormatter()
                            dateFormatterYear.dateFormat = "YYYY"
                            let pastdate = dateFormatterYear.string(from: date ?? Date());
                            
                            let todaysDate = Date()
                            let currentDate = dateFormatterYear.string(from: todaysDate);
                            //print("currentDate:",currentDate)
                            //print("pastdate:",pastdate)
                            guard let currentYear = Int(currentDate), let pastYear = Int(pastdate) else {
                                //print("Some value is nil")
                                return
                            }
                            let user_age_limit = currentYear - pastYear
                            UserDefaults.standard.set(user_age_limit, forKey: "user_age_limit")
                            
                            self.appDelegate.USER_NAME = strName;
                            self.appDelegate.USER_NAME_FULL = (fn ?? "") + " " + (ln ?? "")
                            UserDefaults.standard.set(self.appDelegate.USER_NAME, forKey: "USER_NAME")
                            UserDefaults.standard.set(self.appDelegate.USER_NAME_FULL, forKey: "USER_NAME_FULL")
                            self.lblUserName.text = self.appDelegate.USER_NAME_FULL
                            
                            let strURL = profile_data["profile_pic"]as? String ?? ""
                            if let url = URL(string: strURL){
                                self.downloadImage(from: url as URL, imageView: self.imgProfilePic)
                            }else{
                                self.viewActivity.isHidden = true
                                self.imgProfilePic.image = UIImage.init(named: "user")
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
    func logoutAPI(){
        let netAvailable = appDelegate.isConnectedToInternet()
        if(!netAvailable){
            showAlert(strMsg: "Please check your internet connection!")
            return
        }
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let url: String = appDelegate.baseURL +  "/logout"
        viewActivity.isHidden = false
        let headers: HTTPHeaders
        headers = [appDelegate.securityKey: appDelegate.securityValue]
        let user_id = UserDefaults.standard.string(forKey: "user_id");
        let params: [String: Any] = ["user_id":user_id ?? ""]
        AF.request(url, method: .post,  parameters: params, encoding: JSONEncoding.default,headers:headers)
            .responseJSON { response in
                self.viewActivity.isHidden = true
                print("--logout response:",response)
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any] {
                        //print("json:",json)
                        self.viewActivity.isHidden = true
                        if (json["statusCode"]as? String == "200"){
                            self.logout()
                        }
                        else{
                            let strError = json["message"] as? String
                            ////print(strError ?? "")
                            self.showAlert(strMsg: strError ?? "")
                        }
                    }
                    
                case .failure(let error):
                    //print(error)
                    self.showAlert(strMsg: error.localizedDescription)
                }
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
            self.logoutAPI();
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
            return sectionTitles.count;
        }
        return 1;
    }
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (aryLiveChannelsData.count == 0 && aryUpcomingData.count == 0 && aryMyListData.count == 0 && aryTrendingChannelsData.count == 0){
            lblNoData.isHidden = false
        }else{
            lblNoData.isHidden = true
        }
        if (tableView == tblMain){
            if (section == 0){
                if(aryLiveChannelsData.count == 0 && aryUpcomingData.count == 0){
                    return 0;
                }
            }else if (section == 1){
                if(aryMyListData.count == 0){
                    return 0;
                }
            }else if (section == 2){
                if(aryTrendingChannelsData.count == 0){
                    return 0;
                }
            }
            return 1;
        }
        return arySideMenu.count;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) ->  CGFloat {
        if (tableView == tblMain){
            let screenRect = UIScreen.main.bounds
            var screenHeight = screenRect.size.height/2 - 90 //for live Channels and mylist
            return screenHeight
        }else{
            if(UIDevice.current.userInterfaceIdiom == .pad){
                return 60;
            }else{
                return 50;
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // let cell = myTableView.dequeueReusableCell(withIdentifier: "DashBoardCell", for: indexPath) as! DashBoardCell
        if (tableView == tblMain){
            if (indexPath.section == 0){
                let cell = tblMain.dequeueReusableCell(withIdentifier: "DashBoardCell", for: indexPath) as! DashBoardCell
                let data = aryLiveChannelsData + aryUpcomingData
                cell.updateCellWith(row: data,controller: "dashboard")
                cell.cellDelegate = self
                return cell
            }else if (indexPath.section == 1){
                let cell = tblMain.dequeueReusableCell(withIdentifier: "DashBoardCell", for: indexPath) as! DashBoardCell
                cell.updateCellWith(row: aryMyListData,controller: "dashboard_my_list")
                cell.cellDelegate = self
                return cell
            }else {
                let cell = tblMain.dequeueReusableCell(withIdentifier: "DashBoardCell", for: indexPath) as! DashBoardCell
                cell.updateCellWith(row: aryTrendingChannelsData,controller: "dashboard_trending_channels")
                cell.cellDelegate = self
                return cell
            }
        }
        else{
            let cell = tblSide.dequeueReusableCell(withIdentifier: "SideMenuCell", for: indexPath) as! SideMenuCell
            let selectedItem = arySideMenu[indexPath.row];
            let name = selectedItem["name"];
            cell.lblName.text = name
            let imageNamed = selectedItem["icon"];
            cell.imgItem.image = UIImage(named:imageNamed!)
            cell.backgroundColor = .clear
            
            let bgColorView = UIView()
            bgColorView.backgroundColor = UIColor.init(red: 43, green: 31, blue: 48)
            cell.selectedBackgroundView = bgColorView
            
            return cell;
        }
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (tableView == tblMain){
            tableView.deselectRow(at: indexPath, animated: true)
        }
        else{
            let selectedItem = arySideMenu[indexPath.row];
            let name = selectedItem["name"];
            switch  name?.lowercased(){
            case "logout":
                showConfirmation(strMsg: "Are you sure you want to logout?")
            case "my profile":
                hideSideMenu()
                let storyboard = UIStoryboard(name: "Main", bundle: nil);
                let vc = storyboard.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
                self.navigationController?.pushViewController(vc, animated: true)
            case "my payments":
                hideSideMenu()
                let storyboard = UIStoryboard(name: "Main", bundle: nil);
                let vc = storyboard.instantiateViewController(withIdentifier: "PaymentHistoryVC") as! PaymentHistoryVC
                self.navigationController?.pushViewController(vc, animated: true)
            case "my events":
                hideSideMenu()
                let storyboard = UIStoryboard(name: "Main", bundle: nil);
                let vc = storyboard.instantiateViewController(withIdentifier: "MyEventsVC") as! MyEventsVC
                self.navigationController?.pushViewController(vc, animated: true)
            case "my purchases":
                hideSideMenu()
                let storyboard = UIStoryboard(name: "Main", bundle: nil);
                let vc = storyboard.instantiateViewController(withIdentifier: "MyPurchasesVC") as! MyPurchasesVC
                self.navigationController?.pushViewController(vc, animated: true)
            case "help":
                hideSideMenu()
                let storyboard = UIStoryboard(name: "Main", bundle: nil);
                let vc = storyboard.instantiateViewController(withIdentifier: "HelpVC") as! HelpVC
                self.navigationController?.pushViewController(vc, animated: true)
            default:
                hideSideMenu()
                //print ("default")
            }
        }
    }
    func showSideMenu(){
        viewSideMenu.isHidden = false;
        self.leftConstraintLeftMenu?.constant = -(self.view.frame.size.width);
        //self.viewSideMenu.layoutIfNeeded()
        let movementDistance:CGFloat = (self.view.frame.size.width);
        var movement:CGFloat = 0
        movement = movementDistance
        UIView.animate(withDuration: 1.0, animations: {
            self.viewSideMenu.frame = self.viewSideMenu.frame.offsetBy(dx: movement, dy: 0)
        })
    }
    func hideSideMenu(){
        let movementDistance:CGFloat = (self.view.frame.size.width);
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
            //print(response?.suggestedFilename ?? url.lastPathComponent)
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
    // MARK: collectionView Delegate
    func collectionView(collectionviewcell: DBCollectionViewCell?, index: Int, didTappedInTableViewCell: DashBoardCell) {
        hideSideMenu()
        let orgsList = didTappedInTableViewCell.rowWithItems
        let selectedOrg = orgsList[index] as? [String: Any]
        //print("item:\(String(describing: selectedOrg))")
        
        if (selectedOrg?["parent_category_id"]as? Int != nil){
            let storyboard = UIStoryboard(name: "Main", bundle: nil);
            let vc = storyboard.instantiateViewController(withIdentifier: "StreamDetailVC") as! StreamDetailVC
            vc.orgId = selectedOrg?["organization_id"] as? Int ?? 0
            vc.streamId = selectedOrg?["id"] as? Int ?? 0
            vc.delegate = self
            appDelegate.isLiveLoad = "1"
            //        //print("userId:",selectedOrg?["user_id"] as Any)
            if (selectedOrg?["performer_id"] as? Int) != nil {
                vc.performerId = selectedOrg?["performer_id"] as! Int
            }
            else {
                vc.performerId = 1;
            }
            vc.strTitle = selectedOrg?["stream_video_title"] as? String ?? "Channel Details"
            
            self.navigationController?.pushViewController(vc, animated: true)
        }else{
            let storyboard = UIStoryboard(name: "Main", bundle: nil);
            let vc = storyboard.instantiateViewController(withIdentifier: "ChannelDetailVC") as! ChannelDetailVC
            vc.orgId = selectedOrg?["id"] as? Int ?? 0
            if (selectedOrg?["user_id"] as? Int) != nil {
                vc.performerId = selectedOrg?["user_id"] as! Int
            }
            else {
                vc.performerId = 1;
            }
            vc.strTitle = selectedOrg?["performer_display_name"] as? String ?? "Channel Details"
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    //MARK: UISearchbar delegate
    @IBAction func searchTapped(_ sender: UIButton){
        let storyboard = UIStoryboard(name: "Main", bundle: nil);
        let vc = storyboard.instantiateViewController(withIdentifier: "SearchViewController") as! SearchViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func helpPressed(_ sender: Any){
        let storyboard = UIStoryboard(name: "Main", bundle: nil);
        let vc = storyboard.instantiateViewController(withIdentifier: "HelpVC") as! HelpVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
}

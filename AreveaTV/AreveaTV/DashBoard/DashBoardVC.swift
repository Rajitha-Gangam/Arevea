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
import CoreLocation


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

class DashBoardVC: UIViewController,UITableViewDelegate,UITableViewDataSource,CollectionViewCellDelegate,UITextFieldDelegate,OpenChanannelChatDelegate,CLLocationManagerDelegate{
    
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
    var sectionTitles = ["Live Events","Upcoming Events","My List","Trending Channels"]
    var locationManager:CLLocationManager!

    //MARK:View Life Cycle Methods
    
    @IBOutlet weak var viewActivity: UIView!
    @IBOutlet weak var heightTopView: NSLayoutConstraint?
    @IBOutlet weak var viewTop: UIView!
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh(_:)), for: UIControl.Event.valueChanged)
        refreshControl.tintColor = UIColor.white
        
        return refreshControl
    }()
    
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
        self.imgProfilePic.layer.borderColor = UIColor.gray.cgColor
        self.imgProfilePic.layer.borderWidth = 2.0
        
        self.tblMain.addSubview(self.refreshControl)//pull to refresh handled
        let arn = UserDefaults.standard.string(forKey: "arn");
        print("==arn:",arn)
        
        locationManager = CLLocationManager()
         locationManager.delegate = self
         locationManager.desiredAccuracy = kCLLocationAccuracyBest
         locationManager.requestAlwaysAuthorization()
         
         if CLLocationManager.locationServicesEnabled(){
         locationManager.startUpdatingLocation()
         }

    }
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        // Do some reloading of data and update the table view's data source
        // Fetch more objects from a web service, for example...
        // Simply adding an object to the data source for this example
        if (appDelegate.strCategory != ""){
            getEvents(inputData: ["category_name":appDelegate.strCategory]);
        }else{
            // onGoingEvents()
            getEvents(inputData: [:]);
        }
        refreshControl.endRefreshing()
    }
    
    
    func getAppversion() -> String {
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as! String
        let build = dictionary["CFBundleVersion"] as! String
        return "\(version).\(build)"
    }
    
    /*override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
     super.viewWillTransition(to: size, with: coordinator)
     self.viewSideMenu.isHidden = true
     self.tblMain.reloadData()
     if UIDevice.current.orientation.isLandscape {
     //print("DB Landscape")
     DispatchQueue.main.async {
     //AppDelegate.AppUtility.lockOrientation(.portrait)
     }
     } else {
     //print("DB Portrait")
     }
     }*/
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        self.viewSideMenu.isHidden = true
        self.tblMain.reloadData()
        AppDelegate.AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
        
        if UIDevice.current.orientation.isLandscape {
            //print("DB Landscape")
            DispatchQueue.main.async {
                //  AppDelegate.AppUtility.lockOrientation(.portrait)
            }
        } else {
            // AppDelegate.AppUtility.lockOrientation(.portrait)
            //print("DB Portrait")
        }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        appDelegate.strCategory = "";
        appDelegate.genreId = 0;
        AppDelegate.AppUtility.lockOrientation(.all)
        
    }
    override func viewDidAppear(_ animated: Bool) {
        /*AppDelegate.AppUtility.lockOrientation(.portrait)
         if(UIDevice.current.userInterfaceIdiom == .phone){
         let value = UIInterfaceOrientation.portrait.rawValue
         UIDevice.current.setValue(value, forKey: "orientation")
         }
         tblMain.reloadData()*/
        
    }
    override func viewWillAppear(_ animated: Bool) {
        AppDelegate.AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
        // AppDelegate.AppUtility.lockOrientation(.portrait)
        let indexPath = IndexPath(row: 0, section: 0)
        tblSide.selectRow(at: indexPath, animated: true, scrollPosition: .bottom)
        //tblSide.delegate?.tableView!(myTableView, didSelectRowAt: indexPath)
        
        self.lblUserName.text = self.appDelegate.USER_DISPLAY_NAME
        
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
        let current = UNUserNotificationCenter.current()

        current.getNotificationSettings(completionHandler: { [self] (settings) in
            if settings.authorizationStatus == .notDetermined {
                // Notification permission has not been asked yet, go for it!
                current.requestAuthorization(options: []) { granted, error in
                    if error != nil {
                        // Handle the error here.
                    }
                    // Enable or disable features based on the authorization.
                }
            } else if settings.authorizationStatus == .denied {
                // Notification permission was previously denied, go to settings & privacy to re-enable
                //self.showAlert(strMsg: "Disabled PN")
                self.enablePN()
            } else if settings.authorizationStatus == .authorized {
                // Notification permission was already granted
               // self.showAlert(strMsg: "Enabled PN")
                
            }
        })
        
        
        
        //test()
    }
    func enablePN(){
        let alertController = UIAlertController(title: "Alert", message: "Please enable push notifictaions for this app, as it impacts more on app", preferredStyle: .alert)

           // Setting button action
           let settingsAction = UIAlertAction(title: "Go to Settings", style: .default) { (_) -> Void in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                   return
               }
               
               if UIApplication.shared.canOpenURL(settingsUrl) {
                   UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                       // Checking for setting is opened or not
                       print("Setting is opened: \(success)")
                   })
               }
           }
           
           alertController.addAction(settingsAction)
           // Cancel button action
           let cancelAction = UIAlertAction(title: "Cancel", style: .default){ (_) -> Void in
               // Magic is here for cancel button
           }
           alertController.addAction(cancelAction)
           // This part is important to show the alert controller ( You may delete "self." from present )
        DispatchQueue.main.async {
           self.present(alertController, animated: true, completion: nil)
        }
    }
    func showAlert(strMsg: String){
        let alert = UIAlertController(title: "Alert", message: strMsg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
        
    }
    // MARK: Handler for onGoingEvents(Live Events) API
    func onGoingEvents(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let url: String = appDelegate.baseURL +  "/ongoingEvents"
        viewActivity.isHidden = false
        let headers: HTTPHeaders
        headers = [appDelegate.x_api_key: appDelegate.x_api_value]
        
        AF.request(url, method: .get, encoding: JSONEncoding.default,headers:headers)
            .responseJSON { response in
                self.viewActivity.isHidden = true
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any] {
                        ////print("onGoingEvents JSON:",json)
                        self.aryLiveChannelsData  = json["Data"] as? [Any] ?? [Any]();
                        //print("live count:",self.aryLiveChannelsData.count)
                        self.tblMain.reloadSections([0], with: .none)
                    }
                case .failure(let error):
                    let errorDesc = error.localizedDescription.replacingOccurrences(of: "URLSessionTask failed with error:", with: "")
                    self.showAlert(strMsg: errorDesc)
                    self.viewActivity.isHidden = true
                    
                }
        }
    }
    // MARK: Handler for myList(myList) API
    func myList(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let url: String = appDelegate.ol_lambda_url +  "/myList"
        let user_id = UserDefaults.standard.string(forKey: "user_id");
        let inputData: [String: Any] = ["userid":user_id ?? ""]
        let session_token = UserDefaults.standard.string(forKey: "session_token") ?? ""
        let headers : HTTPHeaders = [
            "Content-Type": "application/json",
            appDelegate.x_api_key:appDelegate.x_api_value,
            "Authorization": "Bearer " + session_token
        ]
        viewActivity.isHidden = false
        AF.request(url, method: .post,parameters: inputData, encoding: JSONEncoding.default,headers:headers)
            .responseJSON { response in
                self.viewActivity.isHidden = true
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any] {
                        //print("myList JSON:",json)
                        if (json["statusCode"]as? String == "200" ){
                            self.aryMyListData  = json["Data"] as? [Any] ?? [Any]();
                            //print("Mylist count:",self.aryMyListData.count)
                            self.tblMain.reloadSections([2], with: .none)
                        }else{
                            let strMsg = json["message"] as? String ?? ""
                            self.showAlert(strMsg: strMsg)
                        }
                        
                    }
                case .failure(let error):
                    let errorDesc = error.localizedDescription.replacingOccurrences(of: "URLSessionTask failed with error:", with: "")
                    self.showAlert(strMsg: errorDesc)
                    self.viewActivity.isHidden = true
                    
                }
        }
    }
    
    
    // MARK: Handler for myList(myList) API
    func trendingChannels(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let url: String = appDelegate.baseURL +  "/trendingChannels"
        viewActivity.isHidden = false
        let headers: HTTPHeaders
        headers = [appDelegate.x_api_key: appDelegate.x_api_value]
        let params: [String: Any] = [:]
        
        AF.request(url, method: .post,  parameters: params, encoding: JSONEncoding.default,headers:headers)
            .responseJSON { response in
                DispatchQueue.main.async {
                    self.viewActivity.isHidden = true
                    switch response.result {
                    case .success(let value):
                        if let json = value as? [String: Any] {
                            print("trendingChannels JSON:",json)
                            if (json["statusCode"]as? String == "200"){
                                //////print(json["message"] ?? "")
                                self.aryTrendingChannelsData  = json["Data"] as? [Any] ?? [Any]();
                                //print("trendingChannels count:",self.aryTrendingChannelsData.count)
                                self.tblMain.reloadSections([3], with: .none)
                                
                            }
                            else{
                                let strError = json["message"] as? String
                                //print("Trending channels error:",strError ?? "")
                                // self.showAlert(strMsg: strError ?? "")
                            }
                        }
                    case .failure(let error):
                        let errorDesc = error.localizedDescription.replacingOccurrences(of: "URLSessionTask failed with error:", with: "")
                        //print("trending channels errorDesc:",errorDesc)
                        
                        self.showAlert(strMsg: errorDesc)
                        self.viewActivity.isHidden = true
                        
                    }
                }
        }
    }
    // MARK: Handler for events(events) API
    func getEvents(inputData:[String: Any]){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let url: String = appDelegate.baseURL +  "/events"
        print("getEvents input:",inputData)
        viewActivity.isHidden = false
        let headers: HTTPHeaders
        headers = [appDelegate.x_api_key: appDelegate.x_api_value]
        AF.request(url, method: .post,parameters: inputData, encoding: JSONEncoding.default,headers:headers)
            .responseJSON { response in
                DispatchQueue.main.async {
                    self.viewActivity.isHidden = true
                    switch response.result {
                    case .success(let value):
                        if let json = value as? [String: Any] {
                            print("events JSON:",json)
                            let data  = json["Data"] as? [String:Any];
                            self.aryLiveChannelsData = data?["live_events"] as? [Any] ?? [Any]();
                            self.aryUpcomingData = data?["upcoming_events"] as? [Any] ?? [Any]();
                            //print("live count:",self.aryLiveChannelsData.count)
                            //print("upcoming count:",self.aryUpcomingData.count)
                            self.tblMain.reloadSections([0,1], with: .none)
                            //self.tblMain.reloadSections([1], with: .none)
                            // self.tblMain.reloadData()
                        }
                    case .failure(let error):
                        let errorDesc = error.localizedDescription.replacingOccurrences(of: "URLSessionTask failed with error:", with: "")
                        //print("getEvents errorDesc:",errorDesc)
                        self.showAlert(strMsg: errorDesc)
                        self.viewActivity.isHidden = true
                        
                    }
                }
        }
    }
    // MARK: Handler for events(events) API
    
    func getProfile(){
        let user_id = UserDefaults.standard.string(forKey: "user_id");
        //print("getProfile:",user_id)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let url: String = appDelegate.ol_base_url + "/api/2/users/" + user_id!
        viewActivity.isHidden = false
        let headers: HTTPHeaders = [
            "Authorization": "Bearer " + appDelegate.ol_access_token,
            "Accept": "application/json"
        ]
        AF.request(url, method: .get, encoding: JSONEncoding.default,headers:headers)
            .responseJSON { response in
                self.viewActivity.isHidden = true
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any] {
                        //print("getProfile JSON:",json)
                        let user = json
                        let custom_attributes = json["custom_attributes"]as?[String: Any] ?? [:]
                        
                        let fn = user["firstname"] as? String
                        let ln = user["lastname"]as? String
                        let strName = String((fn?.first ?? "A")) + String((ln?.first ?? "B"))
                        
                        let dob = custom_attributes["date_of_birth"]as? String ?? ""
                        //self.txtDOB.text = dob;
                        
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "YYYY-MM-dd"
                        let date = dateFormatter.date(from: dob)
                        
                        let dateFormatterYear = DateFormatter()
                        dateFormatterYear.dateFormat = "YYYY"
                        let pastdate = dateFormatterYear.string(from: date ?? Date());
                        
                        let todaysDate = Date()
                        let currentDate = dateFormatterYear.string(from: todaysDate);
                        ////print("currentDate:",currentDate)
                        ////print("pastdate:",pastdate)
                        guard let currentYear = Int(currentDate), let pastYear = Int(pastdate) else {
                            ////print("Some value is nil")
                            return
                        }
                        let user_age_limit = currentYear - pastYear
                        UserDefaults.standard.set(user_age_limit, forKey: "user_age_limit")
                        
                        self.appDelegate.USER_NAME = strName;
                        self.appDelegate.USER_NAME_FULL = (fn ?? "") + " " + (ln ?? "")
                        self.appDelegate.USER_DISPLAY_NAME = custom_attributes["user_display_name"] as? String ?? ""
                        UserDefaults.standard.set(self.appDelegate.USER_NAME, forKey: "USER_NAME")
                        UserDefaults.standard.set(self.appDelegate.USER_NAME_FULL, forKey: "USER_NAME_FULL")
                        self.lblUserName.text = self.appDelegate.USER_DISPLAY_NAME
                        
                        let strURL = custom_attributes["profile_pic"]as? String ?? ""
                        if let url = URL(string: strURL){
                            self.imgProfilePic.sd_setImage(with: url, placeholderImage: UIImage(named: "user"))
                        }else{
                            self.viewActivity.isHidden = true
                            self.imgProfilePic.image = UIImage.init(named: "user")
                        }
                        
                    }
                case .failure(let error):
                    let errorDesc = error.localizedDescription.replacingOccurrences(of: "URLSessionTask failed with error:", with: "")
                    //print("getProfile error:",error)
                    self.showAlert(strMsg: errorDesc)
                    
                }
        }
    }
    func logoutOL(){
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let user_id = UserDefaults.standard.string(forKey: "user_id");
        
        let url: String = appDelegate.ol_base_url + "/api/1/users/" + user_id! + "/logout"
        viewActivity.isHidden = false
        let headers: HTTPHeaders = [
            "Authorization": "Bearer " + appDelegate.ol_access_token,
            "Accept": "application/json"
        ]
        AF.request(url, method:.put, encoding: JSONEncoding.default,headers:headers)
            .responseJSON { response in
                self.viewActivity.isHidden = true
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any] {
                        //print("logoutOL json:",json)
                        let status = json["status"] as? [String:Any] ?? [:]
                        if(status["code"] as? Int == 200){
                            self.logoutLambda()
                        }else{
                            let strMsg = status["message"] as? String ?? ""
                            self.showAlert(strMsg: strMsg)
                        }
                    }
                case .failure(let error):
                    let errorDesc = error.localizedDescription.replacingOccurrences(of: "URLSessionTask failed with error:", with: "")
                    self.showAlert(strMsg: errorDesc)
                    
                }
        }
    }
    func logoutLambda(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let url: String = appDelegate.ol_lambda_url +  "/logout"
        let user_id = UserDefaults.standard.string(forKey: "user_id");
        let inputData: [String: Any] = ["user_id":user_id ?? ""]
        let session_token = UserDefaults.standard.string(forKey: "session_token") ?? ""
        let headers : HTTPHeaders = [
            "Content-Type": "application/json",
            appDelegate.x_api_key:appDelegate.x_api_value,
            "Authorization": "Bearer " + session_token
        ]
        viewActivity.isHidden = false
        AF.request(url, method: .post,parameters: inputData, encoding: JSONEncoding.default,headers:headers)
            .responseJSON { response in
                self.viewActivity.isHidden = true
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any] {
                        //print("logoutLambda JSON:",json)
                        if (json["statusCode"]as? String == "200" ){
                            UserDefaults.standard.set("0", forKey: "user_id")
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
                            
                        }else{
                            let strMsg = json["message"] as? String ?? ""
                            self.showAlert(strMsg: strMsg)
                        }
                        
                    }
                case .failure(let error):
                    let errorDesc = error.localizedDescription.replacingOccurrences(of: "URLSessionTask failed with error:", with: "")
                    self.showAlert(strMsg: errorDesc)
                    self.viewActivity.isHidden = true
                    
                }
        }
    }
    
    
    func showConfirmation(strMsg: String){
        let alert = UIAlertController(title: "Alert", message: strMsg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            self.viewSideMenu.isHidden = true
            self.logoutOL();
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
            if (section == 0 && aryLiveChannelsData.count == 0){
                return 0;
            }else if (section == 1 && aryUpcomingData.count == 0){
                return 0;
            }
            else if (section == 2 && aryMyListData.count == 0){
                return 0;
            }else if (section == 3 && aryTrendingChannelsData.count == 0){
                return 0;
            }
            return 1;
        }
        return arySideMenu.count;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) ->  CGFloat {
        if (tableView == tblMain){
            let screenRect = UIScreen.main.bounds
            let screenHeight = screenRect.size.height/2 - 90 //for live Channels and mylist
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
                let data = aryLiveChannelsData
                cell.updateCellWith(row: data,controller: "dashboard")
                cell.cellDelegate = self
                return cell
            }else if (indexPath.section == 1){
                let cell = tblMain.dequeueReusableCell(withIdentifier: "DashBoardCell", for: indexPath) as! DashBoardCell
                let data = aryUpcomingData
                cell.updateCellWith(row: data,controller: "dashboard_up")
                cell.cellDelegate = self
                return cell
            }else if (indexPath.section == 2){
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
                vc.isCameFrom = "db"
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
        UIView.animate(withDuration: 0.5, animations: {
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
    
    @IBAction func viewBGTapped(_ sender: Any) {
        hideSideMenu()
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent // .default
    }
    // MARK: collectionView Delegate
    func collectionView(collectionviewcell: DBCollectionViewCell?, index: Int,title: String, didTappedInTableViewCell: DashBoardCell) {
        
        hideSideMenu()
        let orgsList = didTappedInTableViewCell.rowWithItems
        let selectedOrg = orgsList[index] as? [String: Any] ?? [:]
                print("item:\(String(describing: selectedOrg))")
        //        //print("title:",title)
        if (title == "dashboard" || title == "dashboard_my_list" || title == "dashboard_up"){
            var streamInfo = selectedOrg["stream_info"] as? [String: Any] ?? [:]
            if (title == "dashboard_my_list"){
                streamInfo = selectedOrg
            }
            let storyboard = UIStoryboard(name: "Main", bundle: nil);
            let number_of_creators = streamInfo["number_of_creators"] as? Int ?? 0
            let orgId = streamInfo["organization_id"] as? Int ?? 0
            var streamId = 0
            let performer_id = streamInfo["performer_id"] as? Int ?? 0
            let stream_video_title = streamInfo["stream_video_title"] as? String ?? "Channel Details"
            if (title == "dashboard_my_list"){
                streamId = streamInfo["stream_video_id"] as? Int ?? 0
            }else{
                streamId = streamInfo["id"] as? Int ?? 0
            }
            appDelegate.isLiveLoad = "1"
            //print("number_of_creators:",number_of_creators)
            let vc = storyboard.instantiateViewController(withIdentifier: "StreamDetailVC") as! StreamDetailVC
            vc.orgId = orgId
            vc.streamId = streamId
            vc.delegate = self
            vc.performerId = performer_id
            vc.strTitle = stream_video_title
            self.navigationController?.pushViewController(vc, animated: true)
        }else if(title == "dashboard_trending_channels"){
            let performerDetails = selectedOrg["performer_details"] as? [String: Any] ?? [:]
            let storyboard = UIStoryboard(name: "Main", bundle: nil);
            let vc = storyboard.instantiateViewController(withIdentifier: "ChannelDetailVC") as! ChannelDetailVC
            vc.orgId = performerDetails["id"] as? Int ?? 0
            vc.channel_name = performerDetails["channel_name"] as? String ?? ""
            if (performerDetails["user_id"] as? Int) != nil {
                vc.performerId = performerDetails["user_id"] as! Int
            }
            else {
                vc.performerId = 1;
            }
            vc.strTitle = performerDetails["performer_display_name"] as? String ?? "Channel Details"
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
    //MARK: - location delegate methods
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let netAvailable = appDelegate.isConnectedToInternet()
        if(!netAvailable){
            return
        }
        let userLocation :CLLocation = locations[0] as CLLocation
        //print("userLocation:",userLocation)
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(userLocation) { [self] (placemarks, error) in
            if (error != nil){
                ////print("error in reverseGeocode")
            }
            let placemark = placemarks! as [CLPlacemark]
            if placemark.count>0{
                let placemark = placemarks![0]
               // print("country:",placemark.country!)
                self.appDelegate.strCountry = placemark.country!
                self.getRegion()
            }
        }
        
    }
    func getRegion(){
        for (i,_) in appDelegate.aryCountries.enumerated(){
            let element = appDelegate.aryCountries[i]
            let countryNames = element["countries"] as! [Any];
            for (j,_) in countryNames.enumerated() {
                let country = countryNames[j] as! String
                if(country.lowercased() == appDelegate.strCountry.lowercased()){
                    ////print("equal:",country)
                    appDelegate.strRegionCode = element["region_code"]as! String
                    return
                }
            }
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("locationManager Error: \(error)")
    }
    
}

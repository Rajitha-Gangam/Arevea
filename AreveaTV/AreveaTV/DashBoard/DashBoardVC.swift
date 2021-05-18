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

class DashBoardVC: UIViewController,UITableViewDelegate,UITableViewDataSource,CollectionViewCellDelegate,UITextFieldDelegate,OpenChanannelChatDelegate,CLLocationManagerDelegate,UIPopoverPresentationControllerDelegate{
    
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
    var isUpcoming = false;
    
    var isProfileLoaded = false;
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet var imgProfilePic: UIImageView!
    var aryStreamInfo = [String: Any]()

    var arySideMenu : [[String: String]] = [["name":"Home","icon":"home-white","icon_sel":"home_bl"],["name":"My Profile","icon":"user-white","icon_sel":"user_bl"],["name":"My Events","icon":"event-white","icon_sel":"event_bl"],["name":"My Payments","icon":"donation","icon_sel":"donation_bl"],["name":"My Purchases","icon":"purchase-white","icon_sel":"purchase_bl"],["name":"Subscribed Channels","icon":"video-sub-white","icon_sel":"video-sub_bl"],["name":"Private Chat","icon":"chat-white","icon_sel":"chat"],["name":"Logout","icon":"logout","icon_sel":"logout_bl"]];
//["name":"Help","icon":"help-white","icon_sel":"help_bl"]
    //["name":"Private Chat","icon":"chat-white","icon_sel":"chat"]
    var arySideMenuGuest : [[String: String]] = [["name":"Home","icon":"home-white","icon_sel":"home_bl"]];
    //["name":"Help","icon":"help-white","icon_sel":"help_bl"]
    var sectionTitles = ["Live Events","Upcoming Events","My List","Trending Channels"]
    var locationManager:CLLocationManager!
    var selectedLeftMenuIndex = 0
    //MARK:View Life Cycle Methods
    
    @IBOutlet weak var viewActivity: UIView!
    @IBOutlet weak var heightTopView: NSLayoutConstraint?
    @IBOutlet weak var topForLeftTable: NSLayoutConstraint?
    
    @IBOutlet weak var viewTop: UIView!
    var aryUserSubscriptionInfo = [Any]()
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh(_:)), for: UIControl.Event.valueChanged)
        refreshControl.tintColor = UIColor.white
        
        return refreshControl
    }()
    var age_limit = 0;
    @IBOutlet weak var viewContacts: UIView!
    var strSlug = ""
    @IBOutlet weak var btnSignIn: UIButton!
    @IBOutlet weak var btnSignUp: UIButton!
    var parent_streams_id = 0
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
        //lblVersion.text = "v" + "3.0"
        
        self.imgProfilePic.layer.borderColor = UIColor.gray.cgColor
        self.imgProfilePic.layer.borderWidth = 2.0
        
        self.tblMain.addSubview(self.refreshControl)//pull to refresh handled
        let arn = UserDefaults.standard.string(forKey: "arn");
        //print("==arn:",arn)
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled(){
            locationManager.startUpdatingLocation()
        }
        
        ipGeoLocation()
        
        //viewContacts.isHidden = true
        let yellow = UIColor(red: 139, green: 230, blue: 213);
        btnSignIn.layer.borderColor = yellow.cgColor
        btnSignUp.layer.borderColor = UIColor.white.cgColor
        
    }
    func ipGeoLocation(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let url: String = appDelegate.ipGeoLocationURL
        
        AF.request(url, method: .get, encoding: JSONEncoding.default)
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any] {
                        // print("ipGeoLocation JSON:",json)
                        let currency  = json["currency"] as? [String:Any] ?? [:];
                        let time_zone  = json["time_zone"] as? [String:Any] ?? [:];
                        
                        let currencyCode = currency["code"] as? String ?? ""//based on user lcoation, currency code will come, that we need to pass currencies json, and get symbol
                        let timeZoneOffset = time_zone["offset"] as? Double ?? 0.0
                        appDelegate.userTimezoneOffset = timeZoneOffset
                        appDelegate.userCurrencyCode = currencyCode
                        if let path = Bundle.main.path(forResource: "currencies", ofType: "json") {
                            do {
                                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                                if let jsonResult = jsonResult as? Dictionary<String, AnyObject>,
                                   let currencySymbol = jsonResult[currencyCode] as? String {
                                    // do stuff
                                    print("currencySymbol:",currencySymbol)
                                    appDelegate.userCurrencySymbol = currencySymbol
                                }
                            } catch {
                                // handle error
                            }
                        }
                        
                    }
                case .failure(let error):
                    let errorDesc = error.localizedDescription.replacingOccurrences(of: "URLSessionTask failed with error:", with: "")
                //self.showAlert(strMsg: errorDesc)
                }
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
        UIApplication.shared.isIdleTimerDisabled = false //to device lock based on user settings when steraming is not running
        
    }
    override func viewWillAppear(_ animated: Bool) {
        print("===fb viewWillAppear")
        AppDelegate.AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
        // AppDelegate.AppUtility.lockOrientation(.portrait)
        let indexPath = IndexPath(row: 0, section: 0)
        tblSide.selectRow(at: indexPath, animated: true, scrollPosition: .bottom)
        //tblSide.delegate?.tableView!(myTableView, didSelectRowAt: indexPath)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        if(appDelegate.isGuest){
            self.lblUserName.text = "Guest"
            // UserDefaults.standard.set("0", forKey: "user_id")
            btnSignIn.isHidden = false
            btnSignUp.isHidden = false
            topForLeftTable?.constant = 80
            tblSide.layoutIfNeeded()
            
        }else{
            self.lblUserName.text = self.appDelegate.USER_DISPLAY_NAME
            btnSignIn.isHidden = true
            btnSignUp.isHidden = true
            topForLeftTable?.constant = 20
            tblSide.layoutIfNeeded()
            
        }
        
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
        if(!appDelegate.isGuest){
            myList()
        }else{
            //mylist should not be there for guest
            self.aryMyListData  = [Any]();
            self.tblMain.reloadSections([2], with: .none)
        }
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
        
        selectedLeftMenuIndex = 0
        tblSide.reloadData()
        //test()
    }
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name:UIApplication.didBecomeActiveNotification , object: nil)
        NotificationCenter.default.removeObserver(self)
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
        let url: String = appDelegate.baseURL +  "/myList"
        let user_id = UserDefaults.standard.string(forKey: "user_id");
        let inputData: [String: Any] = ["userid":user_id ?? ""]
        //print("myList params:",inputData)
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
                        print("myList JSON:",json)
                        print("my status code:",response.response?.statusCode)
                        if (json["statusCode"]as? String == "200" ){
                            self.aryMyListData  = json["Data"] as? [Any] ?? [Any]();
                            //print("Mylist count:",self.aryMyListData.count)
                            self.tblMain.reloadSections([2], with: .none)
                        }else{
                            if(response.response?.statusCode == 403){
                                self.showConfirmation1(strMsg: "You will be auto log out due to session issue.")
                            }
                            let strMsg = json["message"] as? String ?? ""
                            //self.showAlert(strMsg: strMsg)
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
                            // print("trendingChannels JSON:",json)
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
        if(appDelegate.isGuest){
            UserDefaults.standard.set(0, forKey: "user_age_limit")
            self.appDelegate.USER_NAME = "";
            self.appDelegate.USER_NAME_FULL = ""
            self.appDelegate.USER_DISPLAY_NAME = ""
            UserDefaults.standard.set(self.appDelegate.USER_NAME, forKey: "USER_NAME")
            UserDefaults.standard.set(self.appDelegate.USER_NAME_FULL, forKey: "USER_NAME_FULL")
            if(appDelegate.isGuest){
                self.lblUserName.text = "Guest"
            }else{
                self.lblUserName.text = self.appDelegate.USER_DISPLAY_NAME
            }
            self.imgProfilePic.image = UIImage.init(named: "user")
        }
        else{
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
                            print("user_age_limit:",user_age_limit)
                            UserDefaults.standard.set(user_age_limit, forKey: "user_age_limit")
                            
                            self.appDelegate.USER_NAME = strName;
                            self.appDelegate.USER_NAME_FULL = (fn ?? "") + " " + (ln ?? "")
                            self.appDelegate.USER_DISPLAY_NAME = custom_attributes["user_display_name"] as? String ?? ""
                            UserDefaults.standard.set(self.appDelegate.USER_NAME, forKey: "USER_NAME")
                            UserDefaults.standard.set(self.appDelegate.USER_NAME_FULL, forKey: "USER_NAME_FULL")
                            if(appDelegate.isGuest){
                                self.lblUserName.text = "Guest"
                            }else{
                                self.lblUserName.text = self.appDelegate.USER_DISPLAY_NAME
                            }
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
    func gotoLogin(){
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
    }
    @IBAction func gotoSignUp(){
        UserDefaults.standard.set("0", forKey: "user_id")
        var isSignUpExists = false
        for controller in self.navigationController!.viewControllers as Array {
            if controller.isKind(of: SignUpVC.self) {
                self.navigationController!.popToViewController(controller, animated: true)
                isSignUpExists = true;
                break
            }
        }
        if (!isSignUpExists){
            let storyboard = UIStoryboard(name: "Main", bundle: nil);
            let vc = storyboard.instantiateViewController(withIdentifier: "SignUpVC") as! SignUpVC
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    @IBAction func signInPressed(){
        gotoLogin()
    }
    func logoutLambda(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let url: String = appDelegate.baseURL +  "/logout"
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
            .responseJSON { [self] response in
                self.viewActivity.isHidden = true
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any] {
                        //print("logoutLambda JSON:",json)
                        if (json["statusCode"]as? String == "200" ){
                            //self.gotoLogin()
                            showAlert(strMsg: "You've successfully logged out")
                            UserDefaults.standard.set("0", forKey: "user_id")
                            appDelegate.isGuest = true
                            selectedLeftMenuIndex = 0
                            if(appDelegate.isGuest){
                                self.lblUserName.text = "Guest"
                                btnSignIn.isHidden = false
                                btnSignUp.isHidden = false
                                topForLeftTable?.constant = 80
                                tblSide.layoutIfNeeded()
                                getProfile()
                            }
                            self.tblSide.reloadData()
                            self.aryMyListData  =  [Any]();
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
    func showConfirmation1(strMsg: String){
        let alert = UIAlertController(title: "Alert", message: strMsg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [self] action in
            self.gotoLogin()
        }))
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
    func gotoStreamDetails(myList: Bool){
        let storyboard = UIStoryboard(name: "Main", bundle: nil);
        let streamObj = self.aryStreamInfo
        let stream_status = streamObj["stream_status"] as? String ?? ""

        appDelegate.isLiveLoad = "1"
        let vc = storyboard.instantiateViewController(withIdentifier: "StreamDetailVC") as! StreamDetailVC
        vc.chatDelegate = self
        appDelegate.isUpcoming = isUpcoming
        vc.chatDelegate = self
        if(myList){
            vc.mylist = true
        }
        if(stream_status == "completed" && myList){
            appDelegate.isVOD = true
        }else{
            appDelegate.isVOD = false
        }
        self.navigationController?.pushViewController(vc, animated: true)
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
        }else{
            if(appDelegate.isGuest){
                return arySideMenuGuest.count;
            }else{
                return arySideMenu.count;
            }
        }
        
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
            var selectedItem = [String:String]()
            if(appDelegate.isGuest){
                selectedItem = arySideMenuGuest[indexPath.row];
            }else{
                selectedItem = arySideMenu[indexPath.row];
            }
            let name = selectedItem["name"];
            cell.lblName.text = name
            let imageNamed = selectedItem["icon"];
            cell.imgItem.image = UIImage(named:imageNamed!)
            cell.backgroundColor = .clear
            
            
//            let bgColorView = UIView()
//            bgColorView.backgroundColor = UIColor.init(red: 34, green: 44, blue: 54)
//            cell.selectedBackgroundView = bgColorView
            if(selectedLeftMenuIndex == indexPath.row){
                cell.lblName.textColor = UIColor.init(red: 141, green: 230, blue: 214)
                let imageNamed = selectedItem["icon_sel"];
                cell.imgItem.image = UIImage(named:imageNamed!)
                cell.backgroundColor = UIColor.init(red: 34, green: 44, blue: 54)

            }else{
                cell.lblName.textColor = UIColor.white
                cell.backgroundColor = UIColor.clear

            }
            return cell;
        }
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (tableView == tblMain){
            tableView.deselectRow(at: indexPath, animated: true)
        }
        else{
            tableView.deselectRow(at: indexPath, animated: true)
            selectedLeftMenuIndex = indexPath.row
            tblSide.reloadData()
            //return
            var selectedItem = [String:String]()
            if(appDelegate.isGuest){
                selectedItem = arySideMenuGuest[indexPath.row];
            }else{
                selectedItem = arySideMenu[indexPath.row];
            }
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
            case "private chat":
                hideSideMenu()
                appDelegate.isPvtChatFromLeftMenu = true
                let storyboard = UIStoryboard(name: "Main", bundle: nil);
                let vc = storyboard.instantiateViewController(withIdentifier: "ContactsVC") as! ContactsVC
                self.navigationController?.pushViewController(vc, animated: true)
            case "help":
                hideSideMenu()
                let storyboard = UIStoryboard(name: "Main", bundle: nil);
                let vc = storyboard.instantiateViewController(withIdentifier: "HelpVC") as! HelpVC
                self.navigationController?.pushViewController(vc, animated: true)
            case "subscribed channels":
                hideSideMenu()
                let storyboard = UIStoryboard(name: "Main", bundle: nil);
                let vc = storyboard.instantiateViewController(withIdentifier: "SubscribedChannelsVC") as! SubscribedChannelsVC
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
            isUpcoming = false
            if (title == "dashboard_up"){
                isUpcoming = true
            }
            let storyboard = UIStoryboard(name: "Main", bundle: nil);
            let number_of_creators = streamInfo["number_of_creators"] as? Int ?? 0
            let orgId = streamInfo["organization_id"] as? Int ?? 0
            let performer_id = streamInfo["performer_id"] as? Int ?? 0
            var streamId = streamInfo["stream_video_id"] as? Int ?? 0
            parent_streams_id = streamInfo["parent_streams_id"] as? Int ?? 0
            print("parent_streams_id:",parent_streams_id)
            self.strSlug = streamInfo["slug"] as? String ?? ""
            print("===strSlug:",strSlug)
            if(title != "dashboard_my_list"){
                streamId = streamInfo["id"] as? Int ?? 0
            }
            
            let stream_video_title = streamInfo["stream_video_title"] as? String ?? "Event Details"
            let channelName = streamInfo["channel_name"] as? String ?? ""
            if (title == "dashboard_my_list"){
                LiveEventById(streamInfo:streamInfo,myList: true)
            }else{
                LiveEventById(streamInfo:streamInfo,myList: false)
            }
            
        }else if(title == "dashboard_trending_channels"){
            let performerDetails = selectedOrg["performer_details"] as? [String: Any] ?? [:]
            let storyboard = UIStoryboard(name: "Main", bundle: nil);
            appDelegate.orgId = performerDetails["id"] as? Int ?? 0
            let channelName = performerDetails["channel_name"] as? String ?? ""
            appDelegate.channel_name_subscription = channelName
            appDelegate.strTitle = performerDetails["performer_display_name"] as? String ?? "Channel Details"
            if (performerDetails["user_id"] as? Int) != nil {
                appDelegate.performerId = performerDetails["user_id"] as! Int
            }
            else {
                appDelegate.performerId = 1;
            }
            let vc = storyboard.instantiateViewController(withIdentifier: "ChannelDetailVC") as! ChannelDetailVC
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    func LiveEventById(streamInfo:[String: Any],myList:Bool) {
        // print("streamInfo:",streamInfo)
        var streamId = streamInfo["stream_video_id"] as? Int ?? 0
        if(!myList){
            streamId = streamInfo["id"] as? Int ?? 0
        }
        if (parent_streams_id != 0){
            streamId = parent_streams_id
        }
        // print("streamId:",streamId)
        
        let channelName = streamInfo["channel_name"] as? String ?? ""
        print("===?channelName:",channelName)
        let user_id = UserDefaults.standard.string(forKey: "user_id");
        var streamIdLocal = "0"
        if (streamId != 0){
            streamIdLocal = String(streamId)
        }
        let orgId = streamInfo["organization_id"] as? Int ?? 0
        let performer_id = streamInfo["performer_id"] as? Int ?? 0
        let stream_video_title = streamInfo["stream_video_title"] as? String ?? "Channel Details"
        
        let params: [String: Any] = ["userid":user_id ?? "","performer_id":performer_id,"stream_id": streamIdLocal]
        
        viewActivity.isHidden = false
        let netAvailable = appDelegate.isConnectedToInternet()
        if(!netAvailable){
            showAlert(strMsg: "Please check your internet connection!")
            return
        }
        let url: String = appDelegate.baseURL +  "/LiveEventById"
        
        let headers: HTTPHeaders
        headers = [appDelegate.x_api_key: appDelegate.x_api_value]
        
        print("liveEvents params1:",params)
        AF.request(url, method: .post,parameters: params, encoding: JSONEncoding.default,headers:headers)
            .responseJSON { [self] response in
                self.viewActivity.isHidden = true
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any] {
                        print("LiveEventById JSON1:",json)
                        if (json["statusCode"]as? String == "200"){
                            let data = json["Data"] as? [String:Any]
                            let resultData = data ?? [:]
                            self.aryStreamInfo = data?["stream_info"] as? [String:Any] ?? [:]
                            let stream_info_key_exists = aryStreamInfo["id"]
                            if (stream_info_key_exists != nil){
                                let streamObj = aryStreamInfo
                                let stream_status = streamObj["stream_status"] as? String ?? ""
                                strSlug = streamObj["slug"] as? String ?? ""
                                
                                let user_subscription_info = data?["user_subscription_info"] != nil
                                if(user_subscription_info){
                                    self.aryUserSubscriptionInfo = data?["user_subscription_info"] as? [Any] ?? [Any]()
                                }
                                print("self.aryUserSubscriptionInfo:",self.aryUserSubscriptionInfo.count)
                                var isVOD = false
                                if (streamObj["stream_vod"]as? String == "stream"){
                                    isVOD = false
                                }else{
                                    isVOD = true
                                }
                                let user_age_limit = UserDefaults.standard.integer(forKey:"user_age_limit");
                                self.age_limit = streamObj["age_limit"] as? Int ?? 0
                                appDelegate.isLiveLoad = "1"
                                appDelegate.orgId = orgId
                                appDelegate.streamId = streamId
                                appDelegate.performerId = performer_id
                                appDelegate.strTitle = stream_video_title
                                appDelegate.isVOD = isVOD
                                appDelegate.isUpcoming = isUpcoming
                                appDelegate.strSlug = strSlug
                                appDelegate.channel_name_subscription = channelName
                                print("==appDelegate.channel_name_subscription:",appDelegate.channel_name_subscription)
                                if (self.aryUserSubscriptionInfo.count == 0 || appDelegate.isGuest){
                                    let vc = storyboard!.instantiateViewController(withIdentifier: "EventRegistrationVC") as! EventRegistrationVC
                                    self.navigationController?.pushViewController(vc, animated: true)
                                }else{
                                    if(myList){
                                        //gotoStreamDetails(myList: true)
                                        let vc = storyboard!.instantiateViewController(withIdentifier: "ScheduleVC") as! ScheduleVC
                                        self.navigationController?.pushViewController(vc, animated: true)
                                    }else{
                                        let vc = storyboard!.instantiateViewController(withIdentifier: "ScheduleVC") as! ScheduleVC
                                        self.navigationController?.pushViewController(vc, animated: true)
                                    }
                                }
                                
                            }
                        }else{
                            let strError = json["message"] as? String
                            ////print("strError1:",strError ?? "")
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
    @objc func applicationDidBecomeActive(notification: NSNotification) {
        print("==db applicationDidBecomeActive")
        if(appDelegate.isGuest){
            self.aryMyListData  = [Any]();
            self.tblMain.reloadSections([2], with: .none)
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
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    @IBAction func showPopoverButtonAction(_ sender: Any) {
        let contactsVC = self.storyboard?.instantiateViewController(withIdentifier: "ContactsVC") as? ContactsVC
        let screenRect = UIScreen.main.bounds
        print("screenRect:",screenRect)
        let screenHeight = screenRect.size.height/2
        let screenWidth = screenRect.size.width - 100
        appDelegate.isPvtChatFromLeftMenu = false

        let popupVC = PopupViewController(contentController: contactsVC!, position:.bottomRight(CGPoint(x: 0, y: 30)), popupWidth: screenWidth, popupHeight: screenHeight)
        popupVC.backgroundAlpha = 0.3
        popupVC.backgroundColor = .black
        popupVC.canTapOutsideToDismiss = true
        popupVC.cornerRadius = 10
        popupVC.shadowEnabled = true
        //popupVC.delegate = self
        present(popupVC, animated: true, completion: nil)
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
            if(placemarks?.count ?? 0 > 0){
                let placemark = placemarks! as [CLPlacemark]
                if placemark.count > 0{
                    let placemark = placemarks![0]
                    // print("country:",placemark.country!)
                    self.appDelegate.strCountry = placemark.country!
                    self.getRegion()
                }
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

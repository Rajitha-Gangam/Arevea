//
//  TicketTypesVC.swift
//  AreveaTV
//
//  Created by apple on 12/22/20.
//  Copyright © 2020 apple. All rights reserved.
//

import UIKit
import Alamofire
import SendBirdSDK

class TicketTypesVC: UIViewController,UITableViewDataSource,UITableViewDelegate,OpenChanannelChatDelegate{
    // MARK: - Variables Declaration
    
    @IBOutlet weak var tblTicketTypes: UITableView!
    var currency_type = ""
    var indexSelectedTicketType = -1
    var strTicketType = ""
    var rowHeight = 92
    var orgId = 0;
    var performerId = 0;
    var streamId = 0;
    var strTitle = ""
    var isCameFromGetTickets = false
    var channel_name_subscription = ""
    var isVOD = false;
    var isAudio = false;
    var isStream = true;
    var isUpcoming = false;
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var aryStreamInfo = [String: Any]()
    var tempAryDisplayCurrencies = [Any]()
    @IBOutlet weak var tblheight: NSLayoutConstraint!
    var aryStreamAmounts = [Any]()
    @IBOutlet weak var heightTopView: NSLayoutConstraint?
    @IBOutlet weak var viewTop: UIView!
    @IBOutlet weak var viewActivity: UIView!
    var aryUserSubscriptionInfo = [Any]()
    weak var delegate: OpenChanannelChatDelegate?
    var currencyType = ""
    var currencySymbol = ""
    var jsonCurrencyList = [String:Any]()
    @IBOutlet weak var btnCancel: UIButton!
    var number_of_creators = 1
    
    var aryCurrencyKeys = [String]()
    var aryCurrencyValues = [Any]()
    var aryDisplayCurrencies = [Any]()
    var doubleDisplayCurrencies = [Double]()
    @IBOutlet weak var txtFirstName: UITextField!
    @IBOutlet weak var txtLastName: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var viewPrice: UIView!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var viewGuest: UIView!
    @IBOutlet weak var viewGuestheight: NSLayoutConstraint!
    @IBOutlet weak var viewPriceheight: NSLayoutConstraint!
    @IBOutlet weak var btnProceed: UIButton!
    @IBOutlet weak var btnRegister: UIButton!
    
    var stream_payment_mode = ""
    // MARK: - View Life cycle
    var access_token = ""
    var strSlug = "";

    override func viewDidLoad() {
        super.viewDidLoad()
        txtFirstName.backgroundColor = .clear;
        txtLastName.backgroundColor = .clear;
        txtEmail.backgroundColor = .clear;
        
        // Do any additional setup after loading the view.
        tblTicketTypes.register(UINib(nibName: "TicketTypesCell", bundle: nil), forCellReuseIdentifier: "TicketTypesCell")
        print("tt - aryStreamAmounts:",tempAryDisplayCurrencies)
        
        
        if let path = Bundle.main.path(forResource: "currencies", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResult = jsonResult as? Dictionary<String, AnyObject>
                {
                    // do stuff
                    jsonCurrencyList = jsonResult
                }
            } catch {
                // handle error
            }
        }
        btnCancel.layer.borderColor = UIColor.white.cgColor
        addDoneButton()
        //Free event and guest
        if (stream_payment_mode == "Free" && appDelegate.isGuest){
            let  amountWithCurrencyType = self.currencySymbol + "0.00"
            lblPrice.text = amountWithCurrencyType
        }else{
            //paid event
            //for guest
            if(appDelegate.isGuest){
                viewGuest.isHidden = true
                viewGuestheight.constant = 0
                viewGuest.layoutIfNeeded()
                viewPrice.isHidden = true
                viewPriceheight.constant = 0
                viewPrice.layoutIfNeeded()
            }
            //paid but not guest
            else{
                viewGuest.isHidden = true
                viewGuestheight.constant = 0
                viewGuest.layoutIfNeeded()
                viewPrice.isHidden = true
                viewPriceheight.constant = 0
                viewPrice.layoutIfNeeded()
            }
            
        }
        btnRegister.isHidden = true
        

    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true);
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name:UIApplication.didBecomeActiveNotification , object: nil)
        NotificationCenter.default.removeObserver(self)
    }
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    func showAlert(strMsg: String){
        let alert = UIAlertController(title: "Alert", message: strMsg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
    // continue button pressed action
    @IBAction func proceedPressed(_ sender: UIButton){
        resignKB(sender)
        let netAvailable = appDelegate.isConnectedToInternet()
        if(!netAvailable){
            showAlert(strMsg: "Please check your internet connection!")
            return
        }
        if(appDelegate.isGuest){
            if (stream_payment_mode != "Free"){
                if(indexSelectedTicketType >= 0){
                    getUserByEmail()
                }else{
                    showAlert(strMsg: "Please select Ticket Type")
                }
            }else{
                getUserByEmail()
            }
        }else{
            if(indexSelectedTicketType >= 0){
                proceedToPayment()
            }else{
                showAlert(strMsg: "Please select Ticket Type")
            }
        }
        
    }
    // register button pressed action
    @IBAction func register(_ sender: UIButton){
        resignKB(sender)
        let netAvailable = appDelegate.isConnectedToInternet()
        if(!netAvailable){
            showAlert(strMsg: "Please check your internet connection!")
            return
        }
        if(appDelegate.isGuest && stream_payment_mode == "Free"){
            registerEvent()
        }else if(appDelegate.isGuest && stream_payment_mode != "Free"){
            sendBirdConnect(shouldNavigate: false)
        }
        
    }
    func proceedToPayment(){
        //let url: String = appDelegate.baseURL +  "/proceedToPayment"
        //var user_id
        
        
        let user_id = UserDefaults.standard.string(forKey: "user_id");
        let strUserId = user_id ?? "1"
        var encoded_ticket_type_name = strTicketType
        
        encoded_ticket_type_name = encoded_ticket_type_name.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed) ?? ""
        encoded_ticket_type_name = encoded_ticket_type_name.replacingOccurrences(of: "'", with: "%27")
        encoded_ticket_type_name = encoded_ticket_type_name.replacingOccurrences(of: ":", with: "%3A")
        encoded_ticket_type_name = encoded_ticket_type_name.replacingOccurrences(of: "=", with: "%3D")
        encoded_ticket_type_name = encoded_ticket_type_name.replacingOccurrences(of: "/", with: "%252F")
        
        var queryString = "stream_id=" + String(streamId) + "&user_id=" + strUserId + "&ticket_type_name=" + encoded_ticket_type_name//ppv
        if(appDelegate.isGuest){
            queryString = queryString + "&is_guest=1&" + "token=" + access_token
        }
        print("queryString:",queryString)
        
        let urlOpen = appDelegate.paymentRedirectionURL + "/" + "pay_per_view" + "?" + queryString
        guard let url = URL(string: urlOpen) else { return }
        print("url to open:",url)
        UIApplication.shared.open(url)
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent // .default
    }
    func addDoneButton() {
        let toolbar =  UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 35))
        
        let flexButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action:#selector(resignKB(_:)))
        toolbar.setItems([flexButton, doneButton], animated: true)
        toolbar.sizeToFit()
        txtFirstName.inputAccessoryView = toolbar;
        txtLastName.inputAccessoryView = toolbar;
        txtEmail.inputAccessoryView = toolbar;
    }
    @IBAction func resignKB(_ sender: Any) {
        txtFirstName.resignFirstResponder();
        txtLastName.resignFirstResponder();
        txtEmail.resignFirstResponder();
    }
    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: txtEmail.text)
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
        if(stream_payment_mode == "Free"){
            tblheight.constant = 0
            self.tblTicketTypes.layoutIfNeeded()
            return 0
        }else{
            tblheight.constant = CGFloat(rowHeight * tempAryDisplayCurrencies.count)
            self.tblTicketTypes.layoutIfNeeded()
            return tempAryDisplayCurrencies.count
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) ->  CGFloat {
        return CGFloat(rowHeight);
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TicketTypesCell") as! TicketTypesCell
        cell.backgroundColor = UIColor.clear
        let element = self.tempAryDisplayCurrencies[indexPath.row] as? [String : Any] ?? [String:Any]()
        let ticket_type_name = element["ticket_type_name"]as? String ?? ""
        var strAmount = "0.0"
        if (element["stream_payment_amount"] as? Double) != nil {
            strAmount = String(element["stream_payment_amount"] as? Double ?? 0.00)
        }else if (element["stream_payment_amount"] as? String) != nil {
            strAmount = String(element["stream_payment_amount"] as? String ?? "0.00")
        }
        let double = (strAmount as NSString).doubleValue
        let amountDisplay = String(format: "%.02f",double)
        cell.lblTitle.text = ticket_type_name
        cell.imgCheck.image = UIImage.init(named: "check")
        if(indexSelectedTicketType == indexPath.row){
            cell.imgCheck.image = UIImage.init(named: "checked")
        }
        let  amountWithCurrencyType = self.currencySymbol + amountDisplay
        cell.lblAmount.text = amountWithCurrencyType
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //           let storyboard = UIStoryboard(name: "Main", bundle: nil);
        //           let vc = storyboard.instantiateViewController(withIdentifier: "ChannelDetailVC") as! ChannelDetailVC
        //           self.navigationController?.pushViewController(vc, animated: true)
        if(appDelegate.isGuest){
            viewGuest.isHidden = false
            viewGuestheight.constant = 220
            viewGuest.layoutIfNeeded()
            viewPrice.isHidden = false
            viewPriceheight.constant = 50
            viewPrice.layoutIfNeeded()
        }else{
            viewPrice.isHidden = false
            viewPriceheight.constant = 50
            viewPrice.layoutIfNeeded()
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        let element = self.tempAryDisplayCurrencies[indexPath.row] as? [String : Any] ?? [String:Any]()
        print("element:",element)
        let ticket_type_name = element["ticket_type_name"]as? String ?? ""
        var strAmount = "0.0"
        if (element["stream_payment_amount"] as? Double) != nil {
            strAmount = String(element["stream_payment_amount"] as? Double ?? 0.00)
        }else if (element["stream_payment_amount"] as? String) != nil {
            strAmount = String(element["stream_payment_amount"] as? String ?? "0.00")
        }
        let double = (strAmount as NSString).doubleValue
        let amountDisplay = String(format: "%.02f",double)
        let  amountWithCurrencyType = self.currencySymbol + amountDisplay
        lblPrice.text = amountWithCurrencyType
        
        strTicketType = ticket_type_name
        indexSelectedTicketType = indexPath.row
        tblTicketTypes.reloadData()
    }
    
    func gotoStreamDetails(){
        print("gotoStreamDetails")
        let storyboard = UIStoryboard(name: "Main", bundle: nil);
        let streamInfo = self.aryStreamInfo
        
        let stream_video_title = streamInfo["stream_video_title"] as? String ?? "Channel Details"
        appDelegate.isLiveLoad = "1"
        let vc = storyboard.instantiateViewController(withIdentifier: "StreamDetailVC") as! StreamDetailVC
        vc.orgId = orgId
        vc.streamId = streamId
        vc.delegate = self
        vc.performerId = performerId
        vc.strTitle = stream_video_title
        vc.isCameFromGetTickets = true
        vc.channel_name_subscription = channel_name_subscription
        vc.isVOD = isVOD
        vc.isUpcoming = isUpcoming
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    @objc func applicationDidBecomeActive(notification: NSNotification) {
        // Application is back in the foreground
        print("====applicationDidBecomeActive TT")
        //if user comes from payment redirection, need to refresh stream/vod
        getEventBySlug()
    }
    func LiveEventById() {
        viewActivity.isHidden = false
        let netAvailable = appDelegate.isConnectedToInternet()
        if(!netAvailable){
            showAlert(strMsg: "Please check your internet connection!")
            return
        }
        let url: String = appDelegate.baseURL +  "/LiveEventById"
        let user_id = UserDefaults.standard.string(forKey: "user_id");
        var streamIdLocal = "0"
        if (streamId != 0){
            streamIdLocal = String(streamId)
        }
        let headers: HTTPHeaders
        headers = [appDelegate.x_api_key: appDelegate.x_api_value]
        
        let params: [String: Any] = ["userid":user_id ?? "","performer_id":performerId,"stream_id": streamIdLocal]
        print("liveEvents params:",params)
        // let params: [String: Any] = ["userid":user_id ?? "","performer_id":"101","stream_id": "0"]
        AF.request(url, method: .post,parameters: params, encoding: JSONEncoding.default,headers:headers)
            .responseJSON { [self] response in
                self.viewActivity.isHidden = true
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any] {
                        //print("myList JSON:",json)
                        if (json["statusCode"]as? String == "200" ){
                            let data = json["Data"] as? [String:Any]
                            self.aryStreamInfo = data?["stream_info"] as? [String:Any] ?? [:]
                            
                            let user_subscription_info = data?["user_subscription_info"] != nil
                            if(user_subscription_info){
                                self.aryUserSubscriptionInfo = data?["user_subscription_info"] as? [Any] ?? [Any]()
                            }
                            if (self.aryUserSubscriptionInfo.count > 0){
                                gotoStreamDetails()
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
    func getEventBySlug() {
        let netAvailable = appDelegate.isConnectedToInternet()
        if(!netAvailable){
            showAlert(strMsg: "Please check your internet connection!")
            return
        }
        viewActivity.isHidden = false
        let url: String = appDelegate.baseURL +  "/getEventBySlug"
        let user_id = UserDefaults.standard.string(forKey: "user_id");
        var params: [String: Any] = ["slug":strSlug]
        if(!appDelegate.isGuest){
            // params["userid"] = user_id ?? ""
        }
        params["userid"] = user_id ?? ""

        print("getEventBySlug params:",params)
        let headers: HTTPHeaders
        headers = [appDelegate.x_api_key: appDelegate.x_api_value]
        AF.request(url, method: .post,parameters: params, encoding: JSONEncoding.default,headers:headers)
            .responseJSON { response in
                self.viewActivity.isHidden = true
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any] {
                        print("getEventBySlug JSON:",json)
                        if (json["statusCode"]as? String == "200" ){
                            let data = json["Data"] as? [String:Any]
                            self.aryStreamInfo = data?["stream_info"] as? [String:Any] ?? [:]
                            
                            let user_subscription_info = data?["user_subscription_info"] != nil
                            if(user_subscription_info){
                                self.aryUserSubscriptionInfo = data?["user_subscription_info"] as? [Any] ?? [Any]()
                            }
                            if (self.aryUserSubscriptionInfo.count > 0){
                                self.gotoStreamDetails()
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
    // MARK: Send Bird Methods
    func sendBirdConnect(shouldNavigate:Bool) {
        
        // self.view.endEditing(true)
        if SBDMain.getConnectState() == .open {
            SBDMain.disconnect {
                //                    DispatchQueue.main.async {
                //                        //self.setUIsForDefault()
                //                    }
                self.sendBirdConnect(shouldNavigate: shouldNavigate)
            }
            ////print("sendBirdConnect disconnect")
        }
        else {
            viewActivity.isHidden = false
            let userId = UserDefaults.standard.string(forKey: "user_id");
            let nickname = appDelegate.USER_NAME_FULL
            let userDefault = UserDefaults.standard
            userDefault.setValue(userId, forKey: "sendbird_user_id")
            userDefault.setValue(nickname, forKey: "sendbird_user_nickname")
            
            //self.setUIsWhileConnecting()
            
            ConnectionManager.login(userId: userId ?? "1", nickname: nickname) { user, error in
                print("logged in user info:",user)
                self.viewActivity.isHidden = true
                guard error == nil else {
                    DispatchQueue.main.async {
                        // self.setUIsForDefault()
                    }
                    self.showAlert(strMsg:error?.localizedDescription ?? "" )
                    return
                }
                if(shouldNavigate){
                    DispatchQueue.main.async {
                        self.gotoStreamDetails()
                    }
                }else{
                    //for guets paid event
                    self.proceedToPayment()
                }
               
            }
        }
    }
    func gotoLogin(){
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
    func showConfirmation(strMsg:String,isNewAccount:Bool){
        let alert = UIAlertController(title: "Alert", message: strMsg, preferredStyle: .alert)
        if(isNewAccount){
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { [self] action in
                    //sendpwd need to call
                    sendPassword()
            }))
        }else{
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { [self] action in
                    gotoLogin()
            }))
        }
        if(isNewAccount){
            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { [self] action in
                btnRegister.isHidden = false
                btnProceed.isHidden = true
            }))
        }
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
    func sendPassword(){
        viewActivity.isHidden = false
        let netAvailable = appDelegate.isConnectedToInternet()
        if(!netAvailable){
            showAlert(strMsg: "Please check your internet connection!")
            return
        }
        let url: String = appDelegate.profileURL +  "/sendPassword"
        
        let headers: HTTPHeaders
        headers = [appDelegate.x_api_key: appDelegate.x_api_value]
        let user_id = UserDefaults.standard.string(forKey: "user_id");

        let params: [String: Any] = ["user_id":user_id ?? ""]
        print("sendPassword params:",params)
        // let params: [String: Any] = ["userid":user_id ?? "","performer_id":"101","stream_id": "0"]
        AF.request(url, method: .post,parameters: params, encoding: JSONEncoding.default,headers:headers)
            .responseJSON { [self] response in
                self.viewActivity.isHidden = true
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any] {
                        print("sendPassword JSON:",json)
                        if (json["status"]as? Int == 0 ){
                            let email = txtEmail.text!.lowercased().trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
                            let msg = "Password sent to " + email
                            showAlert(strMsg: msg)
                            btnRegister.isHidden = false
                            btnProceed.isHidden = true
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
    
    func getUserByEmail() {
        let firstName = txtFirstName.text!.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        let lastName = txtLastName.text!.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        let email = txtEmail.text!.lowercased().trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        
        if (firstName.count == 0){
            showAlert(strMsg: "Please enter first name");
        }else if (lastName.count == 0){
            showAlert(strMsg: "Please enter last name");
        }else if (email.count == 0){
            showAlert(strMsg: "Please enter email");
        }else if (!isValidEmail()){
            showAlert(strMsg: "Please enter valid email");
        }else{
            print("else")
            viewActivity.isHidden = false
            let netAvailable = appDelegate.isConnectedToInternet()
            if(!netAvailable){
                showAlert(strMsg: "Please check your internet connection!")
                return
            }
            let url: String = appDelegate.profileURL +  "/getUserByEmail"
            
            let headers: HTTPHeaders
            headers = [appDelegate.x_api_key: appDelegate.x_api_value]
            
            let params: [String: Any] = ["firstname":firstName,"lastname":lastName,"email":email,"stream_id":streamId]
            print("getUserByEmail params:",params)
            // let params: [String: Any] = ["userid":user_id ?? "","performer_id":"101","stream_id": "0"]
            AF.request(url, method: .post,parameters: params, encoding: JSONEncoding.default,headers:headers)
                .responseJSON { [self] response in
                    self.viewActivity.isHidden = true
                    switch response.result {
                    case .success(let value):
                        if let json = value as? [String: Any] {
                            print("getUserByEmail JSON:",json)
                            if (json["status"]as? Int == 0 ){
                                let tickets = json["tickets"]as? Int ?? 0
                                let user = json["user"] as? [String:Any] ?? [:]
                                let is_guest = user["is_guest"]as? Bool ?? false
//                                print("tkts:",tickets)
//                                print("is_guest:",is_guest)
                                access_token = user["access_token"] as? String ?? ""
                                UserDefaults.standard.set(user["id"], forKey: "user_id")
                                UserDefaults.standard.set(user["access_token"], forKey: "session_token")
                                let fn = user["first_name"] as? String ?? ""
                                let ln = user["last_name"]as? String ?? ""
                                let displayName = user["display_name"]as? String ?? ""
                                
                                let strName = String((fn.first ?? "A")) + String((ln.first ?? "B"))
                                self.appDelegate.USER_NAME = strName;
                                self.appDelegate.USER_NAME_FULL = displayName
                                self.appDelegate.USER_DISPLAY_NAME = displayName
                                UserDefaults.standard.set(self.appDelegate.USER_NAME, forKey: "USER_NAME")
                                UserDefaults.standard.set(self.appDelegate.USER_NAME_FULL, forKey: "USER_NAME_FULL")
                                UserDefaults.standard.set(displayName, forKey: "user_display_name")

                                print("access_token:",access_token)
                                if(tickets == 1){
                                    //email id already registered with event
                                    let emailAlert = email + " already registered for this stream"
                                    showAlert(strMsg: emailAlert)
                                    sendBirdConnect(shouldNavigate: true)
                                }else if(tickets == 0){
                                    txtEmail.isEnabled = false
                                    txtFirstName.isEnabled = false
                                    txtLastName.isEnabled = false
                                    txtEmail.textColor = UIColor.lightGray
                                    txtFirstName.textColor = UIColor.lightGray
                                    txtLastName.textColor = UIColor.lightGray
                                    //email id not registered with event
                                    UserDefaults.standard.set("guest-user", forKey: "user")
                                    if(is_guest){
                                        showConfirmation(strMsg: "Do you want to create an account?",isNewAccount:true)
                                    }else {
                                        showConfirmation(strMsg: "An account with this email address already exists, Please sign in.",isNewAccount:false)
                                    }
                                }
                                
                            }else{
                                let strMsg = json["message"] as? String ?? ""
                                //print("422 strMsg:",strMsg)
                                if(strMsg.lowercased().contains("email must be unique")){
                                    showConfirmation(strMsg: "An account with this email address already exists, Please sign in.",isNewAccount:false)
                                }else{
                                    self.showAlert(strMsg: strMsg)
                                }
                            }
                        }
                    case .failure(let error):
                        let errorDesc = error.localizedDescription.replacingOccurrences(of: "URLSessionTask failed with error:", with: "")
                        self.showAlert(strMsg: errorDesc)
                        self.viewActivity.isHidden = true
                        
                    }
                }
        }
    }
    
    // MARK: Handler for getCategoryOrganisations API
    func registerEvent(){
        //print("registerEvent")
        let netAvailable = appDelegate.isConnectedToInternet()
        if(!netAvailable){
            showAlert(strMsg: "Please check your internet connection!")
            return
        }
        viewActivity.isHidden = false
        let url: String = appDelegate.paymentBaseURL +  "/registerEvent"
        let user_id = UserDefaults.standard.string(forKey: "user_id");
        let streamObj = self.aryStreamInfo
        let currency_type = streamObj["currency_type"] as? String ?? ""
        let stream_video_title = streamObj["stream_video_title"] as? String ?? ""
        var strAmount = "0.0"
        
        if (streamObj["stream_payment_amount"] as? Double) != nil {
            strAmount = String(streamObj["stream_payment_amount"] as? Double ?? 0.0)
        }else if (streamObj["stream_payment_amount"] as? String) != nil {
            strAmount = String(streamObj["stream_payment_amount"] as? String ?? "0.0")
        }
        let doubleAmount = Double(strAmount)
        let amount = String(format: "%.02f", doubleAmount!)
        let stream_amounts = streamObj["stream_amounts"] as? String ?? "";
        let publish_date_time = streamObj["publish_date_time"] as? String ?? "";
        let video_thumbnail_image = streamObj["video_thumbnail_image"] as? String ?? "";
        let user_first_name = streamObj["user_first_name"] as? String ?? "";
        let user_last_name = streamObj["user_last_name"] as? String ?? "";
        let user_display_name = streamObj["user_display_name"] as? String ?? "";
        let channel_name = streamObj["channel_name"] as? String ?? "";
        let stream_status = streamObj["stream_status"] as? String ?? "";
        let expected_end_date_time = streamObj["expected_end_date_time"] as? String ?? "";
        
        let params: [String: Any] = ["paymentInfo": ["paymentType": "pay_per_view","payment_type": "pay_per_view","organization_id": orgId,"currency": currency_type,"amount": 0,"stream_id": streamId,"streamInfo": ["id": streamId,"stream_video_title": stream_video_title,"organization_id": orgId,"amount":amount,"currency": currency_type,"stream_amounts":stream_amounts,"publish_date_time": publish_date_time,"video_thumbnail_image": video_thumbnail_image,"performer_id": performerId,"user_first_name": user_first_name,"user_last_name": user_last_name,"user_display_name": user_display_name,"channel_name": channel_name,"number_of_creators": self.number_of_creators,"stream_status": stream_status,"currency_type": currency_type,"expected_end_date_time": expected_end_date_time]]]
        ////print("params:",params)
        
        let session_token = UserDefaults.standard.string(forKey: "session_token") ?? ""
        let headers : HTTPHeaders = [
            "Content-Type": "application/json",
            appDelegate.x_api_key:appDelegate.x_api_value,
            "Authorization": "Bearer " + access_token
        ]
        AF.request(url, method: .post,parameters: params, encoding: JSONEncoding.default,headers:headers)
            .responseJSON { response in
                self.viewActivity.isHidden = true
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any] {
                        //print("registerEvent JSON:",json)
                        if (json["status"]as? Int == 0){
                            self.sendBirdConnect(shouldNavigate: true)
                        }else{
                            let strError = json["message"] as? String
                            //////print("strError1:",strError ?? "")
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
}



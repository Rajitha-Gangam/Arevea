    //
    //  LoginViewController.swift
    //  aws_amplify_integration
    //
    //  Created by Calin Cristian on 27/03/2019.
    //  Copyright © 2019 Calin Cristian Ciubotariu. All rights reserved.
    //
    
    import UIKit
    import AWSAuthCore
    import FBSDKCoreKit
    import AWSCognito
    import Alamofire
    import SendBirdSDK
    import AWSAPIGateway
    
    protocol GLLoginDelegate {
        func didFinishLogin(status: Bool)
    }
    
    class LoginVC: UIViewController,UITextFieldDelegate {
        // MARK: Variables Declarataion
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        var loginDelegate: GLLoginDelegate?
        @IBOutlet weak var txtUserName: ACFloatingTextfield!
        @IBOutlet weak var txtPassword: ACFloatingTextfield!
        @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
        @IBOutlet weak var viewActivity: UIView!
        var strFCMToken = ""
        // MARK: View Life Cycle Methods
        override func viewDidLoad() {
            super.viewDidLoad()
            
            txtUserName.delegate = self;
            txtPassword.delegate = self;
            txtUserName.backgroundColor = .clear;
            txtPassword.backgroundColor = .clear;
            self.navigationController?.isNavigationBarHidden = true
            viewActivity.isHidden = true
            
            addDoneButton()
            // dismissPickerView()
            //self.assignbackground();
        }
        
        
        override func viewWillAppear(_ animated: Bool) {
            AppDelegate.AppUtility.lockOrientation(.portrait)
            
            txtUserName.text = appDelegate.emailPopulate// if user comes from reset pwd / confirm sign up, auto pupulate email
            txtPassword.text = "";
//            txtUserName.text = "gangamrajitha3@gmail.com";
//            txtPassword.text = "V@rshitha12345";
        }
        override func viewWillDisappear(_ animated: Bool) {
            appDelegate.emailPopulate = ""
        }
            func createDeviceToken(){
                print("===createDeviceToken")
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let url: String = appDelegate.FCMBaseURL + "/createDeviceToken"
                //print("getEvents input:",inputData)
                //viewActivity.isHidden = false
               let user_id = UserDefaults.standard.string(forKey: "user_id");
                let inputData: [String: Any] = ["user_id":user_id ?? "","device_token":appDelegate.strFCMToken]
                print("inputData of createDeviceToken:",inputData)
                let headers: HTTPHeaders
                headers = [appDelegate.x_api_key: appDelegate.x_api_value]
                AF.request(url, method: .post,parameters: inputData, encoding: JSONEncoding.default,headers:headers)
                    .responseJSON { response in
                        DispatchQueue.main.async {
                            //self.viewActivity.isHidden = true
                            switch response.result {
                            case .success(let value):
                                if let json = value as? [String: Any] {
                                    print("createDeviceToken JSON:",json)
                                    if (json["statusCode"]as? String == "200" ){
                                        let arn  = json["data"] as? String ?? "";
                                        print("arn:",arn)
                                        UserDefaults.standard.set(arn, forKey: "arn")
                                    }else{
                                        
                                    }
                                    //self.tblMain.reloadSections([1], with: .none)
                                    // self.tblMain.reloadData()
                                }
                            case .failure(let error):
                                let errorDesc = error.localizedDescription.replacingOccurrences(of: "URLSessionTask failed with error:", with: "")
                                //print("getEvents errorDesc:",errorDesc)
        //                        self.showAlert(strMsg: errorDesc)
        //                        self.viewActivity.isHidden = true
                                
                            }
                        }
                }
            }
        @IBAction func resignKB(_ sender: Any) {
            txtUserName.resignFirstResponder();
            txtPassword.resignFirstResponder();
        }
        func addDoneButton() {
            let toolbar =  UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 35))
            let flexButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
            let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action:#selector(resignKB(_:)))
            toolbar.setItems([flexButton, doneButton], animated: true)
            toolbar.sizeToFit()
            txtUserName.inputAccessoryView = toolbar;
            txtPassword.inputAccessoryView = toolbar;
        }
        
        func assignbackground(){
            let background = UIImage(named: "bg")
            var imageView : UIImageView!
            imageView = UIImageView(frame: view.bounds)
            imageView.contentMode =  UIView.ContentMode.scaleAspectFill
            imageView.clipsToBounds = true
            imageView.image = background
            imageView.center = view.center
            view.addSubview(imageView)
            self.view.sendSubviewToBack(imageView)
        }
        func showAlert(strMsg: String){
            let alert = UIAlertController(title: "Alert", message: strMsg, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            
            DispatchQueue.main.async {
                self.present(alert, animated: true)
            }
        }
        
        
        func delayWithSeconds(_ seconds: Double, completion: @escaping () -> ()) {
            DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                completion()
            }
        }
        func isValidEmail() -> Bool {
            let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
            let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
            return emailPred.evaluate(with: txtUserName.text)
        }
        @IBAction func login(_ sender: Any) {
            txtUserName.resignFirstResponder();
            txtPassword.resignFirstResponder();
            if (txtUserName.text?.lowercased().count == 0){
                showAlert(strMsg: "Please enter email");
            }else if (!isValidEmail()){
                showAlert(strMsg: "Please enter valid email");
            }else if (txtPassword.text?.count == 0){
                showAlert(strMsg: "Please enter password");
            }else{
                //AWSsignIn();
                let email = txtUserName.text!.lowercased().trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
                let pwd = txtPassword.text!.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
                let inputData = ["email":email,"password":pwd]
                OLLogin(inputData:inputData )
                
            }
        }
        func OLLogin(inputData:[String: Any]){
            let username = self.txtUserName.text!.lowercased().trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let url: String = appDelegate.websiteURL + "/api/user/v1/fanLogin"
            viewActivity.isHidden = false
            let headers: HTTPHeaders = [
                "Authorization": "Bearer " + appDelegate.ol_access_token,
                "Accept": "application/json"
            ]
            AF.request(url, method: .post,parameters: inputData, encoding: JSONEncoding.default,headers:headers)
                .responseJSON { response in
                    self.viewActivity.isHidden = true
                    switch response.result {
                    case .success(let value):
                        if let json = value as? [String: Any] {
                            //print("OLLogin JSON:",json)
                            if(json["status"] as? Int == 0){
                                let user = json["user"] as? [String:Any] ?? [:]
                                //print("user:",user)
                                let custom_attributes = user["custom_attributes"] as? [String:Any] ?? [:]
                                
                                if (custom_attributes["is_user_verify"] as? String == "0"){
                                    UserDefaults.standard.set(username, forKey: "user_email")
                                    let storyboard = UIStoryboard(name: "Main", bundle: nil);
                                    let vc = storyboard.instantiateViewController(withIdentifier: "ConfirmSignUpVC") as! ConfirmSignUpVC
                                    self.navigationController?.pushViewController(vc, animated: true)
                                }else{
                                    UserDefaults.standard.set(username, forKey: "user_email")
                                    /* self.delayWithSeconds(2.0){
                                     self.viewActivity.isHidden = false
                                     self.getUser();
                                     }*/
                                    let userID = user["id"]as? String ?? ""
                                    //print("====userId:",userID)
                                    UserDefaults.standard.set(userID, forKey: "user_id")
                                    
                                    UserDefaults.standard.set(user["id"], forKey: "user_id")
                                    UserDefaults.standard.set(user["user_type"], forKey: "user_type")
                                    UserDefaults.standard.set(user["session_token"], forKey: "session_token")
                                    let fn = user["user_first_name"] as? String ?? ""
                                    let ln = user["user_last_name"]as? String ?? ""
                                    let displayName = user["user_display_name"]as? String ?? ""
                                    
                                    let strName = String((fn.first ?? "A")) + String((ln.first ?? "B"))
                                    self.appDelegate.USER_NAME = strName;
                                    self.appDelegate.USER_NAME_FULL = (fn ?? "") + " " + (ln ?? "")
                                    self.appDelegate.USER_DISPLAY_NAME = displayName
                                    
                                    UserDefaults.standard.set(self.appDelegate.USER_NAME, forKey: "USER_NAME")
                                    UserDefaults.standard.set(self.appDelegate.USER_NAME_FULL, forKey: "USER_NAME_FULL")
                                    UserDefaults.standard.set(displayName, forKey: "user_display_name")
                                    self.createDeviceToken()
                                    self.sendBirdConnect()
                                    
                                }
                                //user.custom_attributes.is_user_verify
                            }else{
                                let strMsg = json["message"] as? String ?? ""
                                self.showAlert(strMsg: strMsg)
                                
                            }
                            
                        }
                    case .failure(let error):
                        let errorDesc = error.localizedDescription.replacingOccurrences(of: "URLSessionTask failed with error:", with: "")
                        self.showAlert(strMsg: errorDesc)
                        
                    }
            }
        }
        
        @IBAction func signUp(_ sender: Any) {
            let netAvailable = appDelegate.isConnectedToInternet()
            if(!netAvailable){
                showAlert(strMsg: "Please check your internet connection!")
                return
            }
            let storyboard = UIStoryboard(name: "Main", bundle: nil);
            let vc = storyboard.instantiateViewController(withIdentifier: "SignUpVC") as! SignUpVC
            self.navigationController?.pushViewController(vc, animated: true)
        }
        @IBAction func forgotPassword(_ sender: Any) {
            let netAvailable = appDelegate.isConnectedToInternet()
            if(!netAvailable){
                showAlert(strMsg: "Please check your internet connection!")
                return
            }
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil);
            let vc = storyboard.instantiateViewController(withIdentifier: "ResetPasswordVC") as! ResetPasswordVC
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        // MARK: Text Field Delegate Methods
        
        func textFieldDidBeginEditing(_ textField: UITextField) {
            
        }
        func textFieldDidEndEditing(_ textField: UITextField) {
            textField.resignFirstResponder();
        }
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder();
            return true;
        }
        override var preferredStatusBarStyle: UIStatusBarStyle {
            return .lightContent // .default
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
        
        
        // MARK: Handler for events(events) API
        func getUserById(inputData:[String: Any]){
            //print("getUserById:",inputData)
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let url: String = appDelegate.ol_lambda_url +  "/getUserById"
            viewActivity.isHidden = false
            let headers: HTTPHeaders
            headers = [appDelegate.x_api_key: appDelegate.x_api_value]
            AF.request(url, method: .post,parameters:inputData,  encoding: JSONEncoding.default,headers:headers)
                .responseJSON { response in
                    self.viewActivity.isHidden = true
                    switch response.result {
                    case .success(let value):
                        if let json = value as? [String: Any] {
                            //print("getUserById JSON:",json)
                            if (json["status"]as? Int == 0 ){
                                let user = json["user"] as? [String: Any] ?? [:]
                                UserDefaults.standard.set(user["id"], forKey: "user_id")
                                UserDefaults.standard.set(user["user_type"], forKey: "user_type")
                                UserDefaults.standard.set(user["session_token"], forKey: "session_token")
                                let fn = user["user_first_name"] as? String
                                let ln = user["user_last_name"]as? String
                                let displayName = user["user_display_name"]as? String
                                
                                let strName = String((fn?.first ?? "A")) + String((ln?.first ?? "B"))
                                self.appDelegate.USER_NAME = strName;
                                self.appDelegate.USER_NAME_FULL = (fn ?? "") + " " + (ln ?? "")
                                self.appDelegate.USER_DISPLAY_NAME = displayName!
                                
                                UserDefaults.standard.set(self.appDelegate.USER_NAME, forKey: "USER_NAME")
                                UserDefaults.standard.set(self.appDelegate.USER_NAME_FULL, forKey: "USER_NAME_FULL")
                                UserDefaults.standard.set(displayName, forKey: "user_display_name")
                                
                                self.sendBirdConnect()
                            }
                            else{
                                self.logoutOL()
                                let strMsg = json["message"] as? String ?? ""
                                self.showAlert(strMsg: strMsg)
                            }
                            
                        }
                    case .failure(let error):
                        self.logoutOL()
                        let errorDesc = error.localizedDescription.replacingOccurrences(of: "URLSessionTask failed with error:", with: "")
                        self.showAlert(strMsg: errorDesc)
                        self.viewActivity.isHidden = true
                        
                    }
            }
        }
        
        
        
        @objc func action() {
            view.endEditing(true)
        }
        
        // MARK: Send Bird Methods
        func sendBirdConnect() {
            
            // self.view.endEditing(true)
            if SBDMain.getConnectState() == .open {
                SBDMain.disconnect {
                    //                    DispatchQueue.main.async {
                    //                        //self.setUIsForDefault()
                    //                    }
                    self.sendBirdConnect()
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
                    self.viewActivity.isHidden = true
                    guard error == nil else {
                        DispatchQueue.main.async {
                            // self.setUIsForDefault()
                        }
                        // self.showAlert(strMsg:error?.localizedDescription ?? "" )
                        return
                    }
                    
                    DispatchQueue.main.async {
                        // self.setUIsForDefault()
                        ////print("Logged In With SendBird Successfully")
                        let storyboard = UIStoryboard(name: "Main", bundle: nil);
                        let vc = storyboard.instantiateViewController(withIdentifier: "DashBoardVC") as! DashBoardVC
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            }
        }
        @IBAction func loginWithGoogle(_ sender: Any) {
            print("loginWithGoogle")
            let storyboard = UIStoryboard(name: "Main", bundle: nil);
            let vc = storyboard.instantiateViewController(withIdentifier: "FBLoginVC") as! FBLoginVC
            vc.strSocialMedia = "google"
            self.navigationController?.pushViewController(vc, animated: true)
        }
        @IBAction func loginWithFB(_ sender: Any) {
            print("loginWithFB")
            let storyboard = UIStoryboard(name: "Main", bundle: nil);
            let vc = storyboard.instantiateViewController(withIdentifier: "FBLoginVC") as! FBLoginVC
            vc.strSocialMedia = "fb"
            self.navigationController?.pushViewController(vc, animated: true)
        }
        @IBAction func loginWithLinkedIn(_ sender: Any) {
            print("loginWithLinkedIn")
            let storyboard = UIStoryboard(name: "Main", bundle: nil);
            let vc = storyboard.instantiateViewController(withIdentifier: "FBLoginVC") as! FBLoginVC
            vc.strSocialMedia = "linkedin"
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    extension LoginVC: AWSSignInDelegate {
        func onLogin(signInProvider: AWSSignInProvider, result: Any?, error: Error?) {
            ////print(result)
        }
    }

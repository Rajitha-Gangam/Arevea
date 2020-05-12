    //
    //  LoginViewController.swift
    //  aws_amplify_integration
    //
    //  Created by Calin Cristian on 27/03/2019.
    //  Copyright © 2019 Calin Cristian Ciubotariu. All rights reserved.
    //
    
    import UIKit
    import AWSMobileClient
    import AWSAuthCore
    import FBSDKCoreKit
    import AWSCognito
    import Alamofire
    import SendBirdSDK
    
    protocol GLLoginDelegate {
        func didFinishLogin(status: Bool)
    }
    
    class LoginVC: UIViewController,UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
        // MARK: Variables Declarataion
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        var loginDelegate: GLLoginDelegate?
        
        @IBOutlet weak var txtUserName: UITextField!
        @IBOutlet weak var txtPassword: UITextField!
        @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
        @IBOutlet weak var txtEnv: UITextField!
        
        var pickerData: [String] = [String]()
        var sendBirdUserId = "";
        
        // MARK: View Life Cycle Methods
        
        override func viewDidLoad() {
            super.viewDidLoad()
            self.assignbackground();
            txtUserName.delegate = self;
            txtPassword.delegate = self;
            self.navigationController?.isNavigationBarHidden = true
            addDoneButton()
            pickerData = ["dev", "qa", "pre-prod", "prod"]
            createPickerView()
            dismissPickerView()
            
        }
        override func viewWillAppear(_ animated: Bool) {
            txtUserName.text = "";
            txtPassword.text = "";
//            txtUserName.text = "grajitha2009@gmail.com";
//            txtPassword.text = "V@rshitha12345";
            
            
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
        func AWSsignIn(){
            let username = txtUserName.text!
            let password = txtPassword.text!
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
            
            AWSMobileClient.sharedInstance().signIn(username: username, password: password) {
                (signInResult, error) in
                print("signInResult:\(String(describing: signInResult))");
                
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.isHidden = true;
                }
                if let error =  error as? AWSMobileClientError {
                    switch(error) {
                    case .notAuthorized(let message):
                        self.showAlert(strMsg: message);
                    case .userNotFound(let message):
                        self.showAlert(strMsg: message);
                    case .userNotConfirmed(let message):
                        print("userNotConfirmed:",message)
                        DispatchQueue.main.async {
                            UserDefaults.standard.set(username, forKey: "user_email")
                            let storyboard = UIStoryboard(name: "Main", bundle: nil);
                            let vc = storyboard.instantiateViewController(withIdentifier: "ConfirmSignUpVC") as! ConfirmSignUpVC
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                        
                    default:
                        self.showAlert(strMsg: "\(error)");
                        break
                    }
                    print("There's an error : \(error.localizedDescription)")
                    print(error)
                    return
                }
                guard let signInResult = signInResult else {
                    return
                }
                switch (signInResult.signInState) {
                case .signedIn:
                    print("User is signed in.")
                    UserDefaults.standard.set(username, forKey: "user_email")
                    self.getUser();
                    //                                    DispatchQueue.main.async {
                    //                                        let storyboard = UIStoryboard(name: "Main", bundle: nil);
                    //                                        let vc = storyboard.instantiateViewController(withIdentifier: "DashBoardVC") as! DashBoardVC
                    //                                        self.navigationController?.pushViewController(vc, animated: true)
                    //                                    }
                    
                case .newPasswordRequired:
                    print("User needs a new password.")
                    self.showAlert(strMsg: "User needs a new password")
                default:
                    print("Sign In needs info which is not et supported.")
                    self.showAlert(strMsg: "Sign In needs info which is not et supported")
                    
                }
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
            if (txtUserName.text?.count == 0){
                showAlert(strMsg: "Please enter email");
            }else if (!isValidEmail()){
                showAlert(strMsg: "Please enter valid email");
            }else if (txtPassword.text?.count == 0){
                showAlert(strMsg: "Please enter password");
            }else{
                AWSsignIn();
            }
        }
        
        @IBAction func signUp(_ sender: Any) {
            let storyboard = UIStoryboard(name: "Main", bundle: nil);
            let vc = storyboard.instantiateViewController(withIdentifier: "SubscriptionPlanVC") as! SubscriptionPlanVC
            self.navigationController?.pushViewController(vc, animated: true)
        }
        @IBAction func forgotPassword(_ sender: Any) {
            let storyboard = UIStoryboard(name: "Main", bundle: nil);
            let vc = storyboard.instantiateViewController(withIdentifier: "ResetPasswordVC") as! ResetPasswordVC
            self.navigationController?.pushViewController(vc, animated: true)
        }
        @IBAction func facebook(_ sender: Any) {
            // Perform SAML token federation
            AWSMobileClient.sharedInstance().federatedSignIn(providerName: "Facebook",
                                                             token: "230469618276761") { (userState, error) in
                                                                if let error = error as? AWSMobileClientError {
                                                                    print(error.localizedDescription)
                                                                }
                                                                if let userState = userState {
                                                                    print("Status: \(userState.rawValue)")
                                                                }
            }
            // awsSignInFacebook(fbAuthToken: "230469618276761")
            
        }
        func awsSignInFacebook(fbAuthToken: String){
            let logins = ["graph.facebook.com" : fbAuthToken]
            _ = CustomIdentityProvider(tokens: logins)
            //        let credentialsProvider = AWSCognitoCredentialsProvider(regionType: .APSouth1, identityPoolId: AWSConstants.CognitoFederatedIdentityUserPoolId, identityProviderManager: customIdentityProvider)
            
            
            let credentialsProvider = AWSCognitoCredentialsProvider(regionType: .USEast1, identityPoolId: "us-east-1_DjsrvpsGK")
            let configuration = AWSServiceConfiguration(region: .USEast1, credentialsProvider: credentialsProvider)
            AWSServiceManager.default().defaultServiceConfiguration = configuration
            
            credentialsProvider.getIdentityId().continueWith { (task: AWSTask!) -> AnyObject? in
                
                if (task.error != nil) {
                    print("Error: " + (task.error?.localizedDescription)!)
                    
                } else {
                    // the task result will contain the identity id
                    let cognitoId = task.result
                    print("Cognito ID : \(String(describing: cognitoId))")
                }
                return nil
            }
        }
        class CustomIdentityProvider: NSObject, AWSIdentityProviderManager {
            var tokens : [String : String]?
            
            init(tokens: [String : String]) {
                self.tokens = tokens
            }
            
            @objc func logins() -> AWSTask<NSDictionary> {
                return AWSTask(result: tokens! as NSDictionary)
            }
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
        // MARK: Handler for getUser API, using for filters
        func getUser(){
            let url: String = appDelegate.baseURL +  "/getUser"
            let params: [String: Any] = ["email":txtUserName.text!]
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
            AF.request(url, method: .post,  parameters: params, encoding: JSONEncoding.default)
                .responseJSON { response in
                    switch response.result {
                    case .success(let value):
                        if let json = value as? [String: Any] {
                            if (json["status"]as? Int == 0){
                                print(json["message"] ?? "")
                                let user = json["user"] as? [String:Any];
                               // print("user:",user ?? "")
                                UserDefaults.standard.set(user?["id"], forKey: "user_id")
                                UserDefaults.standard.set(user?["user_type"], forKey: "user_type")
                                UserDefaults.standard.set(user?["session_token"], forKey: "session_token")
                                
                                let fn = user?["user_first_name"] as? String
                                let ln = user?["user_last_name"]as? String
                                let strName = String((fn?.first)!) + String((ln?.first)!)
                                UserDefaults.standard.set(user?["session_token"], forKey: "session_token")
                               self.appDelegate.USER_NAME = strName;
                                self.appDelegate.USER_NAME_FULL = (fn ?? "") + " " + (ln ?? "")
                                UserDefaults.standard.set(self.appDelegate.USER_NAME, forKey: "USER_NAME")
                                UserDefaults.standard.set(self.appDelegate.USER_NAME_FULL, forKey: "USER_NAME_FULL")


                                
                                
                                self.activityIndicator.isHidden = true;
                                self.activityIndicator.stopAnimating();
                                self.setupSendBirdUI()
                            }else{
                                let strError = json["message"] as? String
                                print(strError ?? "")
                                self.showAlert(strMsg: strError ?? "")
                                self.activityIndicator.isHidden = true;
                                self.activityIndicator.stopAnimating();
                                //we are calling logout here, bcz if user click on login again it shoold work with AWS, otherwise, user alreday loggen in state will come
                                AWSMobileClient.sharedInstance().signOut() { error in
                                    if let error = error {
                                        print(error)
                                        return
                                    }
                                }
                                
                            }
                            
                        }
                    case .failure(let error):
                        print(error)
                        self.activityIndicator.isHidden = true;
                        self.activityIndicator.stopAnimating();
                        self.showAlert(strMsg: error.localizedDescription)
                        //we are calling logout here, bcz if user click on login again it shoold work with AWS, otherwise, user alreday loggen in state will come
                        AWSMobileClient.sharedInstance().signOut() { error in
                            if let error = error {
                                print(error)
                                return
                            }
                        }
                    }
            }
        }
        
        // MARK: Picker  Methods
        func createPickerView() {
            let pickerView = UIPickerView()
            pickerView.delegate = self
            txtEnv.inputView = pickerView
        }
        
        func dismissPickerView() {
            let toolbar =  UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 35))
            
            toolbar.sizeToFit()
            let flexButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
            let button = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.action))
            toolbar.setItems([flexButton, button], animated: true)
            toolbar.isUserInteractionEnabled = true
            txtEnv.inputAccessoryView = toolbar
            
            
        }
        
        @objc func action() {
            view.endEditing(true)
        }
        // MARK: Picker DataSource & Delegate Methods
        
        func numberOfComponents(in pickerView: UIPickerView) -> Int {
            return 1
        }
        
        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            return pickerData.count
        }
        
        func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            return pickerData[row]
            
        }
        
        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            let selectedItem = pickerData[row]
            txtEnv.text = selectedItem
        }
        // MARK: Send Bird Methods
        
        func setupSendBirdUI() {
            if let userId = UserDefaults.standard.object(forKey: "sendbird_user_id") as? String {
                self.sendBirdUserId = userId
            }
            
            self.sendBirdConnect()
        }
        func sendBirdConnect() {
            
            // self.view.endEditing(true)
            if SBDMain.getConnectState() == .open {
                SBDMain.disconnect {
//                    DispatchQueue.main.async {
//                        //self.setUIsForDefault()
//                    }
                    self.sendBirdConnect()
                }
                print("sendBirdConnect disconnect")
            }
            else {
                activityIndicator.isHidden = false
                activityIndicator.startAnimating()
                let userId = UserDefaults.standard.string(forKey: "user_id");
                let nickname = appDelegate.USER_NAME_FULL
                
                let userDefault = UserDefaults.standard
                userDefault.setValue(userId, forKey: "sendbird_user_id")
                userDefault.setValue(nickname, forKey: "sendbird_user_nickname")
                
                //self.setUIsWhileConnecting()
                
                ConnectionManager.login(userId: userId ?? "1", nickname: nickname) { user, error in
                    self.activityIndicator.isHidden = true;
                    self.activityIndicator.stopAnimating();
                    guard error == nil else {
                        DispatchQueue.main.async {
                            // self.setUIsForDefault()
                        }
                        // self.showAlert(strMsg:error?.localizedDescription ?? "" )
                        return
                    }
                    
                    DispatchQueue.main.async {
                        // self.setUIsForDefault()
                        print("Logged In With SendBird Successfully")
                        let storyboard = UIStoryboard(name: "Main", bundle: nil);
                        let vc = storyboard.instantiateViewController(withIdentifier: "DashBoardVC") as! DashBoardVC
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            }
        }
        
        
        
    }
    extension LoginVC: AWSSignInDelegate {
        func onLogin(signInProvider: AWSSignInProvider, result: Any?, error: Error?) {
            //print(result)
        }
    }

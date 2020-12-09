//
//  NewPasswordViewController.swift
//  aws_amplify_integration
//
//  Created by Calin Cristian on 27/03/2019.
//  Copyright © 2019 Calin Cristian Ciubotariu. All rights reserved.
//

import UIKit
import Alamofire

class NewPasswordVC: UIViewController ,UITextFieldDelegate{
    // MARK: - Variables Declaration
    @IBOutlet weak var txtCode: UITextField!
    @IBOutlet weak var txtPwd: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var username: String?
    var camefrom = "";
    @IBOutlet weak var viewActivity: UIView!
    
    // MARK: - View Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        viewActivity.isHidden = true
        txtCode.backgroundColor = .clear
        txtPwd.backgroundColor = .clear
        
        self.assignbackground();
        username = UserDefaults.standard.string(forKey: "user_email");
        // Do any additional setup after loading the view.
        addDoneButton()
        
    }
    func addDoneButton() {
        let toolbar =  UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 35))
        
        let flexButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action:#selector(resignKB(_:)))
        toolbar.setItems([flexButton, doneButton], animated: true)
        toolbar.sizeToFit()
        txtCode.inputAccessoryView = toolbar;
        txtPwd.inputAccessoryView = toolbar;
    }
    @IBAction func resignKB(_ sender: Any) {
        txtCode.resignFirstResponder();
        txtPwd.resignFirstResponder();
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
    
    
    @IBAction func verifyCode(_ sender: Any) {
        txtPwd.resignFirstResponder();
        txtCode.resignFirstResponder();
        let netAvailable = appDelegate.isConnectedToInternet()
        if(!netAvailable){
            showAlert(strMsg: "Please check your internet connection!")
            return
        }
        if (txtCode.text?.count == 0){
            showAlert(strMsg: "Please enter verification code");
        }else if (txtPwd.text?.count == 0){
            showAlert(strMsg: "Please enter new password");
        }else{
            //CognitoVerify()
            let inputData = ["email": username,"type": "email_verification","otp":txtCode.text!]
            verifyOTP(inputData: inputData)
        }
        
    }
    // MARK: Handler for events(events) API
    func verifyOTP(inputData:[String: Any]){
        //print("verifyOTP:",inputData)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let url: String = appDelegate.baseURL +  "/verifyOTP"
        viewActivity.isHidden = false
        let headers: HTTPHeaders
        headers = [appDelegate.x_api_key: appDelegate.x_api_value]
        AF.request(url, method: .post,parameters: inputData, encoding: JSONEncoding.default,headers:headers)
            .responseJSON { response in
                self.viewActivity.isHidden = true
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any] {
                        //print("verifyOTP JSON:",json)
                        if (json["status"]as? Int == 0 ){
                            let user_id = json["user_id"]
                            if (user_id != nil){
                                let userID = json["user_id"]as? String ?? ""
                                //print("userID1:",userID)
                                self.updatePWD(userId: userID)
                            }
                            
                        }
                            
                        else{
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
    func updatePWD(userId: String){
        //print("updatePWD:",userId)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let url: String = appDelegate.ol_base_url + "/api/1/users/set_password_clear_text/" + userId
        let inputData = ["password":txtPwd.text!,"password_confirmation":txtPwd.text!,"validate_policy":false] as [String : Any]
        viewActivity.isHidden = false
        let headers: HTTPHeaders = [
            "Authorization": "Bearer " + appDelegate.ol_access_token,
            "Accept": "application/json"
        ]
        AF.request(url, method: .put,parameters: inputData, encoding: JSONEncoding.default,headers:headers)
            .responseJSON { response in
                self.viewActivity.isHidden = true
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any] {
                        //print("updateUser JSON:",json)
                        let status = json["status"]  as? [String: Any] ?? [:]
                        if (status["error"]as? Int == 0 ){
                            let strMsg = "Password changed successfully"
                            let alert = UIAlertController(title: "Alert",
                                                          message:strMsg ,
                                                          preferredStyle: .alert)
                            
                            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel) { _ in
                                self.dismiss(self)
                            })
                            DispatchQueue.main.async {
                                self.present(alert, animated: true, completion: nil)
                            }
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
    func showLoginVC(){
        appDelegate.emailPopulate = username ?? ""
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
    @IBAction func signIn(_ sender: Any){
        if (camefrom == "profile"){
            logoutOL()
        }else{
            showLoginVC()
        }
    }
    @IBAction func dismiss(_ sender: Any) {
        if (camefrom == "profile"){
            showConfirmation(strMsg: "This will return you to the sign in screen")
        }else{
            showLoginVC()
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
            .responseJSON { response in
                self.viewActivity.isHidden = true
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any] {
                        //print("logoutLambda JSON:",json)
                        if (json["statusCode"]as? String == "200" ){
                            UserDefaults.standard.set("0", forKey: "user_id")
                            self.showLoginVC()
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
        let alert = UIAlertController(title: "Do you want to logout?", message: strMsg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { action in
            for controller in self.navigationController!.viewControllers as Array {
                if controller.isKind(of: DashBoardVC.self) {
                    self.navigationController!.popToViewController(controller, animated: true)
                    break
                }
            }

        }))
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            self.logoutOL();
        }))
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
    
    // MARK: Text Field Delegate Methods
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if (textField==txtPwd){
            self.animateTextField(textField: textField, up:true)
        }
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if (textField==txtPwd){
            self.animateTextField(textField: textField, up:false)
        }
        textField.resignFirstResponder();
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder();
        return true;
    }
    func animateTextField(textField: UITextField, up: Bool)
    {
        let movementDistance:CGFloat = -130
        var movement:CGFloat = 0
        if up
        {
            movement = movementDistance
        }
        else
        {
            movement = -movementDistance
        }
        UIView.animate(withDuration: 0.3, animations: {
            self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
        })
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent // .default
    }
    override func viewWillAppear(_ animated: Bool) {
        AppDelegate.AppUtility.lockOrientation(.portrait)
    }
    override func viewWillDisappear(_ animated: Bool) {
        AppDelegate.AppUtility.lockOrientation(.all)
    }
}

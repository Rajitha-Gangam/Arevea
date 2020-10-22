//
//  ConfirmSignUpViewController.swift
//  aws_amplify_integration
//
//  Created by Calin Cristian on 27/03/2019.
//  Copyright © 2019 Calin Cristian Ciubotariu. All rights reserved.
//

import UIKit
import Alamofire

class ConfirmSignUpVC: UIViewController,UITextFieldDelegate {
     // MARK: - Variables Declaration
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    @IBOutlet weak var txtCode: UITextField!
    var username: String?
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
@IBOutlet weak var viewActivity: UIView!
    
    // MARK: - View Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        txtCode.backgroundColor = .clear
        viewActivity.isHidden = true
        // Do any additional setup after loading the view.
        addDoneButton()
        self.assignbackground();
        username = UserDefaults.standard.string(forKey: "user_email");

    }
    func addDoneButton() {
        let toolbar =  UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 35))

        let flexButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action:#selector(resignKB(_:)))
        toolbar.setItems([flexButton, doneButton], animated: true)
        toolbar.sizeToFit()
        txtCode.inputAccessoryView = toolbar;
    }
    @IBAction func resignKB(_ sender: Any) {
        txtCode.resignFirstResponder();
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
            self.present(alert, animated: true, completion: nil)
        }
    }
    
  
    
    @IBAction func resendCode(_ sender: Any) {
        let netAvailable = appDelegate.isConnectedToInternet()
               if(!netAvailable){
                   showAlert(strMsg: "Please check your internet connection!")
                   return
               }
        
        guard let username = self.username else {
            ////print("No username")
            return
        }
        let inputData = ["email": username,"type": "email_verification"]
        sendOTP(inputData: inputData)
    }
    // MARK: Handler for events(events) API
    func sendOTP(inputData:[String: Any]){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let url: String = appDelegate.ol_lambda_url +  "/sendOTP"
        viewActivity.isHidden = false
        let headers: HTTPHeaders
        headers = [appDelegate.x_api_key: appDelegate.x_api_value]
        AF.request(url, method: .post,parameters: inputData, encoding: JSONEncoding.default,headers:headers)
            .responseJSON { response in
                self.viewActivity.isHidden = true
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any] {
                        //print("sendOTP JSON:",json)
                        if (json["status"]as? Int == 0 ){
                            self.showAlert(strMsg: "Verification code sent via email")
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
    func verifyOTP(inputData:[String: Any]){
        //print("verifyOTP:",inputData)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let url: String = appDelegate.ol_lambda_url +  "/verifyOTP"
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
                        let msg = json["message"] as? String ?? ""
                        if (json["status"]as? Int == 1 && msg.lowercased() == "wrong otp"){
                            let strMsg = json["message"] as? String ?? ""
                            self.showAlert(strMsg: strMsg)
                        }
                       else{
                            let userID = json["user_id"]as? String ?? ""
                            //print("userID1:",userID)
                            self.updateUser(userId: userID)
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
    func updateUser(userId: String){
        //print("updateUser:",userId)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                   let url: String = appDelegate.ol_base_url + "/api/2/users/" + userId
        let inputData = ["custom_attributes":["is_user_verify":1]]
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
                                   if (json["status"]as? Int == 1 ){
                                       let strMsg = "Verified successfully"
                                       let alert = UIAlertController(title: "Alert",
                                                                     message:strMsg ,
                                                                     preferredStyle: .alert)
                                       
                                       alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel) { _ in
                                        self.dismissModal()
                                       })
                                       DispatchQueue.main.async {
                                           self.present(alert, animated: true, completion: nil)
                                       }
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
    

    @IBAction func confirmSignUp(_ sender: Any) {
        txtCode.resignFirstResponder();
        let netAvailable = appDelegate.isConnectedToInternet()
        if(!netAvailable){
            showAlert(strMsg: "Please check your internet connection!")
            return
        }

        if (txtCode.text?.count == 0){
            showAlert(strMsg: "Please enter verification code");
        }else{
            guard let verificationCode = txtCode.text,
                let username = self.username else {
                    ////print("No username")
                    return
            }
            let inputData = ["email": username,"type": "email_verification","otp":verificationCode]
            verifyOTP(inputData: inputData)
            
        }
        
    }
    
    @IBAction func dismissModal() {
        appDelegate.emailPopulate = username ?? ""
        for controller in self.navigationController!.viewControllers as Array {
            if controller.isKind(of: LoginVC.self) {
                self.navigationController!.popToViewController(controller, animated: true)
                break
            }
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
    
    override func viewWillAppear(_ animated: Bool) {
        AppDelegate.AppUtility.lockOrientation(.portrait)
    }
}

//
//  ProfileVC.swift
//  AreveaTV
//
//  Created by apple on 4/25/20.
//  Copyright © 2020 apple. All rights reserved.
//

import UIKit
import AWSMobileClient
import Alamofire

class ProfileVC: UIViewController,UITextFieldDelegate {
    @IBOutlet weak var txtFirstName: UITextField!
    @IBOutlet weak var txtLastName: UITextField!
    @IBOutlet weak var txtPhone: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        addDoneButton();
        getProfile();

    }
    
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func cancel(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func updatePwd(_ sender: Any) {
        resignKB(sender)
        forgotPassword();
    }
    @IBAction func updateProfile(_ sender: Any) {
        resignKB(sender)
        let firstName = txtFirstName.text!;
        let lastName = txtLastName.text!;
        let phone = txtPhone.text!;
        if (firstName.count == 0){
            showAlert(strMsg: "Please enter first name");
        }else if (lastName.count == 0){
            showAlert(strMsg: "Please enter last name");
        }else if (phone.count == 0){
            showAlert(strMsg: "Please enter phone");
        }else{
        setProfile()
        }
    }
    @IBAction func resignKB(_ sender: Any) {
        txtFirstName.resignFirstResponder();
        txtLastName.resignFirstResponder();
        txtEmail.resignFirstResponder();
        txtPhone.resignFirstResponder();
    }
    func addDoneButton() {
        let toolbar =  UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 35))


        let flexButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action:#selector(resignKB(_:)))
        toolbar.setItems([flexButton, doneButton], animated: true)
        toolbar.sizeToFit()
        txtFirstName.inputAccessoryView = toolbar;
        txtLastName.inputAccessoryView = toolbar;
        txtPhone.inputAccessoryView = toolbar;
        txtEmail.inputAccessoryView = toolbar;
    }
    func showAlert(strMsg: String){
        let alert = UIAlertController(title: "Alert", message: strMsg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
    // MARK: Handler for getProfile API, using for filters
    func getProfile(){
        let url: String = appDelegate.baseURL +  "/getProfile"
        let user_id = UserDefaults.standard.string(forKey: "user_id");
        let user_type = UserDefaults.standard.string(forKey: "user_type");
        let params: [String: Any] = ["user_id":user_id ?? "","user_type":user_type ?? ""]
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        AF.request(url, method: .post, parameters: params, encoding: JSONEncoding.default)
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any] {
                        print(json)
                        if (json["status"]as? Int == 0){
                            print(json["message"] ?? "")
                            var profile_data = [Any]()
                            profile_data = json["profile_data"] as? [Any] ?? [Any]()
                            if (profile_data.count > 0)
                            {
                                let  firstItem = profile_data[0] as? [String:Any]
                                self.txtEmail.text = UserDefaults.standard.string(forKey: "user_email");

                                self.txtFirstName.text = firstItem?["user_first_name"] as? String
                                self.txtLastName.text = firstItem?["user_last_name"]as? String
                                self.txtPhone.text = firstItem?["user_phone_number"]as? String
                            }
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
    
    
    
    // MARK: Handler for setProfile API, using for filters
    func setProfile(){
        let url: String = appDelegate.baseURL +  "/setProfile"
        let user_id = UserDefaults.standard.string(forKey: "user_id");
        let user_email = UserDefaults.standard.string(forKey: "user_email");

        let params: [String: Any] = ["user_id":user_id ?? "","user_first_name":txtFirstName.text!,"user_last_name":txtLastName.text!,"user_phone_number":txtPhone.text!,"user_email":user_email!]
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        AF.request(url, method: .post, parameters: params, encoding: JSONEncoding.default)
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any] {
                        print(json)
                        if (json["status"]as? Int == 0){
                            print(json["message"] ?? "")
                            self.showAlert(strMsg:"Profile updated successfully")
                            self.activityIndicator.isHidden = true;
                            self.activityIndicator.stopAnimating();
                            self.navigationController?.popViewController(animated: true);
                            let fn = self.txtFirstName.text!
                            let ln = self.txtLastName.text!
                            let strName = String((fn.first)!) + String((ln.first)!)
                            self.appDelegate.USER_NAME = strName;
                            self.appDelegate.USER_NAME_FULL = fn + " " + ln
                            
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
    
    func forgotPassword(){
        
        let username =  UserDefaults.standard.string(forKey: "user_email") as! String;
        
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        AWSMobileClient.sharedInstance().forgotPassword(username: username) { (forgotPasswordResult, error) in
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating();
                self.activityIndicator.isHidden = true;
            }
            if let error = error {
                self.showAlert(strMsg: "\(error)");
                print("\(error)")
                return
            }
            if let forgotPasswordResult = forgotPasswordResult {
                switch(forgotPasswordResult.forgotPasswordState) {
                case .confirmationCodeSent:
                    
                    guard let codeDeliveryDetails = forgotPasswordResult.codeDeliveryDetails else {
                        return
                    }
                    
                    let alert = UIAlertController(title: "Code sent",
                                                  message: "Confirmation code sent via \(codeDeliveryDetails.deliveryMedium) to: \(codeDeliveryDetails.destination!)",
                        preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel) { _ in
                        let storyboard = UIStoryboard(name: "Main", bundle: nil);
                        let vc = storyboard.instantiateViewController(withIdentifier: "NewPasswordVC") as! NewPasswordVC
                        vc.camefrom = "profile"
                        
                        self.navigationController?.pushViewController(vc, animated: true)
                    })
                    
                    DispatchQueue.main.async {
                        self.present(alert, animated: true, completion: nil)
                    }
                    
                default:
                    print("Error: Invalid case.")
                }
            } else if let error = error {
                print("Error occurred: \(error.localizedDescription)")
            }
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
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent // .default
    }
    // MARK: Text Field Delegate Methods
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
            self.animateTextField(textField: textField, up:true)
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
            self.animateTextField(textField: textField, up:false)
        textField.resignFirstResponder();
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder();
        return true;
    }
    // MARK: Keyboard  Delegate Methods
    
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
}

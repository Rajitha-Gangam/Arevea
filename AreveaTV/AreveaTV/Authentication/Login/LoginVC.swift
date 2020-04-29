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
protocol GLLoginDelegate {
    func didFinishLogin(status: Bool)
}

class LoginVC: UIViewController,UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    var loginDelegate: GLLoginDelegate?

    @IBOutlet weak var txtUserName: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var txtEnv: UITextField!

    var pickerData: [String] = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.assignbackground();
        txtUserName.delegate = self;
        txtPassword.delegate = self;
        self.navigationController?.isNavigationBarHidden = true
        txtUserName.text = "grajitha2009@gmail.com";
        txtPassword.text = "V@rshitha12345";
        addDoneButton()
        pickerData = ["dev", "qa", "pre-prod", "prod"]
        createPickerView()
        dismissPickerView()

    }
    @IBAction func resignKB(_ sender: Any) {
        txtUserName.resignFirstResponder();
        txtPassword.resignFirstResponder();
    }
    func addDoneButton() {
        let toolbar = UIToolbar()
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
                self.activityIndicator.stopAnimating();
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
                DispatchQueue.main.async {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil);
                    let vc = storyboard.instantiateViewController(withIdentifier: "DashBoardVC") as! DashBoardVC
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                
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
//       AWSMobileClient.sharedInstance().federatedSignIn(providerName: "Facebook",
//                                                         token: "230469618276761") { (userState, error) in
//                                                            if let error = error as? AWSMobileClientError {
//                                                                print(error.localizedDescription)
//                                                            }
//                                                            if let userState = userState {
//                                                                print("Status: \(userState.rawValue)")
//                                                            }
//        }
        awsSignInFacebook(fbAuthToken: "230469618276761")
       
    }
    func awsSignInFacebook(fbAuthToken: String){
        let logins = ["graph.facebook.com" : fbAuthToken]
        let customIdentityProvider = CustomIdentityProvider(tokens: logins)
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
                print("Cognito ID : \(cognitoId)")
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
    
    // MARK: Picker  Methods
    func createPickerView() {
           let pickerView = UIPickerView()
           pickerView.delegate = self
           txtEnv.inputView = pickerView
       }
       
       func dismissPickerView() {
           let toolBar = UIToolbar()
           toolBar.sizeToFit()
           let flexButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
           let button = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.action))
           toolBar.setItems([flexButton, button], animated: true)
           toolBar.isUserInteractionEnabled = true
           txtEnv.inputAccessoryView = toolBar
        
        
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
        var selectedItem = pickerData[row]
        txtEnv.text = selectedItem
    }
    
   
}
extension LoginVC: AWSSignInDelegate {
    func onLogin(signInProvider: AWSSignInProvider, result: Any?, error: Error?) {
        //print(result)
    }
}

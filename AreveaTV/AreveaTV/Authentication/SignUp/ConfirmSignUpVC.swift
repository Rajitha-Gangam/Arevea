//
//  ConfirmSignUpViewController.swift
//  aws_amplify_integration
//
//  Created by Calin Cristian on 27/03/2019.
//  Copyright © 2019 Calin Cristian Ciubotariu. All rights reserved.
//

import UIKit
import AWSMobileClient
import Alamofire

class ConfirmSignUpVC: UIViewController,UITextFieldDelegate {
    
    @IBOutlet weak var txtCode: UITextField!
    var username: String?
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    func resendSignUpHandler(result: SignUpResult?, error: Error?) {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating();
            self.activityIndicator.isHidden = true;
        }
        if let error = error {
            showAlert(strMsg: "\(error)");
            print("\(error)")
            return
        }
        
        guard let signUpResult = result else {
            return
        }
        
        let message = "A verification code has been sent via \(signUpResult.codeDeliveryDetails!.deliveryMedium) at \(signUpResult.codeDeliveryDetails!.destination!)"
        let alert = UIAlertController(title: "Code Sent",
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: { _ in
            //Cancel Action
        }))
        
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func resendCode(_ sender: Any) {
        guard let username = self.username else {
            print("No username")
            return
        }
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        AWSMobileClient.sharedInstance().resendSignUpCode(username: username,
                                                          completionHandler: resendSignUpHandler)
    }
    
    func handleConfirmation(signUpResult: SignUpResult?, error: Error?) {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating();
            self.activityIndicator.isHidden = true;
        }
        if let error =  error as? AWSMobileClientError {
            switch(error) {
            case .codeMismatch:
                self.showAlert(strMsg: "Invalid verification code provided, please try again");
            case .expiredCode(let message):
                self.showAlert(strMsg: message);
            default:
                showAlert(strMsg: "\(error)");
                break
            }
            print("There's an error : \(error.localizedDescription)")
            print(error)
            return
        }
        
        guard let signUpResult = signUpResult else {
            return
        }
        
        switch(signUpResult.signUpConfirmationState) {
        case .confirmed:
            print("User is signed up and confirmed.")
            getUser()
//            DispatchQueue.main.async {
//                let storyboard = UIStoryboard(name: "Main", bundle: nil);
//                let vc = storyboard.instantiateViewController(withIdentifier: "DashBoardVC") as! DashBoardVC
//                self.navigationController?.pushViewController(vc, animated: true)
//            }
            
        case .unconfirmed:
            var username = self.username!;
            let strError = "User is not confirmed and needs verification via email sent at " + username;
            showAlert(strMsg: strError)
            print("User is not confirmed and needs verification via \(signUpResult.codeDeliveryDetails!.deliveryMedium) sent at \(signUpResult.codeDeliveryDetails!.destination!)")
        case .unknown:
            print("Unexpected case")
        }
    }
    
    @IBAction func confirmSignUp(_ sender: Any) {
        txtCode.resignFirstResponder();
        if (txtCode.text?.count == 0){
            showAlert(strMsg: "Please enter verification code");
        }else{
            guard let verificationCode = txtCode.text,
                let username = self.username else {
                    print("No username")
                    return
            }
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
            AWSMobileClient.sharedInstance().confirmSignUp(username: username,
                                                           confirmationCode: verificationCode,
                                                           completionHandler: handleConfirmation)
            
        }
        
    }
    
    @IBAction func dismissModal(_ sender: Any) {
        for controller in self.navigationController!.viewControllers as Array {
            if controller.isKind(of: LoginVC.self) {
                self.navigationController!.popToViewController(controller, animated: true)
                break
            }
        }
    }
    // MARK: Handler for getUser API, using for filters
           func getUser(){
               let appDelegate = UIApplication.shared.delegate as! AppDelegate
               let url: String = appDelegate.baseURL +  "/getUser"
            let params: [String: Any] = ["email":self.username ?? ""]
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
                                   print("user:",user ?? "")
                                   UserDefaults.standard.set(user?["id"], forKey: "user_id")
                                   UserDefaults.standard.set(user?["user_type"], forKey: "user_type")
                                   
                                   let storyboard = UIStoryboard(name: "Main", bundle: nil);
                                   let vc = storyboard.instantiateViewController(withIdentifier: "DashBoardVC") as! DashBoardVC
                                   self.navigationController?.pushViewController(vc, animated: true)
                                   self.activityIndicator.isHidden = true;
                                   self.activityIndicator.stopAnimating();
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
}

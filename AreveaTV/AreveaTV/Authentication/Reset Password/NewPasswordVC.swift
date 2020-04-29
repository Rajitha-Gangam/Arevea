//
//  NewPasswordViewController.swift
//  aws_amplify_integration
//
//  Created by Calin Cristian on 27/03/2019.
//  Copyright © 2019 Calin Cristian Ciubotariu. All rights reserved.
//

import UIKit
import AWSMobileClient

class NewPasswordVC: UIViewController ,UITextFieldDelegate{
    
    @IBOutlet weak var txtCode: UITextField!
    @IBOutlet weak var txtPwd: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var username: String?
    var camefrom = "";
    override func viewDidLoad() {
        super.viewDidLoad()
        self.assignbackground();
        username = UserDefaults.standard.string(forKey: "user_email");
        // Do any additional setup after loading the view.
        addDoneButton()
    
    }
    func addDoneButton() {
        let toolbar = UIToolbar()
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
        if (txtCode.text?.count == 0){
            showAlert(strMsg: "Please enter verification code");
        }else if (txtPwd.text?.count == 0){
            showAlert(strMsg: "Please enter new password");
        }else{
            guard let username = username,
                let newPassword = txtPwd.text,
                let confirmationCode = txtCode.text else {
                    return
            }
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
            
            AWSMobileClient.sharedInstance().confirmForgotPassword(username: username,
                                                                   newPassword: newPassword,
                                                                   confirmationCode: confirmationCode) { (forgotPasswordResult, error) in
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
                                                                        case .done:
                                                                            self.dismiss(self)
                                                                        default:
                                                                            print("Error: Could not change password.")
                                                                        }
                                                                    } else if let error = error {
                                                                        print("Error occurred: \(error.localizedDescription)")
                                                                    }
            }
        }
        
    }
    
    @IBAction func dismiss(_ sender: Any) {
        if (camefrom == "profile"){
            self.navigationController?.popViewController(animated: true)
        }else{
            DispatchQueue.main.async {
                   for controller in self.navigationController!.viewControllers as Array {
                       if controller.isKind(of: LoginVC.self) {
                           self.navigationController!.popToViewController(controller, animated: true)
                           break
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

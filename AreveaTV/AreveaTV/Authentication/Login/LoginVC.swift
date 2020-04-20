//
//  LoginViewController.swift
//  aws_amplify_integration
//
//  Created by Calin Cristian on 27/03/2019.
//  Copyright © 2019 Calin Cristian Ciubotariu. All rights reserved.
//

import UIKit
import AWSMobileClient

class LoginVC: UIViewController,UITextFieldDelegate {
    
    @IBOutlet weak var txtUserName: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.assignbackground();
        txtUserName.delegate = self;
        txtPassword.delegate = self;
        self.navigationController?.isNavigationBarHidden = true
        
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
        
        AWSMobileClient.sharedInstance().signIn(username: username, password: password) {
            (signInResult, error) in
            if let error =  error as? AWSMobileClientError {
                switch(error) {
                case .notAuthorized(let message):
                    self.showAlert(strMsg: message);
                case .userNotFound(let message):
                    self.showAlert(strMsg: message);
                case .userNotConfirmed(let message):
                    print("userNotConfirmed:",message)
                    DispatchQueue.main.async {
                        
                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                        appDelegate.USER_EMAIL = username;
                        let storyboard = UIStoryboard(name: "Main", bundle: nil);
                        let vc = storyboard.instantiateViewController(withIdentifier: "ConfirmSignUpVC") as! ConfirmSignUpVC
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                    
                default:
                    self.showAlert(strMsg: error.localizedDescription);
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
    @IBAction func login(_ sender: Any) {
        if (txtUserName.text?.count == 0){
            showAlert(strMsg: "Please enter username");
        }else if (txtPassword.text?.count == 0){
            showAlert(strMsg: "Please enter password");
        }else{
            AWSsignIn();
        }
    }
    
    @IBAction func signUp(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil);
        let vc = storyboard.instantiateViewController(withIdentifier: "SignUpVC") as! SignUpVC
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
    }
}


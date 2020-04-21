//
//  SignUpViewController.swift
//  aws_amplify_integration
//
//  Created by Calin Cristian on 27/03/2019.
//  Copyright © 2019 Calin Cristian Ciubotariu. All rights reserved.
//

import UIKit
import AWSMobileClient

class SignUpVC: UIViewController ,UITextFieldDelegate{
    
    @IBOutlet weak var txtUserName: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPhone: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtCfrmPassword: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var scrollView: UIScrollView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.assignbackground();
        self.navigationController?.isNavigationBarHidden = true
        //        txtEmail.text = "grajitha2009@gmail.com"
        //        txtUserName.text = "Rajitha Gangam";
        //        txtPassword.text = "V@rshitha12345";
        //        txtCfrmPassword.text =  "V@rshitha12345";
        //        txtPhone.text = "+918096823214";

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
    
    func signUpHandler(signUpResult: SignUpResult?, error: Error?) {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating();
            self.activityIndicator.isHidden = true;
        }
        if let error = error as? AWSMobileClientError {
            switch(error) {
            case .usernameExists(let message):
            showAlert(strMsg: message);
            default:
                showAlert(strMsg: "\(error)");
                break
            }
            
            print("There's an error on signup: \(error.localizedDescription), \(error)")
            
        }
        
        guard let signUpResult = signUpResult else {
            return
        }
        print("signUpConfirmationState: \(signUpResult.signUpConfirmationState)");
        switch(signUpResult.signUpConfirmationState) {
        case .confirmed:
            print("User is signed up and confirmed.")
            
            DispatchQueue.main.async {
                let storyboard = UIStoryboard(name: "Main", bundle: nil);
                let vc = storyboard.instantiateViewController(withIdentifier: "DashBoardVC") as! DashBoardVC
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
        case .unconfirmed:
            let alert = UIAlertController(title: "Code sent",
                                          message: "Confirmation code sent via \(signUpResult.codeDeliveryDetails!.deliveryMedium) to: \(signUpResult.codeDeliveryDetails!.destination!)",
                preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel) { _ in
                guard let username = self.txtEmail.text else {
                    return
                }
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.USER_EMAIL = username;
                let storyboard = UIStoryboard(name: "Main", bundle: nil);
                let vc = storyboard.instantiateViewController(withIdentifier: "ConfirmSignUpVC") as! ConfirmSignUpVC
                self.navigationController?.pushViewController(vc, animated: true)
            })
            
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
            
        case .unknown:
            print("Unexpected case")
        }
    }
    func showAlert(strMsg: String){
        let alert = UIAlertController(title: "Alert", message: strMsg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
        
    }
    
    @IBAction func signIn(_ sender: Any)
    {
        for controller in self.navigationController!.viewControllers as Array {
            if controller.isKind(of: LoginVC.self) {
                self.navigationController!.popToViewController(controller, animated: true)
                break
            }
        }
    }
    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: txtEmail.text)
    }
    @IBAction func signUp(_ sender: Any) {
        txtUserName.resignFirstResponder();
        txtEmail.resignFirstResponder();
        txtPhone.resignFirstResponder();
        txtPassword.resignFirstResponder();
        txtCfrmPassword.resignFirstResponder();
        
        let userName = txtUserName.text!;
        let email = txtEmail.text!;
        let phone = txtPhone.text!;
        let pwd = txtPassword.text!;
        let cfrmPwd = txtCfrmPassword.text!;
        
        if (userName.count == 0){
            showAlert(strMsg: "Please enter name");
        }else if (email.count == 0){
            showAlert(strMsg: "Please enter email");
        }else if (!isValidEmail()){
            showAlert(strMsg: "Please enter valid email");
        }else if (phone.count == 0){
            showAlert(strMsg: "Please enter phone");
        }else if (pwd.count == 0){
            showAlert(strMsg: "Please enter password");
        }else if (cfrmPwd.count == 0){
            showAlert(strMsg: "Please enter confirm password");
        }else if(pwd != cfrmPwd){
            showAlert(strMsg: "password and confirm password did not match");
        }else{
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
            //username value shoulb be like email
            AWSMobileClient.sharedInstance().signUp(username: email,
                                                    password: pwd,
                                                    userAttributes: ["email" : email, "name": userName,"phone_number":phone],
                                                    completionHandler: signUpHandler);
        }
    }
    
    @IBAction func dismissModal(_ sender: Any) {
        self.navigationController?.dismiss(animated: true, completion: nil)
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
       let movementDuration: Double = 0.3

       var movement:CGFloat = 0
       if up
       {
           movement = movementDistance
       }
       else
       {
           movement = -movementDistance
       }
       UIView.beginAnimations("animateTextField", context: nil)
       UIView.setAnimationBeginsFromCurrentState(true)
       UIView.setAnimationDuration(movementDuration)
       self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
       UIView.commitAnimations()
   }
}

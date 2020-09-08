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
import SendBirdSDK

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
    
    func resendSignUpHandler(result: SignUpResult?, error: Error?) {
        DispatchQueue.main.async {
            self.viewActivity.isHidden = true
        }
        if let error = error {
            showAlert(strMsg: "\(error)");
            //print("\(error)")
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
        let netAvailable = appDelegate.isConnectedToInternet()
               if(!netAvailable){
                   showAlert(strMsg: "Please check your internet connection!")
                   return
               }
        
        guard let username = self.username else {
            //print("No username")
            return
        }
        viewActivity.isHidden = false
        AWSMobileClient.default().resendSignUpCode(username: username,
                                                          completionHandler: resendSignUpHandler)
    }
    
    func handleConfirmation(signUpResult: SignUpResult?, error: Error?) {
        DispatchQueue.main.async {
            self.viewActivity.isHidden = true
        }
        if let error =  error as? AWSMobileClientError {
            switch(error) {
            case .codeMismatch:
                self.showAlert(strMsg: "Invalid verification code provided, please try again");
                 return
            case .expiredCode(let message):
                self.showAlert(strMsg: message);
                 return
            default: break
                //showAlert(strMsg: "\(error)");
            }
            //print("There's an error : \(error.localizedDescription)")
            //print(error)
           
        }
        
        guard let signUpResult = signUpResult else {
            return
        }
        
        switch(signUpResult.signUpConfirmationState) {
        case .confirmed:
            //print("User is signed up and confirmed.")
            DispatchQueue.main.async {
                self.viewActivity.isHidden = false
                self.dismissModal()

            }
        case .unconfirmed:
            let username = self.username!;
            let strError = "User is not confirmed and needs verification via email sent at " + username;
            showAlert(strMsg: strError)
            //print("User is not confirmed and needs verification via \(signUpResult.codeDeliveryDetails!.deliveryMedium) sent at \(signUpResult.codeDeliveryDetails!.destination!)")
        case .unknown:
            print("Unexpected case")
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
                    //print("No username")
                    return
            }
            viewActivity.isHidden = false
            AWSMobileClient.default().confirmSignUp(username: username,
                                                           confirmationCode: verificationCode,
                                                           completionHandler: handleConfirmation)
            
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

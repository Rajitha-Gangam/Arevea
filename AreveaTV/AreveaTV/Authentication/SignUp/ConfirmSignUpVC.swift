//
//  ConfirmSignUpViewController.swift
//  aws_amplify_integration
//
//  Created by Calin Cristian on 27/03/2019.
//  Copyright © 2019 Calin Cristian Ciubotariu. All rights reserved.
//

import UIKit
import AWSMobileClient

class ConfirmSignUpVC: UIViewController {
    
    @IBOutlet weak var txtCode: UITextField!
    var username: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.assignbackground();
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        username = appDelegate.USER_EMAIL;
        // Do any additional setup after loading the view.
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
        if let error = error {
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
        
        AWSMobileClient.sharedInstance().resendSignUpCode(username: username,
                                                          completionHandler: resendSignUpHandler)
    }
    
    func handleConfirmation(signUpResult: SignUpResult?, error: Error?) {
        if let error =  error as? AWSMobileClientError {
            switch(error) {
            case .codeMismatch:
                self.showAlert(strMsg: "Invalid verification code provided, please try again");
            case .expiredCode(let message):
                self.showAlert(strMsg: message);
            default:
                self.showAlert(strMsg: error.localizedDescription);
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
            
            DispatchQueue.main.async {
                let storyboard = UIStoryboard(name: "Main", bundle: nil);
                let vc = storyboard.instantiateViewController(withIdentifier: "DashBoardVC") as! DashBoardVC
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
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
        
        guard let verificationCode = txtCode.text,
            let username = self.username else {
                print("No username")
                return
        }
        
        AWSMobileClient.sharedInstance().confirmSignUp(username: username,
                                                       confirmationCode: verificationCode,
                                                       completionHandler: handleConfirmation)
    }
    
    @IBAction func dismissModal(_ sender: Any) {
        for controller in self.navigationController!.viewControllers as Array {
            if controller.isKind(of: LoginVC.self) {
                self.navigationController!.popToViewController(controller, animated: true)
                break
            }
        }
    }
}

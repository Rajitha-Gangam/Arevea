//
//  ResetPasswordViewController.swift
//  aws_amplify_integration
//
//  Created by Calin Cristian on 27/03/2019.
//  Copyright © 2019 Calin Cristian Ciubotariu. All rights reserved.
//

import UIKit
import AWSMobileClient

class ResetPasswordVC: UIViewController ,UITextFieldDelegate{
    
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.assignbackground();
        
        // Do any additional setup after loading the view.
        addDoneButton()

    }
    func addDoneButton() {
        let toolbar =  UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 35))

        let flexButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action:#selector(resignKB(_:)))
        toolbar.setItems([flexButton, doneButton], animated: true)
        toolbar.sizeToFit()
        txtEmail.inputAccessoryView = toolbar;
    }
    @IBAction func resignKB(_ sender: Any) {
        txtEmail.resignFirstResponder();
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
    func isValidEmail() -> Bool {
           let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
           let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
           return emailPred.evaluate(with: txtEmail.text)
       }
    @IBAction func submitUsername(_ sender: Any) {
        txtEmail.resignFirstResponder();
        if (txtEmail.text?.count == 0){
            showAlert(strMsg: "Please enter email");
        }else if (!isValidEmail()){
            showAlert(strMsg: "Please enter valid email");
        }else{
            guard let username = txtEmail.text else {
                print("No username")
                return
            }
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
                            UserDefaults.standard.set(username, forKey: "user_email")

                            let storyboard = UIStoryboard(name: "Main", bundle: nil);
                            let vc = storyboard.instantiateViewController(withIdentifier: "NewPasswordVC") as! NewPasswordVC
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
        
        
        
    }
    
    @IBAction func dismiss(_ sender: Any) {
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
}

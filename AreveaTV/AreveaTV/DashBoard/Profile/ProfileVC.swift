//
//  ProfileVC.swift
//  AreveaTV
//
//  Created by apple on 4/25/20.
//  Copyright © 2020 apple. All rights reserved.
//

import UIKit
import AWSMobileClient

class ProfileVC: UIViewController {
    @IBOutlet weak var txtFirstName: UITextField!
    @IBOutlet weak var txtLastName: UITextField!
    @IBOutlet weak var txtPhone: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPwd: UITextField!
    @IBOutlet weak var txtCfrmPwd: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func cancel(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func update(_ sender: Any) {
        forgotPassword();
    }
    func showAlert(strMsg: String){
        let alert = UIAlertController(title: "Alert", message: strMsg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
     func forgotPassword(){

        let username =  UserDefaults.standard.string(forKey: "user_email") as!String;
        
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
}

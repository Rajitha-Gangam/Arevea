//
//  NewPasswordViewController.swift
//  aws_amplify_integration
//
//  Created by Calin Cristian on 27/03/2019.
//  Copyright © 2019 Calin Cristian Ciubotariu. All rights reserved.
//

import UIKit
import AWSMobileClient

class NewPasswordVC: UIViewController {
    
    @IBOutlet weak var txtCode: UITextField!
    @IBOutlet weak var txtPwd: UITextField!
    
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
    
    @IBAction func verifyCode(_ sender: Any) {
        
        guard let username = username,
            let newPassword = txtPwd.text,
            let confirmationCode = txtCode.text else {
                return
        }
        
        AWSMobileClient.sharedInstance().confirmForgotPassword(username: username,
                                                               newPassword: newPassword,
                                                               confirmationCode: confirmationCode) { (forgotPasswordResult, error) in
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
    
    @IBAction func dismiss(_ sender: Any) {
        for controller in self.navigationController!.viewControllers as Array {
            if controller.isKind(of: LoginVC.self) {
                self.navigationController!.popToViewController(controller, animated: true)
                break
            }
        }
    }
}

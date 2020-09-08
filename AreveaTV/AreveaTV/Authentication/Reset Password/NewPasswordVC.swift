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
    // MARK: - Variables Declaration
    @IBOutlet weak var txtCode: UITextField!
    @IBOutlet weak var txtPwd: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var username: String?
    var camefrom = "";
    @IBOutlet weak var viewActivity: UIView!
    
    // MARK: - View Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        viewActivity.isHidden = true
        txtCode.backgroundColor = .clear
        txtPwd.backgroundColor = .clear

        self.assignbackground();
        username = UserDefaults.standard.string(forKey: "user_email");
        // Do any additional setup after loading the view.
        addDoneButton()
        
    }
    func addDoneButton() {
        let toolbar =  UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 35))
        
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
        let netAvailable = appDelegate.isConnectedToInternet()
        if(!netAvailable){
            showAlert(strMsg: "Please check your internet connection!")
            return
        }
        
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
            viewActivity.isHidden = false
            
            AWSMobileClient.default().confirmForgotPassword(username: username,
                                                            newPassword: newPassword,
                                                            confirmationCode: confirmationCode) { (forgotPasswordResult, error) in
                                                                DispatchQueue.main.async {
                                                                    self.viewActivity.isHidden = true
                                                                    
                                                                    if let error = error {
                                                                        self.showAlert(strMsg: "\(error)");
                                                                        //print("\(error)")
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
                                                                        //print("Error occurred: \(error.localizedDescription)")
                                                                    }
                                                                }
            }
        }
        
    }
    
    @IBAction func dismiss(_ sender: Any) {
        if (camefrom == "profile"){
            for controller in self.navigationController!.viewControllers as Array {
                if controller.isKind(of: DashBoardVC.self) {
                    self.navigationController!.popToViewController(controller, animated: true)
                    break
                }
            }
        }else{
            signIn(sender);
        }
    }
    @IBAction func signIn(_ sender: Any){
        if (camefrom == "profile"){
            AWSMobileClient.default().signOut() { error in
                if let error = error {
                    //print(error)
                    return
                }
            }
        }
        appDelegate.emailPopulate = username ?? ""
        var isLoginExists = false
        for controller in self.navigationController!.viewControllers as Array {
            if controller.isKind(of: LoginVC.self) {
                self.navigationController!.popToViewController(controller, animated: true)
                isLoginExists = true;
                break
            }
        }
        if (!isLoginExists){
            let storyboard = UIStoryboard(name: "Main", bundle: nil);
            let vc = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    // MARK: Text Field Delegate Methods
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if (textField==txtPwd){
            self.animateTextField(textField: textField, up:true)
        }
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if (textField==txtPwd){
            self.animateTextField(textField: textField, up:false)
        }
        textField.resignFirstResponder();

    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder();
        return true;
    }
    func animateTextField(textField: UITextField, up: Bool)
    {
        let movementDistance:CGFloat = -130
        var movement:CGFloat = 0
        if up
        {
            movement = movementDistance
        }
        else
        {
            movement = -movementDistance
        }
        UIView.animate(withDuration: 0.3, animations: {
            self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
        })
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent // .default
    }
    override func viewWillAppear(_ animated: Bool) {
           AppDelegate.AppUtility.lockOrientation(.portrait)
       }
    override func viewWillDisappear(_ animated: Bool) {
        AppDelegate.AppUtility.lockOrientation(.all)
    }
}

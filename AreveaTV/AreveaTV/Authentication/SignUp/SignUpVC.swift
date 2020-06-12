//
//  SignUpViewController.swift
//  aws_amplify_integration
//
//  Created by Calin Cristian on 27/03/2019.
//  Copyright © 2019 Calin Cristian Ciubotariu. All rights reserved.
//

import UIKit
import AWSMobileClient

class SignUpVC: UIViewController ,UITextFieldDelegate,UIPickerViewDelegate, UIPickerViewDataSource{
    
    // MARK: - Variables Declaration
    @IBOutlet weak var txtFirstName: UITextField!
    @IBOutlet weak var txtLastName: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPhone: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtCfrmPassword: UITextField!
    @IBOutlet weak var txtDOB: UITextField!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var scrollView: UIScrollView!
    var planID = "0";
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let pickerView = UIPickerView()
    
    // MARK: - View Life cycle
    @IBOutlet weak var viewActivity: UIView!
    var pickerData =  ["Below 18", "18+"];

    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewActivity.isHidden = true
        self.assignbackground();
        self.navigationController?.isNavigationBarHidden = true
        //        txtEmail.text = "grajitha2009@gmail.com"
        //        txtFirstName.text = "Rajitha Gangam";
        //        txtPassword.text = "V@rshitha12345";
        //        txtCfrmPassword.text =  "V@rshitha12345";
        //        txtPhone.text = "+918096823214";
        addDoneButton()
        pickerView.delegate = self
    }
    
    func addDoneButton() {
        let toolbar =  UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 35))
        
        let flexButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action:#selector(resignKB(_:)))
        toolbar.setItems([flexButton, doneButton], animated: true)
        toolbar.sizeToFit()
        txtFirstName.inputAccessoryView = toolbar;
        txtLastName.inputAccessoryView = toolbar;
        txtEmail.inputAccessoryView = toolbar;
        txtPhone.inputAccessoryView = toolbar;
        txtPassword.inputAccessoryView = toolbar;
        txtCfrmPassword.inputAccessoryView = toolbar;
        txtDOB.inputAccessoryView = toolbar
        txtDOB.inputView = pickerView

    }
    @IBAction func resignKB(_ sender: Any) {
        txtFirstName.resignFirstResponder();
        txtLastName.resignFirstResponder();
        txtEmail.resignFirstResponder();
        txtPhone.resignFirstResponder();
        txtPassword.resignFirstResponder();
        txtCfrmPassword.resignFirstResponder();
        txtDOB.resignFirstResponder();
        
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
            self.viewActivity.isHidden = true
        }
        if let error = error as? AWSMobileClientError {
            switch(error) {
            case .invalidPassword(message: let message):
                //print("==invalidPassword:",message)
                showAlert(strMsg: message);
            case .invalidParameter(message: let message):
                //print("==invalidState:",message)
                showAlert(strMsg: message);
            case .usernameExists(let message):
                showAlert(strMsg: message);
                
            default:
                showAlert(strMsg: "\(error)");
                break
            }
            
            //print("There's an error on signup: \(error.localizedDescription), \(error)")
            
        }
        
        guard let signUpResult = signUpResult else {
            return
        }
        //print("signUpConfirmationState: \(signUpResult.signUpConfirmationState)");
        switch(signUpResult.signUpConfirmationState) {
        case .confirmed:
            //print("User is signed up and confirmed.")
            
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
                UserDefaults.standard.set(username, forKey: "user_email")
                
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
        resignKB(sender)
        let netAvailable = appDelegate.isConnectedToInternet()
        if(!netAvailable){
            showAlert(strMsg: "Please check your internet connection!")
            return
        }
        let firstName = txtFirstName.text!.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        let lastName = txtLastName.text!.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        let phone = txtPhone.text!.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        let email = txtEmail.text!.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        let pwd = txtPassword.text!.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        let cfrmPwd = txtCfrmPassword.text!.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        let dob = txtDOB.text!;
        
        if (firstName.count == 0){
            showAlert(strMsg: "Please enter first name");
        }else if (lastName.count == 0){
            showAlert(strMsg: "Please enter last name");
        }else if (email.count == 0){
            showAlert(strMsg: "Please enter email");
        }else if (!isValidEmail()){
            showAlert(strMsg: "Please enter valid email");
        }else if (phone.count == 0){
            showAlert(strMsg: "Please enter phone number");
        }else if (phone.count != 12 && phone.count != 13){
            showAlert(strMsg: "Please enter valid phone number");
        }else if(dob.count == 0){
            showAlert(strMsg: "Please select age");
        }else if (pwd.count == 0){
            showAlert(strMsg: "Please enter password");
        }else if (cfrmPwd.count == 0){
            showAlert(strMsg: "Please enter confirm password");
        }else if(pwd != cfrmPwd){
            showAlert(strMsg: "password and confirm password did not match");
        }else{
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "YYYY-MM-dd"
            
            let currentDate = Date()
            var dateComponent = DateComponents()
            if (dob == "Below 18"){
                dateComponent.year = -17 // currentdate -17 years
            }else{
                dateComponent.year = -18 // currentdate -18 years
            }
            let pastDate = Calendar.current.date(byAdding: dateComponent, to: currentDate)
            //print("currentDate:",currentDate)
            //print("pastDate:",pastDate!)
            let dobPast = dateFormatter.string(from:pastDate!)
            
            viewActivity.isHidden = false
            //username value shoulb be like email
            AWSMobileClient.default().signUp(username: email,
                                             password: pwd,
                                             userAttributes: ["email" : email, "name":firstName,"phone_number":phone,"family_name":lastName,"birthdate":dobPast,"custom:plan":planID],
                                             completionHandler: signUpHandler);
        }
    }
    
    @IBAction func dismissModal(_ sender: Any) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    // MARK: Text Field Delegate Methods
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if (textField==txtPassword || textField==txtCfrmPassword || textField==txtDOB){
            self.animateTextField(textField: textField, up:true)
        }
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if (textField==txtPassword || textField==txtCfrmPassword || textField==txtDOB){
            self.animateTextField(textField: textField, up:false)
        }
        textField.resignFirstResponder();
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (textField == txtPhone){
            let maxLength = 13
            let currentString: NSString = textField.text! as NSString
            let newString: NSString =
                currentString.replacingCharacters(in: range, with: string) as NSString
            if range.length>0  && range.location == 0 {
                return false
            }
            
            return newString.length <= maxLength
        }
        return true;
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder();
        return true;
    }
    // MARK: Keyboard  Delegate Methods
    
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
    // MARK: Picker DataSource & Delegate Methods
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedItem = pickerData[row]
        txtDOB.text = selectedItem
    }
}

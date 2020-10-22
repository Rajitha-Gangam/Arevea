//
//  SignUpViewController.swift
//  aws_amplify_integration
//
//  Created by Calin Cristian on 27/03/2019.
//  Copyright © 2019 Calin Cristian Ciubotariu. All rights reserved.
//

import UIKit
import Alamofire
import FlagPhoneNumber

class SignUpVC: UIViewController ,UITextFieldDelegate,UIPickerViewDelegate, UIPickerViewDataSource{
    var listController: FPNCountryListViewController = FPNCountryListViewController(style: .grouped)
    var repository: FPNCountryRepository = FPNCountryRepository()
    var countryCode = "+1"
    // MARK: - Variables Declaration
    @IBOutlet weak var txtFirstName: UITextField!
    @IBOutlet weak var txtLastName: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPhone: FPNTextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtCfrmPassword: UITextField!
    @IBOutlet weak var txtDOB: UITextField!
    @IBOutlet weak var btnCheckTermsAndCond: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var scrollView: UIScrollView!
    var planID = "0";
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let pickerView = UIPickerView()
    
    // MARK: - View Life cycle
    @IBOutlet weak var viewActivity: UIView!
    var pickerData =  ["Under 16", "16-17","18+"];
    var keyboardHeight: CGFloat = 0
    var viewUp = false;
    var isTermsChecked = false
    override func viewDidLoad() {
        super.viewDidLoad()
        txtFirstName.backgroundColor = .clear;
        txtLastName.backgroundColor = .clear;
        txtEmail.backgroundColor = .clear;
        txtPhone.backgroundColor = .clear;
        txtDOB.backgroundColor = .clear;
        txtPassword.backgroundColor = .clear;
        txtCfrmPassword.backgroundColor = .clear;
        viewActivity.isHidden = true
        //self.assignbackground();
        self.navigationController?.isNavigationBarHidden = true
        /*txtEmail.text = "grajitha2009@gmail.com"
         txtFirstName.text = "Rajitha";
         txtLastName.text = "Gangam"
         txtPassword.text = "V@rshitha12345";
         txtCfrmPassword.text =  "V@rshitha12345";
         txtPhone.text = "+918096823214";*/
        addDoneButton()
        pickerView.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        txtPhone.displayMode = .list
        txtPhone.textColor = .white
        txtPhone.delegate = self
        //phoneNumberTextField.flagButtonSize = CGSize(width: 44, height: 44)

        listController.setup(repository: txtPhone.countryRepository)
        
        listController.didSelect = { [weak self] country in
            self?.txtPhone.setFlag(countryCode: country.code)
        }

    }
    @objc func dismissCountries() {
        listController.dismiss(animated: true, completion: nil)
    }
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            keyboardHeight = keyboardSize.height
            if (viewUp && self.view.frame.origin.y == 0){
                self.view.frame.origin.y -= 170
            }
        }
    }
    @objc func keyboardWillHide(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            self.view.frame.origin.y = 0;
            
        }
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
    @IBAction func termsAndCond(){
        let urlOpen = appDelegate.websiteURL + "/termsandconditions"
        guard let url = URL(string: urlOpen) else { return }
        //print("url to open:",url)
        UIApplication.shared.open(url)
    }
    @IBAction func checkTermsAndCond(){
        if (isTermsChecked)
        {
            btnCheckTermsAndCond?.setImage(UIImage.init(named: "check"), for: .normal);
            isTermsChecked = false
        }
        else{
            btnCheckTermsAndCond?.setImage(UIImage.init(named: "checked"), for: .normal);
            isTermsChecked = true
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
        let phone = txtPhone.getRawPhoneNumber() ?? "0"// if its valid, number returns, else 0 assigning
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
        }else if (phone == "0"){
            showAlert(strMsg: "Please enter valid phone number");
        }else if(dob.count == 0){
            showAlert(strMsg: "Please select age");
        }else if (pwd.count == 0){
            showAlert(strMsg: "Please enter password");
        }else if (cfrmPwd.count == 0){
            showAlert(strMsg: "Please enter confirm password");
        }else if(pwd != cfrmPwd){
            showAlert(strMsg: "Password and confirm password did not match");
        }else  if (!isTermsChecked)
        {
            showAlert(strMsg: "Please accept terms & conditions");
        }else{
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "YYYY-MM-dd"
            
            let currentDate = Date()
            var dateComponent = DateComponents()
            if (dob == "Under 16"){
                dateComponent.year = -15 // currentdate -15 years
            }else if (dob == "16-17"){
                dateComponent.year = -16 // currentdate -16 years
            }else{
                dateComponent.year = -18 // currentdate -18 years
            }
            let pastDate = Calendar.current.date(byAdding: dateComponent, to: currentDate)
            ////print("currentDate:",currentDate)
            ////print("pastDate:",pastDate!)
            let dobPast = dateFormatter.string(from:pastDate!)
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let phoneWithCC = countryCode + phone
            let url: String = appDelegate.ol_base_url + "/api/2/users"
            let inputData = ["firstname" : firstName,"lastname" : lastName,"email" : email,"username" : email,"phone" : phoneWithCC,"password" : pwd,"password_confirmation" : pwd,"custom_attributes" : ["date_of_birth" : dobPast,"plan" : planID,"profile_pic" : "","user_display_name" : firstName + " " + lastName,"user_type" : 3,"is_user_verify" : 0]
                ] as [String : Any]
            
            
            viewActivity.isHidden = false
            let headers: HTTPHeaders = [
                "Authorization": "Bearer " + appDelegate.ol_access_token,
                "Accept": "application/json"
            ]
            AF.request(url, method: .post,parameters: inputData, encoding: JSONEncoding.default,headers:headers)
                .responseJSON { response in
                    self.viewActivity.isHidden = true
                    switch response.result {
                    case .success(let value):
                        if let json = value as? [String: Any] {
                            //print("signUP JSON:",json)
                            if (json["status"]as? Int == 1 ){
                                let strMsg = "Confirmation code sent via email to " + email
                                let alert = UIAlertController(title: "Code Sent",
                                                              message:strMsg ,
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
                            }else{
                                //An account with the given email already exists.
                                //self.showAlert(strMsg: "An account with the given email already exists.")
                                let strMsg = json["message"] as? String ?? ""
                                if(strMsg.lowercased().contains("email must be unique")){
                                    self.showAlert(strMsg: "An account with the given email already exists.")
                                }else{
                                    self.showAlert(strMsg: strMsg)
                                }
                            }
                        }
                    case .failure(let error):
                        let errorDesc = error.localizedDescription.replacingOccurrences(of: "URLSessionTask failed with error:", with: "")
                        self.showAlert(strMsg: errorDesc)
                        
                    }
            }
            
        }
    }
    
    @IBAction func dismissModal(_ sender: Any) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    // MARK: Text Field Delegate Methods
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        viewUp = false;
        if (textField==txtPassword || textField==txtCfrmPassword || textField==txtDOB || textField == txtPhone || textField == txtEmail){
            viewUp = true;
        }
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        viewUp = true;
        textField.resignFirstResponder();
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return true;
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder();
        return true;
    }
    // MARK: Keyboard  Delegate Methods
    
    
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
    deinit {
        //print("Remove NotificationCenter Deinit")
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        AppDelegate.AppUtility.lockOrientation(.portrait)
    }
}
extension SignUpVC: FPNTextFieldDelegate {
    
    func fpnDisplayCountryList() {
        let navigationViewController = UINavigationController(rootViewController: listController)
        
        listController.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(dismissCountries))
        listController.title = "Countries"

        self.present(navigationViewController, animated: true, completion: nil)
    }
    
    func fpnDidValidatePhoneNumber(textField: FPNTextField, isValid: Bool) {
        textField.rightViewMode = .always
        textField.rightView = UIImageView(image: isValid ? #imageLiteral(resourceName: "success") : #imageLiteral(resourceName: "error"))
        
        print(
            isValid,
            textField.getFormattedPhoneNumber(format: .E164) ?? "E164: nil",
            textField.getFormattedPhoneNumber(format: .International) ?? "International: nil",
            textField.getFormattedPhoneNumber(format: .National) ?? "National: nil",
            textField.getFormattedPhoneNumber(format: .RFC3966) ?? "RFC3966: nil",
            textField.getRawPhoneNumber() ?? "Raw: nil"
        )
    }
    
    func fpnDidSelectCountry(name: String, dialCode: String, code: String) {
        txtPhone.text = ""
        countryCode = dialCode
        //print(name, dialCode, code)
    }
}

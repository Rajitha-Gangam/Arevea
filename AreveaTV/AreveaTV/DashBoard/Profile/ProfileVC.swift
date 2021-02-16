//
//  ProfileVC.swift
//  AreveaTV
//
//  Created by apple on 4/25/20.
//  Copyright © 2020 apple. All rights reserved.
//

import UIKit
import AWSMobileClient
import Alamofire
import FlagPhoneNumber

class ProfileVC: UIViewController,UITextFieldDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIPickerViewDelegate, UIPickerViewDataSource {
    // MARK: - Variables Declaration
    var listController: FPNCountryListViewController = FPNCountryListViewController(style: .grouped)
    var repository: FPNCountryRepository = FPNCountryRepository()
    var countryCode = "+1"
    @IBOutlet weak var txtFirstName: UITextField!
    @IBOutlet weak var txtLastName: UITextField!
    @IBOutlet weak var txtPhone: FPNTextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtDisplayName: UITextField!
    @IBOutlet weak var txtDOB: UITextField!
    var isCameFrom = ""
    var strFirstName = ""
    var strLastName = ""
    var strPhone = ""
    var strDOB = ""
    var strDisplayName = ""
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var btnProfilePic: UIButton!
    @IBOutlet weak var btnEdit: UIButton!
    // var choosenImage = UIImage?.self
    @IBOutlet weak var imgProfilePic: UIImageView!
    var imagePickerController = UIImagePickerController()
    @IBOutlet weak var viewActivity: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var strProfilePicURL = ""
    let pickerView = UIPickerView()
    var pickerData =  ["Under 16", "16-17","18+"];
    var selectedAgeIndex = -1
    @IBOutlet weak var heightTopView: NSLayoutConstraint?
    @IBOutlet weak var viewTop: UIView!
    var isDeleteShow = false
    @IBOutlet weak var viewChangePWD: UIView!
    @IBOutlet weak var viewNoProfilePic: UIView!
    @IBOutlet weak var viewProfilePic: UIView!
    var isFlagLoad = false
    @IBOutlet weak var btnCancel: UIButton!

    // MARK: - View Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        txtFirstName.backgroundColor = .clear;
        txtLastName.backgroundColor = .clear;
        txtEmail.backgroundColor = .clear;
        txtPhone.backgroundColor = .clear;
        txtDOB.backgroundColor = .clear;
        txtDisplayName.backgroundColor = .clear;
        
        viewActivity.isHidden = true
        //Do any additional setup after loading the view.
        addDoneButton();
        getProfile();
        
        imagePickerController.delegate = self
        imgProfilePic.contentMode = .scaleAspectFill
        
        scrollView.contentSize = CGSize(width: self.view.frame.size.width,height: 1000); //sets ScrollView content size
        pickerView.delegate = self
        if(UIDevice.current.userInterfaceIdiom == .pad){
            heightTopView?.constant = 60;
            viewTop.layoutIfNeeded()
        }
        viewChangePWD.layer.borderColor = UIColor.white.cgColor
        viewNoProfilePic.layer.borderColor = UIColor.white.cgColor
        btnCancel.layer.borderColor = UIColor.white.cgColor

        viewProfilePic.isHidden = true
        viewNoProfilePic.isHidden = false
        
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
    override func viewDidAppear(_ animated: Bool) {
        //        scrollView.contentSize = CGSize(width: 320,height: 1000);
        //        scrollView.contentInset = UIEdgeInsets(top: 64.0,left: 0.0,bottom: 44.0,right: 0.0);
        
    }
    override func viewWillLayoutSubviews(){
        super.viewWillLayoutSubviews()
        //scrollView.contentSize = CGSize(width: 375, height: 1500)
    }
    
    @IBAction func back(_ sender: Any) {
        if(isCameFrom == "db"){
            self.navigationController?.popViewController(animated: true)
        }else{
            updateProfile(self)
            //self.navigationController?.popViewController(animated: true)
        }
    }
    @IBAction func cancel(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func updatePwd(_ sender: Any) {
        resignKB(sender)
        let netAvailable = appDelegate.isConnectedToInternet()
        if(!netAvailable){
            showAlert(strMsg: "Please check your internet connection!")
            return
        }
        //forgotPassword();
        let username = UserDefaults.standard.string(forKey: "user_email");
        let inputData = ["email": username,"type": "forgot_password"]
        sendOTP(inputData: inputData as [String : Any])
    }
    @IBAction func updateProfile(_ sender: Any) {
        resignKB(sender)
        let netAvailable = appDelegate.isConnectedToInternet()
        if(!netAvailable){
            showAlert(strMsg: "Please check your internet connection!")
            return
        }
        strFirstName = txtFirstName.text!.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        strLastName = txtLastName.text!.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        let phone = txtPhone.getRawPhoneNumber() ?? "0"// if its valid, number returns, else 0 assigning
        strDisplayName = txtDisplayName.text!.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        strPhone = countryCode + phone
        if (strFirstName.count == 0){
            showAlert(strMsg: "Please enter first name");
        }else if (strLastName.count == 0){
            showAlert(strMsg: "Please enter last name");
        }else if (strDisplayName.count == 0){
            showAlert(strMsg: "Please enter display name");
        }else{
            if (txtPhone.text?.count != 0){
                if (phone == "0"){
                    showAlert(strMsg: "Please enter valid phone number");
                    return
                }
            }
            setProfile()
        }
    }
    @IBAction func resignKB(_ sender: Any) {
        txtFirstName.resignFirstResponder();
        txtLastName.resignFirstResponder();
        txtEmail.resignFirstResponder();
        txtPhone.resignFirstResponder();
        txtDOB.resignFirstResponder();
        txtDisplayName.resignFirstResponder();
    }
    func addDoneButton() {
        let toolbar =  UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 35))
        
        
        let flexButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action:#selector(resignKB(_:)))
        toolbar.setItems([flexButton, doneButton], animated: true)
        toolbar.sizeToFit()
        txtFirstName.inputAccessoryView = toolbar;
        txtLastName.inputAccessoryView = toolbar;
        txtPhone.inputAccessoryView = toolbar;
        txtEmail.inputAccessoryView = toolbar;
        txtDOB.inputAccessoryView = toolbar;
        txtDisplayName.inputAccessoryView = toolbar;
        txtDOB.inputView = pickerView
        
    }
    func showAlert(strMsg: String){
        let alert = UIAlertController(title: "Alert", message: strMsg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
    // MARK: Download Image from URL
    
    // MARK: Handler for performerEvents API, using for upcoming schedules
    func getProfile(){
        let netAvailable = appDelegate.isConnectedToInternet()
        if(!netAvailable){
            showAlert(strMsg: "Please check your internet connection!")
            return
        }
        
        let user_id = UserDefaults.standard.string(forKey: "user_id");
        //print("getProfile:",user_id)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let url: String = appDelegate.ol_base_url + "/api/2/users/" + user_id!
        viewActivity.isHidden = false
        let headers: HTTPHeaders = [
            "Authorization": "Bearer " + appDelegate.ol_access_token,
            "Accept": "application/json"
        ]
        AF.request(url, method: .get, encoding: JSONEncoding.default,headers:headers)
            .responseJSON { response in
                self.viewActivity.isHidden = true
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any] {
                        print("getProfile JSON:",json)
                        let user = json
                        let custom_attributes = json["custom_attributes"]as?[String: Any] ?? [:]
                        
                        self.txtEmail.text = UserDefaults.standard.string(forKey: "user_email");
                        
                        self.txtFirstName.text = user["firstname"] as? String
                        self.txtLastName.text = user["lastname"]as? String
                        let phone1 = user["phone"]as? String ?? ""
                        //print("==phone1:",phone1)
                        self.isFlagLoad = true
                        self.txtPhone.set(phoneNumber:phone1)
                        self.isFlagLoad = false

                        self.txtDisplayName.text = custom_attributes["user_display_name"]as? String
                        //print("txtDIsplay:",self.txtDisplayName.text)
                        let dob = custom_attributes["date_of_birth"]as? String ?? ""
                        if(dob != ""){
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "YYYY-MM-dd"
                            let date = dateFormatter.date(from: dob)
                            
                            let dateFormatterYear = DateFormatter()
                            dateFormatterYear.dateFormat = "YYYY"
                            let pastdate = dateFormatterYear.string(from: date ?? Date());
                            
                            let todaysDate = Date()
                            let currentDate = dateFormatterYear.string(from: todaysDate);
                            ////print("currentDate:",currentDate)
                            ////print("pastdate:",pastdate)
                            guard let currentYear = Int(currentDate), let pastYear = Int(pastdate) else {
                                ////print("Some value is nil")
                                return
                            }
                            let age = currentYear - pastYear
                            print("age:",age)
                            
                            if (age > 17){
                                self.txtDOB.text = self.pickerData[2]
                                ////print("second:",self.pickerData[1])
                                self.selectedAgeIndex = 2
                                self.pickerView.selectRow(2, inComponent: 0, animated: true)
                            }
                            else if (age == 16 || age == 17 ){
                                self.txtDOB.text = self.pickerData[1]
                                ////print("second:",self.pickerData[1])
                                self.selectedAgeIndex = 1
                                self.pickerView.selectRow(1, inComponent: 0, animated: true)
                            }else{
                                self.txtDOB.text = self.pickerData[0]
                                self.selectedAgeIndex = 0
                                self.pickerView.selectRow(0, inComponent: 0, animated: true)
                            }
                        }
                        
                        //let diff = Int(currentDate) - Int(pastdate)
                        
                        let strURL = custom_attributes["profile_pic"]as? String ?? ""
                        
                        self.strProfilePicURL = strURL
                        self.isDeleteShow = false
                        self.viewActivity.isHidden = true
                        
                        if let url = URL(string: strURL){
                            //print("url:",url)
                            self.imgProfilePic.sd_setImage(with: url, placeholderImage: UIImage(named: "user"))
                            self.isDeleteShow = true
                            self.viewProfilePic.isHidden = false
                            self.viewNoProfilePic.isHidden = true
                        }else{
                            self.viewProfilePic.isHidden = true
                            self.viewNoProfilePic.isHidden = false
                        }
                        
                    }
                case .failure(let error):
                    let errorDesc = error.localizedDescription.replacingOccurrences(of: "URLSessionTask failed with error:", with: "")
                    self.showAlert(strMsg: errorDesc)
                    
                }
        }
    }
    func updateUser(inputData:[String: Any],strValue:String){
        let user_id = UserDefaults.standard.string(forKey: "user_id");
        //print("updateUser:",inputData)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let url: String = appDelegate.ol_base_url + "/api/2/users/" + user_id!
        viewActivity.isHidden = false
        let headers: HTTPHeaders = [
            "Authorization": "Bearer " + appDelegate.ol_access_token,
            "Accept": "application/json"
        ]
        AF.request(url, method: .put,parameters: inputData, encoding: JSONEncoding.default,headers:headers)
            .responseJSON { [self] response in
                self.viewActivity.isHidden = true
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any] {
                        //print("updateUser JSON:",json)
                        if (json["status"]as? Int == 1 ){
                            if(strValue == "set_profile"){
                                self.showAlert(strMsg:"Profile updated successfully")
                                let fn = self.txtFirstName.text!
                                let ln = self.txtLastName.text!
                                let strName = String((fn.first)!) + String((ln.first)!)
                                self.appDelegate.USER_NAME = strName;
                                self.appDelegate.USER_NAME_FULL = fn + " " + ln
                                self.appDelegate.USER_DISPLAY_NAME = self.txtDisplayName.text!
                                UserDefaults.standard.set(self.appDelegate.USER_NAME, forKey: "USER_NAME")
                                UserDefaults.standard.set(self.appDelegate.USER_NAME_FULL, forKey: "USER_NAME_FULL")
                                if(self.isCameFrom == "db"){
                                    self.navigationController?.popViewController(animated: true);
                                }else{
                                    let storyboard = UIStoryboard(name: "Main", bundle: nil);
                                    let vc = storyboard.instantiateViewController(withIdentifier: "DashBoardVC") as! DashBoardVC
                                    self.navigationController?.pushViewController(vc, animated: true)
                                }
                            }else if(strValue == "set_profile_pic"){
                                self.showAlert(strMsg:"Profile picture updated successfully")
                                UserDefaults.standard.set("false", forKey: "is_profile_pic_loaded_left_menu")
                                self.isDeleteShow = true
                                self.viewProfilePic.isHidden = false
                                self.viewNoProfilePic.isHidden = true
                            }else if(strValue == "delete_profile_pic"){
                                self.showAlert(strMsg:"Profile picture deleted successfully")
                                self.imgProfilePic.image = UIImage.init(named:"user")
                                self.isDeleteShow = false
                                UserDefaults.standard.set("false", forKey: "is_profile_pic_loaded_left_menu")
                                self.viewProfilePic.isHidden = true
                                self.viewNoProfilePic.isHidden = false
                            }
                        }else{
                            let strMsg = json["message"] as? String ?? ""
                            self.showAlert(strMsg: strMsg)
                        }
                    }
                case .failure(let error):
                    let errorDesc = error.localizedDescription.replacingOccurrences(of: "URLSessionTask failed with error:", with: "")
                    self.showAlert(strMsg: errorDesc)
                    
                }
        }
    }
    func setProfile(){
        let netAvailable = appDelegate.isConnectedToInternet()
        if(!netAvailable){
            showAlert(strMsg: "Please check your internet connection!")
            return
        }
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let dob = txtDOB.text!
        if(dob != ""){
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "YYYY-MM-dd"
            
            let currentDate = Date()
            var dateComponent = DateComponents()
            
            if (dob == "Under 16"){
                selectedAgeIndex = 0
                dateComponent.year = -15 // currentdate -15 years
            }else if (dob == "16-17"){
                selectedAgeIndex = 1
                dateComponent.year = -16 // currentdate -16 years
            }else{
                selectedAgeIndex = 2
                dateComponent.year = -19 // currentdate -18 years
            }
            let pastDate = Calendar.current.date(byAdding: dateComponent, to: currentDate)
            ////print("currentDate:",currentDate)
            ////print("pastDate:",pastDate!)
            let dobPast = dateFormatter.string(from:pastDate!)
            strDOB = dobPast
            print("strDOB:",strDOB)

        }
        
        let url: String = appDelegate.baseURL +  "/setProfile"
        let user_id = UserDefaults.standard.string(forKey: "user_id");
        let user_email = UserDefaults.standard.string(forKey: "user_email");
        
        
        let inputData: [String: Any] = ["user_id":user_id ?? "","user_first_name":strFirstName,"user_last_name":strLastName,"user_phone_number":strPhone,"user_email":user_email!,"user_display_name":strDisplayName,"date_of_birth":strDOB]
        
        print("setProfile inputData:",inputData)
        let session_token = UserDefaults.standard.string(forKey: "session_token") ?? ""
        let headers : HTTPHeaders = [
            "Content-Type": "application/json",
            appDelegate.x_api_key:appDelegate.x_api_value,
            "Authorization": "Bearer " + session_token
        ]
        viewActivity.isHidden = false
        AF.request(url, method: .post,parameters: inputData, encoding: JSONEncoding.default,headers:headers)
            .responseJSON { response in
                self.viewActivity.isHidden = true
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any] {
                        //print("setProfile JSON:",json)
                        if (json["status"]as? Int == 0  ){
                            let inputData: [String: Any] = ["firstname":self.strFirstName,"lastname":self.strLastName,"phone":self.strPhone,"custom_attributes":["date_of_birth":self.strDOB,"profile_pic":"","user_display_name":self.strDisplayName]]
                            self.updateUser(inputData: inputData,strValue: "set_profile")
                        }else{
                            let strMsg = json["message"] as? String ?? ""
                            self.showAlert(strMsg: strMsg)
                        }
                        
                    }
                case .failure(let error):
                    let errorDesc = error.localizedDescription.replacingOccurrences(of: "URLSessionTask failed with error:", with: "")
                    self.showAlert(strMsg: errorDesc)
                    self.viewActivity.isHidden = true
                    
                }
        }
    }
    
    
    func sendOTP(inputData:[String: Any]){
        let netAvailable = appDelegate.isConnectedToInternet()
        if(!netAvailable){
            showAlert(strMsg: "Please check your internet connection!")
            return
        }
        let username = UserDefaults.standard.string(forKey: "user_email");
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let url: String = appDelegate.baseURL +  "/sendOTP"
        viewActivity.isHidden = false
        let headers: HTTPHeaders
        headers = [appDelegate.x_api_key: appDelegate.x_api_value]
        AF.request(url, method: .post,parameters: inputData, encoding: JSONEncoding.default,headers:headers)
            .responseJSON { response in
                self.viewActivity.isHidden = true
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any] {
                        //print("sendOTP JSON:",json)
                        if (json["status"]as? Int == 0 ){
                            //self.showAlert(strMsg: "Verification code sent via email")
                            let alert = UIAlertController(title: "Code sent",
                                                          message: "Confirmation code sent via email",
                                                          preferredStyle: .alert)
                            
                            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel) { _ in
                                UserDefaults.standard.set(username, forKey: "user_email")
                                
                                let storyboard = UIStoryboard(name: "Main", bundle: nil);
                                let vc = storyboard.instantiateViewController(withIdentifier: "NewPasswordVC") as! NewPasswordVC
                                vc.camefrom = "profile"
                                self.navigationController?.pushViewController(vc, animated: true)
                            })
                            
                            DispatchQueue.main.async {
                                self.present(alert, animated: true, completion: nil)
                            }
                            
                            
                        }else{
                            let strMsg = json["message"] as? String ?? ""
                            self.showAlert(strMsg: strMsg)
                        }
                        
                    }
                case .failure(let error):
                    let errorDesc = error.localizedDescription.replacingOccurrences(of: "URLSessionTask failed with error:", with: "")
                    self.showAlert(strMsg: errorDesc)
                    self.viewActivity.isHidden = true
                    
                }
        }
    }
    
    func forgotPassword(){
        
        let username =  UserDefaults.standard.string(forKey: "user_email")!;
        
        viewActivity.isHidden = false
        AWSMobileClient.default().forgotPassword(username: username) { (forgotPasswordResult, error) in
            DispatchQueue.main.async {
                self.viewActivity.isHidden = true
            }
            if let error = error {
                self.showAlert(strMsg: "\(error)");
                ////print("\(error)")
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
                    break
                }
            } else if let error = error {
                //print("Error occurred: \(error.localizedDescription)")
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
    // MARK: Text Field Delegate Methods
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.animateTextField(textField: textField, up:true)
        if(textField == txtDOB){
            for (index,element) in pickerData.enumerated(){
                if(element == txtDOB.text){
                    pickerView.selectRow(index, inComponent: 0, animated: true)
                    break
                }
            }
        }
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.animateTextField(textField: textField, up:false)
        textField.resignFirstResponder();
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder();
        return true;
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return true;
    }
    // MARK: Keyboard  Delegate Methods
    
    func animateTextField(textField: UITextField, up: Bool)
    {
        let movementDistance:CGFloat = -200
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
    
    // MARK: Profile Pic Update Methods
    @IBAction func profilePicTap(){
        editConfirmation()
    }
    
    func editConfirmation() {
        let actionsheet = UIAlertController(title: "Confirmation", message: "", preferredStyle: .actionSheet)
        actionsheet.addAction(UIAlertAction(title: "Update Profile Picture", style: .default, handler: { (action:UIAlertAction)in
            self.chooseProfilePic()
        }))
        actionsheet.addAction(UIAlertAction(title: "Delete Profile Picture", style: .default, handler: { (action:UIAlertAction)in
            self.deleteProfilePic()
            
        }))
        actionsheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        // actionsheet.popoverPresentationController.barButtonItem = button;
        if let popoverController = actionsheet.popoverPresentationController {
            popoverController.sourceRect = btnProfilePic.bounds
            popoverController.sourceView = btnProfilePic
            popoverController.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 1)
        }
        self.present(actionsheet,animated: true, completion: nil)
    }
    @IBAction func chooseProfilePic() {
        let actionsheet = UIAlertController(title: "Photo Source", message: "Choose A Source", preferredStyle: .actionSheet)
        actionsheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action:UIAlertAction)in
            if UIImagePickerController.isSourceTypeAvailable(.camera){
                self.imagePickerController.sourceType = .camera
                self.present(self.imagePickerController, animated: true, completion: nil)
            }else
            {
                ////print("Camera is Not Available")
            }
        }))
        actionsheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (action:UIAlertAction)in
            if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
                self.imagePickerController.sourceType = .savedPhotosAlbum
                self.imagePickerController.allowsEditing = false
                self.present(self.imagePickerController, animated: true, completion: nil)
            }
        }))
        actionsheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        // actionsheet.popoverPresentationController.barButtonItem = button;
        if let popoverController = actionsheet.popoverPresentationController {
            popoverController.sourceRect = btnProfilePic.bounds
            popoverController.sourceView = btnProfilePic
            popoverController.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 1)
        }
        self.present(actionsheet,animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            ////print("didFinishPickingImage")
            imgProfilePic.contentMode = .scaleAspectFill
            imgProfilePic.image = pickedImage
            updateProfilePic()
        }
        dismiss(animated: true, completion: nil)
    }
    func updateProfilePic1(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let url: String = appDelegate.baseURL +  "/uploadFile"
        let user_id = UserDefaults.standard.string(forKey: "user_id");
        let inputData: [String: Any] = ["user_id":user_id ?? "","image_for":"profile"]
        let session_token = UserDefaults.standard.string(forKey: "session_token") ?? ""
        let headers : HTTPHeaders = [
            "Content-Type": "multipart/form-data,application/json",
            appDelegate.x_api_key:appDelegate.x_api_value,
            "Authorization": "Bearer " + session_token
        ]
        viewActivity.isHidden = false
        AF.upload(multipartFormData: { (multipartFormData) in
            for (key, value) in inputData {
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
            }
            let image1 = self.imgProfilePic.image
            //let image1 = UIImage.init(named: "charity-img.png")
            var imageData = image1!.jpegData(compressionQuality: 1.0)
            if(Double(imageData!.count ) / 1024 > 400)
            {
                imageData = image1?.jpegData(compressionQuality: 0.5)
            }
            multipartFormData.append(imageData!, withName: "image", fileName: "profile_pic.png", mimeType: "image/png")
        }, to: url, usingThreshold: UInt64.init(),
           method: .post,headers: headers).responseJSON{ response in
            self.viewActivity.isHidden = true
            switch response.result {
            case .success(let value):
                if let json = value as? [String: Any] {
                    //print("updateProfilePic JSON:",json)
                    if (json["status"]as? Int == 0){
                        ////print(json["message"] ?? "")
                        let strURL = json["path"]as? String ?? ""
                        self.strProfilePicURL = strURL
                        let inputData: [String: Any] = ["custom_attributes":["profile_pic":self.strProfilePicURL]]
                        //print("self.strProfilePicURL:",self.strProfilePicURL)
                        self.updateUser(inputData: inputData,strValue: "set_profile_pic")
                    }else{
                        let strError = json["message"] as? String
                        ////print(strError ?? "")
                        self.showAlert(strMsg: strError ?? "")
                    }
                }
            case .failure(let error):
                ////print("error:",error)
                let errorDesc = error.localizedDescription.replacingOccurrences(of: "URLSessionTask failed with error:", with: "")
                self.showAlert(strMsg: errorDesc)
                self.viewActivity.isHidden = true
                
            }
        }
    }
    @IBAction func updateProfilePic(){
        let netAvailable = appDelegate.isConnectedToInternet()
        if(!netAvailable){
            showAlert(strMsg: "Please check your internet connection!")
            return
        }
        viewActivity.isHidden = false
        let url = appDelegate.profileURL + "/uploadFile" /* your API url */
        let session_token = UserDefaults.standard.string(forKey: "session_token") ?? ""
        
        //let headers: HTTPHeaders
        //headers = [appDelegate.x_api_key: appDelegate.x_api_value]
        let headers: HTTPHeaders = ["Content-type": "multipart/form-data","access_token": session_token]
        
        let user_id = UserDefaults.standard.string(forKey: "user_id");
        
        let params: [String: Any] = ["user_id":user_id ?? "","image_for":"profile"]
        
        AF.upload(multipartFormData: { (multipartFormData) in
            for (key, value) in params {
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
            }
            let image1 = self.imgProfilePic.image
            //let image1 = UIImage.init(named: "charity-img.png")
            var imageData = image1!.jpegData(compressionQuality: 1.0)
            if(Double(imageData!.count ) / 1024 > 400)
            {
                imageData = image1?.jpegData(compressionQuality: 0.5)
            }
            multipartFormData.append(imageData!, withName: "image", fileName: "profile_pic.png", mimeType: "image/png")
        }, to: url, usingThreshold: UInt64.init(),
           method: .post,headers: headers).responseJSON{ response in
            self.viewActivity.isHidden = true
            switch response.result {
            case .success(let value):
                if let json = value as? [String: Any] {
                    //print("updateProfilePic JSON:",json)
                    if (json["status"]as? Int == 0){
                        let strURL = json["path"]as? String ?? ""
                        self.strProfilePicURL = strURL
                        let inputData: [String: Any] = ["custom_attributes":["profile_pic":self.strProfilePicURL]]
                        self.updateUser(inputData: inputData,strValue: "set_profile_pic")
                    }else{
                        let strError = json["message"] as? String
                        ////print(strError ?? "")
                        self.showAlert(strMsg: strError ?? "")
                    }
                }
            case .failure(let error):
                ////print("error:",error)
                let errorDesc = error.localizedDescription.replacingOccurrences(of: "URLSessionTask failed with error:", with: "")
                self.showAlert(strMsg: errorDesc)
                self.viewActivity.isHidden = true
                
            }
        }
    }
    func showConfirmation(strMsg: String){
        let alert = UIAlertController(title: "Alert", message: strMsg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            self.deleteProfilePic()
            //self.showAlert(strMsg: "API is in progress, Please try again later.")
        }))
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
    @IBAction func deleteProfilePicTapped(_ sender: Any){
        showConfirmation(strMsg: "Are you sure you want delete profile picture?")
    }
    // MARK: Handler for deleteSelectedFile API
    func deleteProfilePic(){
        let netAvailable = appDelegate.isConnectedToInternet()
        if(!netAvailable){
            showAlert(strMsg: "Please check your internet connection!")
            return
        }
        
        let url: String = appDelegate.profileURL +  "/deleteSelectedFile"
        viewActivity.isHidden = false
        ////print("getCategoryOrganisations input:",inputData)
        let session_token = UserDefaults.standard.string(forKey: "session_token") ?? ""
        
        //let headers: HTTPHeaders = ["access_token": session_token]
        let user_id = UserDefaults.standard.string(forKey: "user_id");
        //appDelegate.uploadURL/profile/1590754622840_profile_pic.png
        let profile_pic_name = self.strProfilePicURL.replacingOccurrences(of:appDelegate.uploadURL, with: "")//profile/1590754622840_profile_pic.png
        ////print("profile_pic_name:",profile_pic_name)
        let params: [String: Any] = ["delete_for":"profile_pic","image_name":profile_pic_name,"user_id":user_id ?? ""]
        let headers: HTTPHeaders
        headers = ["access_token": session_token]
        AF.request(url, method: .post,  parameters: params,encoding: JSONEncoding.default, headers:headers)
            .responseJSON { response in
                self.viewActivity.isHidden = true
                
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any] {
                        ////print("deleteSelectedFile json:",json)
                        if (json["status"]as? Int == 0){
                            let inputData: [String: Any] = ["custom_attributes":["profile_pic":""]]
                            self.updateUser(inputData: inputData,strValue: "delete_profile_pic")
                        }else{
                            //this one should hide later once API works
                            let strError = json["message"] as? String
                            ////print(strError ?? "")
                            self.showAlert(strMsg: strError ?? "")
                            self.viewProfilePic.isHidden = false
                            self.viewNoProfilePic.isHidden = true
                        }
                    }
                case .failure(let error):
                    let errorDesc = error.localizedDescription.replacingOccurrences(of: "URLSessionTask failed with error:", with: "")
                    self.showAlert(strMsg: errorDesc)
                    self.viewActivity.isHidden = true
                    
                }
        }
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
        
        if (selectedAgeIndex <= row){
            let selectedItem = pickerData[row]
            txtDOB.text = selectedItem
        }else{
            txtDOB.resignFirstResponder()
            showAlert(strMsg: "This operation is restricted")
        }
        
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        AppDelegate.AppUtility.lockOrientation(.all)
    }
    override func viewWillAppear(_ animated: Bool) {
        AppDelegate.AppUtility.lockOrientation(.portrait)
    }
}
extension ProfileVC: FPNTextFieldDelegate {
    
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
        if(isFlagLoad){
            
        }else{
            txtPhone.text = ""
        }
        countryCode = dialCode
        //print(name, dialCode, code)
    }
}

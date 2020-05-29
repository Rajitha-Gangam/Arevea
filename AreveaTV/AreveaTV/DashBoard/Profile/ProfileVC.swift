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

class ProfileVC: UIViewController,UITextFieldDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
     // MARK: - Variables Declaration
    @IBOutlet weak var txtFirstName: UITextField!
    @IBOutlet weak var txtLastName: UITextField!
    @IBOutlet weak var txtPhone: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var btnProfilePic: UIButton!
    @IBOutlet var btnUpload: UIButton!
    // var choosenImage = UIImage?.self
    @IBOutlet var imgProfilePic: UIImageView!
    var imagePickerController = UIImagePickerController()
    @IBOutlet weak var viewActivity: UIView!
    
    // MARK: - View Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        viewActivity.isHidden = true
        // Do any additional setup after loading the view.
        addDoneButton();
        getProfile();
        btnUpload.isHidden = true
        imagePickerController.delegate = self
        imgProfilePic.contentMode = .scaleAspectFill
    }
    
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
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
        forgotPassword();
    }
    @IBAction func updateProfile(_ sender: Any) {
        resignKB(sender)
        let netAvailable = appDelegate.isConnectedToInternet()
        if(!netAvailable){
            showAlert(strMsg: "Please check your internet connection!")
            return
        }
        
        let firstName = txtFirstName.text!.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        let lastName = txtLastName.text!.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        let phone = txtPhone.text!.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        if (firstName.count == 0){
            showAlert(strMsg: "Please enter first name");
        }else if (lastName.count == 0){
            showAlert(strMsg: "Please enter last name");
        }else if (phone.count == 0){
            showAlert(strMsg: "Please enter phone number");
        }else if (phone.count != 13){
            showAlert(strMsg: "Please enter valid phone number");
        }else{
            setProfile()
        }
    }
    @IBAction func resignKB(_ sender: Any) {
        txtFirstName.resignFirstResponder();
        txtLastName.resignFirstResponder();
        txtEmail.resignFirstResponder();
        txtPhone.resignFirstResponder();
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
    }
    func showAlert(strMsg: String){
        let alert = UIAlertController(title: "Alert", message: strMsg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
    // MARK: Download Image from URL
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    func downloadImage(from url: URL, imageView: UIImageView) {
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            DispatchQueue.main.async() { [weak self] in
                imageView.contentMode = .scaleAspectFill
                imageView.image = UIImage(data: data)
                self?.viewActivity.isHidden = true
            }
        }
    }
    // MARK: Handler for performerEvents API, using for upcoming schedules
    func getProfile(){
        let netAvailable = appDelegate.isConnectedToInternet()
        if(!netAvailable){
            showAlert(strMsg: "Please check your internet connection!")
            return
        }
        viewActivity.isHidden = false
        let httpMethodName = "POST"
        let URLString: String = "/getProfile"
        let user_id = UserDefaults.standard.string(forKey: "user_id");
        let user_type = UserDefaults.standard.string(forKey: "user_type");
        let params: [String: Any] = ["user_id":user_id ?? "","user_type":user_type ?? ""]
        print("params:",params)
        let headerParameters = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        // Construct the request object
        let apiRequest = AWSAPIGatewayRequest(httpMethod: httpMethodName,
                                              urlString: URLString,
                                              queryParameters: [:],
                                              headerParameters: headerParameters,
                                              httpBody: params)
        // Fetch the Cloud Logic client to be used for invocation
        let invocationClient = AreveaAPIClient.client(forKey:appDelegate.AWSCognitoIdentityPoolId)
        invocationClient.invoke(apiRequest).continueWith { (task: AWSTask) -> Any? in
            if let error = task.error {
                print("Error occurred: \(error)")
                self.showAlert(strMsg: error as? String ?? error.localizedDescription)
                // Handle error here
                return nil
            }
            // Handle successful result here
            let result = task.result!
            let responseString = String(data: result.responseData!, encoding: .utf8)
            let data = responseString!.data(using: .utf8)!
            do {
                let resultObj = try JSONSerialization.jsonObject(with: data, options : .allowFragments)
                DispatchQueue.main.async {
                    
                    //print(resultObj)
                    if let json = resultObj as? [String: Any] {
                        print(json)
                        if (json["status"]as? Int == 0){
                            //print(json["message"] ?? "")
                            let profile_data = json["profile_data"] as? [String:Any] ?? [:]
                                self.txtEmail.text = UserDefaults.standard.string(forKey: "user_email");
                                
                            self.txtFirstName.text = profile_data["user_first_name"] as? String
                            self.txtLastName.text = profile_data["user_last_name"]as? String
                            self.txtPhone.text = profile_data["user_phone_number"]as? String
                                
                            let strURL = profile_data["profie_pic"]as? String ?? ""
                                if let url = URL(string: strURL){
                                      self.downloadImage(from: url as URL, imageView: self.imgProfilePic)
                                }else{
                                    self.viewActivity.isHidden = true
                                }
                                
                            

                        }else{
                            let strError = json["message"] as? String
                            //print(strError ?? "")
                            self.showAlert(strMsg: strError ?? "")
                            self.viewActivity.isHidden = true
                        }
                        
                    }
                }
                
            } catch let error as NSError {
                //print(error)
                self.showAlert(strMsg: error.localizedDescription)
            }
            return nil
        }
    }
    // MARK: Handler for performerEvents API, using for upcoming schedules
    func setProfile(){
        let netAvailable = appDelegate.isConnectedToInternet()
        if(!netAvailable){
            showAlert(strMsg: "Please check your internet connection!")
            return
        }
       viewActivity.isHidden = false
        let firstName = txtFirstName.text!.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        let lastName = txtLastName.text!.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        let phone = txtPhone.text!.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        
        let httpMethodName = "POST"
        let URLString: String = "/setProfile"
        let user_id = UserDefaults.standard.string(forKey: "user_id");
        let user_email = UserDefaults.standard.string(forKey: "user_email");
        
        let params: [String: Any] = ["user_id":user_id ?? "","user_first_name":firstName,"user_last_name":lastName,"user_phone_number":phone,"user_email":user_email!]
        print("params:",params)
        let headerParameters = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        // Construct the request object
        let apiRequest = AWSAPIGatewayRequest(httpMethod: httpMethodName,
                                              urlString: URLString,
                                              queryParameters: [:],
                                              headerParameters: headerParameters,
                                              httpBody: params)
        // Fetch the Cloud Logic client to be used for invocation
        let invocationClient = AreveaAPIClient.client(forKey:appDelegate.AWSCognitoIdentityPoolId)
        invocationClient.invoke(apiRequest).continueWith { (task: AWSTask) -> Any? in
            if let error = task.error {
                print("Error occurred: \(error)")
                self.showAlert(strMsg: error as? String ?? error.localizedDescription)
                // Handle error here
                return nil
            }
            // Handle successful result here
            let result = task.result!
            let responseString = String(data: result.responseData!, encoding: .utf8)
            let data = responseString!.data(using: .utf8)!
            do {
                let resultObj = try JSONSerialization.jsonObject(with: data, options : .allowFragments)
                DispatchQueue.main.async {
                    
                    //print(resultObj)
                    if let json = resultObj as? [String: Any] {
                        print(json)
                        if (json["status"]as? Int == 0){
                            //print(json["message"] ?? "")
                            self.showAlert(strMsg:"Profile updated successfully")
                            self.viewActivity.isHidden = true
                            self.navigationController?.popViewController(animated: true);
                            let fn = self.txtFirstName.text!
                            let ln = self.txtLastName.text!
                            let strName = String((fn.first)!) + String((ln.first)!)
                            self.appDelegate.USER_NAME = strName;
                            self.appDelegate.USER_NAME_FULL = fn + " " + ln
                            UserDefaults.standard.set(self.appDelegate.USER_NAME, forKey: "USER_NAME")
                            UserDefaults.standard.set(self.appDelegate.USER_NAME_FULL, forKey: "USER_NAME_FULL")
                        }else{
                            let strError = json["message"] as? String
                            //print(strError ?? "")
                            self.showAlert(strMsg: strError ?? "")
                            self.viewActivity.isHidden = true
                        }
                        
                    }
                }
                
            } catch let error as NSError {
                //print(error)
                self.showAlert(strMsg: error.localizedDescription)
            }
            return nil
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
    
    // MARK: Profile Pic Update Methods
    
    @IBAction func chooseProfilePic() {
        let actionsheet = UIAlertController(title: "Photo Source", message: "Choose A Source", preferredStyle: .actionSheet)
        actionsheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action:UIAlertAction)in
            if UIImagePickerController.isSourceTypeAvailable(.camera){
                self.imagePickerController.sourceType = .camera
                self.present(self.imagePickerController, animated: true, completion: nil)
            }else
            {
                print("Camera is Not Available")
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
        self.present(actionsheet,animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            print("didFinishPickingImage")
            self.btnUpload.isHidden = false
            imgProfilePic.contentMode = .scaleAspectFill
            imgProfilePic.image = pickedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func updateProfilePic(){
        let netAvailable = appDelegate.isConnectedToInternet()
        if(!netAvailable){
            showAlert(strMsg: "Please check your internet connection!")
            return
        }
        viewActivity.isHidden = false
        let url = "https://qa.arevea.tv/api/user/v1/uploadFile" /* your API url */
        //  let url = "https://eku2g4rzxl.execute-api.us-west-2.amazonaws.com/dev/uploadProfilePic" /* your API url */
        let headers: HTTPHeaders = [
            "Content-type": "multipart/form-data",
            appDelegate.securityKey: appDelegate.securityValue]
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
            print(response)
            switch response.result {
            case .success(let value):
                if let json = value as? [String: Any] {
                    print(json)
                    if (json["status"]as? Int == 0){
                        //print(json["message"] ?? "")
                        self.showAlert(strMsg:"Profile picture updated successfully")
                        self.viewActivity.isHidden = true
                        UserDefaults.standard.set("false", forKey: "is_profile_pic_loaded_left_menu")
                        
                    }else{
                        let strError = json["message"] as? String
                        //print(strError ?? "")
                        self.showAlert(strMsg: strError ?? "")
                        self.viewActivity.isHidden = true
                    }
                }
            case .failure(let error):
                //print(error)
                self.viewActivity.isHidden = true
                self.showAlert(strMsg: error.localizedDescription)
                
            }
        }
    }
}

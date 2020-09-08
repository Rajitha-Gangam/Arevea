//
//  PaymentVC.swift
//  AreveaTV
//
//  Created by apple on 4/24/20.
//  Copyright © 2020 apple. All rights reserved.
//

import UIKit
import Alamofire


class PaymentVC: UIViewController,UITextFieldDelegate {
    // MARK: Variables declaration
    
    @IBOutlet weak var lblAmount: UILabel!
    @IBOutlet weak var txtTipAmount: UITextField!
    @IBOutlet weak var txtNameOnCard:UITextField!
    @IBOutlet weak var txtCreditCardNo: UITextField!
    @IBOutlet weak var txtExpDate: UITextField!
    @IBOutlet weak var txtCVV: UITextField!
    
    @IBOutlet weak var txtAddress1: UITextField!
    @IBOutlet weak var txtAddress2:UITextField!
    @IBOutlet weak var txtCity: UITextField!
    @IBOutlet weak var txtState: UITextField!
    @IBOutlet weak var txtCountry: UITextField!
    @IBOutlet weak var txtZip: UITextField!
    
    @IBOutlet weak var viewTip: UIView!
    @IBOutlet weak var viewOrderDetails: UIView!
    @IBOutlet weak var lblTier: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var btnUserName: UIButton!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var details = ""
    var orgId = 0;
    var performerId = 0;
    var charityId = 0;
    var streamId = 0;
    @IBOutlet weak var viewActivity: UIView!
    
    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        viewActivity.isHidden = true
        var isShowUserInput = true
        if(details == "subscription_plan" ||  details == "pay_per_view" ){
            isShowUserInput = false
        }
        if (isShowUserInput){
            viewTip.isHidden = false;
            viewOrderDetails.isHidden = true;
        }else{
            viewTip.isHidden = true;
            viewOrderDetails.isHidden = false;
            let strAmount = UserDefaults.standard.string(forKey: "plan_amount");
            lblAmount.text = "$" + strAmount!;
            // let strPlan = UserDefaults.standard.string(forKey: "plan");
            //lblTier.text = strPlan!;
            lblTier.text = "Pay Per View";
        }
        addDoneButton()
        let netAvailable = appDelegate.isConnectedToInternet()
        if(!netAvailable){
            showAlert(strMsg: "Please check your internet connection!")
            return
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        self.btnUserName.setTitle(appDelegate.USER_NAME, for: .normal)
        AppDelegate.AppUtility.lockOrientation(.portrait)

    }
    func addDoneButton() {
        let toolbar =  UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 35))
        
        let flexButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action:#selector(resignKB(_:)))
        toolbar.setItems([flexButton, doneButton], animated: true)
        toolbar.sizeToFit()
        txtTipAmount.inputAccessoryView = toolbar;
        txtNameOnCard.inputAccessoryView = toolbar;
        txtCreditCardNo.inputAccessoryView = toolbar;
        txtExpDate.inputAccessoryView = toolbar;
        txtCVV.inputAccessoryView = toolbar;
        txtAddress1.inputAccessoryView = toolbar;
        txtAddress2.inputAccessoryView = toolbar;
        txtCity.inputAccessoryView = toolbar;
        txtState.inputAccessoryView = toolbar;
        txtCountry.inputAccessoryView = toolbar;
        txtZip.inputAccessoryView = toolbar;
        
        let datePickerView = UIDatePicker()
        datePickerView.datePickerMode = .date
        datePickerView.minimumDate = Date()
        datePickerView.addTarget(self, action: #selector(handleChange(sender:)), for: .valueChanged)
        txtExpDate.inputView = datePickerView
        
    }
    @objc func handleChange(sender: UIDatePicker){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/yyyy"
        txtExpDate.text = dateFormatter.string(from: sender.date)
    }
    @IBAction func resignKB(_ sender: UIButton) {
        txtTipAmount.resignFirstResponder();
        txtNameOnCard.resignFirstResponder();
        txtCreditCardNo.resignFirstResponder();
        txtExpDate.resignFirstResponder();
        txtCVV.resignFirstResponder();
        txtAddress1.resignFirstResponder();
        txtAddress2.resignFirstResponder();
        txtCity.resignFirstResponder();
        txtState.resignFirstResponder();
        txtCountry.resignFirstResponder();
        txtZip.resignFirstResponder();
    }
    func showAlert(strMsg: String){
        let alert = UIAlertController(title: "Alert", message: strMsg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
    @IBAction func cancel(_ sender: UIButton) {
        resignKB(sender)
        self.navigationController?.popViewController(animated: true);
    }
    @IBAction func pay(_ sender: UIButton) {
        resignKB(sender)
        let netAvailable = appDelegate.isConnectedToInternet()
        if(!netAvailable){
            showAlert(strMsg: "Please check your internet connection!")
            return
        }
        
        var strAmount = "";
        var isShowUserInput = true
        if(details == "subscription_plan" ||  details == "pay_per_view" ){
            isShowUserInput = false
        }
        if (isShowUserInput){
            strAmount = txtTipAmount.text!;
        }else{
            let strAmount1 = UserDefaults.standard.string(forKey: "plan_amount");
            strAmount = strAmount1!
        }
        //3% processing fee we need to add
        let gst = (Int(strAmount)! * 3)/100
        let finalAmount = Int(strAmount)! + gst
        
        let strUsername = txtNameOnCard.text!
        let strCreditCardNum = txtCreditCardNo.text!
        let strExpDate = txtExpDate.text!
        let strCVV = txtCVV.text!
        let strAddress1 = txtAddress1.text!
        let strAddress2 = txtAddress2.text!
        let strCity = txtCity.text!
        let strState = txtState.text!
        let strCountry = txtCountry.text!
        let strZip = txtZip.text!
        
        
        if (strAmount.count == 0 && isShowUserInput){
            showAlert(strMsg: "Please enter tip amount");
            return
        }else if (strUsername.count == 0){
            showAlert(strMsg: "Please enter name on card");
            return
        }else if (strCreditCardNum.count == 0){
            showAlert(strMsg: "Please enter credit card number");
            return
        }else if (strCreditCardNum.count <= 14){
            showAlert(strMsg: "Please enter valid credit card number");
            return
        }else if (strExpDate.count == 0){
            showAlert(strMsg: "Please select exp date");
            return
        }
        else if (strCVV.count == 0){
            showAlert(strMsg: "Please enter cvv");
            return
        }else if (strAddress1.count == 0){
            showAlert(strMsg: "Please enter address line1");
            return
        }else if (strCity.count == 0){
            showAlert(strMsg: "Please enter city name");
            return
        }else if (strState.count == 0){
            showAlert(strMsg: "Please enter state name");
            return
        }else if (strCountry.count == 0){
            showAlert(strMsg: "Please enter country name");
            return
        }else if (strZip.count == 0){
            showAlert(strMsg: "Please enter zip code");
            return
        }else{
            let expDate = strExpDate.components(separatedBy: "/")
            let month = expDate[0];
            let year = expDate[1];
            var paymentType = ""
            if(details == "subscription_plan"){
                paymentType = "user_app_subscription"
            }
            else if(details == "donation"){
                paymentType = "charity_donation"
            }else if(details == "tip"){
                paymentType = "performer_tip"
            }else if(details == "pay_per_view"){
                paymentType = "pay_per_view"
            }
            //paymentType -> user_app_subscription for subscription,subscription_id
            //paymentType -> performer_tip for tip,performer_id
            
            //var paymentTypes = ['channel_subscription', 'pay_per_view', 'performer_tip', 'charity_donation', 'performer_app_subscription', 'user_app_subscription'];
            
            var params =
                ["paymentType": paymentType,
                 "organization_id":self.orgId,
                 "performer_id":self.performerId,
                 "currency": "USD",
                 "amount": strAmount,
                 "finalAmount": finalAmount,
                 "nameOnCard":strUsername,
                 "card": ["cardNumber": strCreditCardNum, "month": month, "year": year, "cvv": strCVV],
                 "billingAddress": [
                    "street1": strAddress1, "street2": strAddress2, "city":strCity, "state": strState, "zip": strZip,
                    "country": strCountry
                    ]] as [String : Any];
            if(details == "donation"){
                params["charity_id"] = self.charityId
            }else if(details == "pay_per_view"){
                params["stream_id"] = self.streamId
            }else if(details == "subscription_plan"){
                //params["subscription_id"] = self.subscriptionID
            }
            let inputData = ["paymentInfo":params]
            makePayment(params: inputData);
        }
    }
    // MARK: Handler for makePayment API
    
    func makePayment(params:[String:Any]){
        let url = appDelegate.paymentBaseURL + "/makePayment"
        let params = params;
        //print("params:",params)
        let session_token = UserDefaults.standard.string(forKey: "session_token") ?? ""
        let headers: HTTPHeaders = [
            "Authorization": "Bearer " + session_token,
            "Accept": "application/json"
        ]
        viewActivity.isHidden = false
        AF.request(url, method: .post,  parameters: params,encoding: JSONEncoding.default, headers: headers)
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any] {
                        if (json["status"]as? Int == 0){
                            self.viewActivity.isHidden = true
                            ////print(json["message"] as? String ?? "")
                            self.showAlert(strMsg: "Paid amount successfully")
                            if(self.details == "pay_per_view"){
                                self.appDelegate.isLiveLoad = "1"
                            }
                            self.navigationController?.popViewController(animated: true)
                        }else{
                            let strError = json["message"] as? String
                            ////print(strError ?? "")
                            self.showAlert(strMsg: strError ?? "")
                            self.viewActivity.isHidden = true
                        }
                    }
                case .failure(let error):
                  let errorDesc = error.localizedDescription.replacingOccurrences(of: "URLSessionTask failed with error:", with: "")
                   self.showAlert(strMsg: errorDesc)
                           self.viewActivity.isHidden = true

                }
        }
    }
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true);
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent // .default
    }
    // MARK: Text Field Delegate Methods
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if (textField==txtAddress1 || textField==txtAddress2 || textField==txtCity || textField==txtState || textField==txtCountry || textField==txtZip){
            self.animateTextField(textField: textField, up:true)
        }
        
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if (textField==txtAddress1 || textField==txtAddress2 || textField==txtCity || textField==txtState || textField==txtCountry || textField==txtZip){
            self.animateTextField(textField: textField, up:false)
        }
        textField.resignFirstResponder();
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder();
        return true;
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (textField == txtCVV){
            let maxLength = 4
            let currentString: NSString = textField.text! as NSString
            let newString: NSString =
                currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= maxLength
        }else if (textField == txtCreditCardNo) {
            return formatCardNumber(textField: textField, shouldChangeCharactersInRange: range, replacementString: string)
        }
        return true;
    }
    // MARK: Keyboard  Delegate Methods
    
    func animateTextField(textField: UITextField, up: Bool)
    {
        let movementDistance:CGFloat = -230
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
    
    func formatCardNumber(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if textField == txtCreditCardNo {
            let replacementStringIsLegal = string.rangeOfCharacter(from: NSCharacterSet(charactersIn: "0123456789").inverted) == nil
            
            if !replacementStringIsLegal {
                return false
            }
            
            let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
            let components = newString.components(separatedBy: NSCharacterSet(charactersIn: "0123456789").inverted)
            let decimalString = components.joined(separator: "") as NSString
            let length = decimalString.length
            let hasLeadingOne = length > 0 && decimalString.character(at: 0) == (1 as unichar)
            
            if length == 0 || (length > 16 && !hasLeadingOne) || length > 19 {
                let newLength = (textField.text! as NSString).length + (string as NSString).length - range.length as Int
                
                return (newLength > 16) ? false : true
            }
            var index = 0 as Int
            let formattedString = NSMutableString()
            
            if hasLeadingOne {
                formattedString.append("1 ")
                index += 1
            }
            if length - index > 4 {
                let prefix = decimalString.substring(with: NSRange(location: index, length: 4))
                formattedString.appendFormat("%@ ", prefix)
                index += 4
            }
            
            if length - index > 4 {
                let prefix = decimalString.substring(with: NSRange(location: index, length: 4))
                formattedString.appendFormat("%@ ", prefix)
                index += 4
            }
            if length - index > 4 {
                let prefix = decimalString.substring(with: NSRange(location: index, length: 4))
                formattedString.appendFormat("%@ ", prefix)
                index += 4
            }
            
            let remainder = decimalString.substring(from: index)
            formattedString.append(remainder)
            textField.text = formattedString as String
            return false
        } else {
            return true
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        AppDelegate.AppUtility.lockOrientation(.all)
    }
    
   

}

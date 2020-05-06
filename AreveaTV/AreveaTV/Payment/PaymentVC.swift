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

    var isTip = false;
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        if (isTip){
            viewTip.isHidden = false;
            viewOrderDetails.isHidden = true;
        }else{
            viewTip.isHidden = true;
            viewOrderDetails.isHidden = false;
            let strAmount = UserDefaults.standard.string(forKey: "plan_amount");
            lblAmount.text = "$" + strAmount!;
            let strPlan = UserDefaults.standard.string(forKey: "plan");
            lblTier.text = strPlan!;

        }
        addDoneButton()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        self.btnUserName.setTitle(appDelegate.USER_NAME, for: .normal)
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
        var strAmount = "";
        if (isTip){
            strAmount = txtTipAmount.text!;
        }else{
           strAmount = UserDefaults.standard.value(forKey: "plan_amount") as! String;
        }
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

        
        if (strAmount.count == 0 && isTip){
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
            //paymentType -> user_app_subscription for subscription,subscription_id
            //paymentType -> performer_tip for tip,performer_id
            let params = {
                ["paymentType":"user_app_subscription",
                 "organization_id":1,
                 "currency": "USD",
                 "amount": strAmount,
                 "finalAmount": strAmount,
                 "nameOnCard":strUsername,
                 "subscription_id": "",
                 "card": ["cardNumber": strCreditCardNum,"month": month, "year": year],
                 "bank": ["nameOnAccount": strUsername, "routingNumber": "", "accountNumber": "", "accountType": ""],
                 "billingAddress": [
                    "street1": strAddress1, "city":strCity, "state": strState, "zip": strZip,
                    "country": strCountry
                    ]]};
            makePayment(params: params());
            
        }
    }
    // MARK: Handler for makePayment API

    func makePayment(params:[String:Any]){
        let url: String = appDelegate.baseURL +  "/makePayment"
        let params = params;
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        AF.request(url, method: .post,  parameters: params, encoding: JSONEncoding.default)
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any] {
                        if (json["status"]as? Int == 0){
                            self.activityIndicator.isHidden = true;
                            self.activityIndicator.stopAnimating();
                            print(json["message"] as? String ?? "")
                            self.showAlert(strMsg: "Paid amount successfully")
                            self.navigationController?.popViewController(animated: true)
                        }else{
                            let strError = json["message"] as? String
                            print(strError ?? "")
                            self.showAlert(strMsg: strError ?? "")
                            self.activityIndicator.isHidden = true;
                            self.activityIndicator.stopAnimating();
                        }
                        
                    }
                case .failure(let error):
                    print(error)
                    self.showAlert(strMsg: error.localizedDescription)
                    self.activityIndicator.isHidden = true;
                    self.activityIndicator.stopAnimating();
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
}

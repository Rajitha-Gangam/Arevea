//
//  OrderSummaryVC.swift
//  AreveaTV
//
//  Created by apple on 3/4/21.
//  Copyright © 2021 apple. All rights reserved.
//

import UIKit
import Alamofire

class OrderSummaryVC: UIViewController , OpenChanannelChatDelegate, UITextFieldDelegate {
    @IBOutlet weak var viewActivity: UIView!
    @IBOutlet weak var heightTopView: NSLayoutConstraint?
    @IBOutlet weak var viewTop: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblTicketName: UILabel!
    @IBOutlet weak var txtPromoCode: ACFloatingTextfield!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblDiscount: UILabel!
    @IBOutlet weak var lblTotal: UILabel!
    @IBOutlet weak var btnClear: UIButton!
    @IBOutlet weak var btnApply: UIButton!
    @IBOutlet weak var lblDiscountTitle: UILabel!
    @IBOutlet weak var lblTotalTitle: UILabel!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var strTicketIDs = ""
    var strTicketName = ""
    var strPrice = ""
    var questionsObj = [Int:Any]()

    weak var chatDelegate: OpenChanannelChatDelegate?
    var discountApplied = false
    var strPromoCode = ""
    @IBOutlet weak var heightOrderView: NSLayoutConstraint!
    @IBOutlet weak var viewOrder: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        lblTitle.text = "   " + appDelegate.strTitle
        lblTicketName.text = strTicketName
        lblPrice.text = strPrice
        
        self.btnApply.isHidden = false
        
        self.btnClear.isHidden = true
        self.lblDiscount.isHidden = true
        self.lblDiscountTitle.isHidden = true
        self.lblTotal.isHidden = true
        self.lblTotalTitle.isHidden = true
        btnClear.layer.borderColor = UIColor.lightGray.cgColor
        // Do any additional setup after loading the view.
        heightOrderView.constant = 150
        viewOrder.layoutIfNeeded()
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    @IBAction func clearTap(_ sender: Any) {
        print("clear")
        txtPromoCode.text = ""
        self.btnApply.isHidden = false
        self.btnClear.isHidden = true
        self.lblDiscount.isHidden = true
        self.lblDiscountTitle.isHidden = true
        self.lblTotal.isHidden = true
        self.lblTotalTitle.isHidden = true
        self.discountApplied = false
        self.txtPromoCode.isEnabled = true
        heightOrderView.constant = 150
        viewOrder.layoutIfNeeded()
    }
    @IBAction func applyTap(_ sender: Any) {
        print("apply")
        verifyCode()
    }
    
    
    @IBAction func placeOrderTap(_ sender: Any) {
        print("placeOrder")
        //let url: String = appDelegate.baseURL +  "/proceedToPayment"
        //var user_id
        let user_id = UserDefaults.standard.string(forKey: "user_id");
        let strUserId = user_id ?? "1"
        let session_token = UserDefaults.standard.string(forKey: "session_token") ?? ""
        print("questionsObj:",questionsObj)
        let isQuestionEmpty = questionsObj.isEmpty
        //  https://dev1.arevea.com/payment/pay_per_view?stream_id=6490&ticket_ids=228&questions=%7B%22148%22:%2250%22,%22147%22:%22yes%22%7D&user_id=117308200
        
        var queryString = "stream_id=" + String(appDelegate.streamId) + "&user_id=" + strUserId + strTicketIDs
        if(!isQuestionEmpty){
            queryString = queryString + "&questions=" + "\(questionsObj)"
        }
        if(appDelegate.isGuest){
            queryString = queryString + "&is_guest=1" + "&token=" + session_token
        }
        if(discountApplied){
            queryString = queryString + "&discount_code=" + strPromoCode
        }
        queryString = queryString.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed) ?? ""
        
        let urlOpen = appDelegate.paymentRedirectionURL + "/" + "pay_per_view" + "?" + queryString
        print("urlOpen:",urlOpen)
        
        guard let url = URL(string: urlOpen) else { return }
        UIApplication.shared.open(url)
        
        
    }
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //currentResponder = textField
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder();
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder();
        return true;
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let textFieldText: NSString = (textField.text ?? "") as NSString
        let txtAfterUpdate = textFieldText.replacingCharacters(in: range, with: string)
        
        return true
    }
    func showAlert(strMsg: String){
        let alert = UIAlertController(title: "Alert", message: strMsg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
    func verifyCode(){
        strPromoCode = txtPromoCode.text!.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        if (strPromoCode.count == 0){
            showAlert(strMsg: "Please enter promo code");
            return
        }
        
        let netAvailable = appDelegate.isConnectedToInternet()
        if(!netAvailable){
            showAlert(strMsg: "Please check your internet connection!")
            return
        }
        viewActivity.isHidden = false
        let url: String = appDelegate.baseURL +  "/verifyCode"
        var streamIdLocal = "0"
        if (appDelegate.streamId != 0){
            streamIdLocal = String(appDelegate.streamId)
        }
        
        let params: [String: Any] = ["stream_id": streamIdLocal,"code":strPromoCode]
        
        //print("getQuestionsByEventId url:",url)
        let headers: HTTPHeaders
        headers = [appDelegate.x_api_key: appDelegate.x_api_value]
        AF.request(url, method: .post,parameters: params, encoding: JSONEncoding.default,headers:headers)
            .responseJSON { response in
                self.viewActivity.isHidden = true
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any] {
                        print("verifyCode JSON:",json)
                        if (json["statusCode"]as? String == "200" ){
                            let strMsg = json["message"] as? String ?? ""
                            let data = json["Data"] as? [Any] ?? [Any]()
                            if (data.count == 0){
                                self.showAlert(strMsg: strMsg)
                            }else{
                                
                                var discountPer = "0.00"
                                
                                if(data.count > 0){
                                    let object = data[0] as? [String:Any] ?? [:]
                                    //for referral code it should not work, so handling like this
                                    let referrer = object["referrer"] as? String ?? ""
                                    if(referrer != ""){
                                        self.showAlert(strMsg: "Invalid code")
                                        return
                                    }
                                    self.txtPromoCode.isEnabled = false
                                    self.btnApply.isHidden = true
                                    self.btnClear.isHidden = false
                                    self.lblDiscount.isHidden = false
                                    self.lblDiscountTitle.isHidden = false
                                    self.lblTotal.isHidden = false
                                    self.lblTotalTitle.isHidden = false
                                    
                                    if (object["discount"] as? Int) != nil {
                                        discountPer = String(object["discount"] as? Int ?? 0)
                                    }else if (object["discount"] as? String) != nil {
                                        discountPer = String(object["discount"] as? String ?? "0.00")
                                    }else if (object["discount"] as? Double) != nil {
                                        discountPer = String(object["discount"] as? Double ?? 0.00)
                                    }
                                }
                                let doubleDiscountPer = Double(discountPer) ?? 0.00
                                print("discountPer:",discountPer)
                                if(self.strPrice.count > 0){
                                    let symobol = self.strPrice[0]
                                    let actualPrice = self.strPrice.substring(fromIndex: 1) // returns "def"
                                    let amountDouble = Double(actualPrice) ?? 0.00
                                    let per = doubleDiscountPer/100.00
                                    print("per:",per)

                                    let discount = (amountDouble) * per
                                    let total = amountDouble - Double(discount)
                                    
                                    let totalAmount = String(format: "%.02f", total)
                                    
                                    let amountShown = symobol + totalAmount
                                    self.lblTotal.text = amountShown
                                    self.lblDiscount.text = symobol + String(format: "%.02f", Double(discount))
                                    self.lblDiscountTitle.text = "Discount Applied (" + discountPer + "%)"
                                    self.heightOrderView.constant = 300
                                    self.viewOrder.layoutIfNeeded()
                                    self.discountApplied = true
                                }
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
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent // .default
    }
    func gotoSchedule(){
        let vc = storyboard!.instantiateViewController(withIdentifier: "ScheduleVC") as! ScheduleVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true);
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name:UIApplication.didBecomeActiveNotification , object: nil)
        NotificationCenter.default.removeObserver(self)
    }
    @objc func applicationDidBecomeActive(notification: NSNotification) {
        // Application is back in the foreground
        print("====applicationDidBecomeActive TT")
        //if user comes from payment redirection, need to refresh stream/vod
        getEventBySlug()
    }
    func getEventBySlug() {
        let netAvailable = appDelegate.isConnectedToInternet()
        if(!netAvailable){
            showAlert(strMsg: "Please check your internet connection!")
            return
        }
        viewActivity.isHidden = false
        let url: String = appDelegate.baseURL +  "/getEventBySlug"
        let user_id = UserDefaults.standard.string(forKey: "user_id");
        var params: [String: Any] = ["slug":appDelegate.strSlug]
        if(!appDelegate.isGuest){
            // params["userid"] = user_id ?? ""
        }
        params["userid"] = user_id ?? ""
        
        //print("getEventBySlug params:",params)
        let headers: HTTPHeaders
        headers = [appDelegate.x_api_key: appDelegate.x_api_value]
        AF.request(url, method: .post,parameters: params, encoding: JSONEncoding.default,headers:headers)
            .responseJSON { response in
                self.viewActivity.isHidden = true
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any] {
                        //print("getEventBySlug JSON:",json)
                        if (json["statusCode"]as? String == "200" ){
                            let data = json["Data"] as? [String:Any]
                            let user_subscription_info =  data?["user_subscription_info"] as? [Any] ?? [Any]()
                            if (user_subscription_info.count > 0){
                                self.gotoSchedule()
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
}

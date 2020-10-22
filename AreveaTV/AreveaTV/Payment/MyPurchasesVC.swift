//
//  MyPurchasesVC.swift
//  AreveaTV
//
//  Created by apple on 7/27/20.
//  Copyright © 2020 apple. All rights reserved.
//

import UIKit
import Alamofire

class MyPurchasesVC: UIViewController , UITableViewDelegate,UITableViewDataSource{
    
    // MARK: Variables declaration
    @IBOutlet weak var tblView: UITableView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var viewActivity: UIView!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var aryPaymentInfo : [[String:Any]] = []
    @IBOutlet weak var heightTopView: NSLayoutConstraint?
    @IBOutlet weak var viewTop: UIView!
    @IBOutlet weak var lblNoData: UILabel!
    var selectedFilters = [String]();
    var isFilter = false
    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        viewActivity.isHidden = true
        // Do any additional setup after loading the view.
        tblView.register(UINib(nibName: "PaymentHistoryCell", bundle: nil), forCellReuseIdentifier: "PaymentHistoryCell")
        
        
        if(UIDevice.current.userInterfaceIdiom == .pad){
            heightTopView?.constant = 60;
            viewTop.layoutIfNeeded()
        }
        myList()
        
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    //MARK:Tableview Delegates and Datasource Methods
    
    func numberOfSections(in tableView: UITableView) ->  Int {
        return 1;
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (aryPaymentInfo.count > 0){
            lblNoData.isHidden = true;
        }else{
            lblNoData.isHidden = false;
        }
        return aryPaymentInfo.count;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) ->  CGFloat {
        return 150;
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblView.dequeueReusableCell(withIdentifier: "PaymentHistoryCell", for: indexPath) as! PaymentHistoryCell
        let charity  = self.aryPaymentInfo[indexPath.row]
        cell.lblDonatedToTitle.text = "PAID TO"
        cell.lblTypeOfDonationTitle.text = "TYPE OF PAYMENT"
        
        cell.lblDonatedTo.text = charity["stream_video_title"] as? String ?? ""
        cell.lblTypeOfDonation.text = "Pay Per View"
        let dateCreated = charity["created_on"] as? String ?? ""
        
        var currency_type = charity["currency_type"] as? String ?? ""
        if(currency_type == "GBP"){
            currency_type = "£"
        }else{
            currency_type = "$"
        }
        var amount = "0.0"
        
        if (charity["transaction_user_paid_amount"] as? Double) != nil {
            amount = String(charity["transaction_user_paid_amount"] as? Double ?? 0.0)
        }else if (charity["transaction_user_paid_amount"] as? String) != nil {
            amount = String(charity["transaction_user_paid_amount"] as? String ?? "0.0")
        }
        if(amount == "0.0"){
            cell.lblAmount.text = "Free"
        }else{
            cell.lblAmount.text = currency_type + amount
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = NSTimeZone(abbreviation: "UTC") as TimeZone?
        
        if let date = formatter.date(from: dateCreated) {
            let formatter1 = DateFormatter()
            formatter1.dateFormat = "dd MMM yyyy, hh:mm a"
            cell.lblDate.text = formatter1.string(from: date)
        }else{
            //print ("invalid date");
            cell.lblDate.text = "";
        }
        return cell
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true);
    }
    func showAlert(strMsg: String){
        let alert = UIAlertController(title: "Alert", message: strMsg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
    // MARK: Handler for myList(myList) API
    func myList(){
        let netAvailable = appDelegate.isConnectedToInternet()
        if(!netAvailable){
            showAlert(strMsg: "Please check your internet connection!")
            return
        }
              let appDelegate = UIApplication.shared.delegate as! AppDelegate
              let url: String = appDelegate.ol_lambda_url +  "/myList"
        let user_id = UserDefaults.standard.string(forKey: "user_id");
        let inputData: [String: Any] = ["userid":user_id ?? ""]
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
                              //print("myList JSON:",json)
                              if (json["statusCode"]as? String == "200" ){
                                self.aryPaymentInfo = json["Data"] as? [[String: Any]] ?? [[String:Any]]()
                                //print("Mylist count:",self.aryPaymentInfo.count)
                                self.tblView.reloadData()
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
    override func viewWillDisappear(_ animated: Bool) {
        AppDelegate.AppUtility.lockOrientation(.all)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        AppDelegate.AppUtility.lockOrientation(.portrait)
    }

}


//
//  PaymentHistoryVC.swift
//  AreveaTV
//
//  Created by apple on 5/18/20.
//  Copyright © 2020 apple. All rights reserved.
//

import UIKit

class PaymentHistoryVC: UIViewController, UITableViewDelegate,UITableViewDataSource{
    
    // MARK: Variables declaration
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var tblFilter: UITableView!
    @IBOutlet weak var viewFilter: UIView!
    
    @IBOutlet weak var btnFilter: UIButton!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var viewActivity: UIView!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var aryPaymentInfo : [[String:Any]] = []
    var aryFilterData : [[String:Any]] = []
    var aryFilter = ["Tips","Donations"]
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
        
        tblFilter.register(UINib(nibName: "CheckMarkCell", bundle: nil), forCellReuseIdentifier: "CheckMarkCell")
        
        if(UIDevice.current.userInterfaceIdiom == .pad){
            heightTopView?.constant = 60;
            viewTop.layoutIfNeeded()
        }
        userDonations()
        btnFilter.isHidden = true
        viewFilter.isHidden = true
        
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
        if(tableView == tblView){
            
            if (isFilter){
                if (aryFilterData.count > 0){
                    lblNoData.isHidden = true;
                }else{
                    lblNoData.isHidden = false;
                }
                return aryFilterData.count
            }else{
                if (aryPaymentInfo.count > 0){
                    lblNoData.isHidden = true;
                }else{
                    lblNoData.isHidden = false;
                }
                return aryPaymentInfo.count;
            }
        }
        else{
            return aryFilter.count;
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) ->  CGFloat {
        if(tableView == tblView){
            return 150;
        }else{
            return 50
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(tableView == tblView){
            let cell = tblView.dequeueReusableCell(withIdentifier: "PaymentHistoryCell", for: indexPath) as! PaymentHistoryCell
            var charity = [String:Any]()
            if (isFilter){
                charity = self.aryFilterData[indexPath.row]
            }else{
                charity = self.aryPaymentInfo[indexPath.row]
            }
            cell.lblDonatedTo.text = charity["name"] as? String ?? ""
            let donation_mode  = charity["donation_mode"] as? String ?? ""
            if (donation_mode == "charity_donation"){
                cell.lblTypeOfDonation.text = "Charity"
            }else  if (donation_mode == "performer_tip"){
                cell.lblTypeOfDonation.text = "Tip"
            }else{
                cell.lblTypeOfDonation.text = "Other"
                
            }
            let dateCreated = charity["created_on"] as? String ?? ""
            var amount = "0.0"
            
            if (charity["amount"] as? Double) != nil {
                amount = String(charity["amount"] as? Double ?? 0.0)
            }else if (charity["amount"] as? String) != nil {
                amount = String(charity["amount"] as? String ?? "0.0")
            }
            cell.lblAmount.text = amount
            
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
        }else{
            let cell:CheckMarkCell = self.tblFilter.dequeueReusableCell(withIdentifier: "CheckMarkCell") as! CheckMarkCell
            cell.lblTitle.text = aryFilter[indexPath.row]
            cell.imgCheck.tag = 10 + (indexPath.row)
            return cell
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if(tableView == tblFilter){
            
            let tag = 10 + (indexPath.row)
            let checkImg = tblFilter.viewWithTag(tag) as? UIImageView
            if ((checkImg?.image?.isEqual(UIImage.init(named: "check-icon.png")))!)
            {
                checkImg?.image = UIImage.init(named: "uncheck-icon.png")
                if(indexPath.row == 0){
                    selectedFilters.removeObject("0")
                }else{
                    selectedFilters.removeObject("1")
                }
            }
            else{
                checkImg?.image = UIImage.init(named: "check-icon.png")
                if(indexPath.row == 0){
                    selectedFilters.append("0")
                }else{
                    selectedFilters.append("1")
                }
                
            }
            print("selectedFilters:",selectedFilters)
        }
        
    }
    @IBAction func openFilter(_ sender: Any) {
        if(viewFilter.isHidden){
            viewFilter.isHidden = false
        }else{
            viewFilter.isHidden = true
        }
    }
    @IBAction func closeFilter(_ sender: Any) {
        viewFilter.isHidden = true
    }
    @IBAction func applyFilter(_ sender: Any) {
        viewFilter.isHidden = true
        if (selectedFilters.count == 1){
            isFilter = true
            var donation_mode = "charity_donation"
            if(selectedFilters[0] == "0"){
                donation_mode  = "performer_tip"
            }
            let predicate = NSPredicate(format:"donation_mode == %@", donation_mode)
            //let filteredArray = aryPaymentInfo1.filtered(using: predicate)
            aryFilterData = (self.aryPaymentInfo as NSArray).filtered(using: predicate) as! [[String:Any]]
            print("aryFilterData:",aryFilterData)
        }else{
            isFilter = false
        }
        tblView.reloadData()
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
    // MARK: Handler for userDonations API
    func userDonations(){
        let netAvailable = appDelegate.isConnectedToInternet()
        if(!netAvailable){
            showAlert(strMsg: "Please check your internet connection!")
            return
        }
        viewActivity.isHidden = false
        let httpMethodName = "POST"
        let URLString: String = "/userDonations"
        let user_id = UserDefaults.standard.string(forKey: "user_id");
        let params: [String: Any] = ["user_id":user_id ?? ""]
        
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
                //print("Error occurred: \(error)")
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
                    if let json = resultObj as? [String: Any] {
                        print("json:",json)
                        
                        self.viewActivity.isHidden = true
                        if (json["statusCode"]as? String == "200"){
                            ////print(json["message"] ?? "")
                            //  var paymentData = [Any]()
                            let paymentData = json["Data"] as? [[String: Any]] ?? [[String:Any]]()
                            self.aryPaymentInfo = paymentData
                            //self.aryPaymentInfo = paymentData;
                            if (self.aryPaymentInfo.count > 0){
                                self.btnFilter.isHidden = false
                            }else{
                                self.btnFilter.isHidden = true
                            }
                            self.btnFilter.isHidden = false
                            
                            self.tblView.reloadData()
                        }
                        else{
                            let strError = json["message"] as? String
                            ////print(strError ?? "")
                            self.showAlert(strMsg: strError ?? "")
                        }
                    }
                }
            }
            catch let error as NSError {
                ////print(error)
                self.showAlert(strMsg: error.localizedDescription)
                self.viewActivity.isHidden = true
                
            }
            return nil
        }
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent // .default
    }
}

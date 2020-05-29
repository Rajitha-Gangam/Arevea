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
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var viewActivity: UIView!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var aryPaymentInfo = [Any]()
    @IBOutlet weak var btnUserName: UIButton!
    @IBOutlet weak var lblNoData: UILabel!

    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        viewActivity.isHidden = true
        // Do any additional setup after loading the view.
        tblView.register(UINib(nibName: "PaymentHistoryCell", bundle: nil), forCellReuseIdentifier: "PaymentHistoryCell")
        userDonations()
        self.btnUserName.setTitle(appDelegate.USER_NAME, for: .normal)

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
        let charity = self.aryPaymentInfo[indexPath.row] as? [String : Any];
        cell.lblDonatedTo.text = charity?["name"] as? String ?? ""
        let donation_mode  = charity?["donation_mode"] as? String ?? ""
        if (donation_mode == "charity_donation"){
            cell.lblTypeOfDonation.text = "Charity"
        }else  if (donation_mode == "performer_tip"){
            cell.lblTypeOfDonation.text = "Tip"
        }else{
            cell.lblTypeOfDonation.text = "Other"
            
        }
        let dateCreated = charity?["created_on"] as? String ?? ""
        cell.lblAmount.text = "$" + String(charity?["amount"] as? Int ?? 0)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if let date = formatter.date(from: dateCreated) {
            let formatter1 = DateFormatter()
            formatter1.dateFormat = "dd MMM yyyy ,hh:mm a"
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
                        if (json["statusCode"]as? String == "200"){
                            ////print(json["message"] ?? "")
                            var paymentData = [Any]()
                            paymentData = json["Data"] as? [Any] ?? [Any]()
                            self.aryPaymentInfo = paymentData;
                            self.tblView.reloadData()
                            self.viewActivity.isHidden = true
                        }
                        else{
                            let strError = json["message"] as? String
                            ////print(strError ?? "")
                            self.showAlert(strMsg: strError ?? "")
                            self.viewActivity.isHidden = true
                        }
                    }
                }
            }
            catch let error as NSError {
                ////print(error)
                self.showAlert(strMsg: error.localizedDescription)
            }
            return nil
        }
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent // .default
    }
}

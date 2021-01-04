//
//  SubscribedChannelsVC.swift
//  AreveaTV
//
//  Created by apple on 12/2/20.
//  Copyright © 2020 apple. All rights reserved.
//

import UIKit
import Alamofire

class SubscribedChannelsVC: UIViewController ,UITableViewDataSource,UITableViewDelegate{
    @IBOutlet weak var viewActivity: UIView!
    @IBOutlet weak var heightTopView: NSLayoutConstraint?
    @IBOutlet weak var viewTop: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tblSubscriptions: UITableView!
    var arySubscriptions = [Any]();
    @IBOutlet weak var lblNoDataSubscriptions: UILabel!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var jsonCurrencyList = [String:Any]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tblSubscriptions.register(UINib(nibName: "SubscribedCell", bundle: nil), forCellReuseIdentifier: "SubscribedCell")
        if let path = Bundle.main.path(forResource: "currencies", ofType: "json") {
                    do {
                        let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                        let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                        if let jsonResult = jsonResult as? Dictionary<String, AnyObject>
                            {
                            // do stuff
                            jsonCurrencyList = jsonResult
                        }
                    } catch {
                        // handle error
                    }
                }


    }
    override func viewWillAppear(_ animated: Bool) {
        AppDelegate.AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
        lblNoDataSubscriptions.isHidden = true
        getUserSubscriptons()
    }
    
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true);
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
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            if (self.arySubscriptions.count > 0){
                lblNoDataSubscriptions.isHidden = true
            }else{
                lblNoDataSubscriptions.isHidden = false
            }
            return arySubscriptions.count;
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) ->  CGFloat {
            return 170;
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SubscribedCell") as! SubscribedCell
            cell.viewContent.layer.borderColor = UIColor.white.cgColor
            cell.viewContent.layer.borderWidth = 1.0
        cell.imgUser.layer.borderColor = UIColor.white.cgColor
        cell.imgUser.layer.borderWidth = 1.0
           // cell.btnSubscribe.addTarget(self, action: #selector(subscribeBtnPressed(_:)), for: .touchUpInside)
            let subscribeObj = self.arySubscriptions[indexPath.row] as? [String : Any] ?? [:];
        let plan_details = subscribeObj["plan_details"] as? [String : Any] ?? [:];
            let feature_details = plan_details["feature_details"] as? [Any] ?? [Any]() ;
            print("feature_details count:",feature_details.count)
            let tier_name = plan_details["tier_name"] as? String ?? ""
            let channel_name = subscribeObj["channel_name"] as? String ?? ""

            cell.lblTierName.text = tier_name
            cell.lblChannelName.text = channel_name

            let subscription_amount = subscribeObj["subscription_amount"] as? Double ?? 0.0
            print("subscription_amount:", subscription_amount)
            let amount = String(format: "%.02f", subscription_amount)
            print("amount:",amount)
            var currency_type = subscribeObj["currency"] as? String ?? ""
        
        let currencySymbol1 = jsonCurrencyList[currency_type] as? String
        let currencySymbol = currencySymbol1 ?? "$"

            let amountWithCurrencyType = currencySymbol + amount
            cell.lblAmount.text = amountWithCurrencyType
            let tier_amount_mode = plan_details["tier_amount_mode"] as? String ?? ""
            print("tier_amount_mode:",tier_amount_mode)
            cell.lblAmountMode.text = tier_amount_mode

            for (index,_) in feature_details.enumerated() {
                let feature_details = feature_details[index] as? [String : Any] ?? [:];
                if(index < 4){
                    switch index {
                    case 0:
                        cell.lbl1.text = feature_details["feature_name"] as? String ?? ""
                    case 1:
                        cell.lbl2.text = feature_details["feature_name"] as? String ?? ""
                    case 2:
                        cell.lbl3.text = feature_details["feature_name"] as? String ?? ""
                    case 3:
                        cell.lbl4.text = feature_details["feature_name"] as? String ?? ""
                    default:
                        print("default")
                    }
                }
            }
            return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let subObj = arySubscriptions[indexPath.row] as? [String: Any] ?? [:]
        let storyboard = UIStoryboard(name: "Main", bundle: nil);
        let vc = storyboard.instantiateViewController(withIdentifier: "ChannelDetailVC") as! ChannelDetailVC
        vc.orgId = subObj["organization_id"] as? Int ?? 0
        let channelName = subObj["channel_name"] as? String ?? ""
        vc.channel_name = channelName
        if (subObj["performer_id"] as? Int) != nil {
            vc.performerId = subObj["performer_id"] as! Int
        }
        else {
            vc.performerId = 1;
        }
        vc.strTitle = subObj["performer_display_name"] as? String ?? "Channel Details"
        vc.fromSubscribed = true
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    func showAlert(strMsg: String){
        let alert = UIAlertController(title: "Alert", message: strMsg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
    
    // MARK: Handler for getUserSubscriptons API
    func getUserSubscriptons(){
        let netAvailable = appDelegate.isConnectedToInternet()
        if(!netAvailable){
            showAlert(strMsg: "Please check your internet connection!")
            return
        }
        viewActivity.isHidden = false
        let url: String = appDelegate.FCMBaseURL +  "/getUserSubscriptons"
        let user_id = UserDefaults.standard.string(forKey: "user_id");
        let params: [String: Any] = ["user_id":user_id ?? ""]
        //print("getUserSubscriptons params:",params)
        let headers: HTTPHeaders
        headers = [appDelegate.x_api_key: appDelegate.x_api_value]
        AF.request(url, method: .post,parameters: params, encoding: JSONEncoding.default,headers:headers)
            .responseJSON { response in
                self.viewActivity.isHidden = true
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any] {
                        print("getUserSubscriptons JSON:",json)
                        if (json["statusCode"]as? String == "200"){
                            self.lblNoDataSubscriptions.text = "No subscriptions found"
                            self.arySubscriptions = json["Data"] as? [Any] ?? [Any]()
                            self.tblSubscriptions.reloadData()
                        }else{
                            let strError = json["message"] as? String
                            ////print("strError1:",strError ?? "")
                            self.showAlert(strMsg: strError ?? "")
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
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        AppDelegate.AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
    }
}

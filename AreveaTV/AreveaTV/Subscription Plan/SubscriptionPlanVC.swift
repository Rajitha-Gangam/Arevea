//
//  SubscriptionPlanVC.swift
//  AreveaTV
//
//  Created by apple on 4/24/20.
//  Copyright © 2020 apple. All rights reserved.
//

import UIKit
import Alamofire
extension StringProtocol {
    var firstUppercased: String { return prefix(1).uppercased() + dropFirst() }
    var firstCapitalized: String { return prefix(1).capitalized + dropFirst() }
}
class SubscriptionPlanVC: UIViewController {
    var arySubscriptionsData = [Any]();
    @IBOutlet weak var txtTier1Desc: UITextView!
    @IBOutlet weak var txtTier2Desc: UITextView!
    @IBOutlet weak var lblTier1: UILabel!
    @IBOutlet weak var lblTier2: UILabel!
    @IBOutlet weak var lblTier1Amount: UILabel!
    @IBOutlet weak var lblTier2Amount: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var comingfrom = "";
    var planID = 0;
    var tier1Amount = 0;
    var tier2Amount = 0;
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        if (comingfrom == ""){
            //if user comes from sign in(when tap on signup) details subscription
            //before sign up we need to call standard/premium plans
            lblTier1.text = "Standard";
            lblTier2.text = "Premium";
            getSubscriptionPlans()
        }else{
            //if suer comes from channel details subscription
            //after signin need to call tier plans
            lblTier1.text = "Tier - 1";
            lblTier2.text = "Tier - 2";
            getOrganizationSubscription()
        }
    }
    // MARK: Handler for getSubscriptionPlans API,before signup
    
    func getSubscriptionPlans() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let url: String = appDelegate.baseURL +  "/getSubscriptionPlans"
        let params: [String: Any] = ["plan_type": "user"]
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
                            self.arySubscriptionsData = json["subscription_plan"] as? [Any] ?? [Any]();
                            if (self.arySubscriptionsData.count > 0){
                                let dic = self.arySubscriptionsData[0] as? [String:Any];
                                let aryFeatureList = dic?["feature_details"] as? [Any] ?? [Any]();
                                //                                self.tier1Amount = dic["tier_base_amount"] as? Int;
                                //                                self.lblTier1.text = "$\(self.tier1Amount)";

                                self.planID = dic?["id"] as? Int ?? 0;
                                self.lblTier1Amount.text = "$0";
                                var strPrem1 = "";
                                for item in aryFeatureList{
                                    let item1 = item as! [String:Any];
                                    let strFeauture = item1["feature_name"] as! String
                                    strPrem1 += strFeauture + "\n\n";
                                }
                                self.txtTier1Desc.text = strPrem1.lowercased();
                            }
                            else{
                                self.txtTier1Desc.text = "";
                            }
                            if (self.arySubscriptionsData.count > 1){
                                let dic = self.arySubscriptionsData[1] as? [String:Any];
                                self.planID = dic?["id"] as? Int ?? 0;
                                let aryFeatureList = dic?["feature_details"] as? [Any] ?? [Any]();
                                //                                self.tier2Amount = dic["tier_base_amount"] as? Int;
                                //                                self.lblTier2.text = "$\(self.tier2Amount)";
                                self.lblTier2Amount.text = "$10";
                                var strPrem1 = "";
                                for item in aryFeatureList{
                                    let item1 = item as! [String:Any];
                                    //NSLog("==14: item1:%@",item1 )
                                    let strFeauture = item1["feature_name"] as! String;
                                    strPrem1 += strFeauture + "\n\n";
                                }
                                self.txtTier2Desc.text = strPrem1.lowercased();
                            }else{
                                self.txtTier2Desc.text = "";
                            }
                            
                        }else{
                            let strError = json["message"] as? String
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
    // MARK: Handler for getSubscriptionPlans API,from video details page
    
    func getOrganizationSubscription() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let url: String = appDelegate.baseURL +  "/getOrganizationSubscription"
        let params: [String: Any] = ["organization_id": 1]
        
        AF.request(url, method: .post,  parameters: params, encoding: JSONEncoding.default)
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any] {
                        if (json["status"]as? Int == 0){
                            print(json["message"] as? String ?? "")
                            self.arySubscriptionsData = json["subscriptionsData"] as? [Any] ?? [Any]();
                            NSLog("plans count:%d", self.arySubscriptionsData.count);
                            if (self.arySubscriptionsData.count > 0){
                                let dic = self.arySubscriptionsData[0] as? [String:Any];
                                
                                let aryFeatureList = dic?["feature_details"] as? [Any] ?? [Any]();
                                self.tier1Amount = dic?["tier_base_amount"] as? Int ?? 0;
                                self.lblTier1Amount.text = "$\(self.tier1Amount)";
                                var strPrem1 = "";
                                for item in aryFeatureList{
                                    let item1 = item as! [String:Any];
                                    let strFeauture = item1["feature_name"] as! String;
                                    strPrem1 += strFeauture  + "\n\n";
                                }
                                self.txtTier1Desc.text = strPrem1.lowercased();
                            }
                            else{
                                self.txtTier1Desc.text = "";
                            }
                            if (self.arySubscriptionsData.count > 1){
                                let dic = self.arySubscriptionsData[1] as? [String:Any];
                                
                                let aryFeatureList = dic?["feature_details"] as? [Any] ?? [Any]();
                                self.tier2Amount = dic?["tier_base_amount"] as? Int ?? 0;
                                self.lblTier2Amount.text = "$\(self.tier2Amount)";
                                var strPrem1 = "";
                                for item in aryFeatureList{
                                    let item1 = item as! [String:Any];
                                    let strFeauture = item1["feature_name"] as! String;
                                    strPrem1 += strFeauture + "\n\n";
                                }
                                
                                self.txtTier2Desc.text = strPrem1.lowercased();
                            }else{
                                self.txtTier2Desc.text = "";
                            }
                            
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
    @IBAction func trailPlan(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil);
        let vc = storyboard.instantiateViewController(withIdentifier: "SignUpVC") as! SignUpVC
        vc.planID = String(self.planID);
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func selectPlan(_ sender: UIButton) {
        
        //NSLog("Tag:%d",sender.tag);
        //if tag 10- standard
        //if tag 20- Premium
        
        if (sender.tag == 10){
            if(comingfrom == ""){
                UserDefaults.standard.set("Standard Plan", forKey: "plan")
                let storyboard = UIStoryboard(name: "Main", bundle: nil);
                let vc = storyboard.instantiateViewController(withIdentifier: "SignUpVC") as! SignUpVC
                self.navigationController?.pushViewController(vc, animated: true)
            }else{
                UserDefaults.standard.set("Tier - 1 Plan", forKey: "plan");
                UserDefaults.standard.set(self.tier1Amount, forKey: "plan_amount");
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil);
                let vc = storyboard.instantiateViewController(withIdentifier: "PaymentVC") as! PaymentVC
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }else
        {
            if(comingfrom == ""){
                UserDefaults.standard.set("Premium Plan", forKey: "plan");
                showAlert(strMsg: "This plan is coming soon, Please try standard plan");
            }else{
                UserDefaults.standard.set("Tier - 2 Plan", forKey: "plan");
                UserDefaults.standard.set(self.tier2Amount, forKey: "plan_amount")
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil);
                let vc = storyboard.instantiateViewController(withIdentifier: "PaymentVC") as! PaymentVC
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    func showAlert(strMsg: String){
        let alert = UIAlertController(title: "Alert", message: strMsg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true);
        
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent // .default
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}

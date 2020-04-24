//
//  SubscriptionPlanVC.swift
//  AreveaTV
//
//  Created by apple on 4/24/20.
//  Copyright © 2020 apple. All rights reserved.
//

import UIKit
import Alamofire

class SubscriptionPlanVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        getSubscriptionPlans();
    }
    func getSubscriptionPlans(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let url: String = appDelegate.baseURL +  "/getSubscriptionPlans"
        let params: [String: Any] = ["plan_type": "user"]
        
      AF.request(url, method: .post,  parameters: params, encoding: JSONEncoding.default)
           .responseJSON { response in
               switch response.result {
               case .success(let value):
                   if let json = value as? [String: Any] {
                       print(json["message"] as! String)
                    
                   }
               case .failure(let error):
                   print(error)
               }
       }
    }
    @IBAction func selectPlan(_ sender: UIButton) {
        
        //NSLog("Tag:%d",sender.tag);
        //if tag 10- standard
        //if tag 20- Premium
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if (sender.tag == 10){
            appDelegate.plan = "standard";
        }else
        {
            appDelegate.plan = "premium";
        }
        let storyboard = UIStoryboard(name: "Main", bundle: nil);
        let vc = storyboard.instantiateViewController(withIdentifier: "PaymentVC") as! PaymentVC
        self.navigationController?.pushViewController(vc, animated: true)
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

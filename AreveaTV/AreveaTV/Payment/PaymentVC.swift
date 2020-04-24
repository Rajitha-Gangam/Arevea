//
//  PaymentVC.swift
//  AreveaTV
//
//  Created by apple on 4/24/20.
//  Copyright © 2020 apple. All rights reserved.
//

import UIKit

class PaymentVC: UIViewController {
    @IBOutlet weak var lblAmount: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if (appDelegate.plan == "premium"){
            lblAmount.text = "$9.99"
        }else{
            lblAmount.text = "$5.99"
        }
    }
    @IBAction func pay(_ sender: UIButton) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil);
        let vc = storyboard.instantiateViewController(withIdentifier: "DashBoardVC") as! DashBoardVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true);
        
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent // .default
    }
    
}

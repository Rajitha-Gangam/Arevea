//
//  MultiStreamVC.swift
//  AreveaTV
//
//  Created by apple on 7/16/20.
//  Copyright © 2020 apple. All rights reserved.
//

import UIKit
import Alamofire
import AWSAppSync

class MultiStreamVC: UIViewController {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var backPressed = false
    var appSyncClient: AWSAppSyncClient?
    @IBOutlet weak var heightTopView: NSLayoutConstraint?
    @IBOutlet weak var viewTop: UIView!
    weak var delegate: OpenChanannelChatDelegate?
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var viewActivity: UIView!
    
    var orgId = 0;
    var performerId = 0;
    var streamId = 0;
    var strTitle = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        appSyncClient = appDelegate.appSyncClient
        getGuestDetailInGraphql(.returnCacheDataAndFetch)
        lblTitle.text = strTitle
        viewActivity.isHidden = true

        
    }
    func getGuestDetailInGraphql(_ cachePolicy: CachePolicy) {
        
        let listQuery = GetMulticreatorshareddataQuery(id: "58_1594894849561_multi_creator_test_event")
        
        appSyncClient?.fetch(query: listQuery, cachePolicy: cachePolicy) { result, error in
            
            if let error = error {
                print("Error fetching data: \(error)")
                return
            }
            print("--result:",result)
            if((result != nil)  && (result?.data != nil)){
                print("--data:",result?.data)
                var data = result?.data
                if((data?.getMulticreatorshareddata) != nil){
                    print("--data2:",data?.getMulticreatorshareddata)
                }else{
                    print("--getMulticreatorshareddata null")
                }
                
            }
            // Remove existing records if we're either loading from cache, or loading fresh (e.g., from a refresh)
        }
    }
    @IBAction func payTip(_ sender: Any) {
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true);
        backPressed = false
        
    }
    @IBAction func back(_ sender: Any) {
        if (!backPressed){
            backPressed = true
            self.navigationController?.popViewController(animated: true)
        }
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

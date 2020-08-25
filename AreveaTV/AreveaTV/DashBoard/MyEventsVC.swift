//
//  MyEventsVC.swift
//  AreveaTV
//
//  Created by apple on 7/21/20.
//  Copyright © 2020 apple. All rights reserved.
//

import UIKit
import Alamofire

class MyEventsVC: UIViewController,OpenChanannelChatDelegate,UITableViewDelegate,UITableViewDataSource, CollectionViewCellDelegateMyEvents {
    
    
    @IBOutlet weak var tblMain: UITableView!
    @IBOutlet weak var lblNoData: UILabel!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var aryMyListData = [Any]();
    @IBOutlet weak var viewActivity: UIView!
    @IBOutlet weak var heightTopView: NSLayoutConstraint?
    @IBOutlet weak var viewTop: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewActivity.isHidden = true
        tblMain.register(UINib(nibName: "MyEventsCell", bundle: nil), forCellReuseIdentifier: "MyEventsCell")
        lblNoData.isHidden = true;
        
        // Do any additional setup after loading the view.
        if(UIDevice.current.userInterfaceIdiom == .pad){
            heightTopView?.constant = 60;
            viewTop.layoutIfNeeded()
        }
        tblMain.layoutIfNeeded()
        myList()
        
    }
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true);
    }
    func showAlert(strMsg: String){
        let alert = UIAlertController(title: "Alert", message: strMsg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    // MARK: Handler for myList(myList) API
    func myList(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let URLString: String = "/myList"
        viewActivity.isHidden = false
        let user_id = UserDefaults.standard.string(forKey: "user_id");
        let params: [String: Any] = ["userid":user_id ?? ""]
        
        let headerParameters = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        let httpMethodName = "POST"
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
                    self.viewActivity.isHidden = true

                    //print(resultObj)
                    if let json = resultObj as? [String: Any] {
                        if (json["statusCode"]as? String == "200"){
                            print("Mylist JSON:",json)
                            print("Mylist JSON:",json)
                            self.aryMyListData  = json["Data"] as? [Any] ?? [Any]();
                            print("Mylist count:",self.aryMyListData.count)
                            self.tblMain.reloadData()
                        }
                        else{
                            let strError = json["message"] as? String
                            print("Mylist error:",strError ?? "")
                            self.showAlert(strMsg: strError ?? "")
                        }
                        
                    }
                }
                
            } catch let error as NSError {
                //print(error)
                self.showAlert(strMsg: error.localizedDescription)
                self.viewActivity.isHidden = true
            }
            return nil
        }
    }
    
    
    //MARK:Tableview Delegates and Datasource Methods
    
    func numberOfSections(in tableView: UITableView) ->  Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (aryMyListData.count == 0){
            lblNoData.isHidden = false
        }else{
            lblNoData.isHidden = true
        }
        if(aryMyListData.count == 0)
        {
            return 0
        }
        return 1
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) ->  CGFloat {
        let screenRect = UIScreen.main.bounds
        let screenHeight = screenRect.size.height
        return screenHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblMain.dequeueReusableCell(withIdentifier: "MyEventsCell", for: indexPath) as! MyEventsCell
        cell.updateCellWith(row: aryMyListData,controller: "my_events")
        cell.cellDelegate = self
        return cell
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
    }
    // MARK: collectionView Delegate
    
    func collectionView(collectionviewcell: DBCollectionViewCell?, index: Int, didTappedInTableViewCell: MyEventsCell) {
        
        let orgsList = didTappedInTableViewCell.rowWithItems
        let selectedOrg = orgsList[index] as? [String: Any] ?? [:]
        //print("item:\(String(describing: selectedOrg))")
        
        let streamInfo = selectedOrg
       let storyboard = UIStoryboard(name: "Main", bundle: nil);
       let number_of_creators = streamInfo["number_of_creators"] as? Int ?? 0
       let orgId = streamInfo["organization_id"] as? Int ?? 0
       var streamId = 0
       let performer_id = streamInfo["performer_id"] as? Int ?? 0
       let stream_video_title = streamInfo["stream_video_title"] as? String ?? "Channel Details"
       if (title == "dashboard_my_list"){
           streamId = streamInfo["stream_video_id"] as? Int ?? 0
       }else{
           streamId = streamInfo["id"] as? Int ?? 0
       }
       appDelegate.isLiveLoad = "1"
       print("number_of_creators:",number_of_creators)
       let vc = storyboard.instantiateViewController(withIdentifier: "StreamDetailVC") as! StreamDetailVC
                      vc.orgId = orgId
                      vc.streamId = streamId
                      vc.delegate = self
                      vc.performerId = performer_id
                      vc.strTitle = stream_video_title
                      self.navigationController?.pushViewController(vc, animated: true)
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
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


//
//  MyEventsVC.swift
//  AreveaTV
//
//  Created by apple on 7/21/20.
//  Copyright © 2020 apple. All rights reserved.
//

import UIKit
import Alamofire

class MyEventsVC: UIViewController,CollectionViewCellDelegate,OpenChanannelChatDelegate,UITableViewDelegate,UITableViewDataSource {
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
        tblMain.register(UINib(nibName: "DashBoardCell", bundle: nil), forCellReuseIdentifier: "DashBoardCell")
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
        let url: String = appDelegate.baseURL +  "/myList"
        viewActivity.isHidden = false
        let headers: HTTPHeaders
        headers = [appDelegate.securityKey: appDelegate.securityValue]
        let user_id = UserDefaults.standard.string(forKey: "user_id");
        let params: [String: Any] = ["userid":user_id ?? ""]
        
        AF.request(url, method: .post,  parameters: params, encoding: JSONEncoding.default,headers:headers)
            .responseJSON { response in
                self.viewActivity.isHidden = true
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any] {
                        if (json["statusCode"]as? String == "200"){
                            ////print(json["message"] ?? "")
                            print("Mylist JSON:",json)
                            self.aryMyListData  = json["Data"] as? [Any] ?? [Any]();
                            print("Mylist count:",self.aryMyListData.count)
                            self.tblMain.reloadData()
                            
                        }
                        else{
                            let strError = json["message"] as? String
                            ////print(strError ?? "")
                            self.showAlert(strMsg: strError ?? "")
                        }
                    }
                case .failure(let error):
                    //print(error)
                    self.showAlert(strMsg: error.localizedDescription)
                }
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
        let screenHeight = screenRect.size.height-120
        return screenHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblMain.dequeueReusableCell(withIdentifier: "DashBoardCell", for: indexPath) as! DashBoardCell
        cell.updateCellWith(row: aryMyListData,controller: "my_events")
        cell.cellDelegate = self
        return cell
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
    }
    // MARK: collectionView Delegate
    
    func collectionView(collectionviewcell: DBCollectionViewCell?, index: Int, didTappedInTableViewCell: DashBoardCell) {
        
        let orgsList = didTappedInTableViewCell.rowWithItems
        let selectedOrg = orgsList[index] as? [String: Any]
        //print("item:\(String(describing: selectedOrg))")
        
        if (selectedOrg?["parent_category_id"]as? Int != nil){
            let storyboard = UIStoryboard(name: "Main", bundle: nil);
            let vc = storyboard.instantiateViewController(withIdentifier: "ChannelDetailVC") as! ChannelDetailVC
            vc.orgId = selectedOrg?["organization_id"] as? Int ?? 0
            vc.streamId = selectedOrg?["id"] as? Int ?? 0
            vc.delegate = self
            appDelegate.isLiveLoad = "1"
            //        //print("userId:",selectedOrg?["user_id"] as Any)
            if (selectedOrg?["performer_id"] as? Int) != nil {
                vc.performerId = selectedOrg?["performer_id"] as! Int
            }
            else {
                vc.performerId = 1;
            }
            vc.strTitle = selectedOrg?["user_display_name"] as? String ?? "Channel Details"
            
            
            self.navigationController?.pushViewController(vc, animated: true)
        }
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
}


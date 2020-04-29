//
//  ChannelsVC.swift
//  AreveaTV
//
//  Created by apple on 4/23/20.
//  Copyright © 2020 apple. All rights reserved.
//

import UIKit
import Alamofire

class ChannelsVC: UIViewController,UITableViewDelegate,UITableViewDataSource,CollectionViewCellDelegate{
    @IBOutlet weak var tblMain: UITableView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    var detailItem: String = "";
    var aryChannels = [Any]();
    
    var aryMainMenu :[[String: String]] = [["name":"House","icon":"channel1.png"],["name":"Bass","icon":"channel2.png"],["name":"Bass","icon":"channel4.png"],["name":"House","icon":"channel3.png"],["name":"House","icon":"channel4.png"],
                                           ["name":"Bass","icon":"channel1.png"],
                                           ["name":"Bass","icon":"channel2.png"],
                                           ["name":"House","icon":"channel3.png"],
                                           ["name":"Bass","icon":"channel2.png"],
                                           ["name":"House","icon":"channel3.png"]];
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationController?.isNavigationBarHidden = true
        tblMain.register(UINib(nibName: "DashBoardCell", bundle: nil), forCellReuseIdentifier: "DashBoardCell")
        lblTitle.text = "Channels";
        organizationChannels();
    }
    func showAlert(strMsg: String){
        let alert = UIAlertController(title: "Alert", message: strMsg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    func organizationChannels(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let url: String = appDelegate.baseURL +  "/organizationChannels"
        let params: [String: Any] = ["organization_id": "1"]
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        AF.request(url, method: .post,  parameters: params, encoding: JSONEncoding.default)
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any] {
                        self.aryChannels = json["channels"] as! [Any];
                        NSLog("aryChannels count:%d", self.aryChannels.count);
                        self.activityIndicator.isHidden = true;
                        self.activityIndicator.stopAnimating();
                        self.tblMain.reloadData()
                        
                    }
                case .failure(let error):
                    print(error)
                    self.activityIndicator.isHidden = true;
                    self.activityIndicator.stopAnimating();
                    self.showAlert(strMsg: error.localizedDescription)
                }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        
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
        return aryChannels.count;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) ->  CGFloat {
        return 180
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DashBoardCell", for: indexPath) as! DashBoardCell
        let rowArray = aryChannels;
        cell.updateCellWith(row: rowArray,controller: "channels")
        cell.cellDelegate = self
        return cell
    }
    func getColorByHex(rgbHexValue:UInt32, alpha:Double = 1.0) -> UIColor {
        let red = Double((rgbHexValue & 0xFF0000) >> 16) / 256.0
        let green = Double((rgbHexValue & 0xFF00) >> 8) / 256.0
        let blue = Double((rgbHexValue & 0xFF)) / 256.0
        
        return UIColor(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: CGFloat(alpha))
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil);
        let vc = storyboard.instantiateViewController(withIdentifier: "ChannelDetailVC") as! ChannelDetailVC
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    func collectionView(collectionviewcell: DBCollectionViewCell?, index: Int, didTappedInTableViewCell: DashBoardCell) {
          let storyboard = UIStoryboard(name: "Main", bundle: nil);
           let vc = storyboard.instantiateViewController(withIdentifier: "ChannelDetailVC") as! ChannelDetailVC
           self.navigationController?.pushViewController(vc, animated: true)
       }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent // .default
    }
    
}

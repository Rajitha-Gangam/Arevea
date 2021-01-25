//
//  TicketTypesVC.swift
//  AreveaTV
//
//  Created by apple on 12/22/20.
//  Copyright © 2020 apple. All rights reserved.
//

import UIKit
import Alamofire

class TicketTypesVC: UIViewController,UITableViewDataSource,UITableViewDelegate,OpenChanannelChatDelegate{
    // MARK: - Variables Declaration
    
    @IBOutlet weak var tblTicketTypes: UITableView!
    var currency_type = ""
    var indexSelectedTicketType = -1
    var strTicketType = ""
    var rowHeight = 92
    var orgId = 0;
    var performerId = 0;
    var streamId = 0;
    var strTitle = ""
    var isCameFromGetTickets = false
    var channel_name_subscription = ""
    var isVOD = false;
    var isAudio = false;
    var isStream = true;
    var isUpcoming = false;
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var aryStreamInfo = [String: Any]()
    var tempAryDisplayCurrencies = [Any]()
    @IBOutlet weak var tblheight: NSLayoutConstraint!
    var aryStreamAmounts = [Any]()
    @IBOutlet weak var heightTopView: NSLayoutConstraint?
    @IBOutlet weak var viewTop: UIView!
    @IBOutlet weak var viewActivity: UIView!
    var aryUserSubscriptionInfo = [Any]()
    weak var delegate: OpenChanannelChatDelegate?
    var currencyType = ""
    var currencySymbol = ""
    var jsonCurrencyList = [String:Any]()
    @IBOutlet weak var btnCancel: UIButton!
    
    var aryCurrencyKeys = [String]()
    var aryCurrencyValues = [Any]()
    var aryDisplayCurrencies = [Any]()
    var doubleDisplayCurrencies = [Double]()
    // MARK: - View Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        tblTicketTypes.register(UINib(nibName: "TicketTypesCell", bundle: nil), forCellReuseIdentifier: "TicketTypesCell")
        print("tt - aryStreamAmounts:",tempAryDisplayCurrencies)
       
        
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
        btnCancel.layer.borderColor = UIColor.white.cgColor

        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true);
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        
    }
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    func showAlert(strMsg: String){
        let alert = UIAlertController(title: "Alert", message: strMsg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
    @IBAction func proceedPressed(_ sender: UIButton){
        if(indexSelectedTicketType >= 0){
            proceedToPayment(type: "pay_per_view",charityId: 0,ticket_type_name: strTicketType)
        }else{
            showAlert(strMsg: "Please select Ticket Type")
        }
    }
    func proceedToPayment(type:String,charityId:Int,ticket_type_name:String){
        //let url: String = appDelegate.baseURL +  "/proceedToPayment"
        let user_id = UserDefaults.standard.string(forKey: "user_id");
        let strUserId = user_id ?? "1"
        var encoded_ticket_type_name = ticket_type_name
        
        encoded_ticket_type_name = encoded_ticket_type_name.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed) ?? ""
        encoded_ticket_type_name = encoded_ticket_type_name.replacingOccurrences(of: "'", with: "%27")
        encoded_ticket_type_name = encoded_ticket_type_name.replacingOccurrences(of: ":", with: "%3A")
        encoded_ticket_type_name = encoded_ticket_type_name.replacingOccurrences(of: "=", with: "%3D")
        encoded_ticket_type_name = encoded_ticket_type_name.replacingOccurrences(of: "/", with: "%252F")
        
        let queryString = "stream_id=" + String(streamId) + "&user_id=" + strUserId + "&ticket_type_name=" + encoded_ticket_type_name//ppv
        print("queryString:",queryString)
        
        let urlOpen = appDelegate.paymentRedirectionURL + "/" + type + "?" + queryString
        guard let url = URL(string: urlOpen) else { return }
        print("url to open:",url)
        UIApplication.shared.open(url)
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
    //MARK:Tableview Delegates and Datasource Methods
    
    func numberOfSections(in tableView: UITableView) ->  Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tblheight.constant = CGFloat(rowHeight * tempAryDisplayCurrencies.count)
        self.tblTicketTypes.layoutIfNeeded()
        return tempAryDisplayCurrencies.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) ->  CGFloat {
        return CGFloat(rowHeight);
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TicketTypesCell") as! TicketTypesCell
        cell.backgroundColor = UIColor.clear
        let element = self.tempAryDisplayCurrencies[indexPath.row] as? [String : Any] ?? [String:Any]()
        let ticket_type_name = element["ticket_type_name"]as? String ?? ""
        var strAmount = "0.0"
        if (element["stream_payment_amount"] as? Double) != nil {
            strAmount = String(element["stream_payment_amount"] as? Double ?? 0.00)
        }else if (element["stream_payment_amount"] as? String) != nil {
            strAmount = String(element["stream_payment_amount"] as? String ?? "0.00")
        }
        cell.lblTitle.text = ticket_type_name
        cell.imgCheck.image = UIImage.init(named: "check")
        if(indexSelectedTicketType == indexPath.row){
            cell.imgCheck.image = UIImage.init(named: "checked")
        }
        let  amountWithCurrencyType = self.currencySymbol + strAmount
       cell.lblAmount.text = amountWithCurrencyType
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //           let storyboard = UIStoryboard(name: "Main", bundle: nil);
        //           let vc = storyboard.instantiateViewController(withIdentifier: "ChannelDetailVC") as! ChannelDetailVC
        //           self.navigationController?.pushViewController(vc, animated: true)
        
        tableView.deselectRow(at: indexPath, animated: true)
        let element = self.aryStreamAmounts[indexPath.row] as? [String : Any] ?? [String:Any]()
        let ticket_type_name = element["ticket_type_name"]as? String ?? ""
        strTicketType = ticket_type_name
        indexSelectedTicketType = indexPath.row
        tblTicketTypes.reloadData()
    }
    func gotoStreamDetails(){
        print("gotoStreamDetails")
        let storyboard = UIStoryboard(name: "Main", bundle: nil);
        let streamInfo = self.aryStreamInfo
        let stream_video_title = streamInfo["stream_video_title"] as? String ?? "Channel Details"
        appDelegate.isLiveLoad = "1"
        let vc = storyboard.instantiateViewController(withIdentifier: "StreamDetailVC") as! StreamDetailVC
        vc.orgId = orgId
        vc.streamId = streamId
        vc.delegate = self
        vc.performerId = performerId
        vc.strTitle = stream_video_title
        vc.isCameFromGetTickets = true
        vc.channel_name_subscription = channel_name_subscription
        vc.isVOD = isVOD
        vc.isUpcoming = isUpcoming
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    @objc func applicationDidBecomeActive(notification: NSNotification) {
        // Application is back in the foreground
        print("====applicationDidBecomeActive")
        //if user comes from payment redirection, need to refresh stream/vod
        LiveEventById()
    }
    func LiveEventById() {
        viewActivity.isHidden = false
        let netAvailable = appDelegate.isConnectedToInternet()
        if(!netAvailable){
            showAlert(strMsg: "Please check your internet connection!")
            return
        }
        let url: String = appDelegate.baseURL +  "/LiveEventById"
        let user_id = UserDefaults.standard.string(forKey: "user_id");
        var streamIdLocal = "0"
        if (streamId != 0){
            streamIdLocal = String(streamId)
        }
        let headers: HTTPHeaders
        headers = [appDelegate.x_api_key: appDelegate.x_api_value]
        
        let params: [String: Any] = ["userid":user_id ?? "","performer_id":performerId,"stream_id": streamIdLocal]
        print("liveEvents params:",params)
        // let params: [String: Any] = ["userid":user_id ?? "","performer_id":"101","stream_id": "0"]
        AF.request(url, method: .post,parameters: params, encoding: JSONEncoding.default,headers:headers)
            .responseJSON { [self] response in
                self.viewActivity.isHidden = true
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any] {
                        //print("myList JSON:",json)
                        if (json["statusCode"]as? String == "200" ){
                            let data = json["Data"] as? [String:Any]
                            self.aryStreamInfo = data?["stream_info"] as? [String:Any] ?? [:]
                            
                            let user_subscription_info = data?["user_subscription_info"] != nil
                            if(user_subscription_info){
                                self.aryUserSubscriptionInfo = data?["user_subscription_info"] as? [Any] ?? [Any]()
                            }
                            if (self.aryUserSubscriptionInfo.count > 0){
                                gotoStreamDetails()
                            }
                        }else{
                            let strMsg = json["message"] as? String ?? ""
                            self.showAlert(strMsg: strMsg)
                        }
                    }
                case .failure(let error):
                    let errorDesc = error.localizedDescription.replacingOccurrences(of: "URLSessionTask failed with error:", with: "")
                    self.showAlert(strMsg: errorDesc)
                    self.viewActivity.isHidden = true
                    
                }
            }
    }
}



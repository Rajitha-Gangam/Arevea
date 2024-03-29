//
//  EventRegistrationVC.swift
//  AreveaTV
//
//  Created by apple on 11/9/20.
//  Copyright © 2020 apple. All rights reserved.
//

import UIKit
import AVFoundation
import Alamofire
import SendBirdSDK
import SDWebImage
import Reachability
import AWSAppSync
import EasyTipView

class ScheduleVC: UIViewController,OpenChanannelChatDelegate,UITableViewDataSource,UITableViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    // MARK: - Variables Declaration
    
    @IBOutlet weak var viewBottom: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    
    var aryStreamInfo = [String: Any]()
    var orgId = 0;
    var performerId = 0;
    
    var streamVideoCode = ""
    var number_of_creators = 1
    var streamId = 0;
    var strSlug = "";
    var aryAgendaGuestList = [Any]();
    var isLoaded = 0;
    var arysubEvents = [Any]();
    var aryTicketIds = [Any]();
    
    var aryAgenda = [Any]();
    
    var backPressed = false
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tblSchedule: UITableView!
    
    var channelName = ""
    var streamPaymentMode = ""
    var strTitle = ""
    @IBOutlet weak var viewActivity: UIView!
    @IBOutlet weak var imgStreamThumbNail: UIImageView!
    @IBOutlet weak var heightTopView: NSLayoutConstraint?
    @IBOutlet weak var viewTop: UIView!
    
    var isVOD = false;
    var isAudio = false;
    var isStream = true;
    var isUpcoming = false;
    var streamVideoDesc = ""
    var stream_status = ""
    var channel_name_subscription = ""
    
    var aryEventdatesJson = [Any]()
    @IBOutlet weak var viewSchedule: UIView!
    @IBOutlet weak var dateCVC: UICollectionView!
    var arySelectedSubEvents = [[String:Any]]();
    @IBOutlet weak var heightDesc: NSLayoutConstraint!
    @IBOutlet weak var txtVideoDesc_Info: UITextView!
    var aryUserSubscriptionInfo = [Any]()
    var tempStreamStatus = ""
    var ticketKey = ""
    var priceDetails = [String:Any]()
    var currencySymbol = ""
    var isUserSubscribe = false
    
    //for tabs highlight when we go respective pages, and after comes back to this page creating these variables.
    weak var chatDelegate: OpenChanannelChatDelegate?
    var aryTickets = [Any]();
    var toolTipPreferences = EasyTipView.Preferences()
    
    // MARK: - View Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        viewActivity.isHidden = true
        lblTitle.text = appDelegate.strTitle
        
        if(UIDevice.current.userInterfaceIdiom == .pad){
            heightTopView?.constant = 60;
            viewTop.layoutIfNeeded()
        }
        
        if(self.channel_name_subscription == ""){
            self.channel_name_subscription = " "
        }
        toolTipPreferences.drawing.font = UIFont(name: "Poppins-Regular", size: 13)!
        toolTipPreferences.drawing.foregroundColor = UIColor.white
        toolTipPreferences.drawing.backgroundColor = UIColor.init(red: 255, green: 127, blue: 80)
        toolTipPreferences.drawing.arrowPosition = EasyTipView.ArrowPosition.top
        //toolTipPreferences.animating.showDuration = 1.5
        // toolTipPreferences.animating.dismissDuration = 1.5
        toolTipPreferences.animating.dismissOnTap = true
        toolTipPreferences.drawing.arrowWidth = 2
        toolTipPreferences.drawing.arrowHeight = 2
        toolTipPreferences.drawing.arrowPosition = .bottom
        toolTipPreferences.animating.dismissTransform = CGAffineTransform(translationX: 0, y: -15)
        toolTipPreferences.animating.showInitialTransform = CGAffineTransform(translationX: 0, y: -15)
        toolTipPreferences.animating.showInitialAlpha = 0
        toolTipPreferences.animating.showDuration = 1.5
        toolTipPreferences.animating.dismissDuration = 1.5
        EasyTipView.globalPreferences = toolTipPreferences
        registerNibs();
        
    }
    func registerNibs() {
        tblSchedule.register(UINib(nibName: "ScheduleHeaderViewCell", bundle: nil), forHeaderFooterViewReuseIdentifier: "ScheduleHeaderViewCell")
        
        tblSchedule.register(UINib(nibName: "ScheduleCell", bundle: nil), forCellReuseIdentifier: "ScheduleCell");
        let nib = UINib(nibName: "DateCVC", bundle: nil)
        dateCVC?.register(nib, forCellWithReuseIdentifier:"DateCVC")
    }
    // MARK: - Collection View Data Source
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return aryEventdatesJson.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DateCVC",for: indexPath) as? DateCVC {
            let dateObj = aryEventdatesJson[indexPath.row] as?[String : Any] ?? [:];
            let startDate = dateObj["start"] as? String ?? ""
            let formatter = DateFormatter()
            formatter.timeZone = NSTimeZone(abbreviation: "UTC") as TimeZone?
            formatter.locale = Locale(identifier: "en_US_POSIX")
            
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
            if let eventStartDate = formatter.date(from: startDate){
                formatter.dateFormat = "E, dd MMM yyyy"
                let strStartDate = formatter.string(from: eventStartDate)
                cell.configureCell(name: strStartDate)
                
            }
            cell.btnDate.addTarget(self, action: #selector(btnDatePress(_:)), for: .touchUpInside)
            cell.btnDate.tag = 20 + (indexPath.row);
            if(indexPath.row == 0){
                let yellow = UIColor(red: 139, green: 230, blue: 213);
                cell.btnDate.backgroundColor = yellow
                cell.btnDate.setTitleColor(.black, for: .normal)
                
            }else{
                let gray = UIColor(red: 34, green: 44, blue: 54);
                cell.btnDate.backgroundColor = gray
                cell.btnDate.layer.borderColor = UIColor.white.cgColor
                cell.btnDate.setTitleColor(.white, for: .normal)
            }
            
            return cell
            
        }
        return UICollectionViewCell()
        
    }
    func reloadTbl(index:Int){
        print("ary count:",aryEventdatesJson.count)
        print("ary:",aryEventdatesJson)
        
        if(aryEventdatesJson.count > 0){
            
            let dateObj = aryEventdatesJson[index] as?[String : Any] ?? [:];
            let startDate = dateObj["start"] as? String ?? ""
            let formatter = DateFormatter()
            formatter.timeZone = NSTimeZone(abbreviation: "UTC") as TimeZone?
            formatter.locale = Locale(identifier: "en_US_POSIX")
            arySelectedSubEvents = []
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
            if let eventStartDate = formatter.date(from: startDate){
                formatter.dateFormat = "yyyy-MM-dd"
                let strStartDate = formatter.string(from: eventStartDate)
                
                for(index,_)in self.arysubEvents.enumerated(){
                    var subEvent = self.arysubEvents[index]as? [String : Any] ?? [String:Any]()
                    var streamInfo = subEvent["stream_info"] as? [String : Any] ?? [String:Any]()
                    var publish_date_time = streamInfo["publish_date_time"]as? String ?? ""
                    print("::publish_date_time:",publish_date_time)
                    let formatter = DateFormatter()
                    formatter.timeZone = NSTimeZone(abbreviation: "UTC") as TimeZone?
                    formatter.locale = Locale(identifier: "en_US_POSIX")
                    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    if let publishDate = formatter.date(from: publish_date_time){
                        formatter.dateFormat = "yyyy-MM-dd"
                        let strPublishDate = formatter.string(from: publishDate)
                        if(strStartDate == strPublishDate){
                            arySelectedSubEvents.append(subEvent)
                        }else{
                            print("date not matched")
                        }
                    }
                    //var expected_end_date_time = streamInfo["expected_end_date_time"]as? String ?? ""
                }
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                self.arySelectedSubEvents = self.arySelectedSubEvents.sorted{[dateFormatter] one, two in
                    return dateFormatter.date(from:one["publish_date_time"] as! String )! < dateFormatter.date(from: two["publish_date_time"] as! String )! }
            }
            //tblSchedule.reloadSections([index], with: .automatic)
            tblSchedule.reloadData()
        }
    }
    @objc func btnDatePress(_ sender: UIButton) {
        tblSchedule.isHidden = false
        let tag = sender.tag
        print("tag:",tag)
        for (index,_) in aryEventdatesJson.enumerated() {
            let name = aryEventdatesJson[index]
            let btnTag = 20 + index;
            let btnText = self.dateCVC.viewWithTag(btnTag) as? UIButton
            if (tag == btnTag){
                print("btnTag:",btnTag)
                let yellow = UIColor(red: 139, green: 230, blue: 213);
                btnText?.backgroundColor = yellow
                btnText?.setTitleColor(.black, for: .normal)
            }else{
                let gray = UIColor(red: 34, green: 44, blue: 54);
                btnText?.backgroundColor = gray
                btnText?.setTitleColor(.white, for: .normal)
            }
        }
        
        //date caluculation for agenda
        let dateIndex = tag - 20
        reloadTbl(index: dateIndex)
        
    }
    func showAlert(strMsg: String){
        let alert = UIAlertController(title: "Alert", message: strMsg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
    
    @objc func applicationDidBecomeActive(notification: NSNotification) {
        // Application is back in the foreground
        print("====applicationDidBecomeActive ER")
        //if user comes from payment redirection, need to refresh stream/vod
        getEventBySlug()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true);
        backPressed = false
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        if(UIDevice.current.userInterfaceIdiom == .pad){
            //self.imgStreamThumbNail.image = UIImage.init(named: "sample-event")
        }else{
            //self.imgStreamThumbNail.image = UIImage.init(named: "sample_vod_square")
        }
        getEventBySlug()
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name:UIApplication.didBecomeActiveNotification , object: nil)
        NotificationCenter.default.removeObserver(self)
    }
    func delay(_ delay:Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }
    
    
    @IBAction func back(_ sender: Any) {
        
        //self.navigationController?.popViewController(animated: true)
        popToDashBoard()
        
    }
    func popToDashBoard(){
        for controller in self.navigationController!.viewControllers as Array {
            if controller.isKind(of: DashBoardVC.self) {
                self.navigationController!.popToViewController(controller, animated: true)
                break
            }
        }
    }
    
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                //////print(error.localizedDescription)
            }
        }
        return nil
    }
    func convertToArray(text: String) -> [Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [Any]
            } catch {
                //////print(error.localizedDescription)
            }
        }
        return nil
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent // .default
    }
    func heightForView(text:String, width:CGFloat) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = UIFont.systemFont(ofSize: 18.0)
        label.text = text
        label.sizeToFit()
        return label.frame.height
    }
    
    
    // MARK: Handler for getEventBySlug API
    func getEventBySlug(){
        let netAvailable = appDelegate.isConnectedToInternet()
        if(!netAvailable){
            showAlert(strMsg: "Please check your internet connection!")
            return
        }
        viewActivity.isHidden = false
        let url: String = appDelegate.baseURL +  "/getEventBySlug"
        let user_id = UserDefaults.standard.string(forKey: "user_id");
        var params: [String: Any] = ["slug":appDelegate.strSlug]
        params["userid"] = user_id ?? ""
        print("getEventBySlug params:",params)
        let headers: HTTPHeaders
        headers = [appDelegate.x_api_key: appDelegate.x_api_value]
        AF.request(url, method: .post,parameters: params, encoding: JSONEncoding.default,headers:headers)
            .responseJSON { [self] response in
                self.viewActivity.isHidden = true
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any] {
                        print("getEventBySlug JSON:",json)
                        if (json["statusCode"]as? String == "200"){
                            let data = json["Data"] as? [String:Any]
                            self.aryStreamInfo = data?["stream_info"] as? [String:Any] ?? [:]
                            let streamObj = self.aryStreamInfo
                            self.aryTickets = data?["tickets"] as? [Any] ?? [Any]()
                            
                            print("==>self.aryStreamInfo:",self.aryStreamInfo)
                            let stream_info_key_exists = self.aryStreamInfo["id"]
                            self.priceDetails = data?["price_details"]as? [String:Any] ?? [:]
                            self.isUserSubscribe = self.priceDetails["subscription_status"] as?Bool ?? false
                            
                            let currencyTypePrice = self.priceDetails["currency"] as? String ?? ""
                            var currencySymbolPrice = ""
                            //based on currency type, get currency symbol
                            if let path = Bundle.main.path(forResource: "currencies", ofType: "json") {
                                do {
                                    let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                                    let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                                    if let jsonResult = jsonResult as? Dictionary<String, AnyObject>,
                                       let currencySymbol = jsonResult[currencyTypePrice] as? String {
                                        // do stuff
                                        currencySymbolPrice = currencySymbol
                                        self.currencySymbol = currencySymbol
                                    }
                                } catch {
                                    // handle error
                                }
                            }
                            
                            
                            self.arysubEvents = data?["subEvents"]as? [Any] ?? [Any]()
                            var isTicket = false
                            
                            self.aryUserSubscriptionInfo = data?["user_subscription_info"] as? [Any] ?? [Any]()
                            print("aryUserSubscriptionInfo:",aryUserSubscriptionInfo)
                            if(self.aryUserSubscriptionInfo.count > 0){
                                let userSubscription = self.aryUserSubscriptionInfo[0] as? [String : Any] ?? [:];
                                self.aryTicketIds = userSubscription["ticket_ids"] as? [Any] ?? [Any]()
                                appDelegate.strTicketKey = userSubscription["ticket_key"] as? String ?? "";
                                // print("appDelegate.strTicketKey:",appDelegate.strTicketKey)
                                
                            }else{
                                self.aryTicketIds = []
                            }
                            if(arysubEvents.count > 1)
                            {
                                
                            }else{
                                gotoStreamDetails()
                                return
                            }
                            
                            
                            let event_dates_json = streamObj["event_dates_json"] as? String ?? "";
                            
                            self.aryEventdatesJson = self.convertToArray(text:event_dates_json ) ?? [Any]()
                            
                            self.dateCVC.reloadData()
                            if(self.aryEventdatesJson.count > 0){
                                reloadTbl(index: 0)
                            }
                            self.streamPaymentMode = streamObj["stream_payment_mode"] as? String ?? ""
                            self.appDelegate.streamPaymentMode = self.streamPaymentMode
                            
                            self.streamVideoCode = streamObj["stream_video_code"] as? String ?? ""
                            _ = streamObj["stream_video_title"] as? String ?? ""
                            self.streamVideoDesc = streamObj["stream_video_description"] as? String ?? ""
                            if(self.streamVideoDesc == "null"){
                                self.streamVideoDesc = ""
                            }
                            let videoDesc = self.streamVideoDesc;
                            print("videoDesc:",videoDesc)
                            
                            let fullText = videoDesc
                            let strDesc = fullText.htmlToString
                            var height = self.heightForView(text: strDesc, width: 380)
                            if(height > 60){
                                height = 60
                            }
                            self.heightDesc.constant = height
                            self.txtVideoDesc_Info.layoutIfNeeded()
                            self.txtVideoDesc_Info.text = strDesc
                            
                            let streamBannerURL = streamObj["video_banner_image"] as? String ?? ""
                            if let urlBanner = URL(string: streamBannerURL){
                                var imageName = "sample_vod_square"
                                if(UIDevice.current.userInterfaceIdiom == .pad){
                                    imageName = "sample-event"
                                }
                                self.imgStreamThumbNail.sd_setImage(with:urlBanner, placeholderImage: UIImage(named: imageName))
                            }
                            
                            
                        }else{
                            let strError = json["message"] as? String
                            print("strError 1:",strError ?? "")
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
    
    func utcToLocalDate(dateStr: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, MMM dd yyyy"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        if let date = dateFormatter.date(from: dateStr) {
            dateFormatter.timeZone = TimeZone.current
            dateFormatter.dateFormat = "MMM dd yyyy"
            
            return dateFormatter.string(from: date)
        }
        return nil
    }
    func utcToLocalDate1(dateStr: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd yyyy"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        if let date = dateFormatter.date(from: dateStr) {
            dateFormatter.timeZone = TimeZone.current
            dateFormatter.dateFormat = "MMM dd yyyy"
            
            return dateFormatter.string(from: date)
        }
        return nil
    }
    func UTCToLocalTime(dateStr: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        if let date = dateFormatter.date(from: dateStr) {
            dateFormatter.timeZone = TimeZone.current
            dateFormatter.dateFormat = "hh:mm a"
            
            return dateFormatter.string(from: date)
        }
        return nil
    }
    func gotoStreamDetails(){
        //print("gotoStreamDetails")
        let storyboard = UIStoryboard(name: "Main", bundle: nil);
        let streamInfo = self.aryStreamInfo
        let stream_video_title = streamInfo["stream_video_title"] as? String ?? "Channel Details"
        appDelegate.isLiveLoad = "1"
        //print("number_of_creators:",number_of_creators)
        let vc = storyboard.instantiateViewController(withIdentifier: "StreamDetailVC") as! StreamDetailVC
        vc.chatDelegate = self
        vc.isCameFromGetTickets = true
        vc.tempStreamStatus = tempStreamStatus
        
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    // MARK: Handler for endSession API
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        //adding observer
        AppDelegate.AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        AppDelegate.AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        AppDelegate.AppUtility.lockOrientation(.all)
        NotificationCenter.default.removeObserver(self)
        
    }
    
    
    @IBAction func payPerView(_ sender: Any) {
        
        
    }
    func getTicketDetails(){
        print("==getTicketDetails")
        // let params: [String: Any] = ["userid":user_id ?? "","performer_id":"101","stream_id": "0"]
        let url: String = appDelegate.baseURL +  "/getTicketDetails"
        let user_id = UserDefaults.standard.string(forKey: "user_id");
        var streamIdLocal = "0"
        if (appDelegate.streamId != 0){
            streamIdLocal = String(appDelegate.streamId)
        }
        let headers: HTTPHeaders
        headers = [appDelegate.x_api_key: appDelegate.x_api_value]
        
        let params: [String: Any] = ["ticket_key": appDelegate.strSlug]
        print("getTicketDetails params:",params)
        
        AF.request(url, method: .post,parameters: params, encoding: JSONEncoding.default,headers:headers)
            .responseJSON { [self] response in
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any] {
                        print("getTicketDetails JSON:",json)
                        if (json["statusCode"]as? String == "200" ){
                            
                            
                        }else{
                            let strMsg = json["message"] as? String ?? ""
                            //self.showAlert(strMsg: strMsg)
                        }
                        
                    }
                case .failure(let error):
                    let errorDesc = error.localizedDescription.replacingOccurrences(of: "URLSessionTask failed with error:", with: "")
                    //self.showAlert(strMsg: errorDesc)
                    self.viewActivity.isHidden = true
                    
                }
            }
    }
    //MARK:Tableview Delegates and Datasource Methods
    
    func numberOfSections(in tableView: UITableView) ->  Int {
        if(tableView == tblSchedule){
            return arySelectedSubEvents.count
        }
        return 1
    }
    func setParamForRegisterEvent(){
        _ = UserDefaults.standard.string(forKey: "user_id");
        let streamObj = self.aryStreamInfo
        let currency_type = streamObj["currency_type"] as? String ?? ""
        let stream_video_title = streamObj["stream_video_title"] as? String ?? ""
        var strAmount = "0.0"
        
        if (streamObj["stream_payment_amount"] as? Double) != nil {
            strAmount = String(streamObj["stream_payment_amount"] as? Double ?? 0.0)
        }else if (streamObj["stream_payment_amount"] as? String) != nil {
            strAmount = String(streamObj["stream_payment_amount"] as? String ?? "0.0")
        }
        let doubleAmount = Double(strAmount)
        let amount = String(format: "%.02f", doubleAmount!)
        let stream_amounts = streamObj["stream_amounts"] as? String ?? "";
        let publish_date_time = streamObj["publish_date_time"] as? String ?? "";
        let video_thumbnail_image = streamObj["video_thumbnail_image"] as? String ?? "";
        let user_first_name = streamObj["user_first_name"] as? String ?? "";
        let user_last_name = streamObj["user_last_name"] as? String ?? "";
        let user_display_name = streamObj["user_display_name"] as? String ?? "";
        let channel_name = streamObj["channel_name"] as? String ?? "";
        let stream_status = streamObj["stream_status"] as? String ?? "";
        let expected_end_date_time = streamObj["expected_end_date_time"] as? String ?? "";
        
        let params: [String: Any] = ["paymentInfo": ["paymentType": "pay_per_view","payment_type": "pay_per_view","organization_id": appDelegate.orgId,"currency": currency_type,"amount": 0,"stream_id": appDelegate.streamId,"streamInfo": ["id": appDelegate.streamId,"stream_video_title": stream_video_title,"organization_id": appDelegate.orgId,"amount":amount,"currency": currency_type,"stream_amounts":stream_amounts,"publish_date_time": publish_date_time,"video_thumbnail_image": video_thumbnail_image,"performer_id": appDelegate.performerId,"user_first_name": user_first_name,"user_last_name": user_last_name,"user_display_name": user_display_name,"channel_name": channel_name,"number_of_creators": self.number_of_creators,"stream_status": stream_status,"currency_type": currency_type,"expected_end_date_time": expected_end_date_time]]]
        
        appDelegate.paramsForFreeRegistration = params
        registerEvent()
    }
    func gotoTicketTypes(){
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil);
        let user_id = UserDefaults.standard.string(forKey: "user_id") ?? ""
        let urlOpen = appDelegate.websiteURL + "/event/" + appDelegate.strSlug + "/place-order?user_id=" + user_id
        print("urlOpen1:",urlOpen)
        let vc = storyboard.instantiateViewController(withIdentifier: "PaymentWebVC") as! PaymentWebVC
        vc.strURL = urlOpen
        vc.isCameFrom = "schedule"
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    @objc func watchNow(_ sender: UIButton) {
        print("watchNow")
        let subEvent = arySelectedSubEvents[sender.tag] as? [String:Any] ?? [:]
        //print("subEvent:",subEvent)
        let streamInfo = subEvent["stream_info"] as? [String : Any] ?? [String:Any]()
        appDelegate.streamId = subEvent["streamid"] as? Int ?? 0
        print("==>appDelegate.streamId:",appDelegate.streamId)
        let strVideoCode = streamInfo["stream_video_code"] as? String ?? ""
        // appDelegate.strea = streamInfo["streamid"] as? Int ?? 0
        print("==>appDelegate.strVideoCode:",strVideoCode)
        
        let stage = streamInfo["stage"] as? String ?? ""
        let stream_status = streamInfo["stream_status"] as? String ?? "";
        tempStreamStatus = stream_status
        let titleBtn = sender.titleLabel?.text
        if(titleBtn == "Get Tickets"){
            if(self.streamPaymentMode == "paid"){
                gotoTicketTypes()
            }else{
                setParamForRegisterEvent()
            }
        }
        else if(titleBtn == "Watch"){
            appDelegate.isVOD = true
            gotoStreamDetails()
        }else {
            appDelegate.isVOD = false
            gotoStreamDetails()
            //place order
        }
    }
    // MARK: Handler for getCategoryOrganisations API
    func registerEvent(){
        //print("registerEvent")
        let netAvailable = appDelegate.isConnectedToInternet()
        if(!netAvailable){
            showAlert(strMsg: "Please check your internet connection!")
            return
        }
        viewActivity.isHidden = false
        let url: String = appDelegate.paymentBaseURL +  "/registerEvent"
        ////print("params:",params)
        let session_token = UserDefaults.standard.string(forKey: "session_token") ?? ""
        let headers : HTTPHeaders = [
            "Content-Type": "application/json",
            appDelegate.x_api_key:appDelegate.x_api_value,
            "Authorization": "Bearer " + session_token
        ]
        AF.request(url, method: .post,parameters: appDelegate.paramsForFreeRegistration, encoding: JSONEncoding.default,headers:headers)
            .responseJSON { response in
                self.viewActivity.isHidden = true
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any] {
                        //print("registerEvent JSON:",json)
                        if (json["status"]as? Int == 0){
                            self.gotoStreamDetails()
                        }else{
                            let strError = json["message"] as? String
                            //////print("strError1:",strError ?? "")
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
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let subEvent = arySelectedSubEvents[section] as? [String:Any] ?? [:]
        let streamInfo = subEvent["stream_info"] as? [String : Any] ?? [String:Any]()
        let stream_id = streamInfo["id"] as? Int ?? 0
        let isTicket = isTicketFound(index: section)
        let parent_streams_id = streamInfo["parent_streams_id"] as? Int ?? 0
        let ticketIdExists = aryTicketIds.filter { $0 as! Int == stream_id }.count > 0
        let ticketParentIdExists = aryTicketIds.filter { $0 as! Int == parent_streams_id }.count > 0
        let stream_status = streamInfo["stream_status"] as? String ?? "";
        if(self.streamPaymentMode != "paid" || ticketIdExists ||  ticketParentIdExists)
        {
            if(stream_status == "completed"){
                //show status completed
                return 70.0
            }
        }else{
            if(!isTicket && stream_status == "completed"){
                //class slick-disabled
                //show status completed
                //No ticket available
                return 70.0
            }
        }
        return 55.0
    }
    func isTicketFound(index:Int)->Bool{
        var elementSubEvent = self.arySelectedSubEvents[index] as? [String : Any] ?? [String:Any]()
        let eventId = elementSubEvent["streamid"]as? Int ?? 0
        for(indexJ,_)in self.aryTickets.enumerated(){
            let elementTicket = self.aryTickets[indexJ]as? [String : Any] ?? [String:Any]()
            let sessions = elementTicket["sessions"] as? [Any] ?? [Any]()
            for(indexK,_)in sessions.enumerated(){
                let elementSession = sessions[indexK]as? Int ?? 0
                if(elementSession == eventId){
                    //for avoid duplicate stages
                    return true
                }
            }
            
        }
    
    return false
    
}
func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    if(tableView == tblSchedule){
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "ScheduleHeaderViewCell") as! ScheduleHeaderViewCell
        headerView.lblCompleted.isHidden = true
        headerView.lblNotickets.isHidden = true
        headerView.lblCompletedHeight.constant = 0
        headerView.layoutIfNeeded()
        headerView.btnTitle.addTarget(self, action: #selector(scheduleHeaderTapped(_:)), for: .touchUpInside)
        headerView.btnTitle.tag = section
        
        headerView.BtnJoin.tag = section
        headerView.BtnJoin.addTarget(self, action: #selector(watchNow(_:)), for: .touchUpInside)
        
        let subEvent = arySelectedSubEvents[section] as? [String:Any] ?? [:]
        let streamInfo = subEvent["stream_info"] as? [String : Any] ?? [String:Any]()
        //print("==>subEvent:",subEvent)
        
        let stage = streamInfo["stage"] as? String ?? ""
        print("==>sec:",section,",stage:",stage)
        let start_time = streamInfo["publish_date_time"]as? String ?? ""
        let end_time = streamInfo["expected_end_date_time"]as? String ?? ""
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let formatter2 = DateFormatter()
        formatter2.dateFormat = "hh:mm a"
        
        if let startTime = formatter.date(from: start_time){
            let strStartTime = formatter2.string(from: startTime)
            let localStartTime = UTCToLocalTime(dateStr: strStartTime)
            if let endTime = formatter.date(from: end_time){
                let strEndTime = formatter2.string(from: endTime)
                let localEndTime = UTCToLocalTime(dateStr: strEndTime)
                
                print("strEndTime:",strEndTime)
                let btnTitle = stage + " - " + localStartTime! + " - " + localEndTime!
                headerView.btnTitle.setTitle(btnTitle, for: .normal)
            }else{
                let btnTitle = stage + " - " + localStartTime!
                headerView.btnTitle.setTitle(btnTitle, for: .normal)
            }
        }else{
            headerView.btnTitle.setTitle(stage, for: .normal)
        }
        headerView.btnTitle.sizeToFit()
        
        
        let stream_id = streamInfo["id"] as? Int ?? 0
        let isTicket = isTicketFound(index: section)
        print("==isTicket:",isTicket)
        
        let parent_streams_id = streamInfo["parent_streams_id"] as? Int ?? 0
        let ticketIdExists = aryTicketIds.filter { $0 as! Int == stream_id }.count > 0
        let ticketParentIdExists = aryTicketIds.filter { $0 as! Int == parent_streams_id }.count > 0
        let stream_status = streamInfo["stream_status"] as? String ?? "";
        /*if(stream_status == "completed"){
         headerView.BtnJoin.setTitle("Watch", for: .normal)
         }else if(stream_status == "progress"){
         headerView.BtnJoin.setTitle("Live", for: .normal)
         }else if(stream_status == "pending"){
         headerView.BtnJoin.setTitle("Join Now", for: .normal)
         }*/
        headerView.BtnJoin.isEnabled = true
        let green = UIColor(red: 139, green: 230, blue: 213);
        headerView.BtnJoin.backgroundColor = green
        
        if(self.streamPaymentMode != "paid" || ticketIdExists ||  ticketParentIdExists)
        {
            if(stream_status == "completed"){
                //show status completed
                headerView.lblCompletedHeight.constant = 21
                headerView.contentView.layoutIfNeeded()
                headerView.lblCompleted.isHidden = false
                headerView.BtnJoin.setTitle("Watch", for: .normal)
            }else if(stream_status == "progress"){
                headerView.BtnJoin.setTitle("Live", for: .normal)
            }else {
                headerView.BtnJoin.setTitle("Join Now", for: .normal)
            }
        }else{
            headerView.BtnJoin.setTitle("Get Tickets", for: .normal)
            if(!isTicket && stream_status == "completed"){
                //class slick-disabled
                //show status completed
                //No ticket available
                headerView.lblCompleted.isHidden = false
                headerView.lblNotickets.isHidden = false
                headerView.BtnJoin.backgroundColor = UIColor.lightGray
                headerView.lblCompletedHeight.constant = 21
                headerView.contentView.layoutIfNeeded()
            }
            if(!isTicket){
                headerView.BtnJoin.isEnabled = false
                headerView.BtnJoin.backgroundColor = UIColor.lightGray
            }
        }
        return headerView
    }else{
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        return headerView
    }
    
}
@objc func scheduleHeaderTapped(_ sender: UIButton) {
    print("Tapping working1")
    var tootlTipText = ""
    let subEvent = arySelectedSubEvents[sender.tag] as? [String:Any] ?? [:]
    let streamInfo = subEvent["stream_info"] as? [String : Any] ?? [String:Any]()
    
    let stage = streamInfo["stage"] as? String ?? ""
    
    let start_time = streamInfo["publish_date_time"]as? String ?? ""
    let end_time = streamInfo["expected_end_date_time"]as? String ?? ""
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    let formatter2 = DateFormatter()
    formatter2.dateFormat = "hh:mm a"
    
    if let startTime = formatter.date(from: start_time){
        let strStartTime = formatter2.string(from: startTime)
        let localStartTime = UTCToLocalTime(dateStr: strStartTime)
        if let endTime = formatter.date(from: end_time){
            let strEndTime = formatter2.string(from: endTime)
            let localEndTime = UTCToLocalTime(dateStr: strEndTime)
            
            print("localStartTime:",localStartTime)
            print("localEndTime:",localEndTime)
            tootlTipText = stage + " - " + localStartTime! + " - " + localEndTime!
            
        }else{
            tootlTipText = stage + " - " + localStartTime!
        }
    }else{
        tootlTipText = stage
    }
    
    let toolTipView = EasyTipView(text: tootlTipText, preferences: toolTipPreferences)
    
    toolTipView.show(forView: sender, withinSuperview: tblSchedule)
    self.delay(2.0){
        toolTipView.dismiss()
    }
}
func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if(tableView == tblSchedule){
        let subEvent = self.arySelectedSubEvents[section]as? [String : Any] ?? [String:Any]()
        let streamInfo = subEvent["stream_info"] as? [String : Any] ?? [String:Any]()
        let aryAgenda = streamInfo["agenda"] as? [Any] ?? [Any]()
        return aryAgenda.count
    }
    return 0
}
func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) ->  CGFloat {
    if(tableView == tblSchedule){
        return 190
    }
    return 44
    
}
func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if(tableView == tblSchedule){
        let cell = tableView.dequeueReusableCell(withIdentifier: "ScheduleCell") as! ScheduleCell
        let subEvent = self.arySelectedSubEvents[indexPath.section] as? [String : Any] ?? [String:Any]()
        let streamInfo = subEvent["stream_info"] as? [String : Any] ?? [String:Any]()
        let aryAgenda1 = streamInfo["agenda"] as? [Any] ?? [Any]()
        print("agenda count",aryAgenda1.count)
        let agendaObj = aryAgenda1[indexPath.row] as? [String : Any] ?? [:];
        let aryAgendaGuestList1 =  subEvent["guestList"] as? [Any] ?? [Any]()
        print("aryAgendaGuestList1:",aryAgendaGuestList1)
        print("aryAgendaGuestList1 co:",aryAgendaGuestList1.count)
        print("indexPath.row:",indexPath.row)
        
        let title = agendaObj["title"]as? String ?? ""
        let desc = agendaObj["description"]as? String ?? ""
        cell.updateCellWith(row: aryAgendaGuestList1)
        
        cell.lblTitle.text = title
        cell.txtDesc.text = desc
        let start_time = agendaObj["start_time"]as? String ?? ""
        let end_time = agendaObj["end_time"]as? String ?? ""
        let formatter = DateFormatter()
        formatter.timeZone = NSTimeZone(abbreviation: "UTC") as TimeZone?
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let formatter2 = DateFormatter()
        formatter2.timeZone = NSTimeZone(abbreviation: "UTC") as TimeZone?
        formatter2.locale = Locale(identifier: "en_US_POSIX")
        formatter2.dateFormat = "hh:mm a"
        
        if let startTime = formatter.date(from: start_time){
            let strStartTime = formatter2.string(from: startTime)
            let localStartTime = UTCToLocalTime(dateStr: strStartTime)
            
            if let endTime = formatter.date(from: end_time){
                let strEndTime = formatter2.string(from: endTime)
                let localEndTime = UTCToLocalTime(dateStr: strEndTime)
                
                cell.lblStartTime.text = localStartTime! + " - " + localEndTime!
            }else{
                cell.lblStartTime.text = localStartTime!
            }
        }else{
            cell.lblStartTime.text = ""
        }
        
        cell.backgroundColor = UIColor.clear
        //cell.imgUser.layer.borderColor = UIColor.white.cgColor
        return cell
    }else{
        let cell: UITableViewCell = UITableViewCell()
        return cell
    }
}
func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    tableView.deselectRow(at: indexPath, animated: true)
}

}




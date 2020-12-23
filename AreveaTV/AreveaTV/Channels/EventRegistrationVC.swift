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
import AVKit
import SendBirdSDK
import MUXSDKStats;
import CoreLocation
import EasyTipView
import SDWebImage
import WebKit
import Reachability
import AWSAppSync
import R5Streaming

class EventRegistrationVC: UIViewController,OpenChanannelChatDelegate{
    // MARK: - Variables Declaration
    
    @IBOutlet weak var viewBottom: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var txtProfile: UITextView!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    @IBOutlet weak var btnGetTickets: UIButton!
    @IBOutlet weak var lblAmount: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    
    var dicPerformerInfo = [String: Any]()
    var aryStreamInfo = [String: Any]()
    var aryUserSubscriptionInfo = [Any]()
    var orgId = 0;
    var performerId = 0;
    
    var streamVideoCode = ""
    var number_of_creators = 1
    var streamId = 0;
    var strSlug = "";
    var aryStreamAmounts = [Any]()
    var dicAmounts = [String: Any]()
    var detailItem = [String:Any]();
    var isLoaded = 0;
    var detailStreamItem: NSDictionary? {
        didSet {
            // Update the view.
            // self.configureView()
        }
    }
    var isShareScreenConfigured = false
    var backPressed = false
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var lblVideoDesc_info: UILabel!
    @IBOutlet weak var lblVideoTitle_info: UILabel!
    @IBOutlet weak var txtVideoDesc_Info: UITextView!
    @IBOutlet weak var imgPerformer: UIImageView!
    
    var age_limit = 0;
    @IBOutlet weak var txtComment: UITextField!
    @IBOutlet weak var txtEmoji: UITextField!
    
    @IBOutlet weak var sendUserMessageButton: UIButton!
    @IBOutlet weak var inputMessageInnerContainerViewBottomMargin: NSLayoutConstraint!
    @IBOutlet weak var liveStreamHeight: NSLayoutConstraint!
    
    var channelName = ""
    var paymentAmount = 0
    var streamPaymentMode = ""
    var strTitle = ""
    @IBOutlet weak var viewActivity: UIView!
    @IBOutlet weak var imgStreamThumbNail: UIImageView!
    @IBOutlet weak var lblStreamUnavailable: UILabel!
    @IBOutlet weak var heightTopView: NSLayoutConstraint?
    @IBOutlet weak var viewTop: UIView!
    
    var isVOD = false;
    var isAudio = false;
    var strAudioSource = ""
    var isStream = true;
    var isUpcoming = false;
    var streamVideoDesc = ""
    
    @IBOutlet weak var viewBtns: UIView?
    
    var resultData = [String:Any]()
    var amountWithCurrencyType = ""
    var saleStarts = false
    var checkSale = false
    var saleCompleted = false
    var stream_status = ""
    @IBOutlet weak var btnSubscribe: UIButton!
    @IBOutlet weak var ageDesc: UILabel!
    @IBOutlet weak var shareEventTop: NSLayoutConstraint!
    @IBOutlet weak var tblheight: NSLayoutConstraint!
    @IBOutlet weak var viewShareEvent: UIView!
    var channel_name_subscription = ""
    var arySubscriptionDetails = [Any]();
    var arySubscriptions = [Any]();
    var subscription_details = false
    var isUserSubscribe = true
    var currency_type = ""

    
    // MARK: - View Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        viewActivity.isHidden = true
        btnSubscribe.layer.borderWidth = 2
        btnSubscribe.layer.borderColor = UIColor.darkGray.cgColor
        lblTitle.text = strTitle
        
        if(UIDevice.current.userInterfaceIdiom == .pad){
            heightTopView?.constant = 60;
            viewTop.layoutIfNeeded()
        }
        btnSubscribe.isHidden = true
        if(self.channel_name_subscription == ""){
            self.channel_name_subscription = " "
        }
        btnSubscribe.isHidden = true
    }
    func delayWithSeconds(_ seconds: Double, completion: @escaping () -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            completion()
        }
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
        print("====applicationDidBecomeActive")
        //if user comes from payment redirection, need to refresh stream/vod
        getSubscriptionStatus()
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
        
        getSubscriptionStatus()
    }
    
    func delay(_ delay:Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }
    
    
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func subscribeBtnPressed(_ sender: UIButton){
        if(arySubscriptions.count > 0){
            subscribe(row: 0)
        }
    }
    
    
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                ////print(error.localizedDescription)
            }
        }
        return nil
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent // .default
    }
    
    
    // MARK: Handler for getCategoryOrganisations API
    func getEventBySlug(){
        let netAvailable = appDelegate.isConnectedToInternet()
        if(!netAvailable){
            showAlert(strMsg: "Please check your internet connection!")
            return
        }
        viewActivity.isHidden = false
        let url: String = appDelegate.baseURL +  "/getEventBySlug"
        let user_id = UserDefaults.standard.string(forKey: "user_id");
        let params: [String: Any] = ["userid":user_id ?? "","slug":strSlug]
        
        let headers: HTTPHeaders
        headers = [appDelegate.x_api_key: appDelegate.x_api_value]
        AF.request(url, method: .post,parameters: params, encoding: JSONEncoding.default,headers:headers)
            .responseJSON { response in
                self.viewActivity.isHidden = true
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any] {
                        //print("getEventBySlug JSON:",json)
                        if (json["statusCode"]as? String == "200"){
                            
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
    // MARK: Handler for getCategoryOrganisations API
    func registerEvent(){
        print("registerEvent")
        let netAvailable = appDelegate.isConnectedToInternet()
        if(!netAvailable){
            showAlert(strMsg: "Please check your internet connection!")
            return
        }
        viewActivity.isHidden = false
        let url: String = appDelegate.paymentBaseURL +  "/registerEvent"
        let user_id = UserDefaults.standard.string(forKey: "user_id");
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
        
        let params: [String: Any] = ["paymentInfo": ["paymentType": "pay_per_view","payment_type": "pay_per_view","organization_id": orgId,"currency": currency_type,"amount": 0,"stream_id": streamId,"streamInfo": ["id": streamId,"stream_video_title": stream_video_title,"organization_id": orgId,"amount":amount,"currency": currency_type,"stream_amounts":stream_amounts,"publish_date_time": publish_date_time,"video_thumbnail_image": video_thumbnail_image,"performer_id": performerId,"user_first_name": user_first_name,"user_last_name": user_last_name,"user_display_name": user_display_name,"channel_name": channel_name,"number_of_creators": self.number_of_creators,"stream_status": stream_status,"currency_type": currency_type,"expected_end_date_time": expected_end_date_time]]]
        //print("params:",params)
        
        let session_token = UserDefaults.standard.string(forKey: "session_token") ?? ""
        let headers : HTTPHeaders = [
            "Content-Type": "application/json",
            appDelegate.x_api_key:appDelegate.x_api_value,
            "Authorization": "Bearer " + session_token
        ]
        AF.request(url, method: .post,parameters: params, encoding: JSONEncoding.default,headers:headers)
            .responseJSON { response in
                self.viewActivity.isHidden = true
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any] {
                        print("registerEvent JSON:",json)
                        if (json["status"]as? Int == 0){
                            self.gotoStreamDetails()
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
    func utcToLocal(dateStr: String) -> String? {
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
        print("gotoStreamDetails")
        let storyboard = UIStoryboard(name: "Main", bundle: nil);
        let streamInfo = self.aryStreamInfo
        let stream_video_title = streamInfo["stream_video_title"] as? String ?? "Channel Details"
        appDelegate.isLiveLoad = "1"
        print("number_of_creators:",number_of_creators)
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
    // MARK: Handler for endSession API
    func getVodById(){
        let netAvailable = appDelegate.isConnectedToInternet()
        if(!netAvailable){
            showAlert(strMsg: "Please check your internet connection!")
            return
        }
        viewActivity.isHidden = false
        let url: String = appDelegate.baseURL +  "/getVodById"
        let user_id = UserDefaults.standard.string(forKey: "user_id");
        print("--self.streamId:",self.streamId)
        print("--self.streamId1:",String(self.streamId))
        
        let params: [String: Any] = ["userid":user_id ?? "","stream_id": String(self.streamId)]
        print("getVodById params:",params)
        
        let headers: HTTPHeaders = [appDelegate.x_api_key: appDelegate.x_api_value]
        
        AF.request(url, method: .post,parameters: params, encoding: JSONEncoding.default,headers:headers)
            .responseJSON { [self] response in
                self.viewActivity.isHidden = true
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any] {
                        print("getVodById JSON:",json)
                        if (json["statusCode"]as? String == "200"){
                            var USDPrice = [String]()
                            var GBPPrice = [String]()
                            var doubleGBPPrice = [Double]()
                            var doubleUSDPrice = [Double]()
                            
                            var eventStartDates = [Date]()
                            var eventEndDates = [Date]()
                            ////print(json["message"] as? String ?? "")
                            let data = json["Data"] as? [String:Any]
                            self.aryStreamInfo = data?["stream_info"] as? [String:Any] ?? [:]
                            let stream_info_key_exists = self.aryStreamInfo["id"]
                            if (stream_info_key_exists != nil){
                                
                                let streamObj = self.aryStreamInfo
                                self.streamId = streamObj["id"] as? Int ?? 0
                                self.age_limit = streamObj["age_limit"] as? Int ?? 0
                                self.streamVideoCode = streamObj["stream_video_code"] as? String ?? ""
                                let streamVideoTitle = streamObj["stream_video_title"] as? String ?? ""
                                //print("==streamVideoTitle:",streamVideoTitle)
                                
                                self.streamVideoDesc = streamObj["stream_video_description"] as? String ?? ""
                                if(self.streamVideoDesc == "null"){
                                    self.streamVideoDesc = ""
                                }
                                
                                // "currency_type" = USD;
                                self.currency_type = streamObj["currency_type"] as? String ?? ""
                                if(self.currency_type == "GBP"){
                                    self.currency_type = "£"
                                }else{
                                    self.currency_type = "$"
                                }
                                var strAmount = "0.0"
                                
                                if (streamObj["stream_payment_amount"] as? Double) != nil {
                                    strAmount = String(streamObj["stream_payment_amount"] as? Double ?? 0.0)
                                }else if (streamObj["stream_payment_amount"] as? String) != nil {
                                    strAmount = String(streamObj["stream_payment_amount"] as? String ?? "0.0")
                                }
                                let doubleAmount = Double(strAmount)
                                let amount = String(format: "%.02f", doubleAmount!)
                                self.amountWithCurrencyType = self.currency_type + amount
                                let titleWatchNow = "PAY | " + self.amountWithCurrencyType
                                //self.btnPayPerView.setTitle(titleWatchNow, for: .normal)
                                
                                let streamBannerURL = streamObj["video_banner_image"] as? String ?? ""
                                if let urlBanner = URL(string: streamBannerURL){
                                    var imageName = "sample_vod_square"
                                    if(UIDevice.current.userInterfaceIdiom == .pad){
                                        imageName = "sample-event"
                                    }
                                    self.imgStreamThumbNail.sd_setImage(with:urlBanner, placeholderImage: UIImage(named: imageName))
                                }
                                
                                self.paymentAmount = streamObj["stream_payment_amount"]as? Int ?? 0
                                //self.lblVideoTitle_info.text = streamVideoTitle
                                self.streamPaymentMode = streamObj["stream_payment_mode"] as? String ?? ""
                                self.strSlug = streamObj["slug"] as? String ?? "";
                                
                                let publish_date_time = streamObj["publish_date_time"] as? String ?? "";
                                let expected_end_date_time = streamObj["expected_end_date_time"] as? String ?? "";
                                let formatter = DateFormatter()
                                formatter.timeZone = NSTimeZone(abbreviation: "UTC") as TimeZone?
                                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                                if let publishDate = formatter.date(from: publish_date_time){
                                    if let expectedEndDate = formatter.date(from: expected_end_date_time){
                                        formatter.dateFormat = "E, dd MMM yyyy"
                                        let strPublishDate = formatter.string(from: publishDate)
                                        formatter.dateFormat = "dd MMM yyyy"
                                        let strExpectedEndDate = formatter.string(from: expectedEndDate)
                                        let dateFull = strPublishDate + " - " + strExpectedEndDate
                                        formatter.dateFormat = "hh:mm a"
                                        let startTime = formatter.string(from: publishDate)
                                        let endTime = formatter.string(from: expectedEndDate)
                                        let timeFull = startTime + "-" + endTime
                                        //print("timeFull:",timeFull)
                                        //print("dateFull:",dateFull)
                                        self.lblDate.text = dateFull
                                        //self.lblTime.text = timeFull
                                    }
                                }
                                
                                let stream_amounts = streamObj["stream_amounts"] as? String ?? "";
                                //print("stream_amounts:",stream_amounts)
                                
                                
                                if (stream_amounts != ""){
                                    self.dicAmounts = self.convertToDictionary(text: stream_amounts) ?? [:]
                                    let sub_vod = self.dicAmounts["sub_vod"] as? [Any] ?? [Any]()
                                    if(self.isUserSubscribe && sub_vod.count > 0){
                                        self.aryStreamAmounts = sub_vod
                                    }else if(self.isUserSubscribe && sub_vod.count == 0){
                                        let subscriberPayment = self.dicAmounts["subscriberPayment"] as? String ?? ""
                                        self.aryStreamAmounts = []
                                        if(subscriberPayment == "free"){
                                            self.lblAmount.text = "Free"
                                        }
                                    }else{
                                        let vod = self.dicAmounts["vod"] as? [Any] ?? [Any]()
                                        self.aryStreamAmounts = vod
                                    }
                                    
                                    //print("amounts:",self.aryStreamAmounts)
                                    // //print("amounts count::",amounts.count)
                                    for (index,_) in self.aryStreamAmounts.enumerated(){
                                        let element = self.aryStreamAmounts[index] as? [String : Any] ?? [String:Any]()
                                        //print("-- index:",index)
                                        
                                        //print("--amounts obj:",element)
                                        let amounts = element["amounts"]as? [Any] ?? [Any]()
                                        //print("--amounts:",amounts)
                                        for(j,_)in amounts.enumerated(){
                                            let object = amounts[j] as? [String : Any] ?? [String:Any]()
                                            let currency_type1 = object["currency_type"]as? String ?? "";
                                            var strAmount = "0.0"
                                            
                                            if (object["stream_payment_amount"] as? Double) != nil {
                                                strAmount = String(object["stream_payment_amount"] as? Double ?? 0.0)
                                            }else if (object["stream_payment_amount"] as? String) != nil {
                                                strAmount = String(object["stream_payment_amount"] as? String ?? "0.0")
                                            }
                                            let doubleAmount = Double(strAmount)
                                            let amount = String(format: "%.02f", doubleAmount!)
                                            if (currency_type1 == "USD"){
                                                USDPrice.append(amount);
                                            }
                                            else if (currency_type1 == "GBP"){
                                                GBPPrice.append(amount);
                                            }
                                            
                                        }
                                        doubleGBPPrice = GBPPrice.compactMap(Double.init)//["5.00","100.00"] to [5,1000]
                                        doubleGBPPrice.sort(by: <)//sort ascending
                                        
                                        doubleUSDPrice = USDPrice.compactMap(Double.init)//["5.00","100.00"] to [5,1000]
                                        doubleUSDPrice.sort(by: <)//sort ascending
                                        
                                        let booking_start_date = element["booking_start_date"] as? String ?? ""
                                        let booking_end_date = element["booking_end_date"] as? String ?? ""
                                        
                                        let formatter = DateFormatter()
                                        formatter.timeZone = NSTimeZone(abbreviation: "UTC") as TimeZone?
                                        //formatter.locale = Locale(identifier: "en_US_POSIX")
                                        formatter.dateFormat = "yyyy-MM-dd HH:mm"
                                        if let startDate = formatter.date(from: booking_start_date) {
                                            eventStartDates.append(startDate)
                                        }
                                        if let endDate = formatter.date(from: booking_end_date) {
                                            eventEndDates.append(endDate)
                                        }
                                    }
                                    eventStartDates.sort()
                                    eventEndDates.sort()
                                    
                                    var subCurrencyType = ""
                                    if(USDPrice.count > 0 && GBPPrice.count > 0){
                                        if(self.currency_type == "£"){
                                            subCurrencyType = "GBP"
                                        }else{
                                            subCurrencyType = "USD"
                                        }
                                    }
                                    else if(USDPrice.count > 0){
                                        subCurrencyType = "USD"
                                    }else if(GBPPrice.count > 0){
                                        subCurrencyType = "GBP"
                                    }
                                    if(subCurrencyType == "USD"){
                                        let firstValue = String(doubleUSDPrice[0])
                                        let lastValue = String(doubleUSDPrice[doubleUSDPrice.count - 1]);
                                        let amountDisplay = "$" + firstValue + " - " + "$" + lastValue;
                                        // //print("====amount in Dollars:",amountDisplay)
                                        if(firstValue == lastValue){
                                            self.amountWithCurrencyType = "$" + firstValue
                                        }else{
                                            self.amountWithCurrencyType = amountDisplay;
                                        }
                                        self.lblAmount.text = self.amountWithCurrencyType
                                        
                                    }else if(subCurrencyType == "GBP"){
                                        let firstValue = String(doubleGBPPrice[0])
                                        let lastValue = String(doubleGBPPrice[doubleGBPPrice.count - 1]);
                                        let amountDisplay = "£" + firstValue + " - " + "£" + lastValue;
                                        // //print("====amount in Euros:",amountDisplay)
                                        if(firstValue == lastValue){
                                            self.amountWithCurrencyType = "£" + firstValue
                                        }else{
                                            self.amountWithCurrencyType = amountDisplay
                                        }
                                        self.lblAmount.text = self.amountWithCurrencyType
                                        
                                    }
                                    // //print("===eventStartDates:",eventStartDates)
                                    // //print("===eventEndDates:",eventEndDates)
                                }else{
                                    self.lblAmount.text = "Free"//
                                }
                            }
                            let user_subscription_info = data?["user_subscription_info"] != nil
                            if(user_subscription_info){
                                self.aryUserSubscriptionInfo = data?["user_subscription_info"] as? [Any] ?? [Any]()
                            }
                            let user_age_limit = UserDefaults.standard.integer(forKey:"user_age_limit");
                            // //print("---user_age_limit:",user_age_limit)
                            //   //print("---age_limit:",self.age_limit)
                            if(self.streamPaymentMode == "free"){
                                self.lblAmount.text = "Free"//Free
                            }
                            if (self.age_limit <= user_age_limit || self.age_limit == 0){
                                if (self.aryUserSubscriptionInfo.count == 0 && self.isVOD){
                                    //if user does not pay amount
                                    self.btnGetTickets.isHidden = false
                                }else{
                                    self.btnGetTickets.isHidden = true
                                    self.lblAmount.isHidden = true
                                    self.lblDate.isHidden = true
                                    self.lblTime.isHidden = true
                                    if (stream_info_key_exists != nil){
                                        let streamObj = self.aryStreamInfo
                                        
                                        self.btnGetTickets.isHidden = true;
                                        self.isStream = false;
                                        if (self.isVOD){
                                            
                                            
                                        }else{
                                            //audio
                                            
                                        }
                                    }
                                }
                            }else{
                                //self.showAlert(strMsg: "This vidoe may be inappropriate for some users")
                                self.btnGetTickets.isHidden = true;
                                //self.btnGetTickets.isUserInteractionEnabled = false
                                // self.btnGetTickets.setImage(UIImage.init(named: "eye-cross"), for: .normal)
                                self.lblStreamUnavailable.text = "This vidoe may be inappropriate for some users"
                                
                            }
                            
                            let performer_info = data?["performer_info"] != nil
                            if(performer_info){
                                self.dicPerformerInfo = data?["performer_info"] as? [String : Any] ?? [String:Any]()
                                let performerName = self.dicPerformerInfo["performer_display_name"] as? String ?? ""
                                var firstChar = ""
                                let fullNameArr = performerName.components(separatedBy: " ")
                                let firstName: String = fullNameArr[0]
                                var lastName = ""
                                if (fullNameArr.count > 1){
                                    lastName = fullNameArr[1]
                                }
                                if (lastName == ""){
                                    firstChar = String(firstName.first!)
                                }else{
                                    firstChar = String(firstName.first!) + String(lastName.first!)
                                }
                                
                                let videoDesc = self.streamVideoDesc;
                                let creatorName = "Creator Name: " + performerName;
                                self.txtVideoDesc_Info.text = videoDesc  + "\n\n" + creatorName
                                if (stream_info_key_exists == nil){
                                    //performer_profile_banner
                                    let performer_profile_banner = self.dicPerformerInfo["performer_profile_banner"] as? String ?? ""
                                    if let urlBanner = URL(string: performer_profile_banner){
                                        self.imgStreamThumbNail.sd_setImage(with: urlBanner, placeholderImage: UIImage(named: "sample_vod_square"))
                                    }
                                }
                                let performer_profile_banner1 = self.dicPerformerInfo["performer_profile_pic"] as? String ?? ""
                                
                            }
                            
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
                        print("ERVC LiveEventById JSON:",json)
                        if (json["statusCode"]as? String == "200"){
                            var USDPrice = [String]()
                            var GBPPrice = [String]()
                            var doubleGBPPrice = [Double]()
                            var doubleUSDPrice = [Double]()
                            
                            var eventStartDates = [Date]()
                            var eventEndDates = [Date]()
                            let data = json["Data"] as? [String:Any]
                            self.resultData = data ?? [:]
                            self.aryStreamInfo = data?["stream_info"] as? [String:Any] ?? [:]
                            let stream_info_key_exists = self.aryStreamInfo["id"]
                            if (stream_info_key_exists != nil){
                                let streamObj = self.aryStreamInfo
                                self.streamId = streamObj["id"] as? Int ?? 0
                                self.age_limit = streamObj["age_limit"] as? Int ?? 0
                                if (self.age_limit <= 15) {
                                    self.ageDesc.text = "Family Friendly";
                                } else if (self.age_limit == 16 || self.age_limit <= 17) {
                                    self.ageDesc.text = "Adults Supervision"
                                } else if (self.age_limit == 18 || self.age_limit > 18) {
                                    self.ageDesc.text = "Adults Only"
                                }
                                self.streamVideoCode = streamObj["stream_video_code"] as? String ?? ""
                                let streamVideoTitle = streamObj["stream_video_title"] as? String ?? ""
                                self.number_of_creators = streamObj["number_of_creators"] as? Int ?? 1
                                
                                self.streamVideoDesc = streamObj["stream_video_description"] as? String ?? ""
                                if(self.streamVideoDesc == "null"){
                                    self.streamVideoDesc = ""
                                }
                                // "currency_type" = USD;
                                self.currency_type = streamObj["currency_type"] as? String ?? ""
                                if(self.currency_type == "GBP"){
                                    self.currency_type = "£"
                                }else{
                                    self.currency_type = "$"
                                }
                                var strAmount = "0.0"
                                
                                if (streamObj["stream_payment_amount"] as? Double) != nil {
                                    strAmount = String(streamObj["stream_payment_amount"] as? Double ?? 0.0)
                                }else if (streamObj["stream_payment_amount"] as? String) != nil {
                                    strAmount = String(streamObj["stream_payment_amount"] as? String ?? "0.0")
                                }
                                let doubleAmount = Double(strAmount)
                                let amount = String(format: "%.02f", doubleAmount!)
                                self.amountWithCurrencyType = self.currency_type + amount
                                
                                let streamBannerURL = streamObj["video_banner_image"] as? String ?? ""
                                if let urlBanner = URL(string: streamBannerURL){
                                    var imageName = "sample_vod_square"
                                    if(UIDevice.current.userInterfaceIdiom == .pad){
                                        imageName = "sample-event"
                                    }
                                    self.imgStreamThumbNail.sd_setImage(with:urlBanner, placeholderImage: UIImage(named: imageName))
                                }
                                
                                self.paymentAmount = streamObj["stream_payment_amount"]as? Int ?? 0
                                // self.lblVideoTitle_info.text = streamVideoTitle
                                self.streamPaymentMode = streamObj["stream_payment_mode"] as? String ?? ""
                                self.strSlug = streamObj["slug"] as? String ?? "";
                                
                                let publish_date_time = streamObj["publish_date_time"] as? String ?? "";
                                let expected_end_date_time = streamObj["expected_end_date_time"] as? String ?? "";
                                let formatter = DateFormatter()
                                formatter.timeZone = NSTimeZone(abbreviation: "UTC") as TimeZone?
                                formatter.locale = Locale(identifier: "en_US_POSIX")
                                
                                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                                if let publishDate = formatter.date(from: publish_date_time){
                                    if let expectedEndDate = formatter.date(from: expected_end_date_time){
                                        formatter.dateFormat = "E,MMM dd yyyy"
                                        let strPublishDate = formatter.string(from: publishDate)
                                        formatter.dateFormat = "MMM dd yyyy"
                                        let strExpectedEndDate = formatter.string(from: expectedEndDate)
                                        let strStartDate = strPublishDate.convertDateString()
                                        let strEndDate = strExpectedEndDate.convertDateString()
                                        var dateFull = ""
                                        if(strStartDate == strEndDate){
                                            //if start and end dates are need to show one date
                                            dateFull = strPublishDate
                                        }else{
                                            dateFull = strPublishDate + " - " + strExpectedEndDate
                                        }
                                        
                                        formatter.dateFormat = "hh:mm a"
                                        let startTime = formatter.string(from: publishDate)
                                        let endTime = formatter.string(from: expectedEndDate)
                                        let localStartTime = utcToLocal(dateStr: startTime) ?? ""
                                        let localEndTime = utcToLocal(dateStr: endTime) ?? ""
                                        
                                        let timeFull = localStartTime + " - " + localEndTime
                                        self.lblDate.text = dateFull
                                        self.lblTime.text = timeFull
                                    }
                                }
                                let stream_amounts = streamObj["stream_amounts"] as? String ?? "";
                                // print("stream_amounts:",stream_amounts)
                                
                                if (stream_amounts != ""){
                                    self.dicAmounts = self.convertToDictionary(text: stream_amounts) ?? [:]
                                    // print("==dicAmounts:",self.dicAmounts)
                                    let sub_live_stream = self.dicAmounts["sub_live_stream"] as? [Any] ?? [Any]()
                                    if(isUserSubscribe && sub_live_stream.count > 0){
                                        aryStreamAmounts = sub_live_stream
                                        
                                    }else if(isUserSubscribe && sub_live_stream.count == 0){
                                        let subscriberPayment = self.dicAmounts["subscriberPayment"] as? String ?? ""
                                        aryStreamAmounts = []
                                        if(subscriberPayment == "free"){
                                            self.lblAmount.text = "Free"
                                        }
                                    }else{
                                        let live_stream = self.dicAmounts["live_stream"] as? [Any] ?? [Any]()
                                        aryStreamAmounts = live_stream
                                    }
                                    print("amounts:",self.aryStreamAmounts)
                                    // //print("amounts count::",amounts.count)
                                    for (index,_) in self.aryStreamAmounts.enumerated(){
                                        let element = self.aryStreamAmounts[index] as? [String : Any] ?? [String:Any]()
                                        //print("-- index:",index)
                                        
                                        //print("--amounts obj:",element)
                                        let amounts = element["amounts"]as? [Any] ?? [Any]()
                                        //print("--amounts:",amounts)
                                        for(j,_)in amounts.enumerated(){
                                            let object = amounts[j] as? [String : Any] ?? [String:Any]()
                                            let currency_type1 = object["currency_type"]as? String ?? "";
                                            var strAmount = "0.0"
                                            
                                            if (object["stream_payment_amount"] as? Double) != nil {
                                                strAmount = String(object["stream_payment_amount"] as? Double ?? 0.0)
                                            }else if (object["stream_payment_amount"] as? String) != nil {
                                                strAmount = String(object["stream_payment_amount"] as? String ?? "0.0")
                                            }
                                            let doubleAmount = Double(strAmount)
                                            let amount = String(format: "%.02f", doubleAmount!)
                                            if (currency_type1 == "USD"){
                                                USDPrice.append(amount);
                                            }
                                            else if (currency_type1 == "GBP"){
                                                GBPPrice.append(amount);
                                            }
                                            
                                        }
                                        doubleGBPPrice = GBPPrice.compactMap(Double.init)//["5.00","100.00"] to [5,1000]
                                        doubleGBPPrice.sort(by: <)//sort ascending
                                        
                                        doubleUSDPrice = USDPrice.compactMap(Double.init)//["5.00","100.00"] to [5,1000]
                                        doubleUSDPrice.sort(by: <)//sort ascending
                                        
                                        
                                        let booking_start_date = element["booking_start_date"] as? String ?? ""
                                        let booking_end_date = element["booking_end_date"] as? String ?? ""
                                        
                                        let formatter = DateFormatter()
                                        formatter.locale = Locale(identifier: "en_US_POSIX")
                                        
                                        // formatter.timeZone = NSTimeZone(abbreviation: "UTC") as TimeZone?
                                        //formatter.locale = Locale(identifier: "en_US_POSIX")
                                        formatter.dateFormat = "yyyy-MM-dd HH:mm"
                                        if let startDate = formatter.date(from: booking_start_date) {
                                            eventStartDates.append(startDate)
                                        }
                                        if let endDate = formatter.date(from: booking_end_date) {
                                            eventEndDates.append(endDate)
                                        }
                                    }
                                    eventStartDates.sort()
                                    eventEndDates.sort()
                                    
                                    var subCurrencyType = ""
                                    if(USDPrice.count > 0 && GBPPrice.count > 0){
                                        if(self.currency_type == "£"){
                                            subCurrencyType = "GBP"
                                        }else{
                                            subCurrencyType = "USD"
                                        }
                                    }
                                    else if(USDPrice.count > 0){
                                        subCurrencyType = "USD"
                                    }else if(GBPPrice.count > 0){
                                        subCurrencyType = "GBP"
                                    }
                                    print("==currency_type:",currency_type)
                                    print("==subCurrencyType:",subCurrencyType)
                                    
                                    if(subCurrencyType == "USD"){
                                        let firstValue = String(doubleUSDPrice[0])
                                        let lastValue = String(doubleUSDPrice[doubleUSDPrice.count - 1]);
                                        let amountDisplay = "$" + firstValue + " - " + "$" + lastValue;
                                        // //print("====amount in Dollars:",amountDisplay)
                                        if(firstValue == lastValue){
                                            self.amountWithCurrencyType = "$" + firstValue
                                        }else{
                                            self.amountWithCurrencyType = amountDisplay
                                        }
                                        self.lblAmount.text = self.amountWithCurrencyType
                                        
                                    }else if(subCurrencyType == "GBP"){
                                        let firstValue = String(doubleGBPPrice[0])
                                        let lastValue = String(doubleGBPPrice[doubleGBPPrice.count - 1]);
                                        let amountDisplay = "£" + firstValue + " - " + "£" + lastValue;
                                        // //print("====amount in Euros:",amountDisplay)
                                        if(firstValue == lastValue){
                                            self.amountWithCurrencyType = "£" + firstValue
                                        }else{
                                            self.amountWithCurrencyType = amountDisplay
                                        }
                                        self.lblAmount.text = self.amountWithCurrencyType
                                        
                                        
                                    }
                                    print("===eventStartDates:",eventStartDates)
                                    print("===eventEndDates:",eventEndDates)
                                    
                                    if(eventStartDates.count > 0 && eventEndDates.count > 0){
                                        let currentDate = Date()
                                        let dateFormatter = DateFormatter()
                                        // dateFormatter.timeZone = NSTimeZone(abbreviation: "UTC") as TimeZone?
                                        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                                        
                                        dateFormatter.dateFormat = "MMM dd, yyyy"
                                        let todaysDate = dateFormatter.string(from: currentDate)
                                        let today = dateFormatter.date(from: todaysDate)
                                        let startDate = eventStartDates[0]
                                        let endDate = eventEndDates[eventEndDates.count-1]
                                        //print("startDate:",startDate,";")
                                        //print("endDate:",endDate,";")
                                        //print("today:",today!)
                                        
                                        //print("startDate > today:",startDate > today!)
                                        //print("today! >= startDate && today! <= endDate:",today! >= startDate && today! <= endDate)
                                        //print("today! > endDate:",today! > endDate)
                                        
                                        //If start date is > today
                                        if(startDate > today!)
                                        {
                                            print("==saleStarts")
                                            self.saleStarts = true;
                                        }
                                        //today >= start date && today <= end date
                                        else if(today! >= startDate && today! <= endDate)
                                        {
                                            print("==checkSale")
                                            self.checkSale = true;
                                        }
                                        //If today is > endDate
                                        else if(today! > endDate)
                                        {
                                            print("==saleCompleted")
                                            self.saleCompleted = true;
                                        }
                                    }
                                }//if (stream_amounts != "")
                                else{
                                    self.lblAmount.text = "Free"//
                                }
                                
                                
                            }else{
                                
                            }
                            let user_subscription_info = data?["user_subscription_info"] != nil
                            if(user_subscription_info){
                                self.aryUserSubscriptionInfo = data?["user_subscription_info"] as? [Any] ?? [Any]()
                            }
                            let user_age_limit = UserDefaults.standard.integer(forKey:"user_age_limit");
                            
                            if(self.streamPaymentMode == "free"){
                                self.lblAmount.text = "Free"
                            }
                            let streamObj = self.aryStreamInfo
                            stream_status = streamObj["stream_status"] as? String ?? ""
                            if(stream_status == "completed"){
                                //uncomment below line
                                //self.setLiveStreamConfig()
                                self.lblStreamUnavailable.text = "Sale is completed!"
                                btnGetTickets.isHidden = true
                                return
                                
                            }
                            if (self.age_limit <= user_age_limit || self.age_limit == 0){
                                
                                if (self.aryUserSubscriptionInfo.count == 0){
                                    //if user does not pay amount
                                    self.btnGetTickets.isHidden = false
                                    //                                    self.shareEventTop.constant = 0;
                                    //                                    viewShareEvent.layoutIfNeeded()
                                    if(self.saleStarts){
                                        print("==self.saleStarts")
                                        if(eventStartDates.count > 0){
                                            self.btnGetTickets.isHidden = true
                                            let startDate = eventStartDates[0]
                                            let formatter = DateFormatter()
                                            // formatter.timeZone = NSTimeZone(abbreviation: "UTC") as TimeZone?
                                            formatter.locale = Locale(identifier: "en_US_POSIX")
                                            
                                            formatter.dateFormat = "dd MMM yyyy"
                                            let myString = formatter.string(from: startDate) // string purpose I add here
                                            self.lblStreamUnavailable.text = "Sale Starts On " + myString
                                            btnGetTickets.isHidden = true
                                            
                                        }
                                    }else if(self.saleCompleted){
                                        self.btnGetTickets.isHidden = true
                                        self.lblStreamUnavailable.text = "Sale is completed!"
                                    }
                                    
                                }else{
                                    self.btnGetTickets.isHidden = true
                                    
                                    //                                    self.shareEventTop.constant = -55;
                                    //                                    viewShareEvent.layoutIfNeeded()
                                    // self.lblAmount.isHidden = true
                                    // self.lblDate.isHidden = true
                                    //  self.lblTime.isHidden = true
                                    
                                    if (stream_info_key_exists != nil){
                                        let streamObj = self.aryStreamInfo
                                        if (streamObj["stream_vod"]as? String == "stream" && self.isVOD == false && self.isAudio == false){
                                            
                                            //self.lblStreamUnavailable.text = "";
                                            //print("==checkSale:",self.checkSale)
                                            //print("==saleStarts:",self.saleStarts)
                                            //print("==saleCompleted:",self.saleCompleted)
                                            
                                            if(self.checkSale && !self.saleStarts){
                                                gotoStreamDetails()
                                            }else if(self.saleStarts){
                                                print("==self.saleStarts")
                                                if(eventStartDates.count > 0){
                                                    self.btnGetTickets.isHidden = true
                                                    let startDate = eventStartDates[0]
                                                    let formatter = DateFormatter()
                                                    // formatter.timeZone = NSTimeZone(abbreviation: "UTC") as TimeZone?
                                                    formatter.locale = Locale(identifier: "en_US_POSIX")
                                                    
                                                    formatter.dateFormat = "dd MMM yyyy"
                                                    let myString = formatter.string(from: startDate) // string purpose I add here
                                                    self.lblStreamUnavailable.text = "Sale Starts On " + myString
                                                    btnGetTickets.isHidden = true
                                                    
                                                }
                                            }else if(self.saleCompleted){
                                                self.btnGetTickets.isHidden = true
                                                self.lblStreamUnavailable.text = "Sale is completed!"
                                                
                                            }
                                            if(!self.checkSale && !self.saleStarts && !self.saleCompleted && self.lblAmount.text == "Free"){
                                                gotoStreamDetails()
                                            }
                                        }else{
                                            self.isStream = false;
                                            if (self.isVOD || streamObj["stream_vod"]as? String == "vod"){
                                                
                                            }else{
                                                if(self.isAudio){
                                                    //audio
                                                }else{
                                                    //if stream_vod value is not stream or not vod
                                                    
                                                }
                                            }
                                        }
                                    }
                                }
                            }else{
                                //self.showAlert(strMsg: "This vidoe may be inappropriate for some users")
                                self.btnGetTickets.isHidden = true;
                                //self.btnGetTickets.isUserInteractionEnabled = false
                                // self.btnGetTickets.setImage(UIImage.init(named: "eye-cross"), for: .normal)
                                self.lblStreamUnavailable.text = "This vidoe may be inappropriate for some users"
                                
                                
                            }
                            
                            let performer_info = data?["performer_info"] != nil
                            if(performer_info){
                                self.dicPerformerInfo = data?["performer_info"] as? [String : Any] ?? [String:Any]()
                                let performerName = self.dicPerformerInfo["performer_display_name"] as? String ?? ""
                                var firstChar = ""
                                
                                let fullNameArr = performerName.components(separatedBy: " ")
                                let firstName: String = fullNameArr[0]
                                var lastName = ""
                                if (fullNameArr.count > 1){
                                    lastName = fullNameArr[1]
                                }
                                if (lastName == ""){
                                    firstChar = String(firstName.first!)
                                }else{
                                    firstChar = String(firstName.first!) + String(lastName.first!)
                                }
                                // self.lblPerformerName.text = firstChar
                                /* var performer_bio = self.dicPerformerInfo["performer_bio"] as? String ?? ""
                                 performer_bio = performer_bio.htmlToString
                                 
                                 self.txtProfile.text = performerName + "\n" + performer_bio*/
                                let videoDesc = self.streamVideoDesc;
                                let creatorName = "Creator Name: " + performerName;
                                self.txtVideoDesc_Info.text = videoDesc  + "\n" + creatorName
                                self.txtVideoDesc_Info.text = self.txtVideoDesc_Info.text.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
                                //self.txtVideoDesc_Info.backgroundColor = UIColor.red
                                
                                if (stream_info_key_exists == nil){
                                    //performer_profile_banner
                                    let performer_profile_banner = self.dicPerformerInfo["performer_profile_banner"] as? String ?? ""
                                    if let urlBanner = URL(string: performer_profile_banner){
                                        self.imgStreamThumbNail.sd_setImage(with: urlBanner, placeholderImage: UIImage(named: "sample_vod_square"))
                                    }
                                }
                                let performer_profile_banner1 = self.dicPerformerInfo["performer_profile_pic"] as? String ?? ""
                                if let urlBanner = URL(string: performer_profile_banner1){
                                    //                                    self.imgPerformer.sd_setImage(with: urlBanner, placeholderImage: UIImage(named: "user"))
                                    //                                    self.imgPerformer.layer.cornerRadius = self.imgPerformer.frame.size.width/2
                                    //                                    self.imgPerformer.isHidden = false
                                }else{
                                    //                                    self.imgPerformer.layer.cornerRadius = 0
                                    //                                    self.imgPerformer.isHidden = true
                                }
                                ////print("self.app_id_for_adds:",self.app_id_for_adds)
                            }
                        }
                        else{
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
    
    // MARK: - orientation Handlers
    func getAppversion() -> String {
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as! String
        let build = dictionary["CFBundleVersion"] as! String
        return "\(version).\(build)"
    }
    
    func saveToJsonFile() {
        // Get the url of Persons.json in document directory
        guard let documentDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let fileUrl = documentDirectoryUrl.appendingPathComponent("metrics.json")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MMM-yyyy hh:mm a"//14-Aug-2020 12:58 PM
        let time = dateFormatter.string(from: Date())
        let appName = Bundle.main.infoDictionary!["CFBundleName"] as! String
        
        let fileData = [["appName":appName,"appVersion":"v" + getAppversion(),"platform":"iOS","date":time]]
        
        // Transform array into data and save it into file
        do {
            let data = try JSONSerialization.data(withJSONObject: fileData, options: [])
            try data.write(to: fileUrl, options: [])
        } catch {
            //print(error)
        }
    }
    
    
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
        if(self.lblAmount.text == "Free"){
            print("free")
            registerEvent()
        }else{
            print("paid")
            let storyboard = UIStoryboard(name: "Main", bundle: nil);
            let streamInfo = self.aryStreamInfo
            let stream_video_title = streamInfo["stream_video_title"] as? String ?? "Channel Details"
            appDelegate.isLiveLoad = "1"
            let vc = storyboard.instantiateViewController(withIdentifier: "TicketTypesVC") as! TicketTypesVC
            vc.orgId = orgId
            vc.streamId = streamId
            vc.delegate = self
            vc.performerId = performerId
            vc.strTitle = stream_video_title
            vc.isCameFromGetTickets = true
            vc.channel_name_subscription = channel_name_subscription
            vc.isVOD = isVOD
            vc.isUpcoming = isUpcoming
            vc.aryStreamAmounts = aryStreamAmounts
            self.navigationController?.pushViewController(vc, animated: true)
            
        }
    }
    // MARK: - Button Actions
    @IBAction func tapShare(){
        print("share")
        
        let url = appDelegate.websiteURL + "/event/" + self.strSlug
        //print(url)
        let textToShare = [url]
        // set up activity view controller
        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
        activityViewController.excludedActivityTypes = [.airDrop]
        
        if let popoverController = activityViewController.popoverPresentationController {
            popoverController.sourceRect = CGRect(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2, width: 0, height: 0)
            popoverController.sourceView = self.view
            popoverController.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
        }
        
        self.present(activityViewController, animated: true, completion: nil)
        
    }
    func getSubscriptionStatus(){
        let netAvailable = appDelegate.isConnectedToInternet()
        if(!netAvailable){
            showAlert(strMsg: "Please check your internet connection!")
            return
        }
        viewActivity.isHidden = false
        let url: String = appDelegate.FCMBaseURL +  "/getSubscriptionStatus"
        let user_id = UserDefaults.standard.string(forKey: "user_id");
        let params: [String: Any] = ["user_id":user_id ?? "","channel_url":self.channel_name_subscription]
        //print("getSubscriptionStatus params:",params)
        let headers: HTTPHeaders
        headers = [appDelegate.x_api_key: appDelegate.x_api_value]
        AF.request(url, method: .post,parameters: params, encoding: JSONEncoding.default,headers:headers)
            .responseJSON { [self] response in
                self.viewActivity.isHidden = true
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any] {
                        print("getSubscriptionStatus JSON:",json)
                        if (json["statusCode"]as? String == "200"){
                            let data = json["Data"] as? [Any] ?? [Any]();
                            // print("Data:",data)
                            if (data.count > 0){
                                let streamObj = data[0] as? [String: Any] ?? [:]
                                let subscription_status = streamObj["subscription_status"] as? Bool ?? false
                                let subscription_status1 = streamObj["subscription_status"] as? Int ?? 0
                                
                                print("==subscription_status:",subscription_status)
                                
                                let subscription_end_date = streamObj["subscription_end_date"] as? String ?? "";
                                let formatter = DateFormatter()
                                let date = Date()
                                formatter.timeZone = NSTimeZone(abbreviation: "UTC") as TimeZone?
                                formatter.locale = Locale(identifier: "en_US_POSIX")
                                var endDate = date
                                if let subEndDate = formatter.date(from: subscription_end_date){
                                    print("subEndDate:",subEndDate)
                                    endDate = subEndDate
                                }
                                if(!subscription_status){
                                    if(date.isSmallerThan(endDate)){
                                        self.isUserSubscribe = true
                                    }else {
                                        self.isUserSubscribe = false;
                                    }
                                } else {
                                    self.isUserSubscribe = true;
                                }
                            }else {
                                self.isUserSubscribe = false;
                            }
                            
                            getChannelSubscriptionPlans()
                        }else{
                            self.isUserSubscribe = false;
                            btnSubscribe.isHidden = true
                            self.shareEventTop.constant = 5;
                            viewShareEvent.layoutIfNeeded()
                            let strError = json["message"] as? String
                            ////print("strError1:",strError ?? "")
                            self.showAlert(strMsg: strError ?? "")
                        }
                        if(isVOD || isAudio){
                            getVodById()
                        }else{
                            LiveEventById()//to handle payments calling this method after getSubscriptionStatus() called
                        }
                    }
                    
                case .failure(let error):
                    btnSubscribe.isHidden = true
                    let errorDesc = error.localizedDescription.replacingOccurrences(of: "URLSessionTask failed with error:", with: "")
                    self.showAlert(strMsg: errorDesc)
                    self.viewActivity.isHidden = true
                    
                }
            }
    }
    
    func subscribe(row:Int){
        //print("row:",row)
        let subscribeObj = self.arySubscriptions[row] as? [String : Any] ?? [:];
        //print("subscribeObj:",subscribeObj)
        let planId = subscribeObj["id"] as? Int ?? 0
        //print("planId:",planId)
        let user_id = UserDefaults.standard.string(forKey: "user_id");
        let strUserId = user_id ?? "1"
        // https://dev1.arevea.com/subscribe-payment?channel_name=chirantan-patel&user_id=101097275&plan_id=1311
        
        let urlOpen = appDelegate.websiteURL + "/subscribe-payment?channel_name=" + self.channel_name_subscription + "&user_id=" + strUserId + "&plan_id=" + String(planId)
        guard let url = URL(string: urlOpen) else { return }
        print("url to open:",url)
        UIApplication.shared.open(url)
    }
    // MARK: Handler for getChannelSubscriptionPlans API
    func getChannelSubscriptionPlans(){
        //channel_name_subscription = "dev-tv-2019"
        let netAvailable = appDelegate.isConnectedToInternet()
        if(!netAvailable){
            showAlert(strMsg: "Please check your internet connection!")
            return
        }
        viewActivity.isHidden = false
        let url: String = appDelegate.FCMBaseURL +  "/getChannelSubscriptionPlans"
        let user_id = UserDefaults.standard.string(forKey: "user_id");
        //below line need to update
        let params: [String: Any] = ["user_id":user_id ?? "","channel_name":channel_name_subscription,"channel_url":channel_name_subscription]
        print("getChannelSubscriptionPlans params:",params)
        let headers: HTTPHeaders
        headers = [appDelegate.x_api_key: appDelegate.x_api_value]
        AF.request(url, method: .post,parameters: params, encoding: JSONEncoding.default,headers:headers)
            .responseJSON { [self] response in
                self.viewActivity.isHidden = true
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any] {
                        print("getChannelSubscriptionPlans JSON:",json)
                        if (json["statusCode"]as? String == "200"){
                            self.arySubscriptions = []
                            let data = json["Data"] as? [Any] ?? [Any]();
                            // print("Data:",data)
                            if (data.count > 0){
                                let selectedObj = data[0] as? [String: Any] ?? [:]
                                let plans = selectedObj["plans"] as? [String: Any] ?? [:]
                                self.arySubscriptions = plans["subscriptionsData"] as? [Any] ?? [Any]();
                            }
                            subscription_details = false
                            arySubscriptionDetails = json["subscription_details"] as? [Any] ?? [Any]();
                            if(arySubscriptionDetails.count > 0){
                                subscription_details = true
                            }
                           
                            
                            //event does not have any plan
                            if(arySubscriptions.count == 0){
                                btnSubscribe.isHidden = true
                                self.shareEventTop.constant = 5;
                                viewShareEvent.layoutIfNeeded()
                            }else{
                                if(self.isUserSubscribe){
                                    btnSubscribe.isHidden = true
                                    self.shareEventTop.constant = 5;
                                    viewShareEvent.layoutIfNeeded()
                                }else{
                                    btnSubscribe.isHidden = false
                                    self.shareEventTop.constant = 65;
                                    viewShareEvent.layoutIfNeeded()
                                }
                            }
                            
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
    func getAmount(){
        
    }
    
    
}
extension String {
    func convertDateString() -> String? {
        return convert(dateString: self, fromDateFormat: "yyyy-MM-dd HH:mm:ss", toDateFormat: "yyyy-MM-dd")
    }
    func convertDateString1() -> String? {
        return convert(dateString: self, fromDateFormat: "yyyy-MM-dd HH:mm:ss", toDateFormat: "yyyy-MM-dd HH:mm:ss")
    }
    func convert(dateString: String, fromDateFormat: String, toDateFormat: String) -> String? {
        let fromDateFormatter = DateFormatter()
        fromDateFormatter.dateFormat = fromDateFormat
        if let fromDateObject = fromDateFormatter.date(from: dateString) {
            let toDateFormatter = DateFormatter()
            toDateFormatter.dateFormat = toDateFormat
            let newDateString = toDateFormatter.string(from: fromDateObject)
            return newDateString
        }
        return nil
    }
    
}
extension Date {
    
    func isEqualTo(_ date: Date) -> Bool {
        return self == date
    }
    
    func isGreaterThan(_ date: Date) -> Bool {
        return self > date
    }
    
    func isSmallerThan(_ date: Date) -> Bool {
        return self < date
    }
    
    // Convert local time to UTC (or GMT)
    func toGlobalTime() -> Date {
        let timezone = TimeZone.current
        let seconds = -TimeInterval(timezone.secondsFromGMT(for: self))
        return Date(timeInterval: seconds, since: self)
    }
    
    // Convert UTC (or GMT) to local time
    func toLocalTime() -> Date {
        let timezone = TimeZone.current
        let seconds = TimeInterval(timezone.secondsFromGMT(for: self))
        return Date(timeInterval: seconds, since: self)
    }
    
}



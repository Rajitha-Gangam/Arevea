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
import AMPopTip
import SafariServices

class EventRegistrationVC: UIViewController,OpenChanannelChatDelegate,UICollectionViewDataSource,SponsorsCVCDelegate,UICollectionViewDelegateFlowLayout,UITableViewDataSource,UITableViewDelegate,SFSafariViewControllerDelegate{
    
    
    
    
    // MARK: - Variables Declaration
    
    @IBOutlet weak var viewBottom: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    @IBOutlet weak var btnGetTickets: UIButton!
    @IBOutlet weak var lblAmount: UILabel!
    @IBOutlet weak var lblMonth: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblYear: UILabel!
    
    //@IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var imgWallet: UIImageView!
    
    var dicPerformerInfo = [String: Any]()
    var aryStreamInfo = [String: Any]()
    var aryUserSubscriptionInfo = [Any]()
    
    var streamVideoCode = ""
    var number_of_creators = 1
    var aryStreamAmounts = [Any]()
    var dicAmounts = [String: Any]()
    var detailItem = [String:Any]();
    var aryCurrencies = [Any]();
    var aryAgendaGuestList = [Any]();
    var isLoaded = 0;
    var arysubEvents = [Any]();
    var aryTicketIds = [Any]();
    var arySelectedSubEvents = [[String:Any]]();
    var tempArySelectedSubEvents = [Any]();
    
    var aryAgenda = [Any]();
    
    var aryTickets = [Any]();
    var detailStreamItem: NSDictionary? {
        didSet {
            // Update the view.
            // self.configureView()
        }
    }
    var isShareScreenConfigured = false
    var backPressed = false
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var txtVideoDesc_Overview: UITextView!
    @IBOutlet weak var txtTerms: UITextView!
    @IBOutlet weak var tblSchedule: UITableView!
    @IBOutlet weak var tblSpeakers: UITableView!
    @IBOutlet weak var tblSponsors: UITableView!
    @IBOutlet weak var tblHost: UITableView!
    
    
    var age_limit = 0;
    
    
    @IBOutlet weak var sendUserMessageButton: UIButton!
    @IBOutlet weak var inputMessageInnerContainerViewBottomMargin: NSLayoutConstraint!
    @IBOutlet weak var heightDesc: NSLayoutConstraint!
    
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
    
    
    var resultData = [String:Any]()
    var amountWithCurrencyType = ""
    var saleStarts = false
    var checkSale = false
    var saleCompleted = false
    var stream_status = ""
    @IBOutlet weak var btnSubscribe: UIButton!
    @IBOutlet weak var btnShare: UIButton!
    
    @IBOutlet weak var ageDesc: UILabel!
    @IBOutlet weak var shareEventTop: NSLayoutConstraint!
    @IBOutlet weak var tblheight: NSLayoutConstraint!
    @IBOutlet weak var viewShareEvent: UIView!
    var arySubscriptionDetails = [Any]();
    var arySubscriptions = [Any]();
    var subscription_details = false
    var isUserSubscribe = false
    var currencyType = ""
    var currencySymbol = ""
    
    var aryCurrencyKeys = [String]()
    var aryCurrencyValues = [Any]()
    var aryDisplayCurrencies = [Any]()
    var tempAryDisplayCurrencies = [Any]()
    var doubleDisplayCurrencies = [Double]()
    var currentDate = Date()
    var current_time = ""
    @IBOutlet weak var buttonCVC: UICollectionView!
    @IBOutlet weak var dateCVC: UICollectionView!
    
    var aryTabs = ["OVERVIEW","SCHEDULE","SPEAKERS","HOST","SPONSORS","T & C"]
    var aryEventdatesJson =  [Dictionary<String, String>]()
    
    @IBOutlet weak var viewOverview: UIView!
    @IBOutlet weak var viewSchedule: UIView!
    @IBOutlet weak var viewSpeakers: UIView!
    @IBOutlet weak var viewHost: UIView!
    @IBOutlet weak var viewSponsors: UIView!
    @IBOutlet weak var viewTerms: UIView!
    
    //for tabs highlight when we go respective pages, and after comes back to this page creating these variables.
    var arySpeakers = [Any]()
    var aryHosts = [Any]()
    var arySponsors = [Any]()
    var strTerms = "<p>By participating in this Livestream event, I agree to be bound by the following terms and conditions: </p> <ul ><li>I agree not to record (directly or indirectly), download, modify, copy, reproduce,  republish, upload, post, transmit, or distribute in any way this event in whole or in part.</li><li>I understand that any copying including recording of the event is unauthorized and constitutes a violation of US, UK & International Copyright Law.</li><li>I understand that failure to abide by these terms and conditions may result in the loss of access to future event broadcasts on Arevea.</li> <li>If others will be participating in the viewing of the event with me as a group, I will ensure that they have read and agreed to the conditions of this agreement.</li><li>I agree and understand that my email ID and password are solely for my use and are not to be shared with anyone.</li> <li>I understand that Arevea is not responsible for any technical difficulties or problems that may be incurred in the receipt of the live broadcast.</li> <li>If I am encountering issues with accessing the stream or any other technical problems, I can use the link provided for 'Contact Us'. Comments made in page post threads, Twitter feeds, Instagram posts etc. will not be addressed by the support staff.</li> <li>I understand that I am to ensure that my web browser is up-to-date, and that I am to have a strong internet connection in order to experience a high-quality livestream.</li> <li>I understand and agree that the live streaming is provided without warranties of any kind and that, to the fullest extent permissible under applicable law Arevea disclaims any and all such warranties, expressed or implied.</li> <li>I agree and understand that the content I am viewing is the responsibility of the creator and not Arevea </li><li>I agree to abide by any and all chatroom guidelines, I understand that I may be ejected at any point for breaching these guidelines </li> <li>By purchasing this ticket I have opted in to your mailing list, where I can unsubscribe at any time.</li></ul>"
    var isSpeaker = false
    var isHost = false
    var priceDetails = [String:Any]()
    var aryQuestions = [Any]()
    var toolTipPreferences = EasyTipView.Preferences()
    // MARK: - View Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        viewActivity.isHidden = true
        btnSubscribe.layer.borderWidth = 1
        let yellow = UIColor(red: 139, green: 230, blue: 213);
        btnSubscribe.layer.borderColor = yellow.cgColor
        lblTitle.text = appDelegate.strTitle
        btnShare.layer.borderWidth = 1
        btnShare.layer.borderColor = UIColor.white.cgColor
        
        if(UIDevice.current.userInterfaceIdiom == .pad){
            heightTopView?.constant = 60;
            viewTop.layoutIfNeeded()
        }
        /*if(appDelegate.isGuest){
         btnSubscribe.isHidden = false
         self.shareEventTop.constant = 65;
         viewShareEvent.layoutIfNeeded()
         }else{
         btnSubscribe.isHidden = true
         }*/
        btnSubscribe.isHidden = true
        if(appDelegate.channel_name_subscription == ""){
            appDelegate.channel_name_subscription = " "
        }
        //for testing
        //appDelegate.isGuest = true
        registerNibs();
        txtTerms.text = strTerms.htmlToString
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
        
    }
    func registerNibs() {
        let nib = UINib(nibName: "DateCVC", bundle: nil)
        dateCVC?.register(nib, forCellWithReuseIdentifier:"DateCVC")
        if(UIDevice.current.userInterfaceIdiom == .pad){
            let nib = UINib(nibName: "ButtonsCVC-iPad", bundle: nil)
            buttonCVC?.register(nib, forCellWithReuseIdentifier:"ButtonsCVC")
        }else{
            let nib = UINib(nibName: "ButtonsCVC", bundle: nil)
            buttonCVC?.register(nib, forCellWithReuseIdentifier:"ButtonsCVC")
        }
        if let flowLayout = self.buttonCVC?.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.estimatedItemSize = CGSize(width: 1, height: 1)
        }
        
        tblSchedule.register(UINib(nibName: "ScheduleCell", bundle: nil), forCellReuseIdentifier: "ScheduleCell");
        tblSpeakers.register(UINib(nibName: "SpeakersCell", bundle: nil), forCellReuseIdentifier: "SpeakersCell");
        tblSponsors.register(UINib(nibName: "SponsorsCell", bundle: nil), forCellReuseIdentifier: "SponsorsCell");
        tblHost.register(UINib(nibName: "SpeakersCell", bundle: nil), forCellReuseIdentifier: "SpeakersCell");
        
        tblSchedule.register(UINib(nibName: "EventRegHeaderViewCell", bundle: nil), forHeaderFooterViewReuseIdentifier: "EventRegHeaderViewCell")
        
    }
    func hideViews(){
        //print("hideViews")
        viewOverview.isHidden = true;
        viewSpeakers.isHidden = true;
        viewSchedule.isHidden = true;
        viewHost.isHidden = true;
        viewSponsors.isHidden = true;
        viewTerms.isHidden = true
        
        for (index,_) in aryTabs.enumerated() {
            let lineTag = 10 + index;
            let btnTag = 20 + index;
            let lblLine = self.buttonCVC.viewWithTag(lineTag) as? UILabel
            let btnText = self.buttonCVC.viewWithTag(btnTag) as? UIButton
            lblLine?.isHidden = true;
            btnText?.setTitleColor(.white, for: .normal)
        }
    }
    @objc func btnPress(_ sender: UIButton) {
        hideViews()
        isHost = false
        isSpeaker = false
        let title = sender.titleLabel?.text!
        print("title:",title)
        print("aryTabs:",aryTabs)
        for (index,_) in aryTabs.enumerated() {
            let name = aryTabs[index]
            let lineTag = 10 + index;
            let btnTag = 20 + index;
            let lblLine = self.buttonCVC.viewWithTag(lineTag) as? UILabel
            let btnText = self.buttonCVC.viewWithTag(btnTag) as? UIButton
            //            print("title:",title)
            //            print("name:",name)
            if (name == title){
                print("equal btnTag:",btnTag)
                print("btn text:",btnText?.titleLabel?.text)
                
                let orange = UIColor(red: 139, green: 230, blue: 213);
                lblLine?.backgroundColor = orange;
                lblLine?.isHidden = false;
                btnText?.setTitleColor(orange, for: .normal)
            }else{
                lblLine?.isHidden = true;
                btnText?.setTitleColor(.white, for: .normal)
            }
        }
        switch title?.lowercased() {
        case "overview":
            viewOverview.isHidden = false;
        case "speakers":
            viewSpeakers.isHidden = false;
        case "schedule":
            viewSchedule.isHidden = false;
            tblSchedule.isHidden = true
            dateCVC.reloadData()
        case "host":
            viewHost.isHidden = false;
        case "sponsors":
            viewSponsors.isHidden = false;
        case "t & c":
            viewTerms.isHidden = false
        default:
            break
        }
    }
    func sortArrayDictDescending(dict: [Dictionary<String, String>], dateFormat: String) -> [Dictionary<String, String>] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        return dict.sorted{[dateFormatter] one, two in
            return dateFormatter.date(from: one["publish_date_time"] ?? "") ?? Date() > dateFormatter.date(from: two["publish_date_time"] ?? ""  ) ?? Date () }
    }
    
    //use:
    
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
                //print("btnTag:",btnTag)
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
        print("====applicationDidBecomeActive ER")
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
        if(appDelegate.isGuest){
            if(isVOD || isAudio){
                getVodById()
            }else{
                getEventBySlug()//to handle payments calling this method after getSubscriptionStatus() called
            }
            getSubscriptionStatus()
        }else{
            getSubscriptionStatus()
        }
        var tag = 10
        if(isHost){
            tag = 13
            viewHost.isHidden = false
        }else if(isSpeaker){
            tag = 12
            viewSpeakers.isHidden = false
        }else{
            viewOverview.isHidden = false
        }
        let infoLine = self.buttonCVC.viewWithTag(tag) as? UILabel
        let btnText = self.buttonCVC.viewWithTag(tag + 10) as? UIButton
        let orange = UIColor(red: 139, green: 230, blue: 213);
        infoLine?.backgroundColor = orange;
        infoLine?.isHidden = false;
        btnText?.setTitleColor(orange, for: .normal)
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
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func subscribeBtnPressed(_ sender: UIButton){
        if(appDelegate.isGuest){
            gotoLogin()
        }else{
            if(arySubscriptions.count > 0){
                subscribe(row: 0)
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
    func convertToArray(text: String) -> [Dictionary<String, String>]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [Dictionary<String, String>]
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
        if(!appDelegate.isGuest){
            params["userid"] = user_id ?? ""
        }
        print("getEventBySlug params:",params)
        let headers: HTTPHeaders
        headers = [appDelegate.x_api_key: appDelegate.x_api_value]
        AF.request(url, method: .post,parameters: params, encoding: JSONEncoding.default,headers:headers)
            .responseJSON { response in
                self.viewActivity.isHidden = true
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any] {
                        print("getEventBySlug JSON:",json)
                        if (json["statusCode"]as? String == "200"){
                            var strPriceList = [String]()
                            var eventStartDates = [Date]()
                            var eventEndDates = [Date]()
                            let data = json["Data"] as? [String:Any]
                            self.resultData = data ?? [:]
                            self.current_time = data?["current_time"] as? String ?? "";
                            
                            let dfSales = DateFormatter()
                            dfSales.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                            self.currentDate = dfSales.date(from: self.current_time) ?? Date()
                            
                            self.aryStreamInfo = data?["stream_info"] as? [String:Any] ?? [:]
                            
                            let streamObj = self.aryStreamInfo
                            self.aryTickets = data?["tickets"] as? [Any] ?? [Any]()
                            print("==>aryTickets:",self.aryTickets)
                            
                            print("==>self.aryStreamInfo:",self.aryStreamInfo)
                            let stream_info_key_exists = self.aryStreamInfo["id"]
                            self.priceDetails = data?["price_details"]as? [String:Any] ?? [:]
                            self.arysubEvents = data?["subEvents"]as? [Any] ?? [Any]()
                            self.aryTicketIds = data?["ticket_ids"]as? [Any] ?? [Any]()
                            self.arySponsors = data?["sponsers_info"] as? [Any] ?? [Any]()
                            print("==>arysubEvents:",self.arysubEvents.count)
                            if(self.arySponsors.count == 0){
                                for (index,element) in self.aryTabs.enumerated(){
                                    if(element.lowercased() == "sponsors")
                                    {
                                        self.aryTabs.remove(at: index)
                                        break
                                    }
                                }
                            }
                            
                            print("==>arySponsors:",self.arySponsors.count)
                            self.arySpeakers = data?["guestList"] as? [Any] ?? [Any]()
                            print("==>arySpeakers:",self.arySpeakers)
                            if(self.arySpeakers.count == 0){
                                for (index,element) in self.aryTabs.enumerated(){
                                    if(element.lowercased() == "speakers")
                                    {
                                        self.aryTabs.remove(at: index)
                                        break
                                    }
                                }
                            }
                            
                            
                            /* for(index,_)in self.arysubEvents.enumerated(){
                             var subEvent = self.arysubEvents[index]as? [String : Any] ?? [String:Any]()
                             var stream_info = subEvent["stream_info"]as? [String:Any] ?? [:]
                             let stream_info_key_exists1 = stream_info["id"]
                             if (stream_info_key_exists1 != nil){
                             let publish_date_time = stream_info["publish_date_time"] as? String ?? "";
                             let expected_end_date_time = stream_info["expected_end_date_time"] as? String ?? "";
                             let formatter = DateFormatter()
                             formatter.timeZone = NSTimeZone(abbreviation: "UTC") as TimeZone?
                             formatter.locale = Locale(identifier: "en_US_POSIX")
                             formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                             if let publishDate = formatter.date(from: publish_date_time){
                             formatter.dateFormat = "hh:mm A"
                             let strLocalTime = formatter.string(from: publishDate)
                             let localStartTime = self.UTCToLocalTime(dateStr: strLocalTime) ?? ""
                             }
                             
                             }
                             
                             
                             
                             }*/
                            self.streamPaymentMode = streamObj["stream_payment_mode"] as? String ?? ""
                            self.appDelegate.selected_type = streamObj["selected_type"] as? String ?? ""
                            
                            self.appDelegate.streamPaymentMode = self.streamPaymentMode
                            
                            self.isUserSubscribe = self.priceDetails["subscription_status"] as?Bool ?? false
                            var strMinPrice = "0.00"
                            var strMaxPrice = "0.00"
                            if (self.priceDetails["min"] as? Int) != nil {
                                strMinPrice = String(self.priceDetails["min"] as? Int ?? 0)
                            }else if (self.priceDetails["min"] as? String) != nil {
                                strMinPrice = String(self.priceDetails["min"] as? String ?? "0.00")
                            }else if (self.priceDetails["min"] as? Double) != nil {
                                strMinPrice = String(self.priceDetails["min"] as? Double ?? 0.00)
                            }
                            if (self.priceDetails["max"] as? Int) != nil {
                                strMaxPrice = String(self.priceDetails["max"] as? Int ?? 0)
                            }else if (self.priceDetails["max"] as? String) != nil {
                                strMaxPrice = String(self.priceDetails["max"] as? String ?? "0.00")
                            }else if (self.priceDetails["max"] as? Double) != nil {
                                strMaxPrice = String(self.priceDetails["max"] as? Double ?? 0.00)
                            }
                            
                            var amountDispaly = ""
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
                            let msg = self.priceDetails["message"] as? String ?? ""
                            print("self.stream_payment_mode==>",self.streamPaymentMode)
                            if(self.streamPaymentMode == "paid" && (strMinPrice != "0.00"  || strMinPrice != "0.00")){
                                let doubleMinAmount = Double(strMinPrice)
                                let minAmount = String(format: "%.02f", doubleMinAmount!)
                                
                                if(strMinPrice != strMaxPrice){
                                    let doubleMaxAmount = Double(strMaxPrice)
                                    let maxAmount = String(format: "%.02f", doubleMaxAmount!)
                                    
                                    amountDispaly = currencySymbolPrice + minAmount + " - " + currencySymbolPrice + maxAmount
                                }else{
                                    amountDispaly =  currencySymbolPrice + minAmount
                                }
                                self.lblAmount.text = amountDispaly
                            }
                            else if(self.streamPaymentMode == "free" && msg == ""){
                                self.lblAmount.text = "Free"
                            }
                            else if(msg != ""){
                                self.lblAmount.text = msg
                                self.lblStreamUnavailable.text = msg
                                self.btnGetTickets.isHidden = true
                            }
                            
                            if (stream_info_key_exists != nil){
                                self.tblSpeakers.reloadData()
                                self.tblSponsors.reloadData()
                                self.appDelegate.streamId = streamObj["id"] as? Int ?? 0
                                self.age_limit = streamObj["age_limit"] as? Int ?? 0
                                if (self.age_limit <= 15) {
                                    self.ageDesc.text = "Family Friendly";
                                } else if (self.age_limit == 16 || self.age_limit <= 17) {
                                    self.ageDesc.text = "Adults Supervision"
                                } else if (self.age_limit == 18 || self.age_limit > 18) {
                                    self.ageDesc.text = "Adults Only"
                                }
                                self.streamVideoCode = streamObj["stream_video_code"] as? String ?? ""
                                _ = streamObj["stream_video_title"] as? String ?? ""
                                self.number_of_creators = streamObj["number_of_creators"] as? Int ?? 1
                                
                                self.streamVideoDesc = streamObj["stream_video_description"] as? String ?? ""
                                if(self.streamVideoDesc == "null"){
                                    self.streamVideoDesc = ""
                                }
                                let terms = streamObj["t_and_c"] as? String ?? ""
                                if(terms != ""){
                                    self.txtTerms.text = terms.htmlToString
                                }
                                // "currency_type" = USD;
                                
                                var strAmount = "0.0"
                                
                                if (streamObj["stream_payment_amount"] as? Double) != nil {
                                    strAmount = String(streamObj["stream_payment_amount"] as? Double ?? 0.0)
                                }else if (streamObj["stream_payment_amount"] as? String) != nil {
                                    strAmount = String(streamObj["stream_payment_amount"] as? String ?? "0.0")
                                }
                                let doubleAmount = Double(strAmount)
                                let amount = String(format: "%.02f", doubleAmount!)
                                self.amountWithCurrencyType = self.currencySymbol + amount
                                
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
                                self.appDelegate.strSlug = streamObj["slug"] as? String ?? "";
                                
                                let publish_date_time = streamObj["publish_date_time"] as? String ?? "";
                                let expected_end_date_time = streamObj["expected_end_date_time"] as? String ?? "";
                                let formatter = DateFormatter()
                                formatter.timeZone = NSTimeZone(abbreviation: "UTC") as TimeZone?
                                formatter.locale = Locale(identifier: "en_US_POSIX")
                                
                                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                                if let publishDate = formatter.date(from: publish_date_time){
                                    if let expectedEndDate = formatter.date(from: expected_end_date_time){
                                        formatter.dateFormat = "E, MMM dd yyyy"
                                        let strPublishDate = formatter.string(from: publishDate)
                                        let strExpectedEndDate = formatter.string(from: expectedEndDate)
                                        let strStartDate = strPublishDate.convertDateString()
                                        let strEndDate = strExpectedEndDate.convertDateString()
                                        
                                        //formatter.dateFormat = "hh:mm a"
                                        //                                        let startTime = formatter.string(from: publishDate)
                                        //                                        let endTime = formatter.string(from: expectedEndDate)
                                        //                                        let localStartTime = self.UTCToLocalTime(dateStr: startTime) ?? ""
                                        //                                        let localEndTime = self.UTCToLocalTime(dateStr: endTime) ?? ""
                                        let localStartDate = self.utcToLocalDate(dateStr:strPublishDate )
                                        print("strPublishDate:",strPublishDate)
                                        print("strExpectedEndDate:",strExpectedEndDate)
                                        
                                        let localEndDate = self.utcToLocalDate(dateStr:strExpectedEndDate )
                                        //                                        let timeFull = localStartTime + " - " + localEndTime
                                        let aryLocalStartDate = localStartDate?.split{$0 == " "}.map(String.init)//Feb 25 2021
                                        
                                        let aryLocalEndDate = localEndDate?.split{$0 == " "}.map(String.init)//Feb 26 2021
                                        
                                        if(aryLocalStartDate?.count == 3){
                                            self.lblMonth.text = aryLocalStartDate?[0]
                                            if (localStartDate == localEndDate){
                                                self.lblDate.text = aryLocalStartDate?[1]
                                            }else{
                                                let startDate1 = aryLocalStartDate?[1] ?? ""
                                                let endDate1 = aryLocalEndDate?[1] ?? ""
                                                
                                                self.lblDate.text = startDate1 + " - " + endDate1
                                            }
                                            self.lblYear.text = aryLocalStartDate?[2]
                                        }else{
                                            //self.lblDate.text = localStartDate
                                        }
                                        
                                        //self.lblTime.text = timeFull
                                    }
                                }
                                let stream_amounts = streamObj["stream_amounts"] as? String ?? "";
                                print("stream_amounts:",stream_amounts)
                                //print("isUserSubscribe:",isUserSubscribe)
                                let event_dates_json = streamObj["event_dates_json"] as? String ?? "";
                                
                                self.aryEventdatesJson = self.convertToArray(text:event_dates_json ) ?? [Dictionary<String, String>]()
                                if(self.aryEventdatesJson.count == 0 ||      self.appDelegate.selected_type == "single_session_event"){
                                    for (index,element) in self.aryTabs.enumerated(){
                                        if(element.lowercased() == "schedule")
                                        {
                                            self.aryTabs.remove(at: index)
                                            break
                                        }
                                    }
                                }
                                self.dateCVC.reloadData()
                                if(self.aryEventdatesJson.count > 0){
                                    self.reloadTbl(index: 0)
                                }
                                if (stream_amounts != ""){
                                    self.dicAmounts = self.convertToDictionary(text: stream_amounts) ?? [:]
                                    print("==dicAmounts:",self.dicAmounts)
                                    let sub_live_stream = self.dicAmounts["sub_live_stream"] as? [Any] ?? [Any]()
                                    if(self.appDelegate.isGuest){
                                        let live_stream = self.dicAmounts["live_stream"] as? [Any] ?? [Any]()
                                        self.aryStreamAmounts = live_stream
                                    }else{
                                        if(self.isUserSubscribe && sub_live_stream.count > 0){
                                            self.aryStreamAmounts = sub_live_stream
                                            
                                        }else if(self.isUserSubscribe && sub_live_stream.count == 0){
                                            let subscriberPayment = self.dicAmounts["subscriberPayment"] as? String ?? ""
                                            self.aryStreamAmounts = []
                                            if(subscriberPayment == "free"){
                                                //self.lblAmount.text = "Free"
                                            }
                                        }else{
                                            let live_stream = self.dicAmounts["live_stream"] as? [Any] ?? [Any]()
                                            self.aryStreamAmounts = live_stream
                                        }
                                    }
                                    
                                    print("self.aryStreamAmounts:",self.aryStreamAmounts)
                                    var aryCurrencies = [[String:Any]]()
                                    for (index,_) in self.aryStreamAmounts.enumerated(){
                                        let element = self.aryStreamAmounts[index] as? [String : Any] ?? [String:Any]()
                                        let booking_start_date = element["booking_start_date"] as? String ?? ""
                                        let booking_end_date = element["booking_end_date"] as? String ?? ""
                                        let ticket_type_name = element["ticket_type_name"] as? String ?? ""
                                        let formatter = DateFormatter()
                                        formatter.dateFormat = "yyyy-MM-dd HH:mm"
                                        var startDateTemp = Date()
                                        var endDateTemp = Date()
                                        if let startDate = formatter.date(from: booking_start_date) {
                                            eventStartDates.append(startDate)
                                            startDateTemp = startDate
                                        }
                                        if let endDate = formatter.date(from: booking_end_date) {
                                            eventEndDates.append(endDate)
                                            endDateTemp = endDate
                                        }
                                        let amounts = element["amounts"]as? [[String:Any]] ?? [[:]]
                                        for(j,_)in amounts.enumerated(){
                                            var object = amounts[j]
                                            object["booking_start_date"] = startDateTemp
                                            object["booking_end_date"] = endDateTemp
                                            object["ticket_type_name"] = ticket_type_name
                                            aryCurrencies.append(object)
                                        }
                                    }
                                    print("eventStartDates:",eventStartDates)
                                    print("eventEndDates:",eventEndDates)
                                    let currencyKeys = aryCurrencies.compactMap { $0["currency_type"] }//it contains all currency keys [USD, INR, USD, INR]
                                    let currencyKeysUnique = NSMutableArray()
                                    self.aryCurrencyKeys = []
                                    self.aryCurrencyValues = []
                                    self.aryDisplayCurrencies = []
                                    self.doubleDisplayCurrencies = []
                                    // we are removing duplicate currency keys
                                    //[USD, INR]
                                    for (_,element)in currencyKeys.enumerated(){
                                        if(!currencyKeysUnique.contains(element)){
                                            currencyKeysUnique.add(element)
                                            let searchPredicate = NSPredicate(format: "currency_type = %@", element as! CVarArg)
                                            let filteredArray = (aryCurrencies as NSArray).filtered(using: searchPredicate)
                                            self.aryCurrencyKeys.append(element as! String)
                                            self.aryCurrencyValues.append(filteredArray)
                                        }
                                    }
                                    //print("aryCurrencyKeys:",aryCurrencyKeys)
                                    //print("aryCurrencyValues:",aryCurrencyValues)
                                    //if currency count 1, then we need to use its value
                                    if(self.aryCurrencyKeys.count == 1){
                                        for (index,_) in self.aryCurrencyValues.enumerated(){
                                            let currencyAry = self.aryCurrencyValues[index] as? [Any] ?? [Any]()
                                            for (_,element) in currencyAry.enumerated(){
                                                //print("currencyObj1:",element)
                                                self.aryDisplayCurrencies.append(element)
                                            }
                                        }
                                    }else{
                                        let indexUser = self.aryCurrencyKeys.firstIndex(where: {$0 == self.appDelegate.userCurrencyCode}) ?? -1
                                        //if user currency found in response
                                        print("indexUser:",indexUser)
                                        
                                        if(indexUser != -1){
                                            self.currencySymbol = self.appDelegate.userCurrencySymbol
                                            let currencyAry = self.aryCurrencyValues[indexUser] as? [Any] ?? [Any]()
                                            for (_,element) in currencyAry.enumerated(){
                                                //print("currencyObj2:",element)
                                                self.aryDisplayCurrencies.append(element)
                                                
                                            }
                                        }
                                        //if user currency not found in response
                                        //need to check creator currency is there are not in response
                                        else{
                                            let indexCreator = self.aryCurrencyKeys.firstIndex(where: {$0 == self.currencyType}) ?? -1
                                            //if creator currency is there in response
                                            if(indexCreator != -1){
                                                let currencyAry = self.aryCurrencyValues[indexCreator] as? [Any] ?? [Any]()
                                                for (_,element) in currencyAry.enumerated(){
                                                    //print("currencyObj3:",element)
                                                    self.aryDisplayCurrencies.append(element)
                                                }
                                            }
                                            //if creator currency is not there in response
                                            else{
                                                
                                            }
                                            print("indexCreator:",indexCreator)
                                            
                                        }
                                    }
                                    
                                    
                                    //print("aryDisplayCurrencies:",aryDisplayCurrencies)
                                    self.tempAryDisplayCurrencies = []
                                    for (index,_) in self.aryDisplayCurrencies.enumerated(){
                                        let element = self.aryDisplayCurrencies[index] as? [String : Any] ?? [String:Any]()
                                        let booking_start_date = element["booking_start_date"] as? Date
                                        let booking_end_date = element["booking_end_date"] as? Date
                                        
                                        let dateFormatter = DateFormatter()
                                        dateFormatter.dateFormat = "yyyy-MM-dd"
                                        //                                        print("==currentDate:",currentDate)
                                        //                                        print("booking_start_date:",booking_start_date)
                                        //                                        print("booking_end_date:",booking_end_date)
                                        
                                        // current_time 2021-01-19T20:47:00.193Z"
                                        // if we take whole value, if time is more, then next day event coming
                                        let aryCurrentTime = self.current_time.split{$0 == "T"}.map(String.init)
                                        var today = Date()
                                        if(aryCurrentTime.count > 0){
                                            let strDateCurrent  = aryCurrentTime[0]
                                            today = dateFormatter.date(from: strDateCurrent)!
                                        }
                                        
                                        let calendar = Calendar.current
                                        var componentsToday = calendar.dateComponents([.year,.month,.day,.hour,.minute,.second], from: today)
                                        
                                        var componentsStart = calendar.dateComponents([.year,.month,.day,.hour,.minute,.second], from: booking_start_date!)
                                        
                                        var componentsEnd = calendar.dateComponents([.year,.month,.day,.hour,.minute,.second], from: booking_end_date!)
                                        
                                        print("componentsToday:",componentsToday)
                                        print("componentsStart:",componentsStart)
                                        print("componentsEnd:",componentsEnd)
                                        
                                        if (componentsToday.year == componentsStart.year && componentsToday.year == componentsEnd.year && componentsToday.day! >= componentsStart.day! && componentsToday.day! <= componentsEnd.day!) {
                                            var strAmount = "0.0"
                                            if (element["stream_payment_amount"] as? Double) != nil {
                                                strAmount = String(element["stream_payment_amount"] as? Double ?? 0.0)
                                            }else if (element["stream_payment_amount"] as? String) != nil {
                                                strAmount = String(element["stream_payment_amount"] as? String ?? "0.0")
                                            }
                                            let doubleAmount = Double(strAmount)
                                            let amount = String(format: "%.02f", doubleAmount!)
                                            strPriceList.append(amount)
                                            self.tempAryDisplayCurrencies.append(element)
                                        }
                                    }
                                    print("tempAryDisplayCurrencies:",self.tempAryDisplayCurrencies)
                                    //if event is not free, and booking date is not fall under current day
                                    if(self.lblAmount.text != "Free" && self.tempAryDisplayCurrencies.count == 0){
                                        self.imgWallet.isHidden = true
                                    }
                                    
                                    //print("tempAryDisplayCurrencies:",tempAryDisplayCurrencies)
                                    self.doubleDisplayCurrencies = strPriceList.compactMap(Double.init)//["5.00","100.00"] to [5,1000]
                                    
                                    self.doubleDisplayCurrencies.sort(by: <)//sort ascending
                                    if(self.doubleDisplayCurrencies.count > 0){
                                        let firstValue = String(format: "%.02f",self.doubleDisplayCurrencies[0])
                                        let lastValue = String(format: "%.02f",self.doubleDisplayCurrencies[self.doubleDisplayCurrencies.count - 1]);
                                        let amountDisplay = self.currencySymbol + firstValue + " - " + self.currencySymbol + lastValue;
                                        // ////print("====amount in Dollars:",amountDisplay)
                                        if(firstValue == lastValue){
                                            self.amountWithCurrencyType = self.currencySymbol + firstValue
                                        }else{
                                            self.amountWithCurrencyType = amountDisplay
                                        }
                                        //self.lblAmount.text = self.amountWithCurrencyType
                                        
                                    }
                                    //print("doubleDisplayCurrencies:",doubleDisplayCurrencies)
                                    
                                    //print("===eventStartDates:",eventStartDates)
                                    //print("===eventEndDates:",eventEndDates)
                                    
                                    if(eventStartDates.count > 0 && eventEndDates.count > 0){
                                        let dateFormatter = DateFormatter()
                                        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                                        
                                        let dfToday = DateFormatter()
                                        dfToday.dateFormat = "yyyy-MM-dd"
                                        let aryCurrentTime = self.current_time.split{$0 == "T"}.map(String.init)
                                        var today = Date()
                                        if(aryCurrentTime.count > 0){
                                            let strDateCurrent  = aryCurrentTime[0]
                                            today = dfToday.date(from: strDateCurrent)!
                                        }
                                        
                                        /*let todaysDate = dateFormatter.string(from: currentDate )
                                         let today = dateFormatter.date(from: todaysDate)*/
                                        let startDate = eventStartDates[0]
                                        let endDate = eventEndDates[eventEndDates.count-1]
                                        print("==>startDate:",startDate)
                                        print("==>today:",today)
                                        print("==>endDate:",endDate)
                                        
                                        //If start date is > today
                                        /* if(startDate > today)
                                         {
                                         print("==saleStarts")
                                         self.saleStarts = true;
                                         }
                                         //today >= start date && today <= end date
                                         else if(today >= startDate && today <= endDate)
                                         {
                                         //print("==checkSale")
                                         self.checkSale = true;
                                         }
                                         //If today is > endDate
                                         else if(today > endDate)
                                         {
                                         print("==saleCompleted:")
                                         self.saleCompleted = true;
                                         }*/
                                    }
                                }//if (stream_amounts != "")
                                else{
                                    //self.lblAmount.text = "Free"//
                                }
                                
                            }else{
                                
                            }
                            let user_subscription_info = data?["user_subscription_info"] != nil
                            if(user_subscription_info){
                                self.aryUserSubscriptionInfo = data?["user_subscription_info"] as? [Any] ?? [Any]()
                            }
                            let user_age_limit = UserDefaults.standard.integer(forKey:"user_age_limit");
                            print("==user_age_limit:",user_age_limit)
                            
                            self.stream_status = streamObj["stream_status"] as? String ?? ""
                            if(self.stream_status == "completed"){
                                //uncomment below line
                                //self.setLiveStreamConfig()
                                self.lblStreamUnavailable.text = "Sale is completed!"
                                self.btnGetTickets.isHidden = true
                                return
                                
                            }
                            if (self.aryUserSubscriptionInfo.count == 0){
                                //if user does not pay amount
                                // self.btnGetTickets.isHidden = false
                                
                            }else{
                                self.btnGetTickets.isHidden = true
                                if (stream_info_key_exists != nil){
                                    let streamObj = self.aryStreamInfo
                                    if (streamObj["stream_vod"]as? String == "stream" && self.isVOD == false && self.isAudio == false){
                                        self.gotoSchedule()
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
                            if (self.age_limit <= user_age_limit || self.age_limit == 0){
                            }
                            else{
                                if(!self.appDelegate.isGuest && user_age_limit != 0){
                                    self.btnGetTickets.isHidden = true;
                                    self.lblStreamUnavailable.text = "This video may be inappropriate for some users"
                                }
                            }
                            
                            let performer_info = data?["performer_info"] != nil
                            if(performer_info){
                                self.dicPerformerInfo = data?["performer_info"] as? [String : Any] ?? [String:Any]()
                                self.tblHost.reloadData()
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
                                print("videoDesc:",videoDesc)
                                //let creatorName = "Creator Name: " + performerName;
                                //var fullText = videoDesc  + "\n" + creatorName
                                
                                let fullText = videoDesc
                                //self.txtVideoDesc_Info.attributedText = fullText.htmlToAttributedString
                                let strDesc = fullText.htmlToString
                                let desc = videoDesc.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
                                if(desc.count == 0 && self.aryTabs.count > 0){
                                    let firstElement = self.aryTabs[0]
                                    if(firstElement == "OVERVIEW"){
                                        self.aryTabs.remove(at: 0)
                                        self.viewOverview.isHidden = true
                                    }
                                }
                                
                                self.txtVideoDesc_Overview.text = strDesc
                                
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
                                //////print("self.app_id_for_adds:",self.app_id_for_adds)
                                
                            }
                            self.buttonCVC.reloadData()
                            
                        }else{
                            let strError = json["message"] as? String
                            print("strError 1:",strError ?? "")
                            self.showAlert(strMsg: strError ?? "")
                            self.btnGetTickets.isHidden = true
                            self.aryTabs = []
                            self.buttonCVC.reloadData()

                        }
                        
                    }
                    
                case .failure(let error):
                    let errorDesc = error.localizedDescription.replacingOccurrences(of: "URLSessionTask failed with error:", with: "")
                    self.showAlert(strMsg: errorDesc)
                    self.viewActivity.isHidden = true
                    
                }
            }
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
                            self.gotoSchedule()
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
    func gotoSchedule(){
        if(appDelegate.selected_type == "single_session_event"){
            let vc = storyboard!.instantiateViewController(withIdentifier: "ScheduleVC") as! ScheduleVC
            self.navigationController?.pushViewController(vc, animated: true)
        }else{
            let vc = storyboard!.instantiateViewController(withIdentifier: "ScheduleVC") as! ScheduleVC
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
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
        appDelegate.strTitle = stream_video_title
        appDelegate.isVOD = isVOD
        appDelegate.isUpcoming = isUpcoming
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
        //print("--self.streamId:",self.streamId)
        //print("--self.streamId1:",String(self.streamId))
        
        let params: [String: Any] = ["userid":user_id ?? "","stream_id": String(appDelegate.streamId)]
        //print("getVodById params:",params)
        
        let headers: HTTPHeaders = [appDelegate.x_api_key: appDelegate.x_api_value]
        
        AF.request(url, method: .post,parameters: params, encoding: JSONEncoding.default,headers:headers)
            .responseJSON { [self] response in
                self.viewActivity.isHidden = true
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any] {
                        //print("getVodById JSON:",json)
                        if (json["statusCode"]as? String == "200"){
                            var strPriceList = [String]()
                            
                            var eventStartDates = [Date]()
                            var eventEndDates = [Date]()
                            //////print(json["message"] as? String ?? "")
                            let data = json["Data"] as? [String:Any]
                            self.aryStreamInfo = data?["stream_info"] as? [String:Any] ?? [:]
                            let stream_info_key_exists = self.aryStreamInfo["id"]
                            if (stream_info_key_exists != nil){
                                let streamObj = self.aryStreamInfo
                                appDelegate.streamId = streamObj["id"] as? Int ?? 0
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
                                self.currencyType = streamObj["currency_type"] as? String ?? ""
                                //based on currency type, get currency symbol
                                if let path = Bundle.main.path(forResource: "currencies", ofType: "json") {
                                    do {
                                        let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                                        let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                                        if let jsonResult = jsonResult as? Dictionary<String, AnyObject>,
                                           let currencySymbol = jsonResult[self.currencyType] as? String {
                                            // do stuff
                                            self.currencySymbol = currencySymbol
                                        }
                                    } catch {
                                        // handle error
                                    }
                                }
                                var strAmount = "0.0"
                                
                                if (streamObj["stream_payment_amount"] as? Double) != nil {
                                    strAmount = String(streamObj["stream_payment_amount"] as? Double ?? 0.0)
                                }else if (streamObj["stream_payment_amount"] as? String) != nil {
                                    strAmount = String(streamObj["stream_payment_amount"] as? String ?? "0.0")
                                }
                                let doubleAmount = Double(strAmount)
                                let amount = String(format: "%.02f", doubleAmount!)
                                self.amountWithCurrencyType = self.currencySymbol + amount
                                
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
                                appDelegate.strSlug = streamObj["slug"] as? String ?? "";
                                
                                let publish_date_time = streamObj["publish_date_time"] as? String ?? "";
                                let expected_end_date_time = streamObj["expected_end_date_time"] as? String ?? "";
                                let formatter = DateFormatter()
                                formatter.timeZone = NSTimeZone(abbreviation: "UTC") as TimeZone?
                                formatter.locale = Locale(identifier: "en_US_POSIX")
                                
                                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                                if let publishDate = formatter.date(from: publish_date_time){
                                    if let expectedEndDate = formatter.date(from: expected_end_date_time){
                                        formatter.dateFormat = "E, MMM dd yyyy"
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
                                        
                                        //  formatter.dateFormat = "hh:mm a"
                                        //                                        let startTime = formatter.string(from: publishDate)
                                        //                                        let endTime = formatter.string(from: expectedEndDate)
                                        //                                        let localStartTime = UTCToLocalTime(dateStr: startTime) ?? ""
                                        //                                        let localEndTime = UTCToLocalTime(dateStr: endTime) ?? ""
                                        //
                                        //                                        let timeFull = localStartTime + " - " + localEndTime
                                        let localStartDate = self.utcToLocalDate(dateStr:strPublishDate )
                                        
                                        let aryLocalStartDate = localStartDate?.split{$0 == " "}.map(String.init)//Feb 25 2021
                                        if(aryLocalStartDate?.count == 3){
                                            self.lblMonth.text = aryLocalStartDate?[0]
                                            self.lblDate.text = aryLocalStartDate?[1]
                                            self.lblYear.text = aryLocalStartDate?[2]
                                        }else{
                                            //self.lblDate.text = localStartDate
                                        }
                                        // self.lblTime.text = timeFull
                                    }
                                }
                                let stream_amounts = streamObj["stream_amounts"] as? String ?? "";
                                // //print("stream_amounts:",stream_amounts)
                                
                                if (stream_amounts != ""){
                                    self.dicAmounts = self.convertToDictionary(text: stream_amounts) ?? [:]
                                    // //print("==dicAmounts:",self.dicAmounts)
                                    let sub_live_stream = self.dicAmounts["sub_vod"] as? [Any] ?? [Any]()
                                    if(isUserSubscribe && sub_live_stream.count > 0){
                                        aryStreamAmounts = sub_live_stream
                                        
                                    }else if(isUserSubscribe && sub_live_stream.count == 0){
                                        let subscriberPayment = self.dicAmounts["subscriberPayment"] as? String ?? ""
                                        aryStreamAmounts = []
                                        if(subscriberPayment == "free"){
                                            //self.lblAmount.text = "Free"
                                        }
                                    }else{
                                        let live_stream = self.dicAmounts["vod"] as? [Any] ?? [Any]()
                                        aryStreamAmounts = live_stream
                                    }
                                    var aryCurrencies = [[String:Any]]()
                                    for (index,_) in self.aryStreamAmounts.enumerated(){
                                        let element = self.aryStreamAmounts[index] as? [String : Any] ?? [String:Any]()
                                        let booking_start_date = element["booking_start_date"] as? String ?? ""
                                        
                                        let booking_end_date = element["booking_end_date"] as? String ?? ""
                                        let formatter = DateFormatter()
                                        formatter.locale = Locale(identifier: "en_US_POSIX")
                                        formatter.dateFormat = "yyyy-MM-dd HH:mm"
                                        if let startDate = formatter.date(from: booking_start_date) {
                                            
                                            eventStartDates.append(startDate)
                                        }
                                        if let endDate = formatter.date(from: booking_end_date) {
                                            eventEndDates.append(endDate)
                                        }
                                        let amounts = element["amounts"]as? [[String:Any]] ?? [[:]]
                                        for(j,_)in amounts.enumerated(){
                                            let object = amounts[j]
                                            aryCurrencies.append(object)
                                        }
                                    }
                                    let currencyKeys = aryCurrencies.compactMap { $0["currency_type"] }//it contains all currency keys [USD, INR, USD, INR]
                                    let currencyKeysUnique = NSMutableArray()
                                    self.aryCurrencyKeys = []
                                    self.aryCurrencyValues = []
                                    self.aryDisplayCurrencies = []
                                    self.doubleDisplayCurrencies = []
                                    // we are removing duplicate currency keys
                                    //[USD, INR]
                                    for (_,element)in currencyKeys.enumerated(){
                                        if(!currencyKeysUnique.contains(element)){
                                            currencyKeysUnique.add(element)
                                            let searchPredicate = NSPredicate(format: "currency_type = %@", element as! CVarArg)
                                            let filteredArray = (aryCurrencies as NSArray).filtered(using: searchPredicate)
                                            self.aryCurrencyKeys.append(element as! String)
                                            self.aryCurrencyValues.append(filteredArray)
                                        }
                                    }
                                    //print("aryCurrencyKeys:",aryCurrencyKeys)
                                    //print("aryCurrencyValues:",aryCurrencyValues)
                                    if(aryCurrencyKeys.count == 1){
                                        for (index,_) in self.aryCurrencyValues.enumerated(){
                                            let currencyAry = self.aryCurrencyValues[index] as? [Any] ?? [Any]()
                                            for (_,element) in currencyAry.enumerated(){
                                                //print("currencyObj1:",element)
                                                aryDisplayCurrencies.append(element)
                                            }
                                        }
                                    }else{
                                        let indexUser = aryCurrencyKeys.firstIndex(where: {$0 == appDelegate.userCurrencyCode}) ?? -1
                                        //if user currency found in response
                                        if(indexUser != -1){
                                            self.currencySymbol = appDelegate.userCurrencySymbol
                                            let currencyAry = self.aryCurrencyValues[indexUser] as? [Any] ?? [Any]()
                                            for (_,element) in currencyAry.enumerated(){
                                                //print("currencyObj2:",element)
                                                aryDisplayCurrencies.append(element)
                                                
                                            }
                                        }
                                        //if user currency not found in response
                                        //need to check creator currency is there are not in response
                                        else{
                                            let indexCreator = aryCurrencyKeys.firstIndex(where: {$0 == self.currencySymbol}) ?? -1
                                            //if creator currency is there in response
                                            if(indexCreator != -1){
                                                let currencyAry = self.aryCurrencyValues[indexCreator] as? [Any] ?? [Any]()
                                                for (_,element) in currencyAry.enumerated(){
                                                    //print("currencyObj3:",element)
                                                    aryDisplayCurrencies.append(element)
                                                    
                                                }
                                            }
                                            //if creator currency is not there in response
                                            else{
                                                
                                            }
                                        }
                                    }
                                    //print("aryDisplayCurrencies:",aryDisplayCurrencies)
                                    for (index,_) in self.aryDisplayCurrencies.enumerated(){
                                        let element = self.aryDisplayCurrencies[index] as? [String : Any] ?? [String:Any]()
                                        var strAmount = "0.0"
                                        
                                        if (element["stream_payment_amount"] as? Double) != nil {
                                            strAmount = String(element["stream_payment_amount"] as? Double ?? 0.0)
                                        }else if (element["stream_payment_amount"] as? String) != nil {
                                            strAmount = String(element["stream_payment_amount"] as? String ?? "0.0")
                                        }
                                        let doubleAmount = Double(strAmount)
                                        let amount = String(format: "%.02f", doubleAmount!)
                                        strPriceList.append(amount)
                                    }
                                    doubleDisplayCurrencies = strPriceList.compactMap(Double.init)//["5.00","100.00"] to [5,1000]
                                    doubleDisplayCurrencies.sort(by: <)//sort ascending
                                    if(doubleDisplayCurrencies.count > 0){
                                        let firstValue = String(format: "%.02f",doubleDisplayCurrencies[0])
                                        let lastValue = String(format: "%.02f",doubleDisplayCurrencies[doubleDisplayCurrencies.count - 1]);
                                        let amountDisplay = self.currencySymbol + firstValue + " - " + self.currencySymbol + lastValue;
                                        // ////print("====amount in Dollars:",amountDisplay)
                                        if(firstValue == lastValue){
                                            self.amountWithCurrencyType = self.currencySymbol + firstValue
                                        }else{
                                            self.amountWithCurrencyType = amountDisplay
                                        }
                                    }
                                    self.lblAmount.text = self.amountWithCurrencyType
                                    //print("===eventStartDates:",eventStartDates)
                                    //print("===eventEndDates:",eventEndDates)
                                    
                                    if(eventStartDates.count > 0 && eventEndDates.count > 0){
                                        let currentDate = Date()
                                        let dateFormatter = DateFormatter()
                                        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                                        dateFormatter.dateFormat = "MMM dd, yyyy"
                                        let todaysDate = dateFormatter.string(from: currentDate)
                                        let today = dateFormatter.date(from: todaysDate)
                                        let startDate = eventStartDates[0]
                                        let endDate = eventEndDates[eventEndDates.count-1]
                                        
                                        //If start date is > today
                                        if(startDate > today!)
                                        {
                                            //print("==saleStarts")
                                            self.saleStarts = true;
                                        }
                                        //today >= start date && today <= end date
                                        else if(today! >= startDate && today! <= endDate)
                                        {
                                            //print("==checkSale")
                                            self.checkSale = true;
                                        }
                                        //If today is > endDate
                                        else if(today! > endDate)
                                        {
                                            //print("==saleCompleted")
                                            self.saleCompleted = true;
                                        }
                                    }
                                }//if (stream_amounts != "")
                                else{
                                    self.lblAmount.text = "Free"//
                                }
                                
                                
                            }
                            let user_subscription_info = data?["user_subscription_info"] != nil
                            if(user_subscription_info){
                                self.aryUserSubscriptionInfo = data?["user_subscription_info"] as? [Any] ?? [Any]()
                            }
                            let user_age_limit = UserDefaults.standard.integer(forKey:"user_age_limit");
                            // ////print("---user_age_limit:",user_age_limit)
                            //   ////print("---age_limit:",self.age_limit)
                            if(self.streamPaymentMode == "free"){
                                self.lblAmount.text = "Free"//Free
                            }
                            if (self.aryUserSubscriptionInfo.count == 0 && self.isVOD){
                                //if user does not pay amount
                                self.btnGetTickets.isHidden = false
                            }else{
                                self.btnGetTickets.isHidden = true
                                self.lblAmount.isHidden = true
                                self.lblDate.isHidden = true
                                // self.lblTime.isHidden = true
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
                            if (self.age_limit <= user_age_limit || self.age_limit == 0){
                            } else{
                                if(!self.appDelegate.isGuest && user_age_limit != 0){
                                    self.btnGetTickets.isHidden = true;
                                    self.lblStreamUnavailable.text = "this video may be inappropriate for some users"
                                }
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
                                //var fullText = videoDesc  + "\n" + creatorName
                                let fullText = videoDesc
                                self.txtVideoDesc_Overview.text = fullText
                                
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
            ////print(error)
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        //adding observer
        hideViews()
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
    func gotoTicketTypes(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil);
        if(self.lblAmount.text != "Free"){
            let user_id = UserDefaults.standard.string(forKey: "user_id") ?? ""
            let urlOpen = appDelegate.websiteURL + "/event/" + appDelegate.strSlug + "/place-order?user_id=" + user_id
            print("urlOpen1:",urlOpen)
            /*guard let url = URL(string: urlOpen) else { return }
            print("url to open:",url)
            UIApplication.shared.open(url)
            return*/
            let vc = storyboard.instantiateViewController(withIdentifier: "PaymentWebVC") as! PaymentWebVC
            vc.strURL = urlOpen
            self.navigationController?.pushViewController(vc, animated: true)
            
        }else{
            let streamInfo = self.aryStreamInfo
            let stream_video_title = streamInfo["stream_video_title"] as? String ?? "Channel Details"
            appDelegate.isLiveLoad = "1"
            let vc = storyboard.instantiateViewController(withIdentifier: "TicketTypesVC") as! TicketTypesVC
            vc.chatDelegate = self
            appDelegate.strTitle = stream_video_title
            vc.isCameFromGetTickets = true
            vc.currencySymbol = currencySymbol
            vc.aryStreamInfo = self.aryStreamInfo
            vc.isUserSubscribe = isUserSubscribe
            vc.aryTicketsData = aryTickets
            
            if(self.lblAmount.text == "Free"){
                appDelegate.streamPaymentMode = "Free"
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    func showConfirmation(strAge:String){
        let strMsg = "This video intended for person " + strAge + " years or older. I agree that my age is " + strAge + " or above."
        let alert = UIAlertController(title: "Alert", message: strMsg, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { [self] action in
            if(self.lblAmount.text == "Free" && (!appDelegate.isGuest)){
                getQuestionsByEventId()
            }else{
                //print("paid") or guest
                gotoTicketTypes()
            }
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { [self] action in
            showAlert(strMsg: "This video may be inappropriate for some users")
        }))
        
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        dismiss(animated: true)
    }
    @IBAction func payPerView(_ sender: Any) {
        
        if(self.lblAmount.text == "Free"){
            setParamForRegisterEvent()
        }
        
        let user_age_limit = UserDefaults.standard.integer(forKey:"user_age_limit");
        //for guest user or for logged in user age not given
        if((!self.appDelegate.isGuest && user_age_limit == 0) || appDelegate.isGuest){
            if (self.age_limit <= 15) {
                // "Family Friendly";
                //free and logged in user
                if(self.lblAmount.text == "Free" && (!appDelegate.isGuest)){
                    getQuestionsByEventId()
                }else{
                    //print("paid") or guest
                    gotoTicketTypes()
                }
            }
            else if (self.age_limit == 16 || self.age_limit <= 17) {
                // "Adults Supervision"
                showConfirmation(strAge: "16")
            }else if (self.age_limit == 18 || self.age_limit > 18) {
                //"Adults Only"
                showConfirmation(strAge: "18")
            }
        }else{
            //for normal user, which age has given
            if(self.lblAmount.text == "Free" && (!appDelegate.isGuest)){
                //print("free")
                getQuestionsByEventId()
            }else{
                //print("paid")
                gotoTicketTypes()
            }
        }
    }
    // MARK: - Button Actions
    @IBAction func tapShare(){
        //print("share")
        
        let url = appDelegate.websiteURL + "/event/" + appDelegate.strSlug
        ////print(url)
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
        let params: [String: Any] = ["user_id":user_id ?? "","channel_url":appDelegate.channel_name_subscription]
        print("getSubscriptionStatus params:",params)
        let headers: HTTPHeaders
        headers = [appDelegate.x_api_key: appDelegate.x_api_value]
        AF.request(url, method: .post,parameters: params, encoding: JSONEncoding.default,headers:headers)
            .responseJSON { [self] response in
                self.viewActivity.isHidden = true
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any] {
                        //print("getSubscriptionStatus JSON:",json)
                        if (json["statusCode"]as? String == "200"){
                            let data = json["Data"] as? [Any] ?? [Any]();
                            // //print("Data:",data)
                            if (data.count > 0){
                                let streamObj = data[0] as? [String: Any] ?? [:]
                                let subscription_status = streamObj["subscription_status"] as? Bool ?? false
                                let subscription_status1 = streamObj["subscription_status"] as? Int ?? 0
                                
                                //print("==subscription_status:",subscription_status)
                                
                                let subscription_end_date = streamObj["subscription_end_date"] as? String ?? "";
                                let formatter = DateFormatter()
                                let date = Date()
                                formatter.timeZone = NSTimeZone(abbreviation: "UTC") as TimeZone?
                                formatter.locale = Locale(identifier: "en_US_POSIX")
                                var endDate = date
                                if let subEndDate = formatter.date(from: subscription_end_date){
                                    //print("subEndDate:",subEndDate)
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
                            print("strError 11:",strError ?? "")
                            self.showAlert(strMsg: strError ?? "")
                        }
                        if(isVOD || isAudio){
                            getVodById()
                        }else{
                            getEventBySlug()//to handle payments calling this method after getSubscriptionStatus() called
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
    func gotoLogin(){
        var isLoginExists = false
        for controller in self.navigationController!.viewControllers as Array {
            if controller.isKind(of: LoginVC.self) {
                self.navigationController!.popToViewController(controller, animated: true)
                isLoginExists = true;
                break
            }
        }
        if (!isLoginExists){
            let storyboard = UIStoryboard(name: "Main", bundle: nil);
            let vc = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    func subscribe(row:Int){
        print("==subscribe")
        if(appDelegate.isGuest){
            gotoLogin()
        }else{
            ////print("row:",row)
            let subscribeObj = self.arySubscriptions[row] as? [String : Any] ?? [:];
            ////print("subscribeObj:",subscribeObj)
            let planId = subscribeObj["id"] as? Int ?? 0
            ////print("planId:",planId)
            let user_id = UserDefaults.standard.string(forKey: "user_id");
            let strUserId = user_id ?? "1"
            // https://dev1.arevea.com/subscribe-payment?channel_name=chirantan-patel&user_id=101097275&plan_id=1311
            
            let urlOpen = appDelegate.websiteURL + "/subscribe-payment?channel_name=" + appDelegate.channel_name_subscription + "&user_id=" + strUserId + "&plan_id=" + String(planId)
            guard let url = URL(string: urlOpen) else { return }
            //print("url to open:",url)
            UIApplication.shared.open(url)
        }
        
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
        let params: [String: Any] = ["user_id":user_id ?? "","channel_name":appDelegate.channel_name_subscription,"channel_url":appDelegate.channel_name_subscription]
        //print("getChannelSubscriptionPlans params:",params)
        let headers: HTTPHeaders
        headers = [appDelegate.x_api_key: appDelegate.x_api_value]
        AF.request(url, method: .post,parameters: params, encoding: JSONEncoding.default,headers:headers)
            .responseJSON { [self] response in
                self.viewActivity.isHidden = true
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any] {
                        //print("getChannelSubscriptionPlans JSON:",json)
                        if (json["statusCode"]as? String == "200"){
                            self.arySubscriptions = []
                            let data = json["Data"] as? [Any] ?? [Any]();
                            // //print("Data:",data)
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
                            print("strError1 2:",strError ?? "")
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
    func uniq<S : Sequence, T : Hashable>(source: S) -> [T] where S.Iterator.Element == T {
        var buffer = [T]()
        var added = Set<T>()
        for elem in source {
            if !added.contains(elem) {
                buffer.append(elem)
                added.insert(elem)
            }
        }
        return buffer
    }
    // MARK: - Collection View Data Source
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(collectionView == buttonCVC){
            return aryTabs.count
        }else{
            return aryEventdatesJson.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if(collectionView == buttonCVC){
            
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ButtonsCVC",for: indexPath) as? ButtonsCVC {
                let name = aryTabs[indexPath.row]
                print("name:",name)
                cell.btn.addTarget(self, action: #selector(btnPress(_:)), for: .touchUpInside)
                cell.btn.tag = 20 + (indexPath.row);
                cell.lblLine.tag = 10 + (indexPath.row);
                cell.lblLine.isHidden = true
                cell.configureCell(name: name)
                
                
                //cell.btn.setTitleColor(.white, for: .normal)
                return cell
            }
        }else{
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
                /*if(indexPath.row == 0){
                 let yellow = UIColor(red: 139, green: 230, blue: 213);
                 cell.btnDate.backgroundColor = yellow
                 cell.btnDate.setTitleColor(.black, for: .normal)
                 
                 }else{
                 let gray = UIColor(red: 70, green: 69, blue: 92);
                 cell.btnDate.backgroundColor = gray
                 cell.btnDate.layer.borderColor = UIColor.white.cgColor
                 cell.btnDate.setTitleColor(.white, for: .normal)
                 }*/
                return cell
                
            }
        }
        return UICollectionViewCell()
        
    }
    //MARK:Tableview Delegates and Datasource Methods
    
    func numberOfSections(in tableView: UITableView) ->  Int {
        if(tableView == tblSchedule){
            return arySelectedSubEvents.count
        }
        return 1
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
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if(tableView == tblSchedule){
            let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "EventRegHeaderViewCell") as! EventRegHeaderViewCell
            headerView.tag = section
            headerView.btnTitle.addTarget(self, action: #selector(scheduleHeaderTapped(_:)), for: .touchUpInside)
            headerView.btnTitle.tag = section
            let subEvent = arySelectedSubEvents[section] as? [String:Any] ?? [:]
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
            
            return headerView
        }else{
            let headerView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
            return headerView
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(tableView == tblSchedule){
            let subEvent = self.arySelectedSubEvents[section]as? [String : Any] ?? [String:Any]()
            let streamInfo = subEvent["stream_info"] as? [String : Any] ?? [String:Any]()
            let aryAgenda = streamInfo["agenda"] as? [Any] ?? [Any]()
            return aryAgenda.count
        }else if(tableView == tblSpeakers){
            return arySpeakers.count
        }else if(tableView == tblSponsors){
            return arySponsors.count
        }else if(tableView == tblHost){
            return 1
        }
        return 0
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) ->  CGFloat {
        if(tableView == tblSchedule){
            return 190
        }else if(tableView == tblSpeakers || tableView == tblHost){
            return 150
        }else if(tableView == tblSponsors){
            return 500
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
        }else if(tableView == tblSpeakers || tableView == tblHost){
            let cell = tableView.dequeueReusableCell(withIdentifier: "SpeakersCell") as! SpeakersCell
            //cell.viewContent.layer.borderColor = UIColor.white.cgColor
            
            cell.backgroundColor = UIColor.clear
            cell.imgUser.layer.borderColor = UIColor.white.cgColor
            var firstChar = ""
            
            if(tableView == tblSpeakers){
                let speakerObj = self.arySpeakers[indexPath.row] as? [String : Any] ?? [:];
                let fn = speakerObj["first_name"] as? String ?? ""
                let ln = speakerObj["last_name"]as? String ?? ""
                let user_type = speakerObj["user_type"]as? String ?? ""
                if (ln == ""){
                    firstChar = String(fn.first?.uppercased() ?? "A")
                }else{
                    firstChar = String(fn.first?.uppercased() ?? "A") + String(ln.first?.uppercased() ?? " ")
                }
                cell.btnUser.setTitle(firstChar, for: .normal)
                
                let username = fn + " " + ln
                cell.lblName.text = username
                if( user_type == "creator"){
                    cell.lblDesc.text = "creator"
                }
                let profile_image = speakerObj["profile_image"]as? String ?? ""
                if let urlBanner = URL(string: profile_image){
                    cell.imgUser.sd_setImage(with: urlBanner, placeholderImage: UIImage(named: "user-white"))
                    cell.imgUser.isHidden = false
                    cell.btnUser.isHidden = true
                }else{
                    cell.imgUser.isHidden = true
                    cell.btnUser.isHidden = false
                }
                
            }else if(tableView == tblHost){
                _ = self.dicPerformerInfo["app_id"] as? String ?? ""
                let performerName = self.dicPerformerInfo["performer_display_name"] as? String ?? ""
                cell.lblName.text = performerName
                
                let fullName = performerName.split{$0 == " "}.map(String.init)
                let fn = (fullName.count > 0) ? fullName[0] : ""
                let ln = (fullName.count > 1) ? fullName[1] : " "
                if (ln == ""){
                    firstChar = String(fn.first?.uppercased() ?? "A")
                }else{
                    firstChar = String(fn.first ?? "A") + String(ln.first ?? " ")
                }
                cell.btnUser.setTitle(firstChar, for: .normal)
                
                
                let performerBio = self.dicPerformerInfo["performer_bio"] as? String ?? ""
                
                cell.txtDesc.text = performerBio.htmlToString
                
                let  performer_profile_pic = self.dicPerformerInfo["performer_profile_pic"] as? String ?? ""
                if let urlBanner = URL(string: performer_profile_pic){
                    cell.imgUser.sd_setImage(with: urlBanner, placeholderImage: UIImage(named: "user-white"))
                    cell.imgUser.isHidden = false
                    cell.btnUser.isHidden = true
                }else{
                    cell.imgUser.isHidden = true
                    cell.btnUser.isHidden = false
                }
            }
            return cell
        }else if(tableView == tblSponsors){
            let cell = tableView.dequeueReusableCell(withIdentifier: "SponsorsCell") as! SponsorsCell
            cell.updateCellWith(row: self.arySponsors)
            cell.cellDelegate = self
            return cell
        }else{
            let cell: UITableViewCell = UITableViewCell()
            return cell
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if(tableView == tblSpeakers || tableView == tblHost){
            if(tableView == tblSpeakers){
                isHost = false
                isSpeaker = true
            }else{
                isHost = true
                isSpeaker = false
            }
            let storyboard = UIStoryboard(name: "Main", bundle: nil);
            let vc = storyboard.instantiateViewController(withIdentifier: "ArtistProfileVC") as! ArtistProfileVC
            
            if(isHost){
                vc.isHost = true
                vc.dicPerformerInfo = dicPerformerInfo
            }else if(isSpeaker){
                vc.isSpeaker = true
                let speakerObj = self.arySpeakers[indexPath.row] as? [String : Any] ?? [:];
                vc.dicSpeakerInfo = speakerObj
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if(tableView == tblSponsors){
            showAlert(strMsg: "tapped")
        }
    }
    func collectionView(collectionviewcell: SponsorsCVC?, index: Int, didTappedInTableViewCell: SponsorsCell) {
        
    }
    
    func getQuestionsByEventId(){
        let netAvailable = appDelegate.isConnectedToInternet()
        if(!netAvailable){
            showAlert(strMsg: "Please check your internet connection!")
            return
        }
        viewActivity.isHidden = false
        
        let url: String = appDelegate.baseURL +  "/getQuestionsByEventId/" + String(appDelegate.streamId)
        
        //print("getQuestionsByEventId url:",url)
        let headers: HTTPHeaders
        headers = [appDelegate.x_api_key: appDelegate.x_api_value]
        AF.request(url, method: .get, encoding: JSONEncoding.default,headers:headers)
            .responseJSON { response in
                self.viewActivity.isHidden = true
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any] {
                        print("getQuestionsByEventId JSON:",json)
                        if (json["statusCode"]as? String == "200" ){
                            self.aryQuestions = json["Data"] as? [Any] ?? [Any]()
                            if(self.aryQuestions.count > 0){
                                self.gotoQuestions()
                            }else{
                                self.registerEvent()
                            }
                        }else{
                            let strMsg = json["message"] as? String ?? ""
                            print("error:",strMsg)
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
    func gotoQuestions(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil);
        let streamInfo = self.aryStreamInfo
        appDelegate.isLiveLoad = "1"
        let vc = storyboard.instantiateViewController(withIdentifier: "QuestionsVC") as! QuestionsVC
        vc.chatDelegate = self
        vc.aryQuestions = aryQuestions
        vc.aryStreamInfo = aryStreamInfo
        self.navigationController?.pushViewController(vc, animated: true)
    }
}




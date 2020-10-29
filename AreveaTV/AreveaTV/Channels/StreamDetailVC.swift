//
//  ChannelDetailVC.swift
//  AreveaTV
//
//  Created by apple on 4/25/20.
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
class StreamDetailVC: UIViewController,UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,OpenChanannelChatDelegate,OpenChannelMessageTableViewCellDelegate,AGEmojiKeyboardViewDelegate,SBDChannelDelegate, AGEmojiKeyboardViewDataSource,CLLocationManagerDelegate{
    // MARK: - Variables Declaration
    
    
    
    @IBOutlet weak var viewBottom: UIView!
    @IBOutlet weak var viewComments: UIView!
    @IBOutlet weak var viewInfo: UIView!
    @IBOutlet weak var viewDonations: UIView!
    
    @IBOutlet weak var tblComments: UITableView!
    @IBOutlet weak var tblDonations: UITableView!
    @IBOutlet weak var txtProfile: UITextView!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    @IBOutlet weak var btnPayPerView: UIButton!
    @IBOutlet weak var lblAmount: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    
    @IBOutlet weak var webView: WKWebView!
    var txtTopOfToolBar : UITextField!
    var r5ViewController : BaseTest? = nil
    @IBOutlet weak var viewLiveStream: UIView!
    var dicPerformerInfo = [String: Any]()
    var aryCharityInfo = [Any]()
    var aryStreamInfo = [String: Any]()
    var aryUserSubscriptionInfo = [Any]()
    var orgId = 0;
    var performerId = 0;
    
    var streamVideoCode = ""
    var number_of_creators = 1
    var streamId = 0;
    var strSlug = "";
    var aryStreamAmounts = [Any]()
    var detailItem = [String:Any]();
    var isLoaded = 0;
    var detailStreamItem: NSDictionary? {
        didSet {
            // Update the view.
            // self.configureView()
        }
    }
    var backPressed = false
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var lblVideoDesc_info: UILabel!
    @IBOutlet weak var lblVideoTitle_info: UILabel!
    @IBOutlet weak var txtVideoDesc_Info: UITextView!
    @IBOutlet weak var imgPerformer: UIImageView!
    
    @IBOutlet weak var lblNoDataComments: UILabel!
    @IBOutlet weak var lblNoDataDonations: UILabel!
    
    // MARK: - Live Chat Inputs
    var channel: SBDOpenChannel?
    var channel_emoji: SBDOpenChannel?
    var hasPrevious: Bool?
    var minMessageTimestamp: Int64 = Int64.max
    var isLoading: Bool = false
    var messages: [SBDBaseMessage] = []
    var emojis: [SBDBaseMessage] = []
    
    var initialLoading: Bool = true
    var scrollLock: Bool = false
    var resendableMessages: [String:SBDBaseMessage] = [:]
    var preSendMessages: [String:SBDBaseMessage] = [:]
    var resendableMessage_emojis: [String:SBDBaseMessage] = [:]
    var preSendMessage_emojis: [String:SBDBaseMessage] = [:]
    var age_limit = 0;
    @IBOutlet weak var txtComment: UITextField!
    @IBOutlet weak var txtEmoji: UITextField!
    
    @IBOutlet weak var sendUserMessageButton: UIButton!
    @IBOutlet weak var inputMessageInnerContainerViewBottomMargin: NSLayoutConstraint!
    @IBOutlet weak var liveStreamHeight: NSLayoutConstraint!
    
    weak var delegate: OpenChanannelChatDelegate?
    var channelName = ""
    var channelName_Emoji = ""
    var paymentAmount = 0
    var streamPaymentMode = ""
    var strTitle = ""
    @IBOutlet weak var viewActivity: UIView!
    @IBOutlet weak var imgStreamThumbNail: UIImageView!
    @IBOutlet weak var btnPlayStream: UIButton!
    @IBOutlet weak var lblStreamUnavailable: UILabel!
    var toolTipView = EasyTipView(text: "");
    var isChannelAvailable = false;
    var isChannelAvailable_emoji = false;
    var sendBirdErrorCode = 0;
    var sendBirdErrorCode_Emoji = 0;
    var sbdError = SBDError()
    var sbdError_emoji = SBDError()
    
    @IBOutlet weak var imgEmoji: UIImageView!
    var app_id_for_adds = ""
    @IBOutlet weak var heightTopView: NSLayoutConstraint?
    @IBOutlet weak var viewTop: UIView!
    var locationManager:CLLocationManager!
    
    var aryCountries = [["region_code":"blr1","countries":["india","sri lanka","bangaldesh","pakistan","china"]],["region_code":"tor1","countries":["canada"]],["region_code":"fra1","countries":["germany"]],["region_code":"lon1","countries":["england"]],["region_code":"sgp1","countries":["singapore"]],["region_code":"sfo1","countries":["United States"]],["region_code":"sfo2","countries":["United States"]],["region_code":"ams2","countries":["netherlands"]],["region_code":"ams3","countries":["netherlands"]],["region_code":"nyc1","countries":["United States"]],["region_code":"nyc2","countries":["United States"]],["region_code":"nyc3","countries":["United States"]]]
    var strCountry = "India"//United States
    var strRegionCode = "blr1"//sfo1
    var isIpadLandScape = false
    
    var isVOD = false;
    var isAudio = false;
    var strAudioSource = ""
    @IBOutlet weak var VODHeight: NSLayoutConstraint!
    @IBOutlet weak var lblVODUnavailable: UILabel!
    @IBOutlet weak var viewVOD: UIView!
    var videoPlayer = AVPlayer()
    
    var isStream = true;
    var isUpcoming = false;
    var toolTipPreferences = EasyTipView.Preferences()
    var streamVideoDesc = ""
    var startSessionResponse =  [String:Any]()
    var isViewerCountcall = 0;
    var isStreamStarted = false
    @IBOutlet weak var btnInfo: UIView!
    @IBOutlet weak var btnShare: UIView!
    @IBOutlet weak var btnTips: UIView!
    @IBOutlet weak var btnDonations: UIView!
    @IBOutlet weak var btnEmoji: UIView!
    @IBOutlet weak var btnChat: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var viewActions: UIView?
    @IBOutlet weak var viewOverlay: UIView?
    @IBOutlet weak var viewBtns: UIView?
    
    var resultData = [String:Any]()
    var isShowChat = false
    var isAgeAllowed = false
    var amountWithCurrencyType = ""
    var isVODPlaying = false
    @IBOutlet weak var lblNetStatus: UILabel!
    var isNetConnected = false
    var reachability: Reachability!
    var timerNet : Timer?
    var saleStarts = false
    var checkSale = false
    var saleCompleted = false
    var timer : Timer?

    // MARK: - View Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        viewActivity.isHidden = true
        // Do any additional setup after loading the view.
        registerNibs();
        addDoneButton()
        addDoneButton1()
        ////print("detail item in channnel page:\(detailItem)")
        
        viewLiveStream.isHidden = true;
        lblNoDataComments.text = ""
        lblNoDataDonations.text = "No results found"
        lblTitle.text = strTitle
        //sendBirdConnect()
        
        // txtComment.textInputMode?.primaryLanguage = "emoji"
        //imgEmoji.isHidden = true
        let emojiKeyboardView = AGEmojiKeyboardView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 216), dataSource: self)
        emojiKeyboardView?.autoresizingMask = UIView.AutoresizingMask.flexibleHeight
        emojiKeyboardView?.delegate = self
        //self.textView.inputView = emojiKeyboardView;
        txtEmoji.inputView = emojiKeyboardView
        txtEmoji.tintColor = UIColor.clear
        txtEmoji.addTarget(self, action: #selector(txtEmojiTap), for: .touchDown)
        webView.isHidden = true
        //bottom first object should show
        
        if(UIDevice.current.userInterfaceIdiom == .pad){
            heightTopView?.constant = 60;
            viewTop.layoutIfNeeded()
            viewLiveStream.layoutIfNeeded()
        }
        /*locationManager = CLLocationManager()
         locationManager.delegate = self
         locationManager.desiredAccuracy = kCLLocationAccuracyBest
         locationManager.requestAlwaysAuthorization()
         
         if CLLocationManager.locationServicesEnabled(){
         locationManager.startUpdatingLocation()
         }*/
        SBDMain.add(self, identifier: self.description)
        self.webView.backgroundColor = .clear
        self.webView.isOpaque = false
        
        if(UIDevice.current.userInterfaceIdiom == .pad && UIDevice.current.orientation.isLandscape){
            isIpadLandScape = true
        }
        
        toolTipPreferences.drawing.font = UIFont(name: "Poppins-Regular", size: 13)!
        toolTipPreferences.drawing.foregroundColor = UIColor.white
        toolTipPreferences.drawing.backgroundColor = UIColor.init(red: 10, green: 72, blue: 88)
        toolTipPreferences.drawing.arrowPosition = EasyTipView.ArrowPosition.top
        //toolTipPreferences.animating.showDuration = 1.5
        // toolTipPreferences.animating.dismissDuration = 1.5
        toolTipPreferences.animating.dismissOnTap = true
        EasyTipView.globalPreferences = toolTipPreferences
        toolTipView = EasyTipView(text: self.strTitle, preferences: toolTipPreferences)
        
        // later on you can dismiss it
        //tipView.dismiss()
        btnInfo?.layer.borderWidth = 2
        btnShare?.layer.borderWidth = 2
        btnTips?.layer.borderWidth = 2
        btnDonations?.layer.borderWidth = 2
        btnEmoji?.layer.borderWidth = 2
        btnChat?.layer.borderWidth = 2
        if(UIDevice.current.userInterfaceIdiom == .pad){
            heightTopView?.constant = 60;
            viewTop.layoutIfNeeded()
            viewActions?.layoutIfNeeded()
            btnInfo?.layoutIfNeeded()
            btnShare?.layoutIfNeeded()
            btnTips?.layoutIfNeeded()
            btnDonations?.layoutIfNeeded()
            btnEmoji?.layoutIfNeeded()
            btnChat?.layoutIfNeeded()
        }
        let btnRadius = btnShare.frame.size.width/2
        btnInfo?.layer.cornerRadius = btnRadius
        btnShare?.layer.cornerRadius = btnRadius
        btnTips?.layer.cornerRadius = btnRadius
        btnDonations?.layer.cornerRadius = btnRadius
        btnEmoji?.layer.cornerRadius = btnRadius
        btnChat?.layer.cornerRadius = btnRadius
        setBtnDefaultBG()
        imgEmoji.isHidden = true
        
        reachability = try! Reachability()
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged),name: Notification.Name.reachabilityChanged, object: nil)
        do {
            try reachability!.startNotifier()
        } catch {
            //print("could not start reachability notifier")
        }
        lblNetStatus.isHidden = true
        self.viewActions?.isHidden = true
        
    }
    func delayWithSeconds(_ seconds: Double, completion: @escaping () -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            completion()
        }
    }
    @objc func repeatNetMethod(){
        let netAvailable = appDelegate.isConnectedToInternet()
        ////print("----repeatNetMethod")
        if(isStreamStarted){
            if(netAvailable){
                if(!isNetConnected){
                    ////print("----online")
                    isNetConnected = true
                    self.lblNetStatus.isHidden = false
                    let green = UIColor.init(red: 34, green: 139, blue: 34)
                    lblNetStatus.backgroundColor = green
                    lblNetStatus.text = "Back to online"
                    self.configureStreamView();//need to refresh stream
                    
                    delayWithSeconds(10.0){
                        self.lblNetStatus.isHidden = true
                    }
                }
            }else{
                if(isNetConnected){
                    ////print("----offline")
                    isNetConnected = false
                    self.lblNetStatus.isHidden = false
                    lblNetStatus.backgroundColor = .gray
                    lblNetStatus.text = "offline"
                    /*delayWithSeconds(3.0){
                     self.lblNetStatus.isHidden = true
                     }*/
                }
                
            }
        }else{
            self.lblNetStatus.isHidden = true
        }
    }
    @objc func reachabilityChanged(note: Notification) {
        let reachability = note.object as! Reachability
        //print("--reachabilityChanged")
        switch reachability.connection {
        case .wifi:
            //print("--Reachable via WiFi")
            isNetConnected = true
        case .cellular:
            print("--Reachable via Cellular")
        case .unavailable:
            //print("--Network not reachable")
            if(isNetConnected && isStreamStarted){
                repeatNetMethod()
                self.timerNet = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(self.repeatNetMethod), userInfo: nil, repeats: true)
                
            }
            isNetConnected = false
        case .none:
            print("--none")
            
        }
    }
    func setBtnDefaultBG(){
        btnInfo?.layer.borderColor = UIColor.black.cgColor
        btnShare?.layer.borderColor = UIColor.black.cgColor
        btnTips?.layer.borderColor = UIColor.black.cgColor
        btnDonations?.layer.borderColor = UIColor.black.cgColor
        btnEmoji?.layer.borderColor = UIColor.black.cgColor
        btnChat?.layer.borderColor = UIColor.black.cgColor
        viewDonations.isHidden = true
        viewComments.isHidden = true
        viewInfo.isHidden = true
        txtComment.resignFirstResponder()
        txtTopOfToolBar.resignFirstResponder()
        txtEmoji.resignFirstResponder()
    }
    
    
    @IBAction func onTapTitle(){
        //print("onTapTitle called")
        
        /*
         * Optionally you can make these preferences global for all future EasyTipViews
         */
        //toolTipView.show(forView: self.lblTitle, withinSuperview: self.view)
        
    }
    
    
    func sendBirdChatConfig(){
        channelName = streamVideoCode
        ////print("channelName in sendBirdChatConfig:",channelName)
        SBDOpenChannel.getWithUrl(channelName, completionHandler: { (openChannel, error) in
            guard error == nil else {   // Error.
                let errorDesc = "Chat Error:" + error!.localizedDescription
                ////print("Send Bird Error:\(String(describing: error))")
                //print(errorDesc)
                //self.sbdError = error ?? error?.localizedDescription as! SBDError
                self.sendBirdErrorCode = error?.code ?? 0
                //self.showAlert(strMsg:errorDesc )
                ////print("sendBirdErrorCode:",sendBirdErrorCode)
                switch self.sendBirdErrorCode {
                case 403100:
                    self.lblNoDataComments.text = "Application id disabled/expired, Please contact admin."
                case 400300:
                    self.lblNoDataComments.text = "Deactivated user not accessible, Please contact admin."
                case 400301:
                    self.lblNoDataComments.text = "User not found, Please contact admin."
                case 400304:
                    self.lblNoDataComments.text = "Application id not found, Please contact admin."
                case 400306:
                    self.lblNoDataComments.text = "Paid quota exceeded, Please contact admin."
                case 400700:
                    self.lblNoDataComments.text = "Blocked user send not allowed, Please contact admin."
                case 500910:
                    self.lblNoDataComments.text = "Rate limit exceeded, Please contact admin."
                case 400201:
                    self.lblNoDataComments.text = "Channel is not available, Please try again later."
                default:
                    self.lblNoDataComments.text = "Channel is not available, Please try again later."
                //              showAlert(strMsg: "\(self.sbdError)")
                }
                // return
                self.messages.removeAll()
                self.channel = nil
                self.isChannelAvailable = false
                self.tblComments.reloadData()
                return
            }
            self.channel = openChannel
            self.title = self.channel?.name
            self.loadPreviousMessages(initial: true)
            openChannel?.enter(completionHandler: { (error) in
                guard error == nil else {   // Error.
                    return
                }
            })
            
        })
        channel?.getMyMutedInfo(completionHandler: { (isMuted, description, startAt, endAt, duration, error) in
            if isMuted {
                //self.sendUserMessageButton.isEnabled = false
                //self.txtComment.isEnabled = false
                self.txtComment.placeholder = "You are muted"
            } else {
                self.sendUserMessageButton.isEnabled = true
                self.txtComment.isEnabled = true
                self.txtComment.placeholder = "Send a message"
            }
        })
    }
    func sendBirdEmojiConfig(){
        channelName_Emoji = streamVideoCode + "_emoji"
        ////print("channelName_Emoji in sendBirdChatConfig:",channelName_Emoji)
        SBDOpenChannel.getWithUrl(channelName_Emoji, completionHandler: { (openChannel, error) in
            guard error == nil else {   // Error.
                let errorDesc = "Chat Error:" + error!.localizedDescription
                ////print("Send Bird Error:\(error!)")
                ////print(errorDesc)
                self.isChannelAvailable_emoji = false
                return
            }
            self.isChannelAvailable_emoji = true
            self.channel_emoji = openChannel
            self.title = self.channel_emoji?.name
            self.loadPreviousEmojis(initial: true)
            openChannel?.enter(completionHandler: { (error) in
                guard error == nil else {   // Error.
                    return
                }
            })
        })
        channel_emoji?.getMyMutedInfo(completionHandler: { (isMuted, description, startAt, endAt, duration, error) in
            if isMuted {
                //                ALToastView.toast(in: self.viewVOD, withText:"You are muted")
            }
        })
    }
    private func deleteMessageFromTableView(_ messageId: Int64) {
        if self.messages.count == 0 {
            return
        }
        
        for i in 0...self.messages.count-1 {
            let msg = self.messages[i]
            if msg.messageId == messageId {
                self.determineScrollLock()
                self.messages.removeObject(msg)
                self.tblComments.deleteRows(at: [IndexPath(row: i, section: 0)], with: .none)
                self.tblComments.layoutIfNeeded()
                self.scrollToBottom(force: false)
                break
            }
        }
    }
    
    
    
    @objc func StreamNotificationHandler(_ notification:Notification) {
        // Do something now
        ////print("====StreamNotificationHandler")
        if let data = notification.userInfo as? [String: String]
        {
            for (key,value) in data
            {
                //key Stream
                //value Stopped/Started
                ////print("key: \(key)")
                ////print("value: \(value)")
                
                if (value == "started"){
                    self.lblStreamUnavailable.text = ""
                    viewActivity.isHidden = true
                    isStreamStarted = true
                    btnPlayStream.isHidden = true;
                    let htmlString = "<html>\n" + "<body style='margin:0;padding:0;background:transparent;'>\n" +
                        "<iframe width=\"100%\" height=\"100%\" src=\"https://app.singular.live/appinstances/" + self.app_id_for_adds + "/outputs/Output/onair\" frameborder=\"0\" allow=\"accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture\" allowfullscreen>\n" + "</iframe>\n" + "</body>\n" + "</html>";
                    //print("htmlString:",htmlString)
                    self.webView.loadHTMLString(htmlString, baseURL: nil)
                    self.webView.isHidden = false
                    self.viewOverlay?.isHidden = true// controls not working
                    self.viewLiveStream.bringSubviewToFront(self.webView)
                    if (self.timer != nil)
                    {
                        self.timer!.invalidate()
                        self.timer = nil
                    }
                    startSession()
                }else if(value == "stopped"){
                    // lblStreamUnavailable.text = "publisher has unpublished/paused video. Please try again later."
                    /*self.lblStreamUnavailable.text = "The stream has ended."
                    self.viewLiveStream.bringSubviewToFront(lblStreamUnavailable)
                    btnPlayStream.setImage(UIImage.init(named: "refresh"), for: .normal)
                    btnPlayStream.isHidden = false;
                    //unload Webview
                    self.webView.loadHTMLString("", baseURL: nil)
                    self.webView.isHidden = true*/
                    self.viewLiveStream.bringSubviewToFront(lblStreamUnavailable)
                    self.repeatMethod()
                    self.timer = Timer.scheduledTimer(timeInterval: 15.0, target: self, selector: #selector(self.repeatMethod), userInfo: nil, repeats: true)
                    
                    //isStreamStarted = false
                    //endSession()
                }else if(value == "not_available"){
                    viewActivity.isHidden = true
                    if (viewLiveStream.isHidden == false){
                        if(isStreamStarted){
                            lblStreamUnavailable.text = "We are working on the issue. We will be back shortly."
                            btnPlayStream.isHidden = true;
                        }else{
                            lblStreamUnavailable.text = "Video streaming is currently unavailable. Please try again later."
                            btnPlayStream.setImage(UIImage.init(named: "refresh"), for: .normal)
                            btnPlayStream.isHidden = false;
                        }
                        //self.viewOverlay?.isHidden = true// controls not working
                    }
                }
            }
        }
    }
    @objc func applicationDidBecomeActive(notification: NSNotification) {
        // Application is back in the foreground
        ////print("====applicationDidBecomeActive")
        //if user comes from payment redirection, need to refresh stream/vod
        if(isVOD || isAudio){
            getVodById()
        }else{
            LiveEventById();
        }
    }
    func registerNibs() {
        
        
        tblComments.register(UINib(nibName: "OpenChannelUserMessageTableViewCell", bundle: nil), forCellReuseIdentifier: "OpenChannelUserMessageTableViewCell")
        tblDonations.register(UINib(nibName: "CharityCell", bundle: nil), forCellReuseIdentifier: "CharityCell")
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true);
        backPressed = false
        self.btnPlayStream.isHidden = true
        if(UIDevice.current.userInterfaceIdiom == .pad){
            self.imgStreamThumbNail.image = UIImage.init(named: "sample-event")
        }else{
            self.imgStreamThumbNail.image = UIImage.init(named: "sample_vod_square")
        }
        if(isLoaded == 0 || appDelegate.isLiveLoad == "1"){
            let netAvailable = appDelegate.isConnectedToInternet()
            if(!netAvailable){
                showAlert(strMsg: "Please check your internet connection!")
                return
            }
            
            isLoaded = 1;
            appDelegate.isLiveLoad = "0";
            if(isVOD || isAudio){
                getVodById()
            }else{
                LiveEventById();
            }
            //getPerformerOrgInfo();
            //viewInfo.isHidden = false
        }
        
        tblComments.rowHeight = 40
        tblComments.estimatedRowHeight = UITableView.automaticDimension
        
        self.viewLiveStream.bringSubviewToFront(self.viewOverlay!)
        
    }
    func showVideo(strURL : String){
        print("strURL:",strURL)
        if let url = URL(string: strURL){
            videoPlayer = AVPlayer(url: url)
            let controller = AVPlayerViewController()
            controller.player = videoPlayer
            controller.allowsPictureInPicturePlayback = true
            controller.view.frame = self.viewVOD.bounds
            controller.view.frame.origin.y = 44
            controller.view.frame.size.height = self.viewVOD.bounds.size.height - 44
            controller.videoGravity = AVLayerVideoGravity.resize
            self.viewVOD.addSubview(controller.view)
            self.addChild(controller)
            btnPlayStream.isHidden = true;
            viewLiveStream.isHidden = true;
            viewVOD.isHidden = false;
            videoPlayer.play()
            isVODPlaying = true
            // Environment and player data that persists until the player is destroyed
            let playerData = MUXSDKCustomerPlayerData(environmentKey:"dev")
            playerData?.viewerUserId = "1234"
            playerData?.experimentName = "player_test_A"
            playerData?.playerName = "My Main Player"
            playerData?.playerVersion = "1.0.0"
            
            // Video metadata (cleared with videoChangeForPlayer:withVideoData:)
            let videoData = MUXSDKCustomerVideoData()
            videoData.videoId = "abcd123"
            videoData.videoTitle = "My Great Video"
            videoData.videoSeries = "Weekly Great Videos"
            videoData.videoDuration = 120000 // in milliseconds
            videoData.videoIsLive = false
            videoData.videoCdn = "cdn"
            
            MUXSDKStats.monitorAVPlayerViewController(controller, withPlayerName: "Player Name", playerData: playerData!, videoData: videoData)
        }else{
            ////print("Invalid URL")
            showAlert(strMsg: "Unable to play video due to invalid URL.")
        }
    }
    
    
    func stopVideo(){
        videoPlayer.pause()
        videoPlayer.replaceCurrentItem(with: nil)
    }
    func delay(_ delay:Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }
    func animateEmojisLoop(_ iteration: Int = 0) {
        let i = iteration
        if (iteration < self.emojis.count){
            let userMessage = self.emojis[i] as! SBDUserMessage
            self.delay(2.0){
                let strEmojiText = userMessage.message
                self.imgEmoji.image = strEmojiText!.image()
                self.animateEmoji()
                return self.animateEmojisLoop(i + 1)
            }
        }
    }
    
    func animateEmoji() {
        self.imgEmoji.isHidden = false;
        var frameBug = self.imgEmoji.frame
        // ////print("bug fr:",self.imgEmoji.frame)
        if(UIDevice.current.userInterfaceIdiom == .pad){
            frameBug.origin.x = 400
            frameBug.origin.y = 400
        }else{
            frameBug.origin.x = 400
            frameBug.origin.y = 400
        }
        let xConst = frameBug.origin.x;
        let yConst = frameBug.origin.y;
        
        //self.bug.frame = frameBug
        UIView.animate(withDuration: 3.0, delay: 0, options: .curveLinear, animations: {
            self.imgEmoji.transform = CGAffineTransform(translationX: -xConst, y: -yConst)
            //self.bug.transform = CGAffineTransform(rotationAngle: .pi)
            
        }) { (success: Bool) in
            self.imgEmoji.transform = CGAffineTransform.identity
            self.imgEmoji.isHidden = true;
            //self.animateEmojis()
        }
    }
    @IBAction func viewBGTap() {
        setBtnDefaultBG()
    }
    func showConfirmation(strMsg: String){
        let alert = UIAlertController(title: "Alert", message: strMsg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            self.backPressed = true
            self.closeStream()
            self.stopVideo()
            if(self.isStreamStarted){
                self.endSession()
            }
            if (self.timer != nil)
            {
                self.timer!.invalidate()
                self.timer = nil
            }
            AppDelegate.AppUtility.lockOrientation(.portrait)
            self.navigationController?.popViewController(animated: true)
        }))
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
    @IBAction func back(_ sender: Any) {
        if (!backPressed){
            if(isStreamStarted || isVODPlaying){
                var strMsg = "Are you sure you want to close the stream?"
                if(isVODPlaying){
                    strMsg = "Are you sure you want to close the video?"
                }
                showConfirmation(strMsg:strMsg )
            }else{
                backPressed = true
                closeStream()
                stopVideo()
                AppDelegate.AppUtility.lockOrientation(.portrait)
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    // MARK: - Button Actions
    @IBAction func tapShare(){
        //print("share")
        setBtnDefaultBG()
        let orange = UIColor.init(red: 255, green: 155, blue: 90)
        btnShare?.layer.borderColor = orange.cgColor
        
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
    @IBAction func tapInfo(){
        //print("info")
        setBtnDefaultBG()
        let orange = UIColor.init(red: 255, green: 155, blue: 90)
        btnInfo?.layer.borderColor = orange.cgColor
        viewInfo.isHidden = false
    }
    @IBAction func tapTips(){
        //print("tips")
        if(isShowChat){
            setBtnDefaultBG()
            let orange = UIColor.init(red: 255, green: 155, blue: 90)
            btnTips?.layer.borderColor = orange.cgColor
            proceedToPayment(type: "performer_tip",charityId: 0)
        }else{
            if(isAgeAllowed){
                let msg = "Please pay " + amountWithCurrencyType
                showAlert(strMsg: msg)
            }else{
                let msg = "Your age is not supported"
                showAlert(strMsg: msg)
            }
        }
    }
    @IBAction func tapDonations(){
        //print("Donations")
        if(isShowChat){
            setBtnDefaultBG()
            let orange = UIColor.init(red: 255, green: 155, blue: 90)
            btnDonations?.layer.borderColor = orange.cgColor
            viewDonations.isHidden = false
        }else{
            if(isAgeAllowed){
                let msg = "Please pay " + amountWithCurrencyType
                showAlert(strMsg: msg)
            }else{
                let msg = "Your age is not supported"
                showAlert(strMsg: msg)
            }
        }
    }
    @IBAction func tapEmoji(){
        //print("emoji")
        
    }
    @objc func txtEmojiTap(textField: UITextField) {
        if(isShowChat){
            setBtnDefaultBG()
            let orange = UIColor.init(red: 255, green: 155, blue: 90)
            btnEmoji?.layer.borderColor = orange.cgColor
        }else{
            if(isAgeAllowed){
                let msg = "Please pay " + amountWithCurrencyType
                showAlert(strMsg: msg)
            }else{
                let msg = "Your age is not supported"
                showAlert(strMsg: msg)
            }
        }
    }
    @IBAction func tapChat(){
        //print("chat")
        if(isShowChat){
            setBtnDefaultBG()
            let orange = UIColor.init(red: 255, green: 155, blue: 90)
            btnChat?.layer.borderColor = orange.cgColor
            viewComments.isHidden = false
        }else{
            if(isAgeAllowed){
                let msg = "Please pay " + amountWithCurrencyType
                showAlert(strMsg: msg)
            }else{
                let msg = "Your age is not supported"
                showAlert(strMsg: msg)
            }
            
        }
    }
    @IBAction func closeInfo(){
        viewInfo.isHidden = true
        btnInfo?.layer.borderColor = UIColor.black.cgColor
    }
    @IBAction func closeDonations(){
        viewDonations.isHidden = true
        btnDonations?.layer.borderColor = UIColor.black.cgColor
    }
    @IBAction func closeChat(){
        viewComments.isHidden = true
        btnChat?.layer.borderColor = UIColor.black.cgColor
        txtComment.resignFirstResponder()
        txtTopOfToolBar.resignFirstResponder()
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    //MARK: Private Functions
    
    //MARK:Tableview Delegates and Datasource Methods
    
    func numberOfSections(in tableView: UITableView) ->  Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(tableView == tblDonations){
            if (self.aryCharityInfo.count > 0){
                self.lblNoDataDonations.isHidden = true
                tblDonations.isHidden = false
            }else{
                self.lblNoDataDonations.isHidden = false
                tblDonations.isHidden = true
            }
            return aryCharityInfo.count;
        }
        else if(tableView == tblComments){
            
            if (isChannelAvailable && self.messages.count > 0){
                tblComments.isHidden = false
                lblNoDataComments.text = ""
            }else{
                tblComments.isHidden = true
                //lblNoDataComments.text = "Channel is unavailable"
                
            }
            return self.messages.count;
        }
        return 0;
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) ->  CGFloat {
        if  (tableView == tblDonations){
            return 130;
        }
        else if  (tableView == tblComments){
            return UITableView.automaticDimension
        }
        return 44;
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (tableView == tblComments){
            var cell: UITableViewCell = UITableViewCell()
            
            if self.messages[indexPath.row] is SBDAdminMessage {
                if let adminMessage = self.messages[indexPath.row] as? SBDAdminMessage,
                   let adminMessageCell = tableView.dequeueReusableCell(withIdentifier: "OpenChannelUserMessageTableViewCell") as? OpenChannelUserMessageTableViewCell {
                    adminMessageCell.setMessage(adminMessage)
                    adminMessageCell.delegate = self
                    //adminMessageCell.profileImageView
                    if indexPath.row > 0 {
                        //adminMessageCell.setPreviousMessage(self.messages[indexPath.row - 1])
                    }
                    
                    cell = adminMessageCell
                }
            }
            else if self.messages[indexPath.row] is SBDUserMessage {
                let userMessage = self.messages[indexPath.row] as! SBDUserMessage
                if let userMessageCell = tableView.dequeueReusableCell(withIdentifier: "OpenChannelUserMessageTableViewCell") as? OpenChannelUserMessageTableViewCell,
                   let sender = userMessage.sender {
                    userMessageCell.setMessage(userMessage)
                    userMessageCell.delegate = self
                    
                    
                    if sender.userId == SBDMain.getCurrentUser()!.userId {
                        // Outgoing message
                        if let requestId = userMessage.requestId {
                            if self.resendableMessages[requestId] != nil {
                                userMessageCell.showElementsForFailure()
                            }
                            else {
                                userMessageCell.hideElementsForFailure()
                            }
                        }
                    }
                    else {
                        // Incoming message
                        userMessageCell.hideElementsForFailure()
                    }
                    //userMessageCell.profileImageView
                    DispatchQueue.main.async {
                        guard let updateCell = tableView.cellForRow(at: indexPath) else { return }
                        guard updateCell is OpenChannelUserMessageTableViewCell else { return }
                        
                        // updateUserMessageCell.profileImageView.setProfileImageView(for: sender)
                    }
                    
                    cell = userMessageCell
                }
            }
            
            if indexPath.row == 0 && self.messages.count > 0 && self.initialLoading == false && self.isLoading == false {
                self.loadPreviousMessages(initial: false)
            }
            
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "CharityCell") as! CharityCell
            cell.btnDonate.addTarget(self, action: #selector(payDonation(_:)), for: .touchUpInside)
            cell.btnDonate.tag = indexPath.row
            
            let charity = self.aryCharityInfo[indexPath.row] as? [String : Any];
            cell.lblCharityName.text = charity?["charity_name"] as? String ?? ""
            cell.lblCharityDesc.text = charity?["charity_description"] as? String ?? ""
            let strURL = charity?["charity_logo"]as? String ?? ""
            if let urlCharity = URL(string: strURL){
                cell.imgCharity.sd_setImage(with: urlCharity, placeholderImage: UIImage(named: "charity-img.png"))
            }
            
            return cell
            
            
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //           let storyboard = UIStoryboard(name: "Main", bundle: nil);
        //           let vc = storyboard.instantiateViewController(withIdentifier: "ChannelDetailVC") as! ChannelDetailVC
        //           self.navigationController?.pushViewController(vc, animated: true)
        viewBGTap()
        tableView.deselectRow(at: indexPath, animated: true)
        
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
    
    // MARK: Comments Methods
    
    @objc func resignKB(_ sender: Any) {
        txtTopOfToolBar.text = ""
        txtComment.text = ""
        txtComment.resignFirstResponder();
        txtTopOfToolBar.resignFirstResponder()
        txtEmoji.resignFirstResponder()
    }
    func addDoneButton() {
        let toolbar =  UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 35))
        toolbar.backgroundColor = .white
        txtTopOfToolBar =  UITextField(frame: CGRect(x: 50, y: 0, width: view.frame.size.width-150, height: 35))
        // let textfield =  UITextField()
        txtTopOfToolBar.placeholder = "Send a message"
        txtTopOfToolBar.delegate = self
        txtTopOfToolBar.backgroundColor = .clear
        //txtTopOfToolBar.isUserInteractionEnabled = false
        txtTopOfToolBar.borderStyle = UITextField.BorderStyle.none
        
        let textfieldBarButton = UIBarButtonItem.init(customView: txtTopOfToolBar)
        
        // UIToolbar expects an array of UIBarButtonItems:
        
        let flexButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        
        let cancel = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action:#selector(resignKB(_:)))
        
        let button = UIButton.init(type: .custom)
        //set image for button
        button.setImage(UIImage(named: "blue-send"), for: UIControl.State.normal)
        //add function for button
        button.addTarget(self, action: #selector(sendChatMessage), for: UIControl.Event.touchUpInside)
        //set frame
        button.frame = CGRect(x: view.frame.size.width-180, y: 0, width: 20, height: 20)
        
        let sendBtn = UIBarButtonItem(customView: button)
        
        
        toolbar.setItems([cancel,textfieldBarButton,flexButton,sendBtn], animated: true)
        toolbar.sizeToFit()
        txtComment.inputAccessoryView = toolbar;
        txtTopOfToolBar.inputAccessoryView = toolbar;
        
    }
    func addDoneButton1() {
        let toolbar =  UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 35))
        
        let flexButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action:#selector(resignKB(_:)))
        toolbar.setItems([flexButton, doneButton], animated: true)
        toolbar.sizeToFit()
        
        txtEmoji.inputAccessoryView = toolbar
        
    }
    // MARK: Text Field Delegate Methods
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if (txtComment == textField || txtTopOfToolBar == textField){
            
            
        }else if(txtEmoji == textField){
            imgEmoji.isHidden = true
        }
        
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if (txtComment == textField || txtTopOfToolBar == textField){
            //            if(UIDevice.current.userInterfaceIdiom == .phone){
            //                        self.viewComments.frame.origin.y = 0
            //            }
            
        }
        else if(txtEmoji == textField){
            
        }
        textField.resignFirstResponder();
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder();
        if (textField == txtComment || txtTopOfToolBar == textField){
            sendChatMessage()
        }
        return true;
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let textFieldText: NSString = (textField.text ?? "") as NSString
        let txtAfterUpdate = textFieldText.replacingCharacters(in: range, with: string)
        txtTopOfToolBar.text = txtAfterUpdate
        
        return true
    }
    // MARK: Keyboard  Delegate Methods
    
    
    
    // MARK: Tip Methods
    @IBAction func payTip(_ sender: Any) {
        viewBGTap()
        proceedToPayment(type: "performer_tip",charityId: 0)
    }
    @objc func payDonation(_ sender: UIButton) {
        viewBGTap()
        txtEmoji.resignFirstResponder()
        let charity = self.aryCharityInfo[sender.tag] as? [String:Any]
        let charityId = charity?["id"] as? Int ?? 0
        proceedToPayment(type: "charity_donation",charityId:charityId )
    }
    
    @IBAction func payPerView(_ sender: Any) {
        viewBGTap()
        if(self.streamPaymentMode == "paid"){
            //print("paid")
            proceedToPayment(type: "pay_per_view",charityId: 0)
        }else{
            //print("free")
            registerEvent()
        }
        
    }
    func proceedToPayment(type:String,charityId:Int){
        //let url: String = appDelegate.baseURL +  "/proceedToPayment"
        let user_id = UserDefaults.standard.string(forKey: "user_id");
        let strUserId = user_id ?? "1"
        var queryString = "stream_id=" + String(streamId) + "&user_id=" + strUserId//ppv
        if(type == "performer_tip"){
            queryString =  queryString + "&performer_id=" + String(self.performerId)
        }else if(type == "charity_donation"){
            queryString = queryString + "&charity_id=" + String(charityId)
        }
        let urlOpen = appDelegate.paymentRedirectionURL + "/" + type + "?" + queryString
        guard let url = URL(string: urlOpen) else { return }
        print("url to open:",url)
        UIApplication.shared.open(url)
    }
    @IBAction func subscribe(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil);
        let vc = storyboard.instantiateViewController(withIdentifier: "SubscriptionPlanVC") as! SubscriptionPlanVC
        vc.comingfrom = "channel_details"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func showAlert(strMsg: String){
        let alert = UIAlertController(title: "Alert", message: strMsg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
    @IBAction func showChatRules(){
        let strMsg = "ESL encourages a respectful, enjoyable, and harassment-free viewing for experience for everyone.\n\nPlease avoid engaging in any one of the following:\n•    Harassing, stalking, or threatening of individuals\n•    Hate speech (sexist, racist, homophobic, etc.)\n•    Spamming, hijacking, or disrupting stream\n•    Links and advertisements.\n•    Posting other people’s private information"
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .left
        var fontSize = 15
        if(UIDevice.current.userInterfaceIdiom == .pad){
            fontSize = 25
        }
        let attributedText = NSAttributedString(string: strMsg,
                                                attributes: [.paragraphStyle: paragraph,NSAttributedString.Key.font: UIFont.systemFont(ofSize: CGFloat(fontSize))])
        
        //let attributedText = NSMutableAttributedString(string: strMsg, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)])
        
        
        let alert = UIAlertController(title: "Chat Rules", message: "", preferredStyle: .alert)
        alert.setValue(attributedText, forKey: "attributedMessage")
        
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
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
        //print("registerEvent")
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
                        //print("registerEvent JSON:",json)
                        if (json["status"]as? Int == 0){
                            self.LiveEventById()
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
    //this will be called when stream has ended due to tab close or any error occured
    @objc func repeatMethod(){
        print("====repeatMethod")
        LiveEventByIdStatus()
    }
    func LiveEventByIdStatus(){
        // let params: [String: Any] = ["userid":user_id ?? "","performer_id":"101","stream_id": "0"]
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
        
        AF.request(url, method: .post,parameters: params, encoding: JSONEncoding.default,headers:headers)
            .responseJSON { [self] response in
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any] {
                        //print("startSession JSON:",json)
                        if (json["statusCode"]as? String == "200" ){
                            let data = json["Data"] as? [String:Any]
                            let aryStreamInfo = data?["stream_info"] as? [String:Any] ?? [:]
                            let stream_info_key_exists = aryStreamInfo["id"]
                            if (stream_info_key_exists != nil){
                                let streamObj = aryStreamInfo
                                let stream_status = streamObj["stream_status"] as? String ?? ""
                                if(stream_status == "completed"){
                                    self.lblStreamUnavailable.text = "The stream has ended."
                                    if (self.timer != nil)
                                    {
                                        self.timer!.invalidate()
                                        self.timer = nil
                                    }
                                    closeStream()
                                    self.endSession()
                                    AppDelegate.AppUtility.lockOrientation(.portrait)
                                    self.navigationController?.popViewController(animated: true)
                                }else{
                                    r5ViewController?.closeTest()
                                    self.viewLiveStream.isHidden = false;
                                    self.btnPayPerView.isHidden = true
                                    self.lblStreamUnavailable.text = "We are working on the issue. We will be back shortly."
                                    self.viewActions?.isHidden = true
                                    self.LiveEventById()
                                }
                            }
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
    
    func LiveEventById() {
        /*viewVOD.isHidden = false
         viewLiveStream.isHidden = true
         lblAmount.text = ""
         self.showVideo(strURL: "http://demo.unified-streaming.com/video/tears-of-steel/tears-of-steel.ism/.m3u8");
         return*/
        if(isStreamStarted){
            viewActivity.isHidden = true
        }else{
            viewActivity.isHidden = false
            let netAvailable = appDelegate.isConnectedToInternet()
            if(!netAvailable){
                showAlert(strMsg: "Please check your internet connection!")
                return
            }
        }
        self.btnPlayStream.isUserInteractionEnabled = true
        
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
            .responseJSON { response in
                self.viewActivity.isHidden = true
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any] {
                        print("LiveEventById JSON:",json)
                        if (json["statusCode"]as? String == "200"){
                            var USDPrice = [String]()
                            var GBPPrice = [String]()
                            var eventStartDates = [Date]()
                            var eventEndDates = [Date]()
                            
                            ////print(json["message"] as? String ?? "")
                            let data = json["Data"] as? [String:Any]
                            self.resultData = data ?? [:]
                            self.isShowChat = true
                            self.isAgeAllowed = true
                            self.aryStreamInfo = data?["stream_info"] as? [String:Any] ?? [:]
                            let stream_info_key_exists = self.aryStreamInfo["id"]
                            if (stream_info_key_exists != nil){
                                let streamObj = self.aryStreamInfo
                                
                                self.viewLiveStream.isHidden = false;
                                self.btnPlayStream.setImage(UIImage.init(named: "video-play"), for: .normal)
                                self.btnPlayStream.isHidden = true;
                                self.streamId = streamObj["id"] as? Int ?? 0
                                self.age_limit = streamObj["age_limit"] as? Int ?? 0
                                self.streamVideoCode = streamObj["stream_video_code"] as? String ?? ""
                                let streamVideoTitle = streamObj["stream_video_title"] as? String ?? ""
                                self.number_of_creators = streamObj["number_of_creators"] as? Int ?? 1
                                
                                //print("==streamVideoTitle:",streamVideoTitle)
                                self.isChannelAvailable = true
                                self.sendBirdChatConfig()
                                self.sendBirdEmojiConfig()
                                self.streamVideoDesc = streamObj["stream_video_description"] as? String ?? ""
                                // "currency_type" = USD;
                                var currency_type = streamObj["currency_type"] as? String ?? ""
                                if(currency_type == "GBP"){
                                    currency_type = "£"
                                }else{
                                    currency_type = "$"
                                }
                                var strAmount = "0.0"
                                
                                if (streamObj["stream_payment_amount"] as? Double) != nil {
                                    strAmount = String(streamObj["stream_payment_amount"] as? Double ?? 0.0)
                                }else if (streamObj["stream_payment_amount"] as? String) != nil {
                                    strAmount = String(streamObj["stream_payment_amount"] as? String ?? "0.0")
                                }
                                let doubleAmount = Double(strAmount)
                                let amount = String(format: "%.02f", doubleAmount!)
                                self.amountWithCurrencyType = currency_type + amount
                                
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
                                    let dicAmounts = self.convertToDictionary(text: stream_amounts)
                                    self.aryStreamAmounts = dicAmounts?["live_stream"] as? [Any] ?? [Any]()
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
                                        USDPrice.sort()
                                        GBPPrice.sort()
                                        
                                        
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
                                        if(currency_type == "£"){
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
                                        let firstValue = USDPrice[0]
                                        let lastValue = USDPrice[USDPrice.count - 1];
                                        let amountDisplay = "$" + firstValue + " - " + "$" + lastValue;
                                        // //print("====amount in Dollars:",amountDisplay)
                                        self.lblAmount.text = amountDisplay
                                        if(firstValue == lastValue){
                                            self.amountWithCurrencyType = "$" + firstValue
                                        }else{
                                            self.amountWithCurrencyType = "$" + firstValue + " - " + "$" + lastValue;
                                        }
                                    }else if(subCurrencyType == "GBP"){
                                        let firstValue = GBPPrice[0]
                                        let lastValue = GBPPrice[GBPPrice.count - 1];
                                        let amountDisplay = "£" + firstValue + " - " + "£" + lastValue;
                                        // //print("====amount in Euros:",amountDisplay)
                                        self.lblAmount.text = amountDisplay
                                        if(firstValue == lastValue){
                                            self.amountWithCurrencyType = "£" + firstValue
                                        }else{
                                            self.amountWithCurrencyType = "£" + firstValue + " - " + "£" + lastValue;
                                        }
                                        
                                    }
                                    // //print("===eventStartDates:",eventStartDates)
                                    // //print("===eventEndDates:",eventEndDates)
                                    
                                    if(eventStartDates.count > 0 && eventEndDates.count > 0){
                                        let currentDate = Date()
                                        let dateFormatter = DateFormatter()
                                        dateFormatter.timeZone = NSTimeZone(abbreviation: "UTC") as TimeZone?
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
                                
                                
                            }else{
                                //if we get any error default, we are showing VOD
                                self.viewVOD.isHidden = true;
                                self.viewLiveStream.isHidden = false;
                                //self.lblVODUnavailable.text = "Stream Info not found"
                                if (!self.isVOD){
                                    self.lblStreamUnavailable.text = "Please wait for the host to start the live stream"
                                    self.btnPlayStream.isHidden = false
                                    self.btnPlayStream.setImage(UIImage.init(named: "refresh"), for: .normal)
                                    self.btnPlayStream.isUserInteractionEnabled = false
                                }
                                //ALToastView.toast(in: self.viewVOD, withText:"Stream Info not found")
                            }
                            let user_subscription_info = data?["user_subscription_info"] != nil
                            if(user_subscription_info){
                                self.aryUserSubscriptionInfo = data?["user_subscription_info"] as? [Any] ?? [Any]()
                            }
                            let user_age_limit = UserDefaults.standard.integer(forKey:"user_age_limit");
                            // //print("---user_age_limit:",user_age_limit)
                            //   //print("---age_limit:",self.age_limit)
                            /*if(self.checkSale && !self.saleStarts){
                             self.btnPayPerView.isHidden = false
                             }else if(self.saleStarts){
                             if(eventStartDates.count > 0){
                             self.btnPayPerView.isHidden = true
                             let startDate = eventStartDates[0]
                             let formatter = DateFormatter()
                             formatter.timeZone = NSTimeZone(abbreviation: "UTC") as TimeZone?
                             formatter.dateFormat = "dd MMM yyyy"
                             let myString = formatter.string(from: startDate) // string purpose I add here
                             self.lblStreamUnavailable.text = "Sale Starts On " + myString
                             }
                             }else if(self.saleCompleted){
                             self.btnPayPerView.isHidden = true
                             self.lblStreamUnavailable.text = "Sale is completed!"
                             }*/
                            if(self.streamPaymentMode == "free"){
                                self.lblAmount.text = "Free"
                            }
                            let streamObj = self.aryStreamInfo
                            let stream_status = streamObj["stream_status"] as? String ?? ""
                            if(stream_status == "completed"){
                                //uncomment below line
                                //self.setLiveStreamConfig()
                                
                                self.viewLiveStream.isHidden = false;
                                self.btnPayPerView.isHidden = true
                                self.lblStreamUnavailable.text = "Sale is completed!"
                                self.viewActions?.isHidden = true
                                return
                            }
                            if (self.age_limit <= user_age_limit || self.age_limit == 0){
                                if (self.aryUserSubscriptionInfo.count == 0){
                                    //if user does not pay amount
                                    self.btnPayPerView.isHidden = false
                                    self.viewVOD.isHidden = false
                                    self.isChannelAvailable = false
                                    self.isShowChat = false
                                    self.viewActions?.isHidden = true
                                }else{
                                    self.btnPayPerView.isHidden = true
                                    self.lblAmount.isHidden = true
                                    self.lblDate.isHidden = true
                                    self.lblTime.isHidden = true
                                    
                                    if (stream_info_key_exists != nil){
                                        let streamObj = self.aryStreamInfo
                                        if (streamObj["stream_vod"]as? String == "stream" && self.isVOD == false && self.isAudio == false){
                                            
                                            self.viewVOD.isHidden = true
                                            self.viewLiveStream.isHidden = false;
                                            self.isStream = true;
                                            self.btnPlayStream.isHidden = true;
                                            //self.lblStreamUnavailable.text = "";
                                            //print("==checkSale:",self.checkSale)
                                            //print("==saleStarts:",self.saleStarts)
                                            //print("==saleCompleted:",self.saleCompleted)
                                            
                                            if(self.checkSale && !self.saleStarts){
                                                self.setLiveStreamConfig()
                                            }else if(self.saleStarts){
                                                if(eventStartDates.count > 0){
                                                    self.btnPayPerView.isHidden = true
                                                    let startDate = eventStartDates[0]
                                                    let formatter = DateFormatter()
                                                    formatter.timeZone = NSTimeZone(abbreviation: "UTC") as TimeZone?
                                                    formatter.dateFormat = "dd MMM yyyy"
                                                    let myString = formatter.string(from: startDate) // string purpose I add here
                                                    self.lblStreamUnavailable.text = "Sale Starts On " + myString
                                                    self.viewActions?.isHidden = true
                                                }
                                            }else if(self.saleCompleted){
                                                self.btnPayPerView.isHidden = true
                                                self.lblStreamUnavailable.text = "Sale is completed!"
                                                self.viewActions?.isHidden = true
                                                
                                            }
                                            if(!self.checkSale && !self.saleStarts && !self.saleCompleted && self.streamPaymentMode == "free"){
                                                self.setLiveStreamConfig()
                                            }
                                        }else{
                                            self.lblVODUnavailable.text = ""
                                            self.viewVOD.isHidden = false
                                            self.viewLiveStream.isHidden = true;
                                            self.btnPlayStream.isHidden = true;
                                            self.isStream = false;
                                            if (self.isVOD || streamObj["stream_vod"]as? String == "vod"){
                                                let vod_urls = streamObj["vod_urls"] as? String ?? ""
                                                var strURL = "";
                                                if (vod_urls != ""){
                                                    let vod_urls = self.convertToDictionary(text: vod_urls)
                                                    let strHigh = vod_urls?["master"] as? String ?? ""
                                                    if (strHigh != ""){
                                                        strURL = strHigh;
                                                    }else{
                                                        let strMedium = vod_urls?["level3"] as? String ?? ""
                                                        if (strMedium != ""){
                                                            strURL = strMedium;
                                                        }else{
                                                            let strLow = vod_urls?["level2"] as? String ?? ""
                                                            if (strLow != ""){
                                                                strURL = strLow;
                                                            }else{
                                                                let strLowest = vod_urls?["level1"] as? String ?? ""
                                                                if (strLowest != ""){
                                                                    strURL = strLowest;
                                                                }else{
                                                                    let video_url = streamObj["video_url"] as? String ?? ""
                                                                    strURL = video_url
                                                                }
                                                            }
                                                        }
                                                    }
                                                }else{
                                                    let video_url = streamObj["video_url"] as? String ?? ""
                                                    strURL = video_url
                                                }
                                                //print("strURL:",strURL)
                                                self.showVideo(strURL: strURL);
                                            }else{
                                                if(self.isAudio){
                                                    //audio
                                                    //print("strAudioSource:",self.strAudioSource)
                                                    self.showVideo(strURL: self.strAudioSource)
                                                }else{
                                                    //if stream_vod value is not stream or not vod
                                                    let video_url = streamObj["video_url"] as? String ?? ""
                                                    let strURL = video_url
                                                    self.showVideo(strURL: strURL);
                                                }
                                            }
                                        }
                                    }
                                }
                            }else{
                                self.isChannelAvailable = false
                                self.btnPlayStream.isHidden = false;
                                self.btnPlayStream.isUserInteractionEnabled = false
                                self.btnPlayStream.setImage(UIImage.init(named: "eye-cross"), for: .normal)
                                self.lblStreamUnavailable.text = "This video may be inappropriate for some users"
                                self.isShowChat = false
                                self.isAgeAllowed = false
                            }
                            let charity_info = data?["charity_info"] != nil
                            if(charity_info){
                                self.aryCharityInfo = data?["charity_info"] as? [Any] ?? [Any]()
                                self.tblDonations.reloadData()
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
                                
                                self.txtVideoDesc_Info.text = videoDesc  + "\n\n" + creatorName
                                
                                self.app_id_for_adds = self.dicPerformerInfo["app_id"] as? String ?? "0"
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
                            self.viewVOD.isHidden = false
                            self.viewLiveStream.isHidden = true;
                        }
                    }
                case .failure(let error):
                    let errorDesc = error.localizedDescription.replacingOccurrences(of: "URLSessionTask failed with error:", with: "")
                    
                    
                    
                    self.showAlert(strMsg: errorDesc)
                    self.viewActivity.isHidden = true
                    
                }
            }
    }
    
    
    // MARK: - Stream Methods
    func setLiveStreamConfig(){
        
        let netAvailable = appDelegate.isConnectedToInternet()
        if(!netAvailable){
            showAlert(strMsg: "Please check your internet connection!")
        }
        self.viewActions?.isHidden = false
        
        let session_token = UserDefaults.standard.string(forKey: "session_token");
        let user_email = UserDefaults.standard.string(forKey: "user_email");
        
        let path = Bundle.main.path(forResource: "R5options", ofType: "plist")
        let dicPlist = NSMutableDictionary(contentsOfFile: path!)
        let dicGlobalProperties = dicPlist?.value(forKey: "GlobalProperties") as? NSMutableDictionary
        
        let license_key = dicGlobalProperties?["license_key"] as? String
        let server_port = dicGlobalProperties?["server_port"] as? String
        let bitrate = dicGlobalProperties?["bitrate"] as? Int
        let host = appDelegate.red5_pro_host
        let buffer_time = dicGlobalProperties?["buffer_time"] as? Float
        let port = dicGlobalProperties?["port"] as? Int
        let stream2 = dicGlobalProperties?["stream2"] as? String
        let context = dicGlobalProperties?["context"] as? String
        let camera_width = dicGlobalProperties?["camera_width"] as? Int
        let camera_height = dicGlobalProperties?["camera_height"] as? Int
        let fps = dicGlobalProperties?["fps"] as? Int
        let sm_version = dicGlobalProperties?["sm_version"] as? String
        
        Testbed.setUserName(name: user_email ?? "")
        Testbed.setPassword(name: session_token ?? "")
        Testbed.setLicenseKey(name:license_key ?? "")
        Testbed.setServerPort(name: server_port ?? "")
        Testbed.setBitrate(name: bitrate ?? 0)
        Testbed.setBufferTime(name: buffer_time ?? 0.0)
        Testbed.setPort(name: port ?? 0)
        Testbed.setStreamName(name: streamVideoCode)
        Testbed.setStream1Name(name: streamVideoCode)
        Testbed.setStream2Name(name: stream2 ?? "")
        Testbed.setHost(name: host );
        Testbed.setContext(name: context ?? "")
        Testbed.setCameraWidth(name: camera_width ?? 0)
        Testbed.setCameraHeight(name: camera_height ?? 0)
        Testbed.setFPs(name: fps ?? 0)
        Testbed.setSMVersion(name: sm_version ?? "")
        Testbed.setDebug(on: true)
        Testbed.setVideo(on: true)
        Testbed.setAudio(on: true)
        Testbed.setHWAccel(on: false)
        Testbed.setRecord(on: true)
        Testbed.setRecordAppend(on: true)
        // Testbed.parameters = Testbed.dictionary!.value(forKey: "GlobalProperties") as? NSMutableDictionary
        self.configureStreamView()
    }
    func configureStreamView() {
        
        // Update the user interface for the detail item.
        // Access the static shared interface to ensure it's loaded
        //if number_of_creators > 1 multi stream
        //else single stream
        //print("====number_of_creators:",number_of_creators)
        if(number_of_creators > 1){
            let storyboard = UIStoryboard(name: "Main", bundle: nil);
            let vc = storyboard.instantiateViewController(withIdentifier: "MultiStreamVC") as! MultiStreamVC
            vc.strTitle = strTitle
            vc.resultData = self.resultData
            vc.orgId = self.orgId
            vc.performerId = self.performerId
            vc.streamId = self.streamId
            self.navigationController?.pushViewController(vc, animated: false)
        }else{
            if(!isStreamStarted){
                viewActivity.isHidden = false
            }
            _ = Testbed.sharedInstance
            self.detailStreamItem = Testbed.testAtIndex(index: 0)
            if(self.detailStreamItem != nil){
                ////print("props:",self.detailStreamItem!["LocalProperties"] as? NSMutableDictionary)
                
                Testbed.setLocalOverrides(params: self.detailStreamItem!["LocalProperties"] as? NSMutableDictionary)
                let className = self.detailStreamItem!["class"] as! String
                let mClass = NSClassFromString(className) as! BaseTest.Type;
                
                r5ViewController  = mClass.init()
                r5ViewController?.view.frame = self.viewLiveStream.bounds
                self.viewLiveStream.addSubview(r5ViewController!.view)
                self.addChild(r5ViewController!)
                self.viewLiveStream.bringSubviewToFront(webView)
                self.viewLiveStream.bringSubviewToFront(self.viewOverlay!)
                self.viewLiveStream.bringSubviewToFront(lblStreamUnavailable)
                
            }
        }
        
    }
    @objc func showInfo(){
        let alert = UIAlertView()
        alert.title = "Info"
        alert.message = self.detailItem["description"] as? String
        alert.addButton(withTitle: "OK")
        alert.show()
    }
    
    
    
    func closeStream(){
        self.viewLiveStream.isHidden = true;
        // if( r5ViewController != nil ){
        r5ViewController?.closeTest()
        //     r5ViewController = nil
        // }
    }
    var shouldClose:Bool{
        get{
            if(r5ViewController != nil){
                return (r5ViewController?.shouldClose)!
            }
            else{
                return true
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    open override var shouldAutorotate:Bool {
        get {
            return true
        }
    }
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        get {
            return [UIInterfaceOrientationMask.all]
        }
    }
    func navigationControllerSupportedInterfaceOrientations(_ navigationController: UINavigationController) -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.all
    }
    // MARK: - Send Bird Methods
    
    
    
    func loadPreviousMessages(initial: Bool) {
        guard let channel = self.channel else { return }
        
        if self.isLoading {
            return
        }
        
        self.isLoading = true
        
        var timestamp: Int64 = 0
        
        if initial {
            self.hasPrevious = true
            timestamp = Int64.max
        }
        else {
            timestamp = self.minMessageTimestamp
        }
        
        if self.hasPrevious == false {
            return
        }
        
        channel.getPreviousMessages(byTimestamp: timestamp, limit: 30, reverse: !initial, messageType: .all, customType: nil, completionHandler: { (msgs, error) in
            if error != nil {
                self.isLoading = false
                
                return
            }
            
            guard let messages = msgs else { return }
            
            if messages.count == 0 {
                self.hasPrevious = false
            }
            
            if initial {
                if messages.count > 0 {
                    DispatchQueue.main.async {
                        self.messages.removeAll()
                        
                        for message in messages {
                            self.messages.append(message)
                            
                            if self.minMessageTimestamp > message.createdAt {
                                self.minMessageTimestamp = message.createdAt
                            }
                        }
                        
                        self.initialLoading = true
                        
                        self.tblComments.reloadData()
                        self.tblComments.layoutIfNeeded()
                        
                        self.scrollToBottom(force: true)
                        self.initialLoading = false
                        self.isLoading = false
                    }
                }
            }
            else {
                if messages.count > 0 {
                    DispatchQueue.main.async {
                        var messageIndexPaths: [IndexPath] = []
                        var row: Int = 0
                        for message in messages {
                            self.messages.insert(message, at: 0)
                            
                            if self.minMessageTimestamp > message.createdAt {
                                self.minMessageTimestamp = message.createdAt
                            }
                            
                            messageIndexPaths.append(IndexPath(row: row, section: 0))
                            row += 1
                        }
                        
                        self.tblComments.reloadData()
                        self.tblComments.layoutIfNeeded()
                        
                        self.tblComments.scrollToRow(at: IndexPath(row: messages.count-1, section: 0), at: .top, animated: false)
                        self.isLoading = false
                    }
                }
            }
        })
        //print("msgs:",self.messages)
    }
    func loadPreviousEmojis(initial: Bool) {
        guard let channel_emoji = self.channel_emoji else { return }
        
        if self.isLoading {
            return
        }
        
        self.isLoading = true
        
        var timestamp: Int64 = 0
        
        if initial {
            self.hasPrevious = true
            timestamp = Int64.max
        }
        else {
            timestamp = self.minMessageTimestamp
        }
        
        if self.hasPrevious == false {
            return
        }
        
        channel_emoji.getPreviousMessages(byTimestamp: timestamp, limit: 30, reverse: !initial, messageType: .all, customType: nil, completionHandler: { (msgs, error) in
            if error != nil {
                self.isLoading = false
                
                return
            }
            
            guard let emojis = msgs else { return }
            
            if emojis.count == 0 {
                self.hasPrevious = false
            }
            
            if initial {
                if emojis.count > 0 {
                    DispatchQueue.main.async {
                        self.emojis.removeAll()
                        
                        for message in emojis {
                            self.emojis.append(message)
                            ////print("self.emojis:",self.emojis)
                            if self.minMessageTimestamp > message.createdAt {
                                self.minMessageTimestamp = message.createdAt
                            }
                        }
                        
                        self.initialLoading = true
                        self.animateEmojisLoop()
                        //self.tblComments.reloadData()
                        self.initialLoading = false
                        self.isLoading = false
                    }
                }
            }
            else {
                if emojis.count > 0 {
                    DispatchQueue.main.async {
                        var messageIndexPaths: [IndexPath] = []
                        var row: Int = 0
                        for message in emojis {
                            self.emojis.insert(message, at: 0)
                            
                            if self.minMessageTimestamp > message.createdAt {
                                self.minMessageTimestamp = message.createdAt
                            }
                            
                            messageIndexPaths.append(IndexPath(row: row, section: 0))
                            row += 1
                        }
                        
                        //  self.tblComments.reloadData()
                        
                        self.isLoading = false
                    }
                }
            }
        })
    }
    
    @IBAction func sendChatMessage() {
        
        txtComment.resignFirstResponder()
        txtTopOfToolBar.resignFirstResponder()
        let messageText = txtComment.text!.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        if (messageText.count == 0){
            showAlert(strMsg: "Please enter message")
            return
        }
        self.txtComment.text = ""
        self.txtTopOfToolBar.text = ""
        
        if (!isChannelAvailable){
            //print("sendBirdErrorCode:",sendBirdErrorCode)
            switch sendBirdErrorCode {
            case 403100:
                showAlert(strMsg: "Application id disabled/expired, Please contact admin.")
            case 400300:
                showAlert(strMsg: "Deactivated user not accessible, Please contact admin.")
            case 400301:
                showAlert(strMsg: "User not found, Please contact admin.")
            case 400304:
                showAlert(strMsg: "Application id not found, Please contact admin.")
            case 400306:
                showAlert(strMsg: "Paid quota exceeded, Please contact admin.")
            case 400700:
                showAlert(strMsg: "Blocked user send not allowed, Please contact admin.")
            case 500910:
                showAlert(strMsg: "Rate limit exceeded, Please contact admin.")
            case 400201:
                showAlert(strMsg: "Channel is not available, Please try again later.")
            default:
                showAlert(strMsg: "Channel is not available, Please try again later.")
            //              showAlert(strMsg: "\(self.sbdError)")
            }
            return
        }
        
        //print("channelName:",channelName)
        guard let channel = self.channel else {
            showAlert(strMsg: "Channel is not available, Please try again later.")
            return
        }
        //print("channelName2:",self.channel?.name);
        self.txtComment.text = ""
        //self.sendUserMessageButton.isEnabled = false
        var preSendMessage: SBDUserMessage?
        preSendMessage = channel.sendUserMessage(messageText) { (userMessage, error) in
            if error != nil {
                DispatchQueue.main.async {
                    guard let preSendMsg = preSendMessage else { return }
                    guard let requestId = preSendMsg.requestId else { return }
                    
                    self.preSendMessages.removeValue(forKey: requestId)
                    self.resendableMessages[requestId] = preSendMsg
                    self.tblComments.reloadData()
                    self.scrollToBottom(force: true)
                    
                }
                return
            }
            
            guard let message = userMessage else { return }
            guard let requestId = message.requestId else { return }
            
            DispatchQueue.main.async {
                self.determineScrollLock()
                
                if let preSendMessage = self.preSendMessages[requestId] {
                    if let index = self.messages.firstIndex(of: preSendMessage) {
                        self.messages[index] = message
                        self.preSendMessages.removeValue(forKey: requestId)
                        self.tblComments.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
                        self.scrollToBottom(force: true)
                    }
                }
            }
        }
        
        DispatchQueue.main.async {
            self.determineScrollLock()
            if let preSendMsg = preSendMessage {
                if let requestId = preSendMsg.requestId {
                    self.preSendMessages[requestId] = preSendMsg
                    self.messages.append(preSendMsg)
                    self.tblComments.reloadData()
                    self.scrollToBottom(force: true)
                }
            }
        }
    }
    @IBAction func sendEmoji(strEmoji: String) {
        txtEmoji.resignFirstResponder()
        
        if (!isChannelAvailable_emoji){
            ////print("sendBirdErrorCode:",sendBirdErrorCode_Emoji)
            switch sendBirdErrorCode_Emoji {
            case 403100:
                showAlert(strMsg: "Application id disabled/expired, Please contact admin.")
            case 400300:
                showAlert(strMsg: "Deactivated user not accessible, Please contact admin.")
            case 400301:
                showAlert(strMsg: "User not found, Please contact admin.")
            case 400304:
                showAlert(strMsg: "Application id not found, Please contact admin.")
            case 400306:
                showAlert(strMsg: "Paid quota exceeded, Please contact admin.")
            case 400700:
                showAlert(strMsg: "Blocked user send not allowed, Please contact admin.")
            case 500910:
                showAlert(strMsg: "Rate limit exceeded, Please contact admin.")
            case 400201:
                showAlert(strMsg: "Channel is not available, Please try again later.")
            default:
                showAlert(strMsg: "Channel is not available, Please try again later.")
            //showAlert(strMsg: "\(self.sbdError_emoji)")
            }
            return
        }
        
        ////print("channelName:",channelName_Emoji)
        guard let channel_emoji = self.channel_emoji else {
            showAlert(strMsg: "Channel is not available, Please try again later.")
            txtEmoji.resignFirstResponder()
            return
        }
        animateEmoji()
        ////print("channel_emoji name:",self.channel_emoji?.name ?? "");
        //self.sendUserMessageButton.isEnabled = false
        var preSendMessage: SBDUserMessage?
        preSendMessage = channel_emoji.sendUserMessage(strEmoji) { (userMessage, error) in
            if error != nil {
                DispatchQueue.main.async {
                    guard let preSendMsg = preSendMessage else { return }
                    guard let requestId = preSendMsg.requestId else { return }
                    
                    self.preSendMessage_emojis.removeValue(forKey: requestId)
                    self.resendableMessage_emojis[requestId] = preSendMsg
                    // self.tblComments.reloadData()
                }
                return
            }
            
            guard let message = userMessage else {
                return
                
            }
            guard let requestId = message.requestId else {
                return
                
            }
            
            DispatchQueue.main.async {
                self.determineScrollLock()
                
                if let preSendMessage = self.preSendMessage_emojis[requestId] {
                    if let index = self.emojis.firstIndex(of: preSendMessage) {
                        self.emojis[index] = message
                        self.preSendMessage_emojis.removeValue(forKey: requestId)
                        //  self.tblComments.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
                    }
                }
            }
        }
        
        DispatchQueue.main.async {
            self.determineScrollLock()
            if let preSendMsg = preSendMessage {
                if let requestId = preSendMsg.requestId {
                    self.preSendMessage_emojis[requestId] = preSendMsg
                    self.emojis.append(preSendMsg)
                    //                    self.tblComments.reloadData()
                    //                    self.scrollToBottom(force: false)
                }
            }
        }
    }
    // MARK: - Scroll
    func scrollToBottom(force: Bool) {
        if self.messages.count == 0 {
            return
        }
        
        if self.scrollLock && force == false {
            return
        }
        
        let currentRowNumber = self.tblComments.numberOfRows(inSection: 0)
        
        self.tblComments.scrollToRow(at: IndexPath(row: currentRowNumber - 1, section: 0), at: .bottom, animated: false)
    }
    // MARK: - Keyboard
    func determineScrollLock() {
        if self.messages.count > 0 {
            if let indexPaths = self.tblComments.indexPathsForVisibleRows {
                if let lastVisibleCellIndexPath = indexPaths.last {
                    let lastVisibleRow = lastVisibleCellIndexPath.row
                    if lastVisibleRow != self.messages.count - 1 {
                        self.scrollLock = true
                    }
                    else {
                        self.scrollLock = false
                    }
                }
            }
        }
    }
    @IBAction func playStream(_ sender: Any){
        //print("playStream called")
        self.configureStreamView();
    }
    // MARK: - Emoji Delegates
    
    //  Converted to Swift 5.2 by Swiftify v5.2.28138 - https://swiftify.com/
    
    func emojiKeyBoardView(_ emojiKeyBoardView: AGEmojiKeyboardView?, didUseEmoji emoji: String?) {
        imgEmoji.image = emoji?.image()
        sendEmoji(strEmoji: emoji ?? "")
        
        //txtEmoji?.text = "\(emoji ?? "")"
    }
    
    func emojiKeyBoardViewDidPressBackSpace(_ emojiKeyBoardView: AGEmojiKeyboardView?) {
    }
    
    func randomColor() -> UIColor? {
        return UIColor(
            red: CGFloat(drand48()),
            green: CGFloat(drand48()),
            blue: CGFloat(drand48()),
            alpha: CGFloat(drand48()))
    }
    
    func randomImage() -> UIImage? {
        let size = CGSize(width: 30, height: 10)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        
        let context = UIGraphicsGetCurrentContext()
        var fillColor = randomColor()
        if let cg = fillColor?.cgColor {
            context?.setFillColor(cg)
        }
        var rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        context?.fill(rect)
        
        fillColor = randomColor()
        if let cg = fillColor?.cgColor {
            context?.setFillColor(cg)
        }
        let xxx: CGFloat = 3
        rect = CGRect(x: xxx, y: xxx, width: size.width - 2 * xxx, height: size.height - 2 * xxx)
        context?.fill(rect)
        
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img
    }
    
    func emojiKeyboardView(_ emojiKeyboardView: AGEmojiKeyboardView?, imageForSelectedCategory category: AGEmojiKeyboardViewCategoryImage) -> UIImage? {
        let img = randomImage()
        img?.withRenderingMode(.alwaysOriginal)
        return img
    }
    
    func emojiKeyboardView(_ emojiKeyboardView: AGEmojiKeyboardView?, imageForNonSelectedCategory category: AGEmojiKeyboardViewCategoryImage) -> UIImage? {
        let img = randomImage()
        img?.withRenderingMode(.alwaysOriginal)
        return img
    }
    
    func backSpaceButtonImage(for emojiKeyboardView: AGEmojiKeyboardView?) -> UIImage? {
        let img = randomImage()
        img?.withRenderingMode(.alwaysOriginal)
        return img
    }
    
    // MARK: - Webview Delegates
    func webViewDidStartLoad(_ webView: UIWebView) {
        //viewActivity.isHidden = false
    }
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error)
    {
        //viewActivity.isHidden = true
        //self.showAlert(strMsg:error.localizedDescription)
    }
    func webViewDidFinishLoad(_ webView: UIWebView) {
        //viewActivity.isHidden = true
    }
    deinit {
        //print("Remove NotificationCenter Deinit")
        NotificationCenter.default.removeObserver(self)
    }
    //MARK: - location delegate methods
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let netAvailable = appDelegate.isConnectedToInternet()
        if(!netAvailable){
            return
        }
        let userLocation :CLLocation = locations[0] as CLLocation
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(userLocation) { (placemarks, error) in
            if (error != nil){
                ////print("error in reverseGeocode")
            }
            let placemark = placemarks! as [CLPlacemark]
            if placemark.count>0{
                let placemark = placemarks![0]
                ////print("country:",placemark.country!)
                self.strCountry = placemark.country!
                self.getRegion()
            }
        }
        
    }
    func getRegion(){
        for (i,_) in aryCountries.enumerated(){
            let element = aryCountries[i]
            let countryNames = element["countries"] as! [Any];
            for (j,_) in countryNames.enumerated() {
                let country = countryNames[j] as! String
                if(country.lowercased() == strCountry.lowercased()){
                    ////print("equal:",country)
                    strRegionCode = element["region_code"]as! String
                    return
                }
            }
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        ////print("Error \(error)")
    }
    // MARK: - SBDChannelDelegate
    func channel(_ sender: SBDBaseChannel, didReceive message: SBDBaseMessage) {
        if let channel = self.channel {
            if sender == channel {
                DispatchQueue.main.async {
                    self.determineScrollLock()
                    UIView.setAnimationsEnabled(false)
                    self.messages.append(message)
                    self.tblComments.insertRows(at: [IndexPath(row: self.messages.count - 1, section: 0)], with: .none)
                    self.scrollToBottom(force: false)
                    UIView.setAnimationsEnabled(true)
                }
            }
        }
    }
    func channel(_ sender: SBDBaseChannel, userWasMuted user: SBDUser) {
        guard let currentUser = SBDMain.getCurrentUser() else { return }
        guard let channel = self.channel else { return }
        
        if user.userId == currentUser.userId, sender.channelUrl == channel.channelUrl {
            let alert = UIAlertController(title: "You are muted.", message: "You are muted. You won't be able to send messages.", preferredStyle: .alert)
            let actionConfirm = UIAlertAction(title: "Okay", style: .cancel) { (action) in
                self.sendUserMessageButton.isEnabled = false
                self.txtComment.isEnabled = false
                self.txtComment.placeholder = "You are muted"
                self.sendUserMessageButton.isEnabled = false
            }
            alert.addAction(actionConfirm)
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func channel(_ sender: SBDBaseChannel, userWasUnmuted user: SBDUser) {
        guard let currentUser = SBDMain.getCurrentUser() else { return }
        guard let channel = self.channel else { return }
        
        if user.userId == currentUser.userId, sender.channelUrl == channel.channelUrl {
            self.sendUserMessageButton.isEnabled = true
            self.txtComment.isEnabled = true
            self.txtComment.placeholder = "Send a message"
            self.sendUserMessageButton.isEnabled = false
        }
    }
    
    func channel(_ sender: SBDBaseChannel, userWasBanned user: SBDUser) {
        guard let currentUser = SBDMain.getCurrentUser() else { return }
        guard let channel = self.channel else { return }
        
        if user.userId == currentUser.userId && sender.channelUrl == channel.channelUrl {
            let alert = UIAlertController(title: "You are banned.", message: "You are banned for 10 minutes. This channel will be closed.", preferredStyle: .alert)
            let actionCancel = UIAlertAction(title: "Close", style: .cancel) { (action) in
                self.navigationController?.popViewController(animated: true)
            }
            alert.addAction(actionCancel)
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func channelWasDeleted(_ channelUrl: String, channelType: SBDChannelType) {
        let alert = UIAlertController(title: "Channel has been deleted.", message: "This channel has been deleted. It will be closed.", preferredStyle: .alert)
        let actionCancel = UIAlertAction(title: "Close", style: .cancel) { (action) in
            self.navigationController?.popViewController(animated: true)
        }
        alert.addAction(actionCancel)
        
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func channel(_ sender: SBDBaseChannel, messageWasDeleted messageId: Int64) {
        DispatchQueue.main.async {
            guard let channel = self.channel else { return }
            
            if sender == channel {
                self.deleteMessageFromTableView(messageId)
            }
        }
    }
    
    func channel(_ sender: SBDBaseChannel, didUpdate message: SBDBaseMessage) {
        for (i, prevMessage) in messages.enumerated() {
            if prevMessage.messageId == message.messageId {
                messages.remove(at: i)
                messages.insert(message, at: i)
                DispatchQueue.main.async {
                    self.tblComments.reloadRows(at: [IndexPath(row: i, section: 0)], with: .none)
                }
                break
            }
        }
    }
    
    func channelWasChanged(_ sender: SBDBaseChannel) {
        DispatchQueue.main.async {
            guard let channel = self.channel else { return }
            
            if sender == channel {
                self.title = channel.name
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
        let params: [String: Any] = ["userid":user_id ?? "","stream_id": String(self.streamId)]
        print("getVodById params:",params)
        
        let headers: HTTPHeaders = [appDelegate.x_api_key: appDelegate.x_api_value]
        
        AF.request(url, method: .post,parameters: params, encoding: JSONEncoding.default,headers:headers)
            .responseJSON { response in
                self.viewActivity.isHidden = true
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any] {
                        print("getVodById JSON:",json)
                        if (json["statusCode"]as? String == "200"){
                            var USDPrice = [String]()
                            var GBPPrice = [String]()
                            var eventStartDates = [Date]()
                            var eventEndDates = [Date]()
                            ////print(json["message"] as? String ?? "")
                            let data = json["Data"] as? [String:Any]
                            self.aryStreamInfo = data?["stream_info"] as? [String:Any] ?? [:]
                            let stream_info_key_exists = self.aryStreamInfo["id"]
                            if (stream_info_key_exists != nil){
                                self.viewLiveStream.isHidden = false;
                                self.btnPlayStream.setImage(UIImage.init(named: "video-play"), for: .normal)
                                self.btnPlayStream.isHidden = true;
                                let streamObj = self.aryStreamInfo
                                self.streamId = streamObj["id"] as? Int ?? 0
                                self.age_limit = streamObj["age_limit"] as? Int ?? 0
                                self.streamVideoCode = streamObj["stream_video_code"] as? String ?? ""
                                let streamVideoTitle = streamObj["stream_video_title"] as? String ?? ""
                                //print("==streamVideoTitle:",streamVideoTitle)
                                self.isChannelAvailable = true
                                self.sendBirdChatConfig()
                                self.sendBirdEmojiConfig()
                                self.streamVideoDesc = streamObj["stream_video_description"] as? String ?? ""
                                // "currency_type" = USD;
                                var currency_type = streamObj["currency_type"] as? String ?? ""
                                if(currency_type == "GBP"){
                                    currency_type = "£"
                                }else{
                                    currency_type = "$"
                                }
                                var strAmount = "0.0"
                                
                                if (streamObj["stream_payment_amount"] as? Double) != nil {
                                    strAmount = String(streamObj["stream_payment_amount"] as? Double ?? 0.0)
                                }else if (streamObj["stream_payment_amount"] as? String) != nil {
                                    strAmount = String(streamObj["stream_payment_amount"] as? String ?? "0.0")
                                }
                                let doubleAmount = Double(strAmount)
                                let amount = String(format: "%.02f", doubleAmount!)
                                self.amountWithCurrencyType = currency_type + amount
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
                                    let dicAmounts = self.convertToDictionary(text: stream_amounts)
                                    self.aryStreamAmounts = dicAmounts?["vod"] as? [Any] ?? [Any]()
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
                                        USDPrice.sort()
                                        GBPPrice.sort()
                                        
                                        
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
                                        if(currency_type == "£"){
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
                                        let firstValue = USDPrice[0]
                                        let lastValue = USDPrice[USDPrice.count - 1];
                                        let amountDisplay = "$" + firstValue + " - " + "$" + lastValue;
                                        // //print("====amount in Dollars:",amountDisplay)
                                        self.lblAmount.text = amountDisplay
                                        if(firstValue == lastValue){
                                            self.amountWithCurrencyType = "$" + firstValue
                                        }else{
                                            self.amountWithCurrencyType = "$" + firstValue + " - " + "$" + lastValue;
                                        }
                                    }else if(subCurrencyType == "GBP"){
                                        let firstValue = GBPPrice[0]
                                        let lastValue = GBPPrice[GBPPrice.count - 1];
                                        let amountDisplay = "£" + firstValue + " - " + "£" + lastValue;
                                        // //print("====amount in Euros:",amountDisplay)
                                        self.lblAmount.text = amountDisplay
                                        if(firstValue == lastValue){
                                            self.amountWithCurrencyType = "£" + firstValue
                                        }else{
                                            self.amountWithCurrencyType = "£" + firstValue + " - " + "£" + lastValue;
                                        }
                                    }
                                    // //print("===eventStartDates:",eventStartDates)
                                    // //print("===eventEndDates:",eventEndDates)
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
                                self.lblAmount.text = ""//Free
                            }
                            if (self.age_limit <= user_age_limit || self.age_limit == 0){
                                if (self.aryUserSubscriptionInfo.count == 0 && self.isVOD){
                                    //if user does not pay amount
                                    self.btnPayPerView.isHidden = false
                                    self.viewVOD.isHidden = false
                                    self.isChannelAvailable = false
                                    self.viewActions?.isHidden = true
                                }else{
                                    self.viewActions?.isHidden = false
                                    self.btnPayPerView.isHidden = true
                                    self.lblAmount.isHidden = true
                                    self.lblDate.isHidden = true
                                    self.lblTime.isHidden = true
                                    if (stream_info_key_exists != nil){
                                        let streamObj = self.aryStreamInfo
                                        self.lblVODUnavailable.text = ""
                                        self.viewVOD.isHidden = false
                                        self.viewLiveStream.isHidden = true;
                                        self.btnPlayStream.isHidden = true;
                                        self.isStream = false;
                                        if (self.isVOD){
                                            let vod_urls = streamObj["vod_urls"] as? String ?? ""
                                            var strURL = "";
                                            if (vod_urls != ""){
                                                let vod_urls = self.convertToDictionary(text: vod_urls)
                                                let strHigh = vod_urls?["master"] as? String ?? ""
                                                if (strHigh != ""){
                                                    strURL = strHigh;
                                                }else{
                                                    let strMedium = vod_urls?["level3"] as? String ?? ""
                                                    if (strMedium != ""){
                                                        strURL = strMedium;
                                                    }else{
                                                        let strLow = vod_urls?["level2"] as? String ?? ""
                                                        if (strLow != ""){
                                                            strURL = strLow;
                                                        }else{
                                                            let strLowest = vod_urls?["level1"] as? String ?? ""
                                                            if (strLowest != ""){
                                                                strURL = strLowest;
                                                            }else{
                                                                let video_url = streamObj["video_url"] as? String ?? ""
                                                                strURL = video_url
                                                            }
                                                        }
                                                    }
                                                }
                                            }else{
                                                let video_url = streamObj["video_url"] as? String ?? ""
                                                strURL = video_url
                                            }
                                            //print("strURL:",strURL)
                                            self.showVideo(strURL: strURL);
                                        }else{
                                            //audio
                                            //print("strAudioSource:",self.strAudioSource)
                                            if(self.strAudioSource == ""){
                                                let  videoUrl = streamObj["video_url"] as? String ?? ""
                                                self.showVideo(strURL:videoUrl)
                                            }else{
                                                self.showVideo(strURL: self.strAudioSource)
                                                
                                            }
                                        }
                                    }
                                }
                            }else{
                                self.isChannelAvailable = false
                                self.btnPlayStream.isHidden = false;
                                self.btnPlayStream.isUserInteractionEnabled = false
                                self.btnPlayStream.setImage(UIImage.init(named: "eye-cross"), for: .normal)
                                self.lblStreamUnavailable.text = "This vidoe may be inappropriate for some users"
                                
                            }
                            let charity_info = data?["charity_info"] != nil
                            if(charity_info){
                                self.aryCharityInfo = data?["charity_info"] as? [Any] ?? [Any]()
                                self.tblDonations.reloadData()
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
                                /* var performer_bio = self.dicPerformerInfo["performer_bio"] as? String ?? ""
                                 performer_bio = performer_bio.htmlToString
                                 
                                 self.txtProfile.text = performerName + "\n" + performer_bio*/
                                let videoDesc = self.streamVideoDesc;
                                let creatorName = "Creator Name: " + performerName;
                                
                                self.txtVideoDesc_Info.text = videoDesc  + "\n\n" + creatorName
                                
                                self.app_id_for_adds = self.dicPerformerInfo["app_id"] as? String ?? "0"
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
    func startSession(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let url: String = appDelegate.ol_lambda_url +  "/startSession"
        let user_id = UserDefaults.standard.string(forKey: "user_id");
        var streamIdLocal = "0"
        if (streamId != 0){
            streamIdLocal = String(streamId)
        }
        let inputData: [String: Any] = [ "user_id": user_id ?? "0",
                                         "event_id": streamIdLocal,
                                         "organization_id" : orgId,
                                         "performer_id" : performerId,
                                         "filekey": "stream_metrics/" + streamVideoCode + "/"]
        print("startSession single params:",inputData)
        
        let session_token = UserDefaults.standard.string(forKey: "session_token") ?? ""
        let headers : HTTPHeaders = [
            "Content-Type": "application/json",
            appDelegate.x_api_key:appDelegate.x_api_value,
            "Authorization": "Bearer " + session_token
        ]
        viewActivity.isHidden = false
        AF.request(url, method: .post,parameters: inputData, encoding: JSONEncoding.default,headers:headers)
            .responseJSON { response in
                self.viewActivity.isHidden = true
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any] {
                        //print("startSession JSON:",json)
                        if (json["statusCode"]as? String == "200" ){
                            self.startSessionResponse = json
                            self.isViewerCountcall = 1;
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
    
    
    
    // MARK: Handler for endSession API
    func endSession(){
        NSLog("==endSession")
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let url: String = appDelegate.ol_lambda_url +  "/endSession"
        let user_id = UserDefaults.standard.string(forKey: "user_id");
        let streamInfo = "stream_metrics/" + self.streamVideoCode + "/" + String(self.streamId)
        let session_start_time = self.startSessionResponse["session_start_time"] as? String ?? ""
        
        let params: [String: Any] = ["id":user_id ?? "","image_for": streamInfo,"session_start_time":session_start_time,"is_final":"true","event_id": String(self.streamId)]
        print("endSession single params:",params)
        let session_token = UserDefaults.standard.string(forKey: "session_token") ?? ""
        let headers : HTTPHeaders = [
            "Content-Type": "application/json",
            appDelegate.x_api_key:appDelegate.x_api_value,
            "Authorization": "Bearer " + session_token
        ]
        viewActivity.isHidden = false
        AF.request(url, method: .post,parameters: params, encoding: JSONEncoding.default,headers:headers)
            .responseJSON { response in
                self.viewActivity.isHidden = true
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any] {
                        //print("startSession JSON:",json)
                        if (json["statusCode"]as? String == "200" ){
                            
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
    func endSession1(){
        let netAvailable = appDelegate.isConnectedToInternet()
        if(!netAvailable){
            showAlert(strMsg: "Please check your internet connection!")
            return
        }
        viewActivity.isHidden = false
        let url: String = appDelegate.baseURL +  "/endSession"
        let session_token = UserDefaults.standard.string(forKey: "session_token") ?? ""
        let user_id = UserDefaults.standard.string(forKey: "user_id");
        let streamInfo = "stream_metrics/" + self.streamVideoCode + "/" + String(self.streamId)
        let session_start_time = self.startSessionResponse["session_start_time"] as? String ?? ""
        let params: [String: Any] = ["id":user_id ?? "","image_for": streamInfo,"session_start_time":session_start_time,"is_final":"true","event_id": String(self.streamId)]
        //print("endSession params:",params)
        
        let headers: HTTPHeaders = ["Content-type": "multipart/form-data","access_token": session_token,appDelegate.x_api_key: appDelegate.x_api_value]
        
        AF.request(url, method: .post,parameters: params, encoding: JSONEncoding.default,headers:headers)
            .responseJSON { response in
                self.viewActivity.isHidden = true
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any] {
                        //print("endSession JSON:",json)
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
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        //adding observer
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(StreamNotificationHandler(_:)), name: .didReceiveStreamData, object: nil)
        
        if(UIDevice.current.userInterfaceIdiom == .phone){
            let value = UIInterfaceOrientation.landscapeRight.rawValue
            UIDevice.current.setValue(value, forKey: "orientation")
        }
        AppDelegate.AppUtility.lockOrientation(.landscapeRight)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        AppDelegate.AppUtility.lockOrientation(.landscape, andRotateTo: .landscapeRight)
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        AppDelegate.AppUtility.lockOrientation(.all)
        NotificationCenter.default.removeObserver(self)
        if (timerNet != nil)
        {
            //print("stop timer net executed")
            timerNet!.invalidate()
            timerNet = nil
        }
    }
    
}



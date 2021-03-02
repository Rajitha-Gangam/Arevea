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
import AWSAppSync
import R5Streaming

class StreamDetailVC: UIViewController,UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,OpenChanannelChatDelegate,OpenChannelMessageTableViewCellDelegate,AGEmojiKeyboardViewDelegate,SBDChannelDelegate, AGEmojiKeyboardViewDataSource,CLLocationManagerDelegate,R5StreamDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    // MARK: - Variables Declaration
    
    @IBOutlet weak var viewBottom: UIView!
    @IBOutlet weak var viewComments: UIView!
    @IBOutlet weak var viewInfo: UIView!
    @IBOutlet weak var viewDonations: UIView!
    @IBOutlet weak var viewSubscriptions: UIView!
    @IBOutlet weak var view_Q_And_A: UIView!
    
    @IBOutlet weak var tblComments: UITableView!
    @IBOutlet weak var tblDonations: UITableView!
    @IBOutlet weak var txtProfile: UITextView!
    @IBOutlet weak var tbl_Q_And_A: UITableView!
    @IBOutlet weak var txt_Q_And_A: UITextField!
    @IBOutlet weak var viewRight: UIView!
    @IBOutlet weak var viewRightShort: UIView!
    @IBOutlet weak var viewRightTitle: UIView!
    @IBOutlet weak var lblRightTitle: UILabel!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    @IBOutlet weak var btnPayPerView: UIButton!
    @IBOutlet weak var lblAmount: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblLive: UILabel!
    @IBOutlet weak var lblLiveLeft: NSLayoutConstraint!
    var mylist = false
    @IBOutlet weak var webView: WKWebView!
    var txtTopOfToolBarChat : UITextField!
    var txtTopOfToolBarQAndA : UITextField!
    
    var r5ViewController : BaseTest? = nil
    var r5ViewControllerScreenShare : BaseTest? = nil
    var index_selected_q_qnd_a = -1
    var past_index_selected_q_qnd_a = -1
    
    @IBOutlet weak var viewLiveStream: UIView!
    @IBOutlet weak var viewStream: UIView!
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
    var isShareScreenConfigured = false
    var backPressed = false
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var lblVideoDesc_info: UILabel!
    @IBOutlet weak var lblVideoTitle_info: UILabel!
    @IBOutlet weak var txtVideoDesc_Info: UITextView!
    @IBOutlet weak var imgPerformer: UIImageView!
    
    @IBOutlet weak var lblNoDataComments: UILabel!
    @IBOutlet weak var lblNoDataDonations: UILabel!
    @IBOutlet weak var lblNoData_Q_And_A: UILabel!
    
    var subscribeStream1 : R5Stream? = nil
    var isStreamConfigured = false
    
    // MARK: - Live Chat Inputs
    var channel: SBDOpenChannel?
    var channel_emoji: SBDOpenChannel?
    var channel_q_and_a: SBDOpenChannel?
    
    var hasPrevious: Bool?
    var hasPrevious_q_and_a: Bool?
    
    var minMessageTimestamp: Int64 = Int64.max
    var isLoading: Bool = false
    var isLoading_q_and_a: Bool = false
    
    var messages: [SBDBaseMessage] = []
    var messages_q_and_a: [SBDBaseMessage] = []
    var messages_q_and_a_answers_main: [Any] = []
    var messages_q_and_a_answers1: [SBDBaseMessage] = []
    
    var emojis: [SBDBaseMessage] = []
    var channel_name_subscription = ""
    var initialLoading: Bool = true
    var initialLoading_q_and_a: Bool = true
    
    var scrollLock: Bool = false
    var resendableMessages: [String:SBDBaseMessage] = [:]
    var preSendMessages: [String:SBDBaseMessage] = [:]
    var resendableMessages_q_and_a: [String:SBDBaseMessage] = [:]
    var preSendMessages_q_and_a: [String:SBDBaseMessage] = [:]
    
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
    var channelName_Q_And_A = ""
    
    var paymentAmount = 0
    var streamPaymentMode = ""
    var strTitle = ""
    @IBOutlet weak var viewActivity: UIView!
    @IBOutlet weak var imgStreamThumbNail: UIImageView!
    @IBOutlet weak var btnPlayStream: UIButton!
    @IBOutlet weak var lblStreamUnavailable: UILabel!
    @IBOutlet weak var lblScreenShareUnavailable: UILabel!
    
    var toolTipView = EasyTipView(text: "");
    //var isChannelAvailable = false;
    //var isChannelAvailable_emoji = false;
    //var isChannelAvailable_q_and_a = false;
    var sendBirdErrorCode = 0;
    var sendBirdErrorCode_Emoji = 0;
    var sendBirdErrorCode_Q_And_A = 0;
    
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
    var isStreamStartedAlias = false
    
    
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
    var appSyncClient: AWSAppSyncClient?
    var isSharedScreen = false;
    var isSubscribeScreenShare = false;
    var stream_status = ""
    var graphQLStartupCall = 0;
    var isCurrentPinScreen = "";
    @IBOutlet weak var viewShareScreen: UIView!
    @IBOutlet weak var viewStreamWidth: NSLayoutConstraint!
    @IBOutlet weak var viewControlsLeft: NSLayoutConstraint!
    
    var serverAddress = ""
    @IBOutlet weak var btnAudio: UIButton!
    @IBOutlet weak var btnVideo: UIButton!
    @IBOutlet weak var sliderVolume: UISlider!
    @IBOutlet weak var viewControls: UIView?
    var publisherIsInBackground = false
    var publisherIsDisconnected = false
    var viewR5StreamingLive : R5VideoViewController? = nil
    var streamNameOfLive = ""
    var arySubscriptions = [Any]();
    
    @IBOutlet weak var lblNoDataSubscriptions: UILabel!
    @IBOutlet weak var tblSubscriptions: UITableView!
    var isCameFromGetTickets = false
    var isPaymentNavigation = false
    var isSubscriptionNavigation = false
    var subscription_details = false
    
    var arySubscriptionDetails = [Any]();
    @IBOutlet weak var trailConstraintRightView: NSLayoutConstraint?
    @IBOutlet weak var lead_q_and_a: NSLayoutConstraint?
    var currencyType = ""
    var currencySymbol = ""
    
    var previouslySelectedHeaderIndex: Int?
    var selectedHeaderIndex: Int?
    var selectedItemIndex: Int?
    var strUpcomingDate = ""
    var settings_q_and_a = 0
    var settings_fan_chat = 0
    var settings_reactions = 0
    var settings_donation = 0
    var settings_tip = 0
    
    var COLORLIST = [
        "#44d7b6",
        "#FF8935",
        "#f3af5a",
        "#846aa4",
        "#bf6780",
        "#b47f60",
        "#21accf",
        "#3d7dca",
        "#ed6c82",
        "#ee91a4",
        "#787ca9",
        "#5b868d",
        "#98bfaa",
        "#55d951",
        "#d0b2a0"
    ];
    var buttonNames = [["title":"info","icon":"s_info","icon_active":"s_info_active"],["title":"share","icon":"s_share","icon_active":"s_share_active"]]
    
    @IBOutlet weak var streamHeaderCVC: UICollectionView!
    var jsonCurrencyList = [String:Any]()
    @IBOutlet weak var viewSend_Q_and_A: UIView!
    @IBOutlet weak var viewSend_Chat: UIView!
    @IBOutlet weak var btnGoLive: UIButton!
    var isChatActive = false
    var isQ_And_A_Active = false
    // MARK: - View Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        viewActivity.isHidden = true
        // Do any additional setup after loading the view.
        registerNibs();
        addDoneButton()
        addDoneButtonEmoji()
        addDoneButton_Q_And_A()
        
        ////print("detail item in channnel page:\(detailItem)")
        
        viewLiveStream.isHidden = true;
        lblNoDataComments.text = ""
        lblNoDataDonations.text = "No donations found"
        lblTitle.text = strTitle
        if(appDelegate.isGuest){
            //sendBirdConnect()
        }
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
        
        viewShareScreen.layer.borderColor = UIColor.lightGray.cgColor
        viewShareScreen.layer.borderWidth = 1.0
        
        if(UIDevice.current.userInterfaceIdiom == .pad){
            heightTopView?.constant = 60;
            viewTop.layoutIfNeeded()
        }
        
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
        appSyncClient = appDelegate.appSyncClient
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.ReceivedPN(notification:)),
                                               name: Notification.Name("PushNotification"), object: nil)
        viewShareScreen.isHidden = true
        
        self.viewControls?.isHidden = true
        self.lblLive.isHidden = true
        
        self.viewStream?.isHidden = false
        sliderVolume.value = 100;
        if(self.channel_name_subscription == ""){
            self.channel_name_subscription = " "
        }
        viewRight.isHidden = true
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
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
        
        notificationCenter.addObserver(self, selector: #selector(appCameToForeground), name: UIApplication.didBecomeActiveNotification, object: nil)
        viewSend_Q_and_A.layer.borderColor = UIColor.gray.cgColor
        viewSend_Q_and_A.layer.cornerRadius = 5
        
        viewSend_Chat.layer.borderColor = UIColor.gray.cgColor
        viewSend_Chat.layer.cornerRadius = 5
        //btnGoLive.layer.borderColor = UIColor.gray.cgColor
        btnGoLive.isHidden = true
    }
    @IBAction func goLiveTapped(){
        print("goLiveTapped")
        configureStreamView()
    }
    func sendBirdConnect() {
        
        if SBDMain.getConnectState() == .open {
            SBDMain.disconnect {
                self.sendBirdConnect()
            }
        }
        else {
            let userId = UserDefaults.standard.string(forKey: "user_id");
            let nickname = appDelegate.USER_NAME_FULL
            
            let userDefault = UserDefaults.standard
            userDefault.setValue(userId, forKey: "sendbird_user_id")
            userDefault.setValue(nickname, forKey: "sendbird_user_nickname")
            
            ConnectionManager.login(userId: userId ?? "1", nickname: nickname) { user, error in
                guard error == nil else {
                    return
                }
            }
        }
    }
    @objc func appMovedToBackground() {
        print("App moved to background!")
        if(isStreamStarted){
        if(self.subscribeStream1 != nil && self.subscribeStream1?.audioController != nil) {
            self.subscribeStream1?.pauseAudio = true
            self.subscribeStream1?.audioController.volume = 0
        }
        }
    }
    @objc func appCameToForeground() {
        print("App came to foreground!")
        if(isStreamStarted){
            print("== isStreamStarted")

            var play = false
            let imgBtn = btnAudio.image(for: .normal)
            if ((imgBtn?.isEqual(UIImage.init(named: "unmute")))!)
            {
                play = true
            }
            let imgBtnVideo = btnVideo?.image(for: .normal)
            if ((imgBtnVideo?.isEqual(UIImage.init(named: "pause")))!)
            {
                if (play)
                {
                    if(self.subscribeStream1 != nil && self.subscribeStream1?.audioController != nil) {
                        self.subscribeStream1?.pauseAudio = false
                        self.subscribeStream1?.audioController.volume = sliderVolume.value / 100
                    }
                }
                
            }
        }
    }

    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
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
            print("--Reachable via WiFi")
            isNetConnected = true
        case .cellular:
            print("--Reachable via Cellular")
        case .unavailable:
            print("--Network not reachable")
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
        
        viewDonations.isHidden = true
        viewComments.isHidden = true
        view_Q_And_A.isHidden = true
        viewInfo.isHidden = true
        viewSubscriptions.isHidden = true
        
        txtComment.resignFirstResponder()
        txtTopOfToolBarChat.resignFirstResponder()
        txtTopOfToolBarQAndA.resignFirstResponder()
        txtEmoji.resignFirstResponder()
        txt_Q_And_A.resignFirstResponder()
        refreshHeaderBtns()
        
    }
    
    
    @IBAction func onTapTitle(){
        //print("onTapTitle called")
        
        /*
         * Optionally you can make these preferences global for all future EasyTipViews
         */
        //toolTipView.show(forView: self.lblTitle, withinSuperview: self.view)
        
    }
    
    
    func sendBirdChatConfig(){
        
        self.sendBirdEmojiConfig()
        if(self.settings_q_and_a == 1){
            //uncomment after this release
            self.sendBird_Q_And_A_Config()
        }
        
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
                // return
                self.messages.removeAll()
                self.channel = nil
                //self.isChannelAvailable = false
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
    func sendBird_Q_And_A_Config(){
        //isChannelAvailable_q_and_a = true
        channelName_Q_And_A = String(self.streamId) + "_qa"
        print("channelName in sendBird_Q_And_A_Config:",channelName_Q_And_A)
        SBDOpenChannel.getWithUrl(channelName_Q_And_A, completionHandler: { (openChannel, error) in
            guard error == nil else {   // Error.
                let errorDesc = "QA Chat Error:" + error!.localizedDescription
                print("Send Bird Error:\(String(describing: error))")
                //print(errorDesc)
                //self.sbdError = error ?? error?.localizedDescription as! SBDError
                self.sendBirdErrorCode_Q_And_A = error?.code ?? 0
                //self.showAlert(strMsg:errorDesc )
                ////print("sendBirdErrorCode:",sendBirdErrorCode)
                
                // return
                self.messages_q_and_a.removeAll()
                self.channel_q_and_a = nil
                //self.isChannelAvailable_q_and_a = false
                self.tbl_Q_And_A.reloadData()
                return
            }
            self.channel_q_and_a = openChannel
            self.title = self.channel_q_and_a?.name
            self.loadPrevious_Q_And_A(initial: true)
            openChannel?.enter(completionHandler: { (error) in
                guard error == nil else {   // Error.
                    return
                }
            })
            
        })
        channel_q_and_a?.getMyMutedInfo(completionHandler: { (isMuted, description, startAt, endAt, duration, error) in
            if isMuted {
                //self.sendUserMessageButton.isEnabled = false
                //self.txtComment.isEnabled = false
                self.txt_Q_And_A.placeholder = "You are muted"
            } else {
                self.sendUserMessageButton.isEnabled = true
                self.txt_Q_And_A.isEnabled = true
                self.txt_Q_And_A.placeholder = "Send a message"
            }
        })
    }
    func sendBirdEmojiConfig(){
        channelName_Emoji = streamVideoCode + "_emoji"
        ////print("channelName_Emoji in sendBirdEmojiConfig:",channelName_Emoji)
        SBDOpenChannel.getWithUrl(channelName_Emoji, completionHandler: { (openChannel, error) in
            guard error == nil else {   // Error.
                let errorDesc = "Emoji Chat Error:" + error!.localizedDescription
                ////print("Send Bird Error:\(error!)")
                ////print(errorDesc)
                //self.isChannelAvailable_emoji = false
                return
            }
            //self.isChannelAvailable_emoji = true
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
    
    
    func streamInfoUpdate(strValue: String){
        if(strValue == "started"){
            UIApplication.shared.isIdleTimerDisabled = true //to avoid device lock when steraming is running
            self.lblStreamUnavailable.text = ""
            viewActivity.isHidden = true
            isStreamStarted = true
            isStreamStartedAlias = true
            btnPlayStream.isHidden = true;
            //overlay hidden
           /* let htmlString = "<html>\n" + "<body style='margin:0;padding:0;background:transparent;'>\n" +
                "<iframe width=\"100%\" height=\"100%\" src=\"https://app.singular.live/appinstances/" + self.app_id_for_adds + "/outputs/Output/onair\" frameborder=\"0\" allow=\"accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture\" allowfullscreen>\n" + "</iframe>\n" + "</body>\n" + "</html>";
            //print("htmlString:",htmlString)
            self.webView.loadHTMLString(htmlString, baseURL: nil)
            self.webView.isHidden = false
            self.viewOverlay?.isHidden = true// controls not working
            self.viewLiveStream.bringSubviewToFront(self.webView)*/
            self.viewLiveStream.bringSubviewToFront(self.lblStreamUnavailable)
            
            if (self.timer != nil)
            {
                self.timer!.invalidate()
                self.timer = nil
            }
            //if screen share already happened from creator before comes to this screen, so we do not get PN Refresh
            startSession()
        }
        if(strValue == "stopped"){
            UIApplication.shared.isIdleTimerDisabled = false //to avoid device lock when steraming is running
            isStreamStartedAlias = false
            LiveEventByIdStatus()
        }else if(strValue == "not_available"){
            viewActivity.isHidden = true
            showHLSVideo()
            /*if (viewLiveStream.isHidden == false){
                if(isStreamStarted){
                    lblStreamUnavailable.text = "We are working on the issue. We will be back shortly."
                    btnPlayStream.isHidden = true;
                }else{
                    if(isUpcoming){
                      //  var localTimeZoneAbbreviation: String { return TimeZone.current.abbreviation() ?? "" }

                        self.lblStreamUnavailable.text = "Please wait. The Stream will begin on \n" + self.strUpcomingDate
                        btnPlayStream.setImage(UIImage.init(named: "refresh"), for: .normal)
                        btnPlayStream.isHidden = true;
                    }else{
                        lblStreamUnavailable.text = "We are working on the issue. We will be back shortly."
                        btnPlayStream.isHidden = false;
                        self.btnPlayStream.setImage(UIImage.init(named: "refresh"), for: .normal)
                        
                    }
                    
                }
                self.viewLiveStream.bringSubviewToFront(self.lblStreamUnavailable)
            }*/
        }
    }
   
    @objc func ScreenShareNotificationHandler(_ notification:Notification) {
        // Do something now
        ////print("====ScreenShareNotificationHandler")
        if let data = notification.userInfo as? [String: String]
        {
            for (key,value) in data
            {
                //key Stream
                //value Stopped/Started
                ////print("key: \(key)")
                ////print("value: \(value)")
                
                if (value == "started"){
                    self.lblScreenShareUnavailable.text = ""
                    ALToastView.toast(in: self.view, withText:"Creator has started screen share.")
                    
                }else if(value == "stopped"){
                    isSharedScreen = false
                    // adjustScreenShare()
                    self.lblScreenShareUnavailable.text = ""
                    ALToastView.toast(in: self.view, withText:"Creator has stopped screen share")
                    
                }else if(value == "not_available"){
                    self.lblScreenShareUnavailable.text = "Unable to locate screen share. Please try again later"
                    // ALToastView.toast(in: self.view, withText:"")
                }
            }
        }
    }
    @objc func applicationDidBecomeActive(notification: NSNotification) {
        // Application is back in the foreground
        print("====active STream:isPaymentNavigation",isPaymentNavigation)
        print("====active:isSubscriptionNavigation",isSubscriptionNavigation)
        
        //if user comes from payment redirection, need to refresh stream/vod
        
        if(isPaymentNavigation){
            if(isVOD || isAudio){
                //getVodById()
            }else{
                //LiveEventById();
                //setLiveStreamConfig()
            }
        }else if(isSubscriptionNavigation){
            getChannelSubscriptionPlans()
        }
        //from mail navigation
        else{
            if(appDelegate.isGuest){
                //LiveEventById()
            }
        }
        //when skype call or any other call happens app come sto bg and when call disconnects app come to this state
        if(isStreamStarted){
            LiveEventById()
        }
    }
    func registerNibs() {
        let nib = UINib(nibName: "StreamHeaderCVC", bundle: nil)
        streamHeaderCVC?.register(nib, forCellWithReuseIdentifier:"StreamHeaderCVC")
        
        tblComments.register(UINib(nibName: "OpenChannelUserMessageTableViewCell", bundle: nil), forCellReuseIdentifier: "OpenChannelUserMessageTableViewCell")
        tbl_Q_And_A.register(UINib(nibName: "Q_And_A_AnswerCell", bundle: nil), forCellReuseIdentifier: "Q_And_A_AnswerCell")
        tbl_Q_And_A.register(UINib(nibName: "Q_And_A_Footer", bundle: nil), forCellReuseIdentifier: "Q_And_A_Footer")
        
        tbl_Q_And_A.register(UINib(nibName: "Q_And_A_Section", bundle: nil), forHeaderFooterViewReuseIdentifier: "Q_And_A_Section")
        // tbl_Q_And_A.register(UINib(nibName: "Q_And_A_Footer", bundle: nil), forHeaderFooterViewReuseIdentifier: "Q_And_A_Footer")
        tblDonations.register(UINib(nibName: "CharityCell", bundle: nil), forCellReuseIdentifier: "CharityCell")
        tblSubscriptions.register(UINib(nibName: "SubscriptionCell", bundle: nil), forCellReuseIdentifier: "SubscriptionCell")
        
        
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
            btnAudio?.setImage(UIImage.init(named: "unmute"), for: .normal);
            btnVideo?.setImage(UIImage.init(named: "pause"), for: .normal);
            //getPerformerOrgInfo();
            //viewInfo.isHidden = false
        }
        
        tblComments.rowHeight = 40
        tblComments.estimatedRowHeight = UITableView.automaticDimension
        tbl_Q_And_A.rowHeight = 90
        tbl_Q_And_A.estimatedRowHeight = UITableView.automaticDimension
        self.viewLiveStream.bringSubviewToFront(self.viewOverlay!)
            getChannelSubscriptionPlans();
            getSubscriptionStatus()
    }
    func showVideo(strURL : String){
        // print("showVideo strURL:",strURL)
        var urlToOpen = URL(string: "https://www.google.com")//in case of invalid url, we need to open this to dispaly vod UI, even though it does not play.
        if let url = URL(string: strURL){
            urlToOpen = url
        }
        videoPlayer = AVPlayer(url: urlToOpen!)
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
        
    }
    func showHLSVideo(){
        // print("showVideo strURL:",strURL)
        //comment or remove below line
        //self.streamVideoCode = "1988_1612446057162_hls_ios_test"
        self.viewLiveStream.isHidden = true;
        self.viewControls?.isHidden = true
        self.lblLive.isHidden = true
        self.viewVOD.isHidden = false;
        self.closeStream()
       let strURL = appDelegate.urlCloudFront + self.streamVideoCode + "/master.m3u8"
       //let strURL = "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"
        print("strURL:",strURL)
        var urlToOpen = URL(string: strURL)//in case of invalid url, we need to open this to dispaly vod UI, even though it does not play.
        if let url = URL(string: strURL){
            urlToOpen = url
        }
        videoPlayer = AVPlayer(url: urlToOpen!)
        let controller = AVPlayerViewController()
        controller.player = videoPlayer
        controller.allowsPictureInPicturePlayback = true
        controller.view.frame = self.viewVOD.bounds
        controller.view.frame.origin.y = 44
        controller.view.frame.size.height = self.viewVOD.bounds.size.height - 44
        controller.videoGravity = AVLayerVideoGravity.resize
        controller.setValue(true, forKey: "requiresLinearPlayback")//for hide forward and backward buttons
        

        self.viewVOD.addSubview(controller.view)
        self.addChild(controller)
        btnPlayStream.isHidden = true;
        viewLiveStream.isHidden = true;
        viewVOD.isHidden = false;
        videoPlayer.play()
        isVODPlaying = true
        btnGoLive.isHidden = false

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
                self.imgEmoji.image = strEmojiText.image()
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
    func popToDashBoard(){
        //print("vc:",self.navigationController!.viewControllers)
        //self.showAlert(strMsg: String(self.navigationController!.viewControllers.count))
        for controller in self.navigationController!.viewControllers as Array {
            if controller.isKind(of: DashBoardVC.self) {
                self.navigationController!.popToViewController(controller, animated: true)
                if(UIDevice.current.userInterfaceIdiom == .phone){
                    NSLog("==orientation")
                    let value = UIInterfaceOrientation.portrait.rawValue
                    UIDevice.current.setValue(value, forKey: "orientation")
                }
                break
            }
        }
    }
    func goBack(){
        if(isCameFromGetTickets){
            popToDashBoard()
        }else{
            AppDelegate.AppUtility.lockOrientation(.portrait)
            self.navigationController?.popViewController(animated: true)
        }
    }
    func showConfirmation(strMsg: String){
        let alert = UIAlertController(title: "Alert", message: strMsg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { [self] action in
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
            self.goBack()
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
                goBack()
            }
        }
    }
    // MARK: - Button Actions
    
    @IBAction func showRightView(){
        viewRight.isHidden = false
        showAnimation()
        viewRightShort.isHidden = true
        setBtnDefaultBG()
        viewRightTitle.isHidden = false
        isChatActive = false

            let index = buttonNames.firstIndex(where: {$0["title"]! == "chat"}) ?? -1
            print("index:",index)
            if(index > 0 && stream_status == "progress"){
                lblRightTitle.text = "Chat"
                let btn = self.streamHeaderCVC.viewWithTag(10 + index) as? UIButton
                btn?.setImage(UIImage.init(named: "s_chat_active"), for: .normal)
                viewComments.isHidden = false
                isChatActive = true
            }else{
                lblRightTitle.text = "Info"
                let btn = self.streamHeaderCVC.viewWithTag(10) as? UIButton
                btn?.setImage(UIImage.init(named: "s_info_active"), for: .normal)
                viewInfo.isHidden = false

            }
        
    }
    
    @IBAction func hideRightView(){
        self.view.endEditing(true)
        hideAnimation()
        //viewRight.isHidden = true
    }
    
    
    @objc func txtEmojiTap(textField: UITextField) {
        setBtnDefaultBG()
        viewRightTitle.isHidden = true
        guard let index = buttonNames.firstIndex(where: {$0["title"]! == "emoji"})else {
            return
        }
        if(index > 0){
            let btn = self.streamHeaderCVC.viewWithTag(10 + index) as? UIButton
            btn?.setImage(UIImage.init(named: "s_emoji_active"), for: .normal)
        }
    }
    
    func showAnimation(){
        self.trailConstraintRightView?.constant = 0;
        self.viewRight.layoutIfNeeded()
        viewRight.isHidden = false;
        let movementDistance:CGFloat = 380;
        var movement:CGFloat = 0
        movement = -movementDistance
        UIView.animate(withDuration: 1.0, animations: {
            self.viewRight.frame = self.viewRight.frame.offsetBy(dx: movement, dy: 0)
        })
    }
    func hideAnimation(){
        self.trailConstraintRightView?.constant = -430;
        self.viewRight.layoutIfNeeded()
        viewRight.isHidden = false;
        let movementDistance:CGFloat = -380;
        var movement:CGFloat = 0
        movement = -movementDistance
        UIView.animate(withDuration: 1.0, animations: { [self] in
                        self.viewRight.frame = self.viewRight.frame.offsetBy(dx: movement, dy: 0)}, completion: { [self]_ in
                            viewRightShort.isHidden = false
                            setBtnDefaultBG()
                        })
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
        if(tableView == tbl_Q_And_A){
            return messages_q_and_a.count
        }else{
            return 1
            
        }
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
            if (self.messages.count > 0){
                tblComments.isHidden = false
                lblNoDataComments.text = ""
            }else{
                tblComments.isHidden = true
                //lblNoDataComments.text = "Channel is unavailable"
                
            }
            return self.messages.count;
        }else if(tableView == tbl_Q_And_A){
            //print("messages_q_and_a:",messages_q_and_a)
            if (self.messages_q_and_a.count > 0){
                tbl_Q_And_A.isHidden = false
                lblNoData_Q_And_A.text = ""
            }else{
                tbl_Q_And_A.isHidden = true
            }
            //return self.messages_q_and_a.count;
            let question = messages_q_and_a[section]
            //print("messageId:",question.messageId)
            //print("messages_q_and_a_answers_main:",messages_q_and_a_answers_main)
            let searchPredicate = NSPredicate(format: "data = %@", String(question.messageId))
            let filteredArray = (messages_q_and_a_answers_main as NSArray).filtered(using: searchPredicate)
            //let filteredArray = messages_q_and_a_answers_main.filter { $0["data"] == "1210730782" }
            //print("filteredArray count:",filteredArray)
            return filteredArray.count
        }else if (tableView == tblSubscriptions ){
            if (self.arySubscriptions.count > 0){
                lblNoDataSubscriptions.isHidden = true
            }else{
                lblNoDataSubscriptions.isHidden = false
            }
            //print("==arySubscriptions count:",arySubscriptions.count)
            return arySubscriptions.count;
        }
        return 0;
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) ->  CGFloat {
        if  (tableView == tblDonations){
            return 140;
        }
        else if  (tableView == tblComments){
            return UITableView.automaticDimension
        }else if  (tableView == tbl_Q_And_A){
            if(index_selected_q_qnd_a == indexPath.section){
                return UITableView.automaticDimension
            }else{
                return 0
            }
        }else if  (tableView == tblSubscriptions){
            return 170;
        }
        return 44;
        
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if(tableView == tbl_Q_And_A){
            let userMessage = self.messages_q_and_a[section] as! SBDUserMessage
            let text = "Q. " + userMessage.message
            let height = heightForView(text: text, width: 380)
            print("height:",height)
            print("section:",section)

            return (height*3)
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if(tableView == tbl_Q_And_A){
            if(index_selected_q_qnd_a == section){
                return 74
            }else{
                return 0
            }
        }else{
            return 0
        }
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

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if(tableView == tbl_Q_And_A){
            let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "Q_And_A_Section") as! Q_And_A_Section
            
            let userMessage = self.messages_q_and_a[section] as! SBDUserMessage
            headerView.lblTitle.text = "Q. " + userMessage.message
            print("hl text:",headerView.lblTitle.text)
            headerView.lblTitle.sizeToFit()
            if(index_selected_q_qnd_a == section){
                headerView.imgArrow.image = UIImage.init(named: "up_arrow")
            }else{
                headerView.imgArrow.image = UIImage.init(named: "down_arrow")
            }
            headerView.tag = section
            let headerTapped = UITapGestureRecognizer (target: self, action:#selector(sectionHeaderTapped(recognizer:)))
            headerView.addGestureRecognizer(headerTapped)
            return headerView
        }else{
            let headerView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
            return headerView
        }
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if(tableView == tbl_Q_And_A){
            if(index_selected_q_qnd_a == section){
                let indexPath = IndexPath(row: 0, section: section)
                let footerView = tbl_Q_And_A.dequeueReusableCell(withIdentifier: "Q_And_A_Footer", for: indexPath) as! Q_And_A_Footer
                footerView.btnSend.tag = section
                footerView.btnSend.addTarget(self, action: #selector(sendReply(_:)), for: .touchUpInside)
                footerView.btnInput.tag = section
                footerView.btnInput.addTarget(self, action: #selector(showPopupWithInput(_:)), for: .touchUpInside)
                footerView.btnInput.isHidden = false
                footerView.viewSendReply.layer.borderColor = UIColor.lightGray.cgColor
                footerView.viewSendReply.layer.borderWidth = 1.0
                /* footerView.txtMsg.delegate = self
                footerView.txtMsg.tag = 100 + section
                //addDoneButton_Q_And_A_Answer(footerView.txtMsg)
                footerView.updateCellWith(index: section)*/
                
                return footerView
            }else{
                let footerView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
                return footerView
            }
        }else{
            let footerView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
            return footerView
        }
    }
    
    
    
    
    @objc func sectionHeaderTapped(recognizer: UITapGestureRecognizer) {
        print("Tapping working")
        print(recognizer.view?.tag)
        
        var indexPath : NSIndexPath = NSIndexPath(row: 0, section:(recognizer.view?.tag as Int?)!)
        past_index_selected_q_qnd_a = recognizer.view?.tag ?? -1
        if(index_selected_q_qnd_a != past_index_selected_q_qnd_a){
            index_selected_q_qnd_a = recognizer.view?.tag ?? -1
        }else{
            index_selected_q_qnd_a = -1
        }
        tbl_Q_And_A.reloadData()
        
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
                    
                    /*if sender.userId == SBDMain.getCurrentUser()!.userId {
                        // Outgoing message
                        let requestId = userMessage.requestId
                        if self.resendableMessages[requestId] != nil {
                            userMessageCell.showElementsForFailure()
                        }
                        else {
                            userMessageCell.hideElementsForFailure()
                        }
                    }
                    else {
                        // Incoming message
                        userMessageCell.hideElementsForFailure()
                    }*/
                    userMessageCell.hideElementsForFailure()

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
        }else if (tableView == tblSubscriptions){
            let cell = tableView.dequeueReusableCell(withIdentifier: "SubscriptionCell") as! SubscriptionCell
            cell.viewContent.layer.borderColor = UIColor.gray.cgColor
            cell.viewContent.layer.borderWidth = 1.0
            cell.btnUnSubscribe.layer.borderColor = UIColor.gray.cgColor
            cell.btnUnSubscribe.layer.borderWidth = 1.0
            
            cell.btnSubscribe.tag = indexPath.row
            cell.btnSubscribe.addTarget(self, action: #selector(subscribeBtnPressed(_:)), for: .touchUpInside)
            cell.btnUnSubscribe.tag = indexPath.row
            cell.btnUnSubscribe.addTarget(self, action: #selector(unSubscribeBtnPressed(_:)), for: .touchUpInside)
            
            cell.btnCheck.isHidden = true
            cell.btnSubscribe.isHidden = false
            cell.btnUnSubscribe.isHidden = true
            
            let subscribeObj = self.arySubscriptions[indexPath.row] as? [String : Any] ?? [:];
            print("==cell for subscribeObj:",subscribeObj)
            
            let feature_details = subscribeObj["feature_details"] as? [Any] ?? [Any]() ;
            // print("feature_details count:",feature_details.count)
            let tier_amounts = subscribeObj["tier_amounts"] as? String ?? ""
            var userIndex = -1
            var creatorIndex = -1
            let aryTierAmounts = self.convertToArray(text: tier_amounts)
            for(j,_)in aryTierAmounts!.enumerated(){
                let object = aryTierAmounts?[j] as? [String : Any] ?? [String:Any]()
                let currency_type1 = object["currency_type"]as? String ?? "";
                if(appDelegate.userCurrencyCode == currency_type1){
                    userIndex = j
                }
                if(self.currencyType == currency_type1){
                    creatorIndex = j
                }
            }
            var index = -1
            if(userIndex != -1){
                index = userIndex
            }else {
                index = creatorIndex
            }
            print("index:",index)
            //if index !=-1 and user not subscribed
            if(index != -1 && arySubscriptionDetails.count == 0){
                let object = aryTierAmounts?[index] as? [String : Any] ?? [String:Any]()
                let tier_amount = object["payment_amount"] as? Double ?? 0.0
                let currency_type = object["currency_type"] as? String ?? ""
                let currencySymbol1 = jsonCurrencyList[currency_type] as? String
                let currencySymbol = currencySymbol1 ?? "$"
                let amount = String(format: "%.02f", tier_amount)
                let amountWithCurrencyType = currencySymbol  + amount
                cell.lblAmount.text = amountWithCurrencyType
            }
            let tier_amount_mode = subscribeObj["tier_amount_mode"] as? String ?? ""
            // print("tier_amount_mode:",tier_amount_mode)
            cell.lblAmountMode.text = tier_amount_mode
            var subscription_status = false
            print("==arySubscriptionDetails:",arySubscriptionDetails)
            //if user subscribed
            if(arySubscriptionDetails.count > 0){
                let subscribeObj1 = self.arySubscriptionDetails[0] as? [String : Any] ?? [:];
                subscription_status = subscribeObj1["subscription_status"] as? Bool ?? false
                
                let tier_amount = subscribeObj1["subscription_amount"] as? Double ?? 0.0
                let currency_type = subscribeObj1["currency"] as? String ?? ""
                let currencySymbol1 = jsonCurrencyList[currency_type] as? String
                let currencySymbol = currencySymbol1 ?? "$"
                let amount = String(format: "%.02f", tier_amount)
                let amountWithCurrencyType = currencySymbol  + amount
                cell.lblAmount.text = amountWithCurrencyType
            }
            // print("tier_amount:",tier_amount)
            
            //if user subscribed
            if(subscription_status){
                let orange = UIColor(red: 95, green: 84, blue: 55);
                cell.viewContent.layer.borderColor = orange.cgColor
                cell.viewContent.layer.borderWidth = 2.0
                cell.btnCheck.isHidden = false
                cell.btnSubscribe.isHidden = true
                cell.btnUnSubscribe.isHidden = false
            }else{
                //if user not subscribed
                cell.btnSubscribe.setTitle("SUBSCRIBE", for: .normal)
                //if user subscribed and cancelled plan
                if(subscription_details){
                    cell.btnSubscribe.setTitle("REACTIVATE", for: .normal)
                }
            }
            for (index,_) in feature_details.enumerated() {
                let feature_details = feature_details[index] as? [String : Any] ?? [:];
                if(index < 4){
                    switch index {
                    case 0:
                        cell.lbl1.text = feature_details["feature_name"] as? String ?? ""
                    case 1:
                        cell.lbl2.text = feature_details["feature_name"] as? String ?? ""
                    case 2:
                        cell.lbl3.text = feature_details["feature_name"] as? String ?? ""
                    case 3:
                        cell.lbl4.text = feature_details["feature_name"] as? String ?? ""
                    default:
                        print("default")
                    }
                }
            }
            return cell
        }else if (tableView == tbl_Q_And_A){
            var cell: UITableViewCell = UITableViewCell()
            if(index_selected_q_qnd_a == indexPath.section){
                let question = messages_q_and_a[indexPath.section]
                let searchPredicate = NSPredicate(format: "data = %@", String(question.messageId))
                let filteredArray = (messages_q_and_a_answers_main as NSArray).filtered(using: searchPredicate)
                if(filteredArray.count > indexPath.row){
                    let object = filteredArray[indexPath.row] as? [String:Any] ?? [:]
                    let userMessageCell = tableView.dequeueReusableCell(withIdentifier: "Q_And_A_AnswerCell") as? Q_And_A_AnswerCell
                   

                    userMessageCell?.lblMsg.text = object["message"] as? String ?? ""
                    userMessageCell?.lblName.text = object["sender"] as? String ?? ""
                    //let color = COLORLIST[indexPath.row]
                    let color = object["color"] as? String ?? "#C71585"
                    userMessageCell?.lblName.textColor = hexStringToUIColor(hex: color)
                    userMessageCell?.lblName.sizeToFit()
                    let isPartner = object["isPartner"] as? String ?? "no"
                    if(isPartner == "yes"){
                        userMessageCell?.imgCreator.isHidden = false
                    }else{
                        userMessageCell?.imgCreator.isHidden = true
                    }
                    cell = userMessageCell ?? cell
                    
                    /*if indexPath.row == 0 && self.messages_q_and_a_answers_main.count > 0 && self.initialLoading_q_and_a == false && self.isLoading_q_and_a == false {
                     self.loadPrevious_Q_And_A(initial: false)
                     }*/
                    //self.loadPrevious_Q_And_A(initial: true)
                    
                }else{
                    cell.backgroundColor = UIColor.clear
                }
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
        tableView.deselectRow(at: indexPath, animated: true)
        if  (tableView == tblSubscriptions){
            /*let subscribeObj = self.arySubscriptions[indexPath.row] as? [String : Any] ?? [:];
             let subscription_status = subscribeObj["subscription_status"] as? Bool ?? false
             if(subscription_status){
             cancelChannelSubscription()
             }else{
             subscribe(row: indexPath.row)
             }*/
        }else{
            viewBGTap()
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
    @objc func subscribeBtnPressed(_ sender: UIButton){
        print("subscribeBtnPressed")
        
            //for subscribe
            if(!subscription_details){
                subscribe(row:sender.tag)
            }
            //for reactivate
            else{
                reActivateChannelSubscription(row: sender.tag)
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
        isSubscriptionNavigation = true
        isPaymentNavigation = false
        UIApplication.shared.open(url)
    }
    @objc func unSubscribeBtnPressed(_ sender: UIButton){
        let row = sender.tag
        let subscribeObj = self.arySubscriptions[row] as? [String : Any] ?? [:];
        let performer_id = subscribeObj["performer_id"] as? Int ?? 0
        //print("==performer_id:",performer_id)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let url: String = appDelegate.paymentBaseURL +  "/cancelChannelSubscription"
        let inputData: [String: Any] = ["performer_id":performer_id]
        print("cancelChannelSubscription params:",inputData)
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
                        print("cancelChannelSubscription JSON:",json)
                        if (json["status"]as? Int == 0){
                            self.viewActivity.isHidden = true
                            //////print(json["message"] as? String ?? "")
                            self.showAlert(strMsg: "Successfully unsubscribed.")
                            self.getChannelSubscriptionPlans()
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
    func reActivateChannelSubscription(row:Int){
        let subscribeObj = self.arySubscriptions[row] as? [String : Any] ?? [:];
        let performer_id = subscribeObj["performer_id"] as? Int ?? 0
        // print("subscribeObj:",subscribeObj)
        //print("==performer_id:",performer_id)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let url: String = appDelegate.paymentBaseURL +  "/reActivateChannelSubscription"
        let inputData: [String: Any] = ["performer_id":performer_id]
        print("reActivateChannelSubscription params:",inputData)
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
                        print("reActivateChannelSubscription JSON:",json)
                        if (json["status"]as? Int == 0){
                            self.viewActivity.isHidden = true
                            //////print(json["message"] as? String ?? "")
                            self.showAlert(strMsg: "Successfully reactivated.")
                            self.getChannelSubscriptionPlans()
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
    // MARK: Handler for getSubscriptionStatus API
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
            .responseJSON { response in
                self.viewActivity.isHidden = true
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any] {
                        print("getSubscriptionStatus JSON:",json)
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
    func convertToArray(text: String) -> [Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [Any] ?? []
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
        // print("resignKB")
        // btnEmoji.setImage(UIImage.init(named: "s_emoji"), for: .normal)
        
        txtTopOfToolBarChat.text = ""
        txtTopOfToolBarQAndA.text = ""
        txtComment.text = ""
        txtComment.resignFirstResponder();
        txtTopOfToolBarChat.resignFirstResponder()
        txtTopOfToolBarQAndA.resignFirstResponder()
        txtEmoji.resignFirstResponder()
        txt_Q_And_A.resignFirstResponder()
        refreshHeaderBtns()
        
    }
    func addDoneButton() {
        let toolbar =  UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 35))
        toolbar.backgroundColor = .white
        txtTopOfToolBarChat =  UITextField(frame: CGRect(x: 50, y: 0, width: view.frame.size.width-150, height: 35))
        // let textfield =  UITextField()
        txtTopOfToolBarChat.placeholder = "Send a message"
        txtTopOfToolBarChat.delegate = self
        txtTopOfToolBarChat.backgroundColor = .clear
        //txtTopOfToolBarChat.isUserInteractionEnabled = false
        txtTopOfToolBarChat.borderStyle = UITextField.BorderStyle.none
        
        let textfieldBarButton = UIBarButtonItem.init(customView: txtTopOfToolBarChat)
        
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
        txtTopOfToolBarChat.inputAccessoryView = toolbar;
        
    }
    func addDoneButton_Q_And_A() {
        let toolbar =  UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 35))
        toolbar.backgroundColor = .white
        txtTopOfToolBarQAndA =  UITextField(frame: CGRect(x: 50, y: 0, width: view.frame.size.width-150, height: 35))
        // let textfield =  UITextField()
        txtTopOfToolBarQAndA.placeholder = "Send a question"
        txtTopOfToolBarQAndA.delegate = self
        txtTopOfToolBarQAndA.backgroundColor = .clear
        //txtTopOfToolBarChat.isUserInteractionEnabled = false
        txtTopOfToolBarQAndA.borderStyle = UITextField.BorderStyle.none
        
        let textfieldBarButton = UIBarButtonItem.init(customView: txtTopOfToolBarQAndA)
        
        // UIToolbar expects an array of UIBarButtonItems:
        
        let flexButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        
        let cancel = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action:#selector(resignKB(_:)))
        
        let button = UIButton.init(type: .custom)
        //set image for button
        button.setImage(UIImage(named: "blue-send"), for: UIControl.State.normal)
        //add function for button
        button.addTarget(self, action: #selector(send_Q_And_A), for: UIControl.Event.touchUpInside)
        //set frame
        button.frame = CGRect(x: view.frame.size.width-180, y: 0, width: 20, height: 20)
        
        let sendBtn = UIBarButtonItem(customView: button)
        
        
        toolbar.setItems([cancel,textfieldBarButton,flexButton,sendBtn], animated: true)
        toolbar.sizeToFit()
        txtTopOfToolBarQAndA.inputAccessoryView = toolbar;
        txt_Q_And_A.inputAccessoryView = toolbar;
        
    }
    
    func addDoneButtonEmoji() {
        let toolbar =  UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 35))
        
        let flexButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action:#selector(resignKB(_:)))
        toolbar.setItems([flexButton, doneButton], animated: true)
        toolbar.sizeToFit()
        
        txtEmoji.inputAccessoryView = toolbar
        
    }
    
    // MARK: Text Field Delegate Methods
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if(txtEmoji == textField){
            guard let index = buttonNames.firstIndex(where: {$0["title"]! == "emoji"})else {
                return
            }
            if(index > 0){
                let btn = self.streamHeaderCVC.viewWithTag(10 + index) as? UIButton
                btn?.setImage(UIImage.init(named: "s_emoji_active"), for: .normal)
            }
            viewRightTitle.isHidden = true
            imgEmoji.isHidden = true
        }else{
        }
        
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("textFieldDidEndEditing")
        //textField.resignFirstResponder();
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("textFieldShouldReturn")
        
        textField.resignFirstResponder();
        if (textField == txtComment || txtTopOfToolBarChat == textField){
            sendChatMessage()
        }else if (textField == txt_Q_And_A || txtTopOfToolBarQAndA == textField){
            send_Q_And_A()
        }
        return true;
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let textFieldText: NSString = (textField.text ?? "") as NSString
        let txtAfterUpdate = textFieldText.replacingCharacters(in: range, with: string)
        txtTopOfToolBarChat.text = txtAfterUpdate
        txtTopOfToolBarQAndA.text = txtAfterUpdate
        
        
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
        let session_token = UserDefaults.standard.string(forKey: "session_token") ?? ""

        if(type == "performer_tip"){
            queryString =  queryString + "&performer_id=" + String(self.performerId)
        }else if(type == "charity_donation"){
            queryString = queryString + "&charity_id=" + String(charityId)
        }
        queryString = queryString + "&token=" + session_token
        let urlOpen = appDelegate.paymentRedirectionURL + "/" + type + "?" + queryString
        guard let url = URL(string: urlOpen) else { return }
        print("url to open:",url)
        isPaymentNavigation = true
        isSubscriptionNavigation = false
        UIApplication.shared.open(url)
        viewRight.isHidden = true
        viewRightShort.isHidden = false
        //btnTips.setImage(UIImage.init(named: "s_tip"), for: .normal)
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
                        print("getEventBySlug JSON:",json)
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
    
    func getTicketDetails(){
        print("==getTicketDetails")
        // let params: [String: Any] = ["userid":user_id ?? "","performer_id":"101","stream_id": "0"]
        let url: String = appDelegate.baseURL +  "/getTicketDetails"
        let user_id = UserDefaults.standard.string(forKey: "user_id");
        var streamIdLocal = "0"
        if (streamId != 0){
            streamIdLocal = String(streamId)
        }
        let headers: HTTPHeaders
        headers = [appDelegate.x_api_key: appDelegate.x_api_value]
        
        let params: [String: Any] = ["ticket_key": "1863-101059776-26pLyiTtnY2N"]
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
    func LiveEventByIdStatus1(){
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
        // print("liveEvents params:",params)
        
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
                                stream_status = streamObj["stream_status"] as? String ?? ""
                                
                                if(stream_status == "completed"){
                                    self.lblStreamUnavailable.text = "The stream has ended."
                                    ALToastView.toast(in: self.view, withText:"The stream has ended")
                                    delayWithSeconds(5.0){
                                        self.viewControls?.isHidden = true
                                        self.lblLive.isHidden = true
                                        
                                        if (self.timer != nil)
                                        {
                                            self.timer!.invalidate()
                                            self.timer = nil
                                        }
                                        closeStream()
                                        self.endSession()
                                        goBack()
                                        return
                                    }
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
        // print("liveEvents params:",params)
        
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
                                stream_status = streamObj["stream_status"] as? String ?? ""
                                print("stream_status--:",stream_status)
                                if(stream_status == "completed"){
                                    self.lblStreamUnavailable.text = "The stream has ended."
                                    ALToastView.toast(in: self.view, withText:"The stream has ended")
                                    delayWithSeconds(5.0){
                                        self.viewControls?.isHidden = true
                                        self.lblLive.isHidden = true
                                        
                                        if (self.timer != nil)
                                        {
                                            self.timer!.invalidate()
                                            self.timer = nil
                                        }
                                        closeStream()
                                        self.endSession()
                                        goBack()
                                        return
                                    }
                                }else{
                                    showHLSVideo()
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
            .responseJSON { [self] response in
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
                                let settings_json = streamObj["settings_json"] as? String ?? ""
                                stream_status = streamObj["stream_status"] as? String ?? ""

                                let dicSettingsJson = self.convertToDictionary(text: settings_json)
                                print("dicSettingsJson:",dicSettingsJson)
                                self.settings_q_and_a = dicSettingsJson?["q_and_a"] as? Int ?? 0
                                self.settings_fan_chat = dicSettingsJson?["fan_chat"] as? Int ?? 0
                                self.settings_reactions = dicSettingsJson?["reactions"] as? Int ?? 0
                                self.settings_donation = dicSettingsJson?["donation"] as? Int ?? 0
                                self.settings_tip = dicSettingsJson?["tip"] as? Int ?? 0
                                if(self.settings_fan_chat == 1){
                                    let predicate = NSPredicate(format:"title == %@", "chat")
                                    let filteredArray = (buttonNames as NSArray).filtered(using: predicate)
                                    //for live only enable chat
                                    print("==>filteredArray.count:",filteredArray.count)
                                    print("==>stream_status:",stream_status)

                                    if(filteredArray.count == 0 && stream_status == "progress"){
                                        let dicItem = ["title":"chat","icon":"s_chat","icon_active":"s_chat_active"]
                                        self.buttonNames.append(dicItem)
                                    }
                                   
                                }
                                if(self.settings_donation == 1){
                                    let predicate = NSPredicate(format:"title == %@", "donation")
                                    let filteredArray = (buttonNames as NSArray).filtered(using: predicate)
                                    if(filteredArray.count == 0){
                                        let dicItem = ["title":"donation","icon":"s_donation","icon_active":"s_donation_active"]
                                        self.buttonNames.append(dicItem)
                                    }
                                }
                                if(self.settings_tip == 1){
                                    let predicate = NSPredicate(format:"title == %@", "tip")
                                    let filteredArray = (buttonNames as NSArray).filtered(using: predicate)
                                    if(filteredArray.count == 0){
                                        let dicItem = ["title":"tip","icon":"s_tip","icon_active":"s_tip_active"]
                                        self.buttonNames.append(dicItem)
                                    }
                                }
                                if(self.settings_reactions == 1){
                                    let predicate = NSPredicate(format:"title == %@", "emoji")
                                    let filteredArray = (buttonNames as NSArray).filtered(using: predicate)
                                    if(filteredArray.count == 0){
                                        let dicItem = ["title":"emoji","icon":"s_emoji","icon_active":"s_emoji_active"]
                                        self.buttonNames.append(dicItem)
                                    }
                                }
                                if(self.settings_q_and_a == 1){
                                    //uncomment after this release
                                    let predicate = NSPredicate(format:"title == %@", "qa")
                                     let filteredArray = (buttonNames as NSArray).filtered(using: predicate)
                                     if(filteredArray.count == 0 && stream_status == "progress"){
                                     let dicItem = ["title":"qa","icon":"s_qa","icon_active":"s_qa_active"]
                                     self.buttonNames.append(dicItem)
                                     }
                                }
                                
                                self.streamHeaderCVC.reloadData()
                                
                                self.viewLiveStream.isHidden = false;
                                self.btnPlayStream.setImage(UIImage.init(named: "video-play"), for: .normal)
                                self.btnPlayStream.isHidden = true;
                                self.streamId = streamObj["id"] as? Int ?? 0
                                self.age_limit = streamObj["age_limit"] as? Int ?? 0
                                // print("self.age_limit:",self.age_limit)
                                self.streamVideoCode = streamObj["stream_video_code"] as? String ?? ""
                                let streamVideoTitle = streamObj["stream_video_title"] as? String ?? ""
                                self.number_of_creators = streamObj["number_of_creators"] as? Int ?? 1
                                
                                //print("==streamVideoTitle:",streamVideoTitle)
                                self.sendBirdChatConfig()
                                self.streamVideoDesc = streamObj["stream_video_description"] as? String ?? ""
                                // "currency_type" = USD;
                                var currency_type = streamObj["currency_type"] as? String ?? ""
                                self.currencyType = currency_type
                                let currencySymbol1 = jsonCurrencyList[currency_type] as? String
                                let currencySymbol = currencySymbol1 ?? "$"
                                
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
                                formatter.locale = Locale(identifier: "en_US_POSIX")
                                
                                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                                if let publishDate = formatter.date(from: publish_date_time){
                                    let localDate = publishDate.toLocalTime()
                                    formatter.dateFormat = "dd MMM yyyy, hh:mm a"
                                    self.strUpcomingDate = formatter.string(from: localDate)
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
                                    // print("==currency_type:",currency_type)
                                    // print("==subCurrencyType:",subCurrencyType)
                                    
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
                                        print("endDate:",endDate,";")
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
                                //self.lblAmount.text = "Free"
                            }
                            let streamObj = self.aryStreamInfo
                            print("==stream_status:",stream_status)
                            if(stream_status == "completed"){
                                //uncomment below line
                                //self.setLiveStreamConfig()
                                
                                self.viewLiveStream.isHidden = false;
                                self.btnPayPerView.isHidden = true
                                self.lblStreamUnavailable.text = "Sale is completed!"
                                self.viewActions?.isHidden = true
                                self.lblLive.isHidden = true
                                
                                return
                            }
                                if (self.aryUserSubscriptionInfo.count == 0){
                                    //if user does not pay amount
                                    self.btnPayPerView.isHidden = false
                                    self.viewVOD.isHidden = false
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
                                            
                                            self.setLiveStreamConfig()
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
                            if (self.age_limit <= user_age_limit || self.age_limit == 0){
                            }
                            else{
                                if(!appDelegate.isGuest){
                                    //self.isChannelAvailable = false
//                                    self.btnPlayStream.isHidden = false;
//                                    self.btnPlayStream.isUserInteractionEnabled = false
//                                    self.btnPlayStream.setImage(UIImage.init(named: "eye-cross"), for: .normal)
//                                    self.lblStreamUnavailable.text = "This video may be inappropriate for some users"
//                                    self.isShowChat = false
//                                    self.isAgeAllowed = false
                                }
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
                                
                                var fullText = videoDesc  + "\n" + creatorName
                                                               fullText = fullText.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
                                                               self.txtVideoDesc_Info.text = fullText.htmlToString

                                
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
        isStreamConfigured = true
        getGuestDetailInGraphql(.returnCacheDataAndFetch)//need to refresh stream
        self.configureStreamView()
    }
    func configureStreamView() {
        self.viewLiveStream.isHidden = false;
        self.viewVOD.isHidden = true;
        self.stopVideo()
        self.btnGoLive.isHidden = true

        // Update the user interface for the detail item.
        // Access the static shared interface to ensure it's loaded
        //if number_of_creators > 1 multi stream
        //else single stream
        //print("====number_of_creators:",number_of_creators)
        
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
            
            /*r5ViewController  = mClass.init()
             r5ViewController?.view.frame = self.viewLiveStream.bounds
             self.viewLiveStream.addSubview(r5ViewController!.view)
             self.addChild(r5ViewController!)*/
            if(stream_status == "progress"){
                metaLive()
                //self.viewLiveStream.bringSubviewToFront(webView)
                self.viewLiveStream.bringSubviewToFront(self.viewOverlay!)
                self.viewLiveStream.bringSubviewToFront(lblStreamUnavailable)
            }else{
                viewActivity.isHidden = true
                self.lblStreamUnavailable.text = "Please wait. The Stream will begin on \n" + self.strUpcomingDate
                btnPlayStream.setImage(UIImage.init(named: "refresh"), for: .normal)
                btnPlayStream.isHidden = true;
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
        if( self.subscribeStream1 != nil ){
            //NSLog("==subscribeStream1 != nil")
            self.subscribeStream1!.stop()
            self.subscribeStream1!.client = nil
            self.subscribeStream1?.delegate = nil
            self.subscribeStream1 = nil
            
        }
        if( self.r5ViewControllerScreenShare != nil ){
            //NSLog("==subscribeStream1 != nil")
            self.r5ViewControllerScreenShare?.closeTest()
        }
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
        
        /* if self.isLoading {
         return
         }*/
        
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
            print("msgs:",msgs)
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
        
        /* if self.isLoading {
         return
         }*/
        
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
    func loadPrevious_Q_And_A(initial: Bool) {
        guard let channel_q_and_a = self.channel_q_and_a else { return }
        
        /*if self.isLoading_q_and_a {
         return
         }*/
        
        self.isLoading_q_and_a = true
        
        var timestamp: Int64 = 0
        
        if initial {
            self.hasPrevious_q_and_a = true
            timestamp = Int64.max
        }
        else {
            timestamp = self.minMessageTimestamp
        }
        
        if self.hasPrevious_q_and_a == false {
            return
        }
        var CUSTOM_TYPE = "QUESTION";
        let MESSAGE_TYPE = "MESG";
        
        channel_q_and_a.getPreviousMessages(byTimestamp: timestamp, limit: 30, reverse: !initial, messageType: .all, customType: CUSTOM_TYPE, completionHandler: { (questions, error) in
            if error != nil {
                self.isLoading_q_and_a = false
                
                return
            }
            let messageList = questions;
            CUSTOM_TYPE = "ANSWER";
            
            channel_q_and_a.getPreviousMessages(byTimestamp: timestamp, limit: 30, reverse: !initial, messageType: .all, customType: CUSTOM_TYPE, completionHandler: { [self] (answers, error) in
                if error != nil {
                    self.isLoading_q_and_a = false
                    
                    return
                }
                guard let messages_q_and_a = questions else { return }
                let messages_q_and_a_answers = answers
                self.messages_q_and_a_answers1 = answers ?? []
                print("messages_q_and_a_answers1:",self.messages_q_and_a_answers1)
                self.messages_q_and_a_answers_main.removeAll()
                for answer in messages_q_and_a_answers ?? [] {
                    //print("answer.data:",answer.data)
                    let metaData = answer.sender?.metaData
                    var color = "#58CCED"
                    if answer.sender?.userId == SBDMain.getCurrentUser()?.userId {
                        //self.nicknameLabel.textColor = .orange
                        //self.userName.backgroundColor = .orange
                        color = "#C71585"
                    }
                    else {
                        //                        let greenColor = UIColor.init(red: 88, green: 204, blue: 237)
                        //                        self.nicknameLabel.textColor = greenColor
                        //                        self.userName.backgroundColor = greenColor
                    }
                    
                    let isPartner = metaData?["isPartner"] ?? "no"
                    let data1 = ["data":answer.data,"sender":answer.sender?.nickname ?? "","message":answer.message,"messageId":answer.messageId,"isPartner":isPartner,"color":color] as [String : Any]
                    self.messages_q_and_a_answers_main.append(data1)
                }
                //print("messages_q_and_a_answers_main:",messages_q_and_a_answers_main)
                //print("count:",messages_q_and_a_answers_main.count)
                
                
                if messages_q_and_a.count == 0 {
                    self.hasPrevious_q_and_a = false
                }
                
                if initial {
                    if messages_q_and_a.count > 0 {
                        DispatchQueue.main.async {
                            self.messages_q_and_a.removeAll()
                            for question in messages_q_and_a {
                                self.messages_q_and_a.append(question)
                                if self.minMessageTimestamp > question.createdAt {
                                    self.minMessageTimestamp = question.createdAt
                                }
                            }
                            
                            self.tbl_Q_And_A.reloadData()
                            self.tbl_Q_And_A.layoutIfNeeded()
                            self.initialLoading_q_and_a = false
                            self.isLoading_q_and_a = false
                            self.scrollToBottom_Q_And_A(force: true)

                        }
                    }
                }
                else {
                    if messages_q_and_a.count > 0 {
                        DispatchQueue.main.async {
                            var messageIndexPaths: [IndexPath] = []
                            var row: Int = 0
                            for question in messages_q_and_a {
                                self.messages_q_and_a.insert(question, at: 0)
                                
                                if self.minMessageTimestamp > question.createdAt {
                                    self.minMessageTimestamp = question.createdAt
                                }
                                
                                messageIndexPaths.append(IndexPath(row: row, section: 0))
                                row += 1
                            }
                            
                            self.tbl_Q_And_A.reloadData()
                            self.tbl_Q_And_A.layoutIfNeeded()
                            self.isLoading_q_and_a = false
                            self.scrollToBottom_Q_And_A(force: true)

                        }
                    }
                }
            })
        })
        //print("msgs:",self.messages)
    }
    @objc func sendReply(_ sender: UIButton) {
        self.view.endEditing(true)
        showAlert(strMsg: "Please enter your reply")
    }
    @IBAction func send_Q_And_A_Answer(msg:String,msgId:String) {
        self.view.endEditing(true)
            //print("sendBirdErrorCode:",sendBirdErrorCode)
         
            switch sendBirdErrorCode_Q_And_A {
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
                print("")
            //              showAlert(strMsg: "\(self.sbdError)")
            }
        //print("channelName:",channelName)
        guard let channel = self.channel_q_and_a else {
            showAlert(strMsg: "Channel is not available, Please try again later.")
            return
        }
        //print("channelName2:",self.channel?.name);
        self.txt_Q_And_A.text = ""
        //self.sendUserMessageButton.isEnabled = false
        var preSendMessage: SBDUserMessage?
        preSendMessage = channel.sendUserMessage(msg, data: msgId,customType: "ANSWER") { (userMessage, error) in
            if error != nil {
                DispatchQueue.main.async {
                    guard let preSendMsg = preSendMessage else { return }
                    let requestId = preSendMsg.requestId
                    
                    self.preSendMessages_q_and_a.removeValue(forKey: requestId)
                    self.resendableMessages_q_and_a[requestId] = preSendMsg
                    //self.tbl_Q_And_A.reloadData()
                    self.loadPrevious_Q_And_A(initial: true)


                }
                return
            }
            self.loadPrevious_Q_And_A(initial: true)


            //self.tbl_Q_And_A.reloadData()
            
            /*guard let message = userMessage else { return }
             let requestId = message.requestId
             
             DispatchQueue.main.async {
             self.determineScrollLock()
             
             if let preSendMessage = self.preSendMessages_q_and_a[requestId] {
             if let index = self.messages_q_and_a.firstIndex(of: preSendMessage) {
             self.messages_q_and_a[index] = message
             self.preSendMessages_q_and_a.removeValue(forKey: requestId)
             self.tbl_Q_And_A.reloadData()
             self.scrollToBottom(force: true)
             }
             }
             }*/
        }
        
        /* DispatchQueue.main.async {
         self.determineScrollLock()
         if let preSendMsg = preSendMessage {
         let requestId = preSendMsg.requestId
         self.preSendMessages_q_and_a[requestId] = preSendMsg
         self.messages_q_and_a.append(preSendMsg)
         self.tbl_Q_And_A.reloadData()
         self.scrollToBottom(force: true)
         
         }
         }*/
    }
    
    @IBAction func send_Q_And_A() {
        
        txt_Q_And_A.resignFirstResponder()
        txtTopOfToolBarQAndA.resignFirstResponder()
        let messageText = txt_Q_And_A.text!.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        if (messageText.count == 0){
            showAlert(strMsg: "Please enter your question")
            return
        }
        self.txt_Q_And_A.text = ""
        self.txtTopOfToolBarQAndA.text = ""
            //print("sendBirdErrorCode:",sendBirdErrorCode)
            switch sendBirdErrorCode_Q_And_A {
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
               print("")
            //              showAlert(strMsg: "\(self.sbdError)")
            }
        
        //print("channelName:",channelName)
        guard let channel = self.channel_q_and_a else {
            showAlert(strMsg: "Channel is not available, Please try again later.")
            return
        }
        //print("channelName2:",self.channel?.name);
        self.txt_Q_And_A.text = ""
        //self.sendUserMessageButton.isEnabled = false
        var preSendMessage: SBDUserMessage?
        preSendMessage = channel.sendUserMessage(messageText, data: messageText,customType: "QUESTION") { (userMessage, error) in
            if error != nil {
                DispatchQueue.main.async {
                    guard let preSendMsg = preSendMessage else { return }
                    let requestId = preSendMsg.requestId
                    
                    self.preSendMessages_q_and_a.removeValue(forKey: requestId)
                    self.resendableMessages_q_and_a[requestId] = preSendMsg
                    self.tbl_Q_And_A.reloadData()
                    self.scrollToBottom_Q_And_A(force: true)
                    
                }
                return
            }
            
            guard let message = userMessage else { return }
            let requestId = message.requestId
            
            DispatchQueue.main.async {
                self.determineScrollLock()
                
                if let preSendMessage = self.preSendMessages_q_and_a[requestId] {
                    if let index = self.messages_q_and_a.firstIndex(of: preSendMessage) {
                        self.messages_q_and_a[index] = message
                        self.preSendMessages_q_and_a.removeValue(forKey: requestId)
                        self.tbl_Q_And_A.reloadData()
                        self.scrollToBottom(force: true)
                    }
                }
            }
        }
        
        DispatchQueue.main.async {
            self.determineScrollLock()
            if let preSendMsg = preSendMessage {
                let requestId = preSendMsg.requestId
                self.preSendMessages_q_and_a[requestId] = preSendMsg
                self.messages_q_and_a.append(preSendMsg)
                self.tbl_Q_And_A.reloadData()
                self.scrollToBottom_Q_And_A(force: true)
                
            }
        }
    }
    @IBAction func sendChatMessage() {
        
        txtComment.resignFirstResponder()
        txtTopOfToolBarChat.resignFirstResponder()
        let messageText = txtComment.text!.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        if (messageText.count == 0){
            showAlert(strMsg: "Please enter message")
            return
        }
        self.txtComment.text = ""
        self.txtTopOfToolBarChat.text = ""
        
            print("sendBirdErrorCode:",sendBirdErrorCode)
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
                print("")
            //              showAlert(strMsg: "\(self.sbdError)")
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
                    let requestId = preSendMsg.requestId
                    
                    self.preSendMessages.removeValue(forKey: requestId)
                    self.resendableMessages[requestId] = preSendMsg
                    self.tblComments.reloadData()
                    self.scrollToBottom(force: true)
                    
                }
                return
            }
            
            guard let message = userMessage else { return }
            let requestId = message.requestId
            
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
                let requestId = preSendMsg.requestId
                self.preSendMessages[requestId] = preSendMsg
                self.messages.append(preSendMsg)
                self.tblComments.reloadData()
                self.scrollToBottom(force: true)
                
            }
        }
    }
    @IBAction func sendEmoji(strEmoji: String) {
        txtEmoji.resignFirstResponder()
        
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
                print("")
            //showAlert(strMsg: "\(self.sbdError_emoji)")
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
                    let requestId = preSendMsg.requestId
                    
                    self.preSendMessage_emojis.removeValue(forKey: requestId)
                    self.resendableMessage_emojis[requestId] = preSendMsg
                    // self.tblComments.reloadData()
                }
                return
            }
            
            guard let message = userMessage else {
                return
                
            }
            let requestId = message.requestId
            
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
                let requestId = preSendMsg.requestId
                self.preSendMessage_emojis[requestId] = preSendMsg
                self.emojis.append(preSendMsg)
                //                    self.tblComments.reloadData()
                //                    self.scrollToBottom(force: false)
                
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
    func scrollToBottom_Q_And_A(force: Bool) {
        /*if self.messages_q_and_a.count == 0 {
            return
        }
        
        if  force == false {
            return
        }
        if(index_selected_q_qnd_a >= 0){
            if(messages_q_and_a.count > 0){
                let question = messages_q_and_a[index_selected_q_qnd_a]
                                let searchPredicate = NSPredicate(format: "data = %@", String(question.messageId))
                                let filteredArray = (messages_q_and_a_answers_main as NSArray).filtered(using: searchPredicate)
                self.tbl_Q_And_A.scrollToRow(at: IndexPath(row: filteredArray.count-1, section: index_selected_q_qnd_a), at: .top, animated: false)

            }
           
        }else{
            if(messages_q_and_a.count > 0){
            self.tbl_Q_And_A.scrollToRow(at: IndexPath(row: NSNotFound, section: messages_q_and_a.count-1), at: .bottom, animated: false)
            }

        }*/

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
        print("didReceive:",message)
        
        if let channel = self.channel {
            if sender == channel {
                DispatchQueue.main.async {
                    self.determineScrollLock()
                    UIView.setAnimationsEnabled(false)
                    self.messages.append(message)
                    self.tblComments.insertRows(at: [IndexPath(row: self.messages.count - 1, section: 0)], with: .none)
                    self.scrollToBottom(force: false)
                    UIView.setAnimationsEnabled(true)
                    let index = self.buttonNames.firstIndex(where: {$0["title"]! == "chat"}) ?? 0
                    print("index:",index)
                    //for chat  show dot on header, if chat is not active
                    if(index  > 0 && !self.isChatActive){
                        let blinkTag = 100 + index;
                        let lblBlink = self.streamHeaderCVC.viewWithTag(blinkTag) as? UILabel
                        lblBlink?.isHidden = false
                    }

                }
            }
        }
        if let channel = self.channel_q_and_a {
            if sender == channel {
                loadPrevious_Q_And_A(initial: true)
                let index = self.buttonNames.firstIndex(where: {$0["title"]! == "qa"}) ?? 0
                print("index:",index)
                //for Q_and_A  show dot on header, if Q_And_A is not active

                if(index  > 0 && !self.isQ_And_A_Active){
                    let blinkTag = 100 + index;
                    let lblBlink = self.streamHeaderCVC.viewWithTag(blinkTag) as? UILabel
                    lblBlink?.isHidden = false
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
                //self.navigationController?.popViewController(animated: true)
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
            //self.navigationController?.popViewController(animated: true)
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
    
    @objc func showPopupWithInput(_ sender: UIButton){
        //print("==tag:",sender.tag)
        //1. Create the alert controller.
        let alert = UIAlertController(title: "Send a reply", message: nil, preferredStyle: .alert)

        //2. Add the text field. You can configure it however you need.
        alert.addTextField { (textField) in
            textField.text = ""
            textField.font = UIFont(name:"Poppins Regular", size: 17.0)

        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            print("Text field: \(textField?.text)")
            
            let messageText = textField?.text?.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
            if (messageText?.count == 0){
                self.showAlert(strMsg: "Please enter your reply")
                return
            }
            let question = self.messages_q_and_a[sender.tag]
            let messageId = String(question.messageId)
            self.send_Q_And_A_Answer(msg:messageText ?? "" , msgId:messageId )
        }))

        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
    }
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
        // print("--self.streamId:",self.streamId)
        // print("--self.streamId1:",String(self.streamId))
        
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
                            var eventStartDates = [Date]()
                            var eventEndDates = [Date]()
                            self.isAgeAllowed = true
                            self.isShowChat = true
                            
                            ////print(json["message"] as? String ?? "")
                            let data = json["Data"] as? [String:Any]
                            self.aryStreamInfo = data?["stream_info"] as? [String:Any] ?? [:]
                            let stream_info_key_exists = self.aryStreamInfo["id"]
                            if (stream_info_key_exists != nil){
                                let streamObj = self.aryStreamInfo
                                let settings_json = streamObj["settings_json"] as? String ?? ""
                                let dicSettingsJson = self.convertToDictionary(text: settings_json)
                                print("dicSettingsJson:",dicSettingsJson)
                                self.settings_q_and_a = dicSettingsJson?["q_and_a"] as? Int ?? 0
                                self.settings_fan_chat = dicSettingsJson?["fan_chat"] as? Int ?? 0
                                self.settings_reactions = dicSettingsJson?["reactions"] as? Int ?? 0
                                self.settings_donation = dicSettingsJson?["donation"] as? Int ?? 0
                                self.settings_tip = dicSettingsJson?["tip"] as? Int ?? 0
                                if(self.settings_fan_chat == 1){
                                    let predicate = NSPredicate(format:"title == %@", "chat")
                                    let filteredArray = (buttonNames as NSArray).filtered(using: predicate)
                                    if(filteredArray.count == 0){
                                        let dicItem = ["title":"chat","icon":"s_chat","icon_active":"s_chat_active"]
                                        self.buttonNames.append(dicItem)
                                    }
                                    
                                }
                                if(self.settings_donation == 1){
                                    let predicate = NSPredicate(format:"title == %@", "donation")
                                    let filteredArray = (buttonNames as NSArray).filtered(using: predicate)
                                    if(filteredArray.count == 0){
                                        let dicItem = ["title":"donation","icon":"s_donation","icon_active":"s_donation_active"]
                                        self.buttonNames.append(dicItem)
                                    }
                                }
                                if(self.settings_tip == 1){
                                    let predicate = NSPredicate(format:"title == %@", "tip")
                                    let filteredArray = (buttonNames as NSArray).filtered(using: predicate)
                                    if(filteredArray.count == 0){
                                        let dicItem = ["title":"tip","icon":"s_tip","icon_active":"s_tip_active"]
                                        self.buttonNames.append(dicItem)
                                    }
                                }
                                if(self.settings_reactions == 1){
                                    let predicate = NSPredicate(format:"title == %@", "emoji")
                                    let filteredArray = (buttonNames as NSArray).filtered(using: predicate)
                                    if(filteredArray.count == 0){
                                        let dicItem = ["title":"emoji","icon":"s_emoji","icon_active":"s_emoji_active"]
                                        self.buttonNames.append(dicItem)
                                    }
                                }
                                if(self.settings_q_and_a == 1){
                                    //uncomment after this release
                                    
                                      let predicate = NSPredicate(format:"title == %@", "qa")
                                     let filteredArray = (buttonNames as NSArray).filtered(using: predicate)
                                     if(filteredArray.count == 0){
                                     let dicItem = ["title":"qa","icon":"s_qa","icon_active":"s_qa_active"]
                                     self.buttonNames.append(dicItem)
                                     }
                                }
                                self.streamHeaderCVC.reloadData()
                                
                                
                                self.viewLiveStream.isHidden = false;
                                self.btnPlayStream.setImage(UIImage.init(named: "video-play"), for: .normal)
                                self.btnPlayStream.isHidden = true;
                                
                                self.streamId = streamObj["id"] as? Int ?? 0
                                self.age_limit = streamObj["age_limit"] as? Int ?? 0
                                self.streamVideoCode = streamObj["stream_video_code"] as? String ?? ""
                                let streamVideoTitle = streamObj["stream_video_title"] as? String ?? ""
                                //print("==streamVideoTitle:",streamVideoTitle)
                                self.sendBirdChatConfig()
                                self.streamVideoDesc = streamObj["stream_video_description"] as? String ?? ""
                                // "currency_type" = USD;
                                var currency_type = streamObj["currency_type"] as? String ?? ""
                                self.currencyType = currency_type
                                
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
                                if (self.aryUserSubscriptionInfo.count == 0 && self.isVOD){
                                    //if user does not pay amount
                                    self.btnPayPerView.isHidden = false
                                    self.viewVOD.isHidden = false
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
                            if (self.age_limit <= user_age_limit || self.age_limit == 0){
                            }else{
                                self.isAgeAllowed = false
                                self.btnPlayStream.isHidden = true;
                                self.btnPlayStream.isUserInteractionEnabled = false
                                //self.btnPlayStream.setImage(UIImage.init(named: "eye-cross"), for: .normal)
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
        let url: String = appDelegate.baseURL +  "/startSession"
        let user_id = UserDefaults.standard.string(forKey: "user_id");
        var streamIdLocal = "0"
        if (streamId != 0){
            streamIdLocal = String(streamId)
        }
        let arn = UserDefaults.standard.string(forKey: "arn");
        
        let inputData: [String: Any] = [ "user_id": user_id ?? "0",
                                         "event_id": streamIdLocal,
                                         "organization_id" : orgId,
                                         "performer_id" : performerId,
                                         "stream_code":streamVideoCode,
                                         "is_mobile":true,
                                         "EndpointArn":arn ?? "",
                                         "filekey": "stream_metrics/" + streamVideoCode + "/"]
        // print("startSession multi params:",inputData)
        
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
                        // print("startSession JSON:",json)
                        if (json["statusCode"]as? String == "200" ){
                            self.startSessionResponse = json
                            self.isViewerCountcall = 1;
                        }else{
                            let strMsg = json["message"] as? String ?? ""
                            //self.showAlert(strMsg: strMsg)
                        }
                        
                    }
                case .failure(let error):
                    let errorDesc = error.localizedDescription.replacingOccurrences(of: "URLSessionTask failed with error:", with: "")
                    self.showAlert(strMsg: errorDesc)
                    self.viewActivity.isHidden = true
                    
                }
            }
    }
    func endSession(){
        NSLog("==endSession")
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let url: String = appDelegate.baseURL +  "/endSession"
        let user_id = UserDefaults.standard.string(forKey: "user_id");
        let streamInfo = "stream_metrics/" + self.streamVideoCode + "/" + String(self.streamId)
        // print("self.startSessionResponse:",self.startSessionResponse)
        var session_start_time = self.startSessionResponse["session_start_time"] as? String ?? ""
        if (session_start_time == ""){
            session_start_time = String(self.startSessionResponse["session_start_time"] as? Int ?? 0)//if it comes as timestamp
        }
        let idData = self.startSessionResponse["Data"] as? String ?? ""
        var arn = self.startSessionResponse["subscription_arn"] as? String ?? ""
        if(arn == ""){
            //if startSessionResponse subscription_arn empty
            arn = UserDefaults.standard.string(forKey: "arn") ?? "";
        }
        let params: [String: Any] = ["id":idData,"image_for": streamInfo,"session_start_time":session_start_time,"is_final":"true","event_id": String(self.streamId),"is_mobile":true,"subscription_arn":arn]
        // print("endSession multi params:",params)
        
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
                        // print("endSession JSON:",json)
                        if (json["statusCode"]as? String == "200" ){
                            
                        }else{
                            let strMsg = json["message"] as? String ?? ""
                            //self.showAlert(strMsg: strMsg)
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(ScreenShareNotificationHandler(_:)), name: .didReceiveScreenShareData, object: nil)
        
        
        if(UIDevice.current.userInterfaceIdiom == .phone){
            let value = UIInterfaceOrientation.landscapeRight.rawValue
            UIDevice.current.setValue(value, forKey: "orientation")
        }
        AppDelegate.AppUtility.lockOrientation(.landscapeRight)
        
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name:UIApplication.didBecomeActiveNotification , object: nil)
        NotificationCenter.default.removeObserver(self)
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
    //MARK: - Screen Share Start
    
    @objc func ReceivedPN(notification: NSNotification){
        guard let userInfo = notification.userInfo else {
            return
        }
        // print("==ReceivedPN userInfo:",userInfo)
        let gcm = userInfo["GCM"] as? [String:Any] ?? [:]
        if(gcm["data"] != nil){
            getGuestDetailInGraphql(.returnCacheDataAndFetch)//need to refresh stream
        }
        /*let gcm = userInfo["GCM"] as? [String:Any] ?? [:]
         let data = gcm["data"]as? [String:Any] ?? [:]
         let message = data["message"]as? [String:Any] ?? [:]
         let innerData = message["data"]as? [String:Any] ?? [:]
         let idKey = innerData["id"]as? [String:Any] ?? [:]
         let skey = idKey["S"] as? String ?? ""
         // print("skey:",skey)
         if(skey != ""){
         //streamVideoCode = skey //stream video key and skey both are same
         getGuestDetailInGraphql(.returnCacheDataAndFetch,showLoader: false)//need to refresh stream
         }*/
        
    }
    func getGuestDetailInGraphql(_ cachePolicy: CachePolicy) {
        // print("====streamVideoCode1:",streamVideoCode)
        //viewActivity.isHidden = false
        /* let listQuery = GetMulticreatorshareddataQuery(id:streamVideoCode)
         //1872_1595845007395_mc2
         //58_1594894849561_multi_creator_test_event
         appSyncClient?.fetch(query: listQuery, cachePolicy: cachePolicy) { [self] result, error in
         self.viewActivity.isHidden = true
         if let error = error {
         // print("Error fetching data: \(error)")
         return
         }
         // print("--result:",result)
         if((result != nil)  && (result?.data != nil)){
         //// print("--data:",result?.data)
         let data = result?.data
         let multiData = data?.getMulticreatorshareddata
         if(multiData != nil){
         let multiDataJSON = self.convertToDictionary(text: multiData?.data ?? "")
         // print("multiDataJSON:",multiDataJSON)
         let liveStatus = multiDataJSON?["liveStatus"] as? Bool ?? false;
         self.isSharedScreen = (multiDataJSON?["isSharedScreen"]as? Bool ?? false) ? true : false;
         let isLive = (multiDataJSON?["isLive"]as? Bool ?? false) ? true : false;
         // print("self.isSharedScreen:",self.isSharedScreen)
         // print("self.isStreamStartedAlias:",self.isStreamStartedAlias)
         // print("isLive:",isLive)
         self.adjustScreenShare();
         
         }else{
         // print("GetMulticreatorshareddataQuery nil:")
         }
         }
         // Remove existing records if we're either loading from cache, or loading fresh (e.g., from a refresh)
         }*/
    }
    
    func SS_startup() {
        // print("==SS_startup")
        //screenshare
        //viewActivity.isHidden = false
        _ = Testbed.sharedInstance
        self.detailStreamItem = Testbed.testAtIndex(index: 0)
        if(self.detailStreamItem != nil){
            ////print("props:",self.detailStreamItem!["LocalProperties"] as? NSMutableDictionary)
            Testbed.setLocalOverrides(params: self.detailStreamItem!["LocalProperties"] as? NSMutableDictionary)
            let className = "ScreenShareVC"
            let mClass = NSClassFromString(className) as! BaseTest.Type;
            appDelegate.sharedScreenBy = streamVideoCode
            r5ViewControllerScreenShare  = mClass.init()
            r5ViewControllerScreenShare?.view.frame = self.viewShareScreen.bounds
            self.viewShareScreen.addSubview(r5ViewControllerScreenShare!.view)
            //self.viewLiveStream.bringSubviewToFront(self.webView)
            self.addChild(r5ViewControllerScreenShare!)
        }
    }
    func SS_shutdown(){
        r5ViewControllerScreenShare?.closeTest()
    }
    
    func adjustScreenShare() {
        isShareScreenConfigured = true
        // print("self1.isSharedScreen",self.isSharedScreen)
        // print("self1.isStreamStartedAlias",self.isStreamStartedAlias)
        //if (self.isSharedScreen && isStreamConfigured)
        if (self.isSharedScreen && isStreamStartedAlias)
        {
            //after stream connected we are calling screen share to avaoid blank screen issue
            SS_startup()
            //show screen share view
            NSLayoutConstraint.setMultiplier(0.45, of: &(viewStreamWidth)!)
            viewShareScreen.isHidden = false
            self.viewStream.layoutIfNeeded()
            viewControlsLeft.constant = (self.view.frame.size.width * 0.55)
            viewControls?.layoutIfNeeded()
            lblLiveLeft.constant = self.viewLiveStream.frame.size.width - 90 //live btn width 80
            lblLive?.layoutIfNeeded()
            
        }else{
            SS_shutdown()
            //hide screen share view
            NSLayoutConstraint.setMultiplier(1.0, of: &(viewStreamWidth)!)
            viewShareScreen.isHidden = true
            self.viewStream.layoutIfNeeded()
            viewControlsLeft.constant = 0
            viewControls?.layoutIfNeeded()
            lblLiveLeft.constant = 10
            lblLive?.layoutIfNeeded()
            
        }
        
    }
    //MARK: - Screen Share End
    
    //MARK: - Live Stream Methods  Start
    func metaLive(){
        let netAvailable = appDelegate.isConnectedToInternet()
        if(!netAvailable){
            showAlert(strMsg: "Please check your internet connection!")
            return
        }
        let host = Testbed.getParameter(param:"host") as! String;
        let version = Testbed.getParameter(param:"sm_version") as! String;
        let stream1 = Testbed.getParameter(param:"stream1") as! String;
        let accessToken = appDelegate.red5_acc_token
        // https:// livestream.arevea.com/streammanager/api/4.0/admin/event/meta/live/<stream_video_code>/?accessToken=YEOkGmERp08V
        let url = "https://" + host  + "/streammanager/api/" + version + "/admin/event/meta/live/" + stream1 + "?accessToken=" + accessToken
        //print("metaLive url:",url)
        //let stream = "1588832196500_taylorswiftevent"
        AF.request(url,method: .get, encoding: JSONEncoding.default)
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    DispatchQueue.main.async { [self] in
                        print("metaLive Response:",value)
                        if let json = value as? [String: Any] {
                            if json["errorMessage"] != nil{
                                // ALToastView.toast(in: self.view, withText:errorMsg as? String ?? "")
                                //let error = "Unable to locate stream. Broadcast has probably not started for this stream: " + stream1
                                // ALToastView.toast(in: self.view, withText: error)
                                self.streamInfoUpdate(strValue: "not_available")

                            }else{
                                let data = json["data"] as? [String:Any]
                                let meta = data?["meta"] as? [String:Any]
                                let stream = meta?["stream"] as? [Any] ?? [Any]()
                                if (stream.count > 0){
                                    let lastStreamObj = stream[stream.count - 1] as? [String:Any]
                                    let strName = lastStreamObj?["name"] as? String ?? ""
                                    ////print("lastStreamObj name:",strName)
                                    self.findStream(streamName: strName)
                                    
                                }else{
                                    self.streamInfoUpdate(strValue: "not_available")
                                    
                                }
                            }
                        }
                    }
                    
                    
                case .failure(let error):
                    // print("error occured in metaLive:",error)
                    self.streamInfoUpdate(strValue: "not_available")
                    
                    
                }
            }
        
    }
    func findStream(streamName: String){
        let netAvailable = appDelegate.isConnectedToInternet()
        if(!netAvailable){
            showAlert(strMsg: "Please check your internet connection!")
            return
        }
        _ = String(Testbed.getParameter(param:"port") as! Int);
        let host = Testbed.getParameter(param:"host") as! String;
        let version = Testbed.getParameter(param:"sm_version") as! String;
        let context = Testbed.getParameter(param:"context") as! String;
        //let stream1 = Testbed.getParameter(param:"stream1") as! String;
        
        let url = "https://" + host  + "/streammanager/api/" + version + "/event/" +
            context + "/" + streamName + "?action=subscribe&region=" + appDelegate.strRegionCode;
        
        print("stream url:",url)
        //let url = "https:// livestream.arevea.com/streammanager/api/4.0/event/live/1588788669277_somethingnew?action=subscribe"
        ////print("findStream url:",url)
        //let stream = "1588832196500_taylorswiftevent"
        
        AF.request(url,method: .get, encoding: JSONEncoding.default)
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    DispatchQueue.main.async {
                        print("stream manager API res:",value)
                    }
                    if let json = value as? [String: Any] {
                        if json["errorMessage"] != nil{
                            DispatchQueue.main.async {
                                self.viewActivity.isHidden = true
                                if (self.viewLiveStream.isHidden == false){
                                    if(self.isStreamStarted){
                                        self.lblStreamUnavailable.text = "We are working on the issue. We will be back shortly."
                                        self.btnPlayStream.isHidden = true;
                                    }else{
                                        if(self.isUpcoming){
                                            //var localTimeZoneAbbreviation: String { return TimeZone.current.abbreviation() ?? "" }
                                        self.lblStreamUnavailable.text = "Please wait. The Stream will begin on \n" + self.strUpcomingDate
                                                self.btnPlayStream.setImage(UIImage.init(named: "refresh"), for: .normal)
                                            self.btnPlayStream.isHidden = true;
                                        }else{
                                            self.lblStreamUnavailable.text = "We are working on the issue. We will be back shortly."
                                            self.btnPlayStream.isHidden = false;
                                            self.btnPlayStream.setImage(UIImage.init(named: "refresh"), for: .normal)
                                        }
                                    }
                                    self.showHLSVideo()
                                    //self.viewOverlay?.isHidden = true// controls not working
                                }
                            }
                        }else{
                            self.viewControls?.isHidden = false
                            self.imgStreamThumbNail.isHidden = true
                            self.lblLive.isHidden = false
                            self.streamNameOfLive = streamName
                            self.serverAddress = json["serverAddress"] as? String ?? ""
                            self.config(url: self.serverAddress,stream:streamName,start: true)
                        }
                    }
                    
                case .failure(let error):
                    print(error)
                }
            }
    }
    func config(url:String,stream:String,start:Bool){
        //adjustScreenShare()
        DispatchQueue.main.async { [self] in
            
            let config = getConfig(url: url)
            // Set up the connection and stream
            let connection = R5Connection(config: config)
            self.subscribeStream1 = R5Stream(connection: connection)
            
            let stats = self.subscribeStream1?.getDebugStats()
            //print("---stats:",stats as Any)
            self.subscribeStream1!.delegate = self
            self.subscribeStream1?.client = self;
            // self.subscribeStream.subscribeToAudio = YES;
            viewR5StreamingLive = getNewR5VideoViewController(rect: viewStream.frame)
            viewR5StreamingLive?.attach(subscribeStream1)
            viewStream.addSubview((viewR5StreamingLive?.view)!)
            //streamName = stream
            self.subscribeStream1!.play(stream, withHardwareAcceleration:false)
        }
        if(start){
            streamInfoUpdate(strValue: "started")
        }
    }
    func getConfig(url:String)->R5Configuration{
        // Set up the configuration
        let config = R5Configuration()
        let userName = Testbed.getParameter(param: "username") as! String
        let password = Testbed.getParameter(param: "password") as! String
        config.parameters = "username=" + userName + ";password=" + password + ";"
        config.host = url;//" livestream.arevea.com";
        config.port = Int32(Testbed.getParameter(param: "port") as! Int);
        config.contextName = (Testbed.getParameter(param: "context") as! String)
        config.`protocol` = Int32(r5_rtsp.rawValue);
        config.buffer_time = Testbed.getParameter(param: "buffer_time") as! Float
        config.licenseKey = (Testbed.getParameter(param: "license_key") as! String)
        return config
    }
    func getNewR5VideoViewController(rect : CGRect) -> R5VideoViewController {
        let view : UIView = UIView(frame: rect)
        var r5View : R5VideoViewController
        r5View = R5VideoViewController.init()
        r5View.view = view;
        return r5View;
    }
    @IBAction func pauseAudio() {
        //if video is pause mode, we should not hear audio
        //handling code for this
        var play = false
        let imgBtn = btnAudio.image(for: .normal)
        if ((imgBtn?.isEqual(UIImage.init(named: "unmute")))!)
        {
            play = false
            btnAudio?.setImage(UIImage.init(named: "mute"), for: .normal);
        }else{
            play = true
            btnAudio?.setImage(UIImage.init(named: "unmute"), for: .normal);
        }
        let imgBtnVideo = btnVideo?.image(for: .normal)
        if ((imgBtnVideo?.isEqual(UIImage.init(named: "pause")))!)
        {
            if (play)
            {
                if(self.subscribeStream1 != nil && self.subscribeStream1?.audioController != nil) {
                    self.subscribeStream1?.pauseAudio = false
                    self.subscribeStream1?.audioController.volume = sliderVolume.value / 100
                    ALToastView.toast(in: self.view, withText:"Playing Audio")
                }
            }
            else{
                if( self.subscribeStream1 != nil && self.subscribeStream1?.audioController != nil) {
                    self.subscribeStream1?.pauseAudio = true
                    self.subscribeStream1?.audioController.volume = 0
                    ALToastView.toast(in: self.view, withText:"Pausing Audio")
                }
            }
        }
       
    }
    @IBAction func pauseVideo() {
        
        let imgBtn = btnVideo?.image(for: .normal)
        if ((imgBtn?.isEqual(UIImage.init(named: "pause")))!)
        {
            btnVideo?.setImage(UIImage.init(named: "play"), for: .normal);
            if(self.subscribeStream1 != nil && self.subscribeStream1?.audioController != nil) {
                self.subscribeStream1?.pauseAudio = true
                self.subscribeStream1?.pauseVideo = true
                self.subscribeStream1?.deactivate_display()
                self.subscribeStream1?.audioController.volume = 0
                ALToastView.toast(in: self.view, withText:"Pausing Video")
            }
        }
        else{
            btnVideo?.setImage(UIImage.init(named: "pause"), for: .normal);
            if(self.subscribeStream1 != nil && self.subscribeStream1?.audioController != nil) {
                self.subscribeStream1?.pauseAudio = false
                self.subscribeStream1?.pauseVideo = false
                self.subscribeStream1?.activate_display()
                self.subscribeStream1?.audioController.volume = sliderVolume.value / 100
                ALToastView.toast(in: self.view, withText:"Playing Video")
            }
        }
    }
    
    @IBAction func sliderValueDidChange() {
        if(self.subscribeStream1 != nil && self.subscribeStream1?.audioController != nil){
            self.subscribeStream1?.audioController.volume = sliderVolume.value / 100
        }
        
    }
    @IBAction func hlsTapped(){
        showHLSVideo()
    }
    // MARK: Handler for Stream Events
    func onR5StreamStatus(_ stream: R5Stream!, withStatus statusCode: Int32, withMessage msg: String!) {
        
        // MARK: Customising
        // print("stream:",stream)
        NSLog("Status: %s ", r5_string_for_status(statusCode))
        let s =  String(format: "Status: %s (%@)",  r5_string_for_status(statusCode), msg)
        NSLog("s:", s)

        //ALToastView.toast(in: self.view, withText:s)
        if (Int(statusCode) == Int(r5_status_disconnected.rawValue)) {
            //self.closeStream()
        } else if ((Int(statusCode) == Int(r5_status_netstatus.rawValue) && msg == "NetStream.Play.UnpublishNotify") || ((Int(statusCode) == Int(r5_status_netstatus.rawValue) && msg == "NetStream.Play.StreamDry"))){
            
            streamInfoUpdate(strValue: "stopped")
            
        } else if ((Int(statusCode) == Int(r5_status_netstatus.rawValue) && msg == "NetStream.Play.SufficientBW")) {
            ////print("=======sufficient band Width")
        }else if ((Int(statusCode) == Int(r5_status_netstatus.rawValue) && msg == "NetStream.Play.InSufficientBW")) {
            ALToastView.toast(in: self.view, withText:"Poor internet connection")
            showHLSVideo()
            
        }else if (Int(statusCode) == Int(r5_status_audio_mute.rawValue))
        {
            ////print("=======r5_status_audio_mute")
            /*let hasAudio = !(self.subscribeStream?.pauseAudio)!;
             if (hasAudio) {
             self.subscribeStream?.pauseAudio = true
             }*/
            ALToastView.toast(in: self.view, withText:"Audio Muted")
            
        }
        else if (Int(statusCode) == Int(r5_status_audio_unmute.rawValue))
        {
            ////print("=======r5_status_audio_unmute")
            /*let hasAudio = !(self.subscribeStream?.pauseAudio)!;
             if (hasAudio) {
             self.subscribeStream?.pauseAudio = false
             }*/
            ALToastView.toast(in: self.view, withText:"Audio Unmuted")
            
            
        }else if (Int(statusCode) == Int(r5_status_video_mute.rawValue))
        {
            ////print("=======r5_status_video_mute")
            /*let hasAudio = !(self.subscribeStream?.pauseAudio)!;
             if (hasAudio) {
             self.subscribeStream?.pauseAudio = true
             }*/
            ALToastView.toast(in: self.view, withText:"Video Muted")
            
        }
        else if (Int(statusCode) == Int(r5_status_video_unmute.rawValue))
        {
            ////print("=======r5_status_video_unmute")
            /*let hasAudio = !(self.subscribeStream?.pauseAudio)!;
             if (hasAudio) {
             self.subscribeStream?.pauseAudio = false
             }*/
            ALToastView.toast(in: self.view, withText:"Video Unmuted")
            
        }
        else if (Int(statusCode) == Int(r5_status_disconnected.rawValue))
        {
            ////print("=======r5_status_disconnected")
            ALToastView.toast(in: self.view, withText:"Video Disconnected")
            
        }
        else if (Int(statusCode) == Int(r5_status_stop_streaming.rawValue))
        {
            ////print("=======r5_status_stop_streaming")
            ALToastView.toast(in: self.view, withText:"Stream Stopped")
        }
        else if ((Int(statusCode) == Int(r5_status_connection_close.rawValue))) {
            print("=======connection closed")
            self.showHLSVideo()
        }
        if(Int(statusCode) == Int(r5_status_connected.rawValue)){
            //showAlert(strMsg: "stream connected")
            /*if(isSharedScreen){
             SS_startup()
             }*/
            getGuestDetailInGraphql(.returnCacheDataAndFetch)//need to refresh stream
        }
    }
    //MARK: - Live Stream Methods end
    // MARK: Handler for getChannelSubscriptionPlans API
    func getChannelSubscriptionPlans(){
        let netAvailable = appDelegate.isConnectedToInternet()
        if(!netAvailable){
            showAlert(strMsg: "Please check your internet connection!")
            return
        }
        viewActivity.isHidden = false
        let url: String = appDelegate.FCMBaseURL +  "/getChannelSubscriptionPlans"
        let user_id = UserDefaults.standard.string(forKey: "user_id");
        //below line need to update
        let params: [String: Any] = ["user_id":user_id ?? "","channel_name":self.channel_name_subscription,"channel_url":self.channel_name_subscription]
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
                            //if event has subscription plan, then show subscription btn
                            if(arySubscriptions.count > 0){
                                let predicate = NSPredicate(format:"title == %@", "subscribe")
                                let filteredArray = (buttonNames as NSArray).filtered(using: predicate)
                                //ofr guest subscription should be hidden, this should comment/remove after this release
                                if(!appDelegate.isGuest){
                                    if(filteredArray.count == 0){
                                        let dicItem = ["title":"subscribe","icon":"s_subscribe","icon_active":"s_subscribe_active"]
                                        self.buttonNames.append(dicItem)
                                        self.streamHeaderCVC.reloadData()
                                        
                                    }
                                }
                               
                            }
                            self.tblSubscriptions.reloadData()
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
    // MARK: - Collection View Data Source
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return buttonNames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StreamHeaderCVC",for: indexPath) as? StreamHeaderCVC {
            let selectedObj = buttonNames[indexPath.row]
            let icon = selectedObj["icon"] ?? ""
            //cell.configureCell(name: name)
            cell.btn.setImage(UIImage.init(named: icon), for: .normal)
            cell.btn.addTarget(self, action: #selector(headerBtnPressed(_:)), for: .touchUpInside)
            cell.btn.tag = 10 + (indexPath.row);
            cell.lblBlink.tag = 100 + (indexPath.row)
            cell.lblBlink.isHidden = true
            //cell.lblLine.tag = 10 + (indexPath.row);
            //cell.btn.setTitleColor(.white, for: .normal)
            return cell
        }
        return UICollectionViewCell()
    }
    func refreshHeaderBtns(){
        for (index,_) in buttonNames.enumerated() {
            let btnTag = 10 + index;
            let blinkTag = 100 + index;

            let btn = self.streamHeaderCVC.viewWithTag(btnTag) as? UIButton
            
            let selectedObj = buttonNames[index]
            let title =  selectedObj["title"] ?? ""
            switch title {
            case "info":
                btn?.setImage(UIImage.init(named: "s_info"), for: .normal)
            case "share":
                btn?.setImage(UIImage.init(named: "s_share"), for: .normal)
            case "emoji":
                btn?.setImage(UIImage.init(named: "s_emoji"), for: .normal)
            case "donation":
                btn?.setImage(UIImage.init(named: "s_donation"), for: .normal)
            case "tip":
                btn?.setImage(UIImage.init(named: "s_tip"), for: .normal)
            case "chat":
                btn?.setImage(UIImage.init(named: "s_chat"), for: .normal)
            case "subscribe":
                btn?.setImage(UIImage.init(named: "s_subscribe"), for: .normal)
            case "qa":
                btn?.setImage(UIImage.init(named: "s_qa"), for: .normal)
            default:
                print("default")
            }
            
        }
    }
    @objc func headerBtnPressed(_ sender: UIButton) {
        //print("headerBtnPressed:",sender.tag)
        //streamHeaderCVC.reloadData()
        refreshHeaderBtns()
        isChatActive = false
        isQ_And_A_Active = false
        if(sender.tag - 10 <= buttonNames.count){
            let selectedObj = buttonNames[sender.tag - 10]
            let blinkTag = 100 + (sender.tag - 10)
            let title =  selectedObj["title"] ?? ""
            //print("title:",title)
            setBtnDefaultBG()
            viewRightTitle.isHidden = false
            switch title {
            case "info":
                lblRightTitle.text = "Info"
                sender.setImage(UIImage.init(named: "s_info_active"), for: .normal)
                viewInfo.isHidden = false
            case "share":
                //print("share")
                viewRightTitle.isHidden = true
                sender.setImage(UIImage.init(named: "s_share_active"), for: .normal)
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
            case "emoji":
                print("emoji")
                txtEmoji.becomeFirstResponder()
            case "donation":
                lblRightTitle.text = "Donations"
                sender.setImage(UIImage.init(named: "s_donation_active"), for: .normal)
                viewDonations.isHidden = false
            case "tip":
                viewRightTitle.isHidden = true
                sender.setImage(UIImage.init(named: "s_tip_active"), for: .normal)
                proceedToPayment(type: "performer_tip",charityId: 0)
            case "chat":
                lblRightTitle.text = "Chat"
                sender.setImage(UIImage.init(named: "s_chat_active"), for: .normal)
                viewComments.isHidden = false
                let lblBlink = self.streamHeaderCVC.viewWithTag(blinkTag) as? UILabel
                lblBlink?.isHidden = true
                isChatActive = true
            case "subscribe":
                lblRightTitle.text = "Subscriptions"
                sender.setImage(UIImage.init(named: "s_subscribe_active"), for: .normal)
                viewSubscriptions.isHidden = false
            case "qa":
                lblRightTitle.text = "Q&A"
                sender.setImage(UIImage.init(named: "s_qa_active"), for: .normal)
                view_Q_And_A.isHidden = false
                loadPrevious_Q_And_A(initial: true)
                let lblBlink = self.streamHeaderCVC.viewWithTag(blinkTag) as? UILabel
                lblBlink?.isHidden = true
                isQ_And_A_Active = true
            default:
                print("default")
            }
        }
    }
}



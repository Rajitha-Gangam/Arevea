//
//  SubscribeTwoStreams.swift
//  R5ProTestbed
//
//  Created by David Heimann on 3/14/16.
//  Copyright © 2015 Infrared5, Inc. All rights reserved.
//
//  The accompanying code comprising examples for use solely in conjunction with Red5 Pro (the "Example Code")
//  is  licensed  to  you  by  Infrared5  Inc.  in  consideration  of  your  agreement  to  the  following
//  license terms  and  conditions.  Access,  use,  modification,  or  redistribution  of  the  accompanying
//  code  constitutes your acceptance of the following license terms and conditions.
//
//  Permission is hereby granted, free of charge, to you to use the Example Code and associated documentation
//  files (collectively, the "Software") without restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit
//  persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The Software shall be used solely in conjunction with Red5 Pro. Red5 Pro is licensed under a separate end
//  user  license  agreement  (the  "EULA"),  which  must  be  executed  with  Infrared5,  Inc.
//  An  example  of  the EULA can be found on our website at: https://account.red5pro.com/assets/LICENSE.txt.
//
//  The above copyright notice and this license shall be included in all copies or portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,  INCLUDING  BUT
//  NOT  LIMITED  TO  THE  WARRANTIES  OF  MERCHANTABILITY, FITNESS  FOR  A  PARTICULAR  PURPOSE  AND
//  NONINFRINGEMENT.   IN  NO  EVENT  SHALL INFRARED5, INC. BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN  AN  ACTION  OF  CONTRACT,  TORT  OR  OTHERWISE,  ARISING  FROM,  OUT  OF  OR  IN CONNECTION
//  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

//

import UIKit
import R5Streaming
import Alamofire
import AWSAppSync
import SendBirdSDK
import  WebKit
import Reachability

@objc(SubscribeTwoStreams)
class SubscribeTwoStreams: UIViewController , R5StreamDelegate, UITableViewDelegate,UITableViewDataSource,OpenChanannelChatDelegate,OpenChannelMessageTableViewCellDelegate,AGEmojiKeyboardViewDelegate,SBDChannelDelegate, AGEmojiKeyboardViewDataSource,UITextFieldDelegate,UIPickerViewDelegate, UIPickerViewDataSource,UIWebViewDelegate {
    // MARK: - Variables Declaration
    
    @IBOutlet weak var view1: UIView?
    @IBOutlet weak var view2: UIView?
    @IBOutlet weak var view3: UIView?
    @IBOutlet weak var view4: UIView?
    @IBOutlet weak var viewOverlay: UIView?
    @IBOutlet weak var viewActions: UIView?
    @IBOutlet weak var viewControls: UIView?
    
    @IBOutlet weak var tblComments: UITableView!
    var aryStreamInfo = [String: Any]()
    var aryUserSubscriptionInfo = [Any]()
    
    var subscribeStream1 : R5Stream? = nil
    var subscribeStream2 : R5Stream? = nil
    var subscribeStream3 : R5Stream? = nil
    var subscribeStream4 : R5Stream? = nil
    
    var appSyncClient: AWSAppSyncClient?
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var superIndex = 0
    @IBOutlet weak var heightTopView: NSLayoutConstraint?
    @IBOutlet weak var viewTop: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var viewActivity: UIView!
    @IBOutlet weak var viewStream: UIView!
    var streamlist = [[String:Any]]()
    var duplicateStreamList = [[String:Any]]()
    var offlineStream = [[String:Any]]()
    var strTitle = ""
    @IBOutlet weak var btnInfo: UIView!
    
    @IBOutlet weak var btnShare: UIView!
    @IBOutlet weak var btnTips: UIView!
    @IBOutlet weak var btnDonations: UIView!
    @IBOutlet weak var btnEmoji: UIView!
    @IBOutlet weak var btnChat: UIView!
    
    @IBOutlet weak var viewTips: UIView!
    @IBOutlet weak var viewDonations: UIView!
    @IBOutlet weak var viewEmoji: UIView!
    @IBOutlet weak var viewComments: UIView!
    
    @IBOutlet weak var heightFirstView: NSLayoutConstraint?
    @IBOutlet weak var heightSecondView: NSLayoutConstraint?
    @IBOutlet weak var heightThirdView: NSLayoutConstraint?
    @IBOutlet weak var heightFourthView: NSLayoutConstraint?
    
    @IBOutlet weak var widthFirstView: NSLayoutConstraint?
    @IBOutlet weak var widthSecondView: NSLayoutConstraint?
    @IBOutlet weak var widthThirdView: NSLayoutConstraint?
    @IBOutlet weak var widthFourthView: NSLayoutConstraint?
    
    @IBOutlet weak var lblNoStream1 :UILabel!
    @IBOutlet weak var lblNoStream2 :UILabel!
    @IBOutlet weak var lblNoStream3 :UILabel!
    @IBOutlet weak var lblNoStream4 :UILabel!
    
    var resultData = [String:Any]()
    @IBOutlet weak var tblDonations: UITableView!
    var aryCharityInfo = [Any]()
    @IBOutlet weak var lblNoDataDonations: UILabel!
    @IBOutlet weak var lblNoDataTips: UILabel!
    @IBOutlet weak var lblStreamUnavailable: UILabel!
    @IBOutlet weak var viewTipsCreators: UIView!
    @IBOutlet weak var viewInfo: UIView!
    @IBOutlet weak var btnPlayStream: UIButton!
    
    var orgId = 0;
    var performerId = 0;
    var streamId = 0;
    var streamVideoCode = ""
    var isChannelAvailable = false;
    var isChannelAvailable_emoji = false;
    var sendBirdErrorCode = 0;
    var sendBirdErrorCode_Emoji = 0;
    var sbdError = SBDError()
    var sbdError_emoji = SBDError()
    var txtTopOfToolBar : UITextField!
    
    @IBOutlet weak var imgEmoji: UIImageView!
    var channelName = ""
    var channelName_Emoji = ""
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
    @IBOutlet weak var lblNoDataComments: UILabel!
    @IBOutlet weak var txtEmoji: UITextField!
    @IBOutlet weak var txtComment: UITextField!
    @IBOutlet weak var sendUserMessageButton: UIButton!
    
    @IBOutlet weak var btnAudio: UIButton!
    @IBOutlet weak var btnVideo: UIButton!
    @IBOutlet weak var sliderVolume: UISlider!
    let pickerView = UIPickerView()
    var pickerData =  [String:Any]();
    var stream_status = ""
    @IBOutlet weak var txtTipCreator: UITextField!
    var selectedCreatorForTip = -1
    var newCommentsSubscriptionWatcher: AWSAppSyncSubscriptionWatcher<OnUpdateMulticreatorshareddataSubscription>?
    var startSessionResponse =  [String:Any]()
    var isViewerCountcall = 0;
    var isStreamStarted = false
    @IBOutlet weak var txtVideoDesc_Info: UITextView!
    var app_id_for_adds = ""
    @IBOutlet weak var webView: WKWebView!
    var publisherIsInBackground = false
    var publisherIsDisconnected = false
    @IBOutlet weak var lblLive: UILabel!
    @IBOutlet weak var imgStreamThumbNail: UIImageView!
    var timer : Timer?
    var timerNet : Timer?
    var aryTipGuestList = [Any]()
    
    //declare this property where it won't go out of scope relative to your listener
    var isNetConnected = false
    @IBOutlet weak var lblNetStatus: UILabel!
    var reachability: Reachability!
    var strSlug = "";

    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        appSyncClient = appDelegate.appSyncClient
        
        print("resultData:",resultData)
        btnInfo?.layer.borderWidth = 2
        btnShare?.layer.borderWidth = 2
        btnTips?.layer.borderWidth = 2
        btnDonations?.layer.borderWidth = 2
        btnEmoji?.layer.borderWidth = 2
        btnChat?.layer.borderWidth = 2
        
        
        
        lblTitle.text = strTitle
        viewActivity.isHidden = true
        
        tblDonations.register(UINib(nibName: "CharityCell", bundle: nil), forCellReuseIdentifier: "CharityCell")
        tblComments.register(UINib(nibName: "OpenChannelUserMessageTableViewCell", bundle: nil), forCellReuseIdentifier: "OpenChannelUserMessageTableViewCell")
        
        let charity_info = resultData["charity_info"] != nil
        if(charity_info){
            self.aryCharityInfo = resultData["charity_info"] as? [Any] ?? [Any]()
            self.tblDonations.reloadData()
        }
        self.aryStreamInfo = resultData["stream_info"] as? [String:Any] ?? [:]
        let stream_info_key_exists = self.aryStreamInfo["id"]
        if (stream_info_key_exists != nil){
            self.streamId = aryStreamInfo["id"] as? Int ?? 0
            self.streamVideoCode = aryStreamInfo["stream_video_code"] as? String ?? ""
            self.strSlug = aryStreamInfo["slug"] as? String ?? "";

            self.isChannelAvailable = true
            self.sendBirdChatConfig()
            self.sendBirdEmojiConfig()
        }
        let streamVideoDesc = aryStreamInfo["stream_video_description"] as? String ?? ""
        var  performerName = ""
        let performer_info = resultData["performer_info"] != nil
        if(performer_info){
            let dicPerformerInfo = resultData["performer_info"] as? [String : Any] ?? [String:Any]()
            performerName = dicPerformerInfo["performer_display_name"] as? String ?? ""
            self.app_id_for_adds = dicPerformerInfo["app_id"] as? String ?? "0"
            
        }
        let tipGuestList1 = resultData["guestList"] != nil
        print("===tipGuestList1:",tipGuestList1)
        if(tipGuestList1){
            aryTipGuestList = resultData["guestList"] as? [Any] ?? [Any]()
            print("aryTipGuestList:",aryTipGuestList)
        }
        let creatorName = "Creator Name: " + performerName;
        self.txtVideoDesc_Info.text = streamVideoDesc  + "\n\n" + creatorName
        //let creators = aryStreamInfo["creators"] as? String ?? ""
        
        
        sliderVolume.minimumValue = 0
        sliderVolume.maximumValue = 100
        let emojiKeyboardView = AGEmojiKeyboardView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 216), dataSource: self)
        emojiKeyboardView?.autoresizingMask = UIView.AutoresizingMask.flexibleHeight
        emojiKeyboardView?.delegate = self
        txtEmoji.inputView = emojiKeyboardView
        txtEmoji.tintColor = UIColor.clear
        txtEmoji.addTarget(self, action: #selector(txtEmojiTap), for: .touchDown)
        imgEmoji.isHidden = true
        addDoneButton()
        addDoneButton1()
        setBtnDefaultBG()
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
        
        pickerView.delegate = self
        
        tblComments.rowHeight = 40
        tblComments.estimatedRowHeight = UITableView.automaticDimension
        lblLive.isHidden = true
        lblStreamUnavailable.text = "Please wait for the host to start the live stream."
        lblNoDataComments.text = ""
        if(UIDevice.current.userInterfaceIdiom == .pad){
            self.imgStreamThumbNail.image = UIImage.init(named: "sample-event")
        }else{
            self.imgStreamThumbNail.image = UIImage.init(named: "sample_vod_square")
        }
        let streamBannerURL = aryStreamInfo["video_banner_image"] as? String ?? ""
        if let urlBanner = URL(string: streamBannerURL){
            var imageName = "sample_vod_square"
            if(UIDevice.current.userInterfaceIdiom == .pad){
                imageName = "sample-event"
            }
            self.imgStreamThumbNail.sd_setImage(with:urlBanner, placeholderImage: UIImage(named: imageName))
        }
        do {
            try startSubscription()
        } catch {
            print("Error subscribing to events: \(error)")
        }
        self.viewControls?.isHidden = true
        self.lblStreamUnavailable.isHidden = false
        self.btnPlayStream.isHidden = false
        btnAudio?.setImage(UIImage.init(named: "unmute"), for: .normal);
        btnVideo?.setImage(UIImage.init(named: "pause"), for: .normal);
        reachability = try! Reachability()
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged),name: Notification.Name.reachabilityChanged, object: nil)
        do {
            try reachability!.startNotifier()
        } catch {
            print("could not start reachability notifier")
        }
        
        lblNetStatus.isHidden = true
        stream_status = aryStreamInfo["stream_status"] as? String ?? ""
        print("====stream_status:",stream_status)
        AWSDDLog.sharedInstance.logLevel = .verbose

        if (stream_status == "completed"){
            self.lblLive.isHidden = true
            self.viewControls?.isHidden = true
            self.lblStreamUnavailable.text = "The stream has ended."
            self.lblStreamUnavailable.isHidden = false
            self.btnPlayStream.isHidden = false
        }else{
            getGuestDetailInGraphql(.returnCacheDataAndFetch)
        }
    }
    
    @objc func repeatNetMethod(){
        let netAvailable = appDelegate.isConnectedToInternet()
        //print("----repeatNetMethod")
        if(isStreamStarted){
            if(netAvailable){
                if(!isNetConnected){
                    //print("----online")
                    isNetConnected = true
                    self.lblNetStatus.isHidden = false
                    let green = UIColor.init(red: 34, green: 139, blue: 34)
                    lblNetStatus.backgroundColor = green
                    lblNetStatus.text = "Back to online"
                    getGuestDetailInGraphql(.returnCacheDataAndFetch)//need to refresh stream
                    /*delayWithSeconds(10.0){
                        self.lblNetStatus.isHidden = true
                    }*/
                }
            }else{
                if(isNetConnected){
                   // print("----offline")
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
        print("--reachabilityChanged")
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
        btnInfo?.layer.borderColor = UIColor.black.cgColor
        btnShare?.layer.borderColor = UIColor.black.cgColor
        btnTips?.layer.borderColor = UIColor.black.cgColor
        btnDonations?.layer.borderColor = UIColor.black.cgColor
        btnEmoji?.layer.borderColor = UIColor.black.cgColor
        btnChat?.layer.borderColor = UIColor.black.cgColor
        viewDonations.isHidden = true
        viewComments.isHidden = true
        viewTips.isHidden = true
        viewInfo.isHidden = true
        txtComment.resignFirstResponder()
        txtTopOfToolBar.resignFirstResponder()
        txtEmoji.resignFirstResponder()
    }
    @objc func resignKB(_ sender: Any) {
        txtTopOfToolBar.text = ""
        txtComment.text = ""
        txtComment.resignFirstResponder();
        txtTopOfToolBar.resignFirstResponder()
        txtEmoji.resignFirstResponder()
        txtTipCreator.resignFirstResponder()
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
        txtTipCreator.inputAccessoryView = toolbar
        txtTipCreator.inputView = pickerView
        
    }
    
    func cleanup () {
        if( self.subscribeStream1 != nil ) {
            self.subscribeStream1!.client = nil
            self.subscribeStream1?.delegate = nil
            self.subscribeStream1 = nil
        }
        if( self.subscribeStream2 != nil ) {
            self.subscribeStream2!.client = nil
            self.subscribeStream2?.delegate = nil
            self.subscribeStream2 = nil
        }
        if( self.subscribeStream3 != nil ) {
            self.subscribeStream3!.client = nil
            self.subscribeStream3?.delegate = nil
            self.subscribeStream3 = nil
        }
        if( self.subscribeStream4 != nil ) {
            self.subscribeStream4!.client = nil
            self.subscribeStream4?.delegate = nil
            self.subscribeStream4 = nil
        }
        self.removeFromParent()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addOverLay1()
        
    }
    
    func onR5StreamStatus(_ stream: R5Stream!, withStatus statusCode: Int32, withMessage msg: String!) {
        //super.onR5StreamStatus(stream, withStatus: statusCode, withMessage: msg)
        //        if( Int(statusCode) == Int(r5_status_start_streaming.rawValue) ){
        //            let session : AVAudioSession = AVAudioSession.sharedInstance()
        //            let cat = session.category
        //            let opt = session.categoryOptions
        //            let s =  String(format: "AV: %@ (%d)",  cat.rawValue, opt.rawValue)
        //            ALToastView.toast(in: self.view, withText:s)
        //        }
        //
        //        if( Int(statusCode) == Int(r5_status_video_render_start.rawValue) ){
        //            let f = Int(stream.getFormat().rawValue)
        //            let s =  String(format: "Video Format: (%d)", f)
        //            ALToastView.toast(in: self.view, withText:s)
        //        }
        // MARK: Customising
        
        NSLog("Status: %s ", r5_string_for_status(statusCode))
        let s =  String(format: "Status: %s (%@)",  r5_string_for_status(statusCode), msg)
        //ALToastView.toast(in: self.view, withText:s)
        print("net status",r5_status_netstatus.rawValue)
        if (Int(statusCode) == Int(r5_status_disconnected.rawValue)) {
            //self.cleanup()
            //ALToastView.toast(in: self.view, withText:"Video Disconnected")
        } else if ((Int(statusCode) == Int(r5_status_netstatus.rawValue) && msg == "NetStream.Play.UnpublishNotify") || ((Int(statusCode) == Int(r5_status_netstatus.rawValue) && msg == "NetStream.Play.StreamDry"))){
            //self.lblStreamUnavailable.text = "Video Disconnected"
            
        } else if ((Int(statusCode) == Int(r5_status_netstatus.rawValue) && msg == "NetStream.Play.SufficientBW")) {
            //print("=======sufficient band Width")
        }else if ((Int(statusCode) == Int(r5_status_netstatus.rawValue) && msg == "NetStream.Play.InSufficientBW")) {
            ALToastView.toast(in: self.view, withText:"Poor internet connection")
        }else if (Int(statusCode) == Int(r5_status_audio_mute.rawValue))
        {
            //print("=======r5_status_audio_mute")
            /*let hasAudio = !(self.subscribeStream?.pauseAudio)!;
             if (hasAudio) {
             self.subscribeStream?.pauseAudio = true
             }*/
            ALToastView.toast(in: self.view, withText:"Audio Muted")
            
        }
        else if (Int(statusCode) == Int(r5_status_audio_unmute.rawValue))
        {
            //print("=======r5_status_audio_unmute")
            /*let hasAudio = !(self.subscribeStream?.pauseAudio)!;
             if (hasAudio) {
             self.subscribeStream?.pauseAudio = false
             }*/
            ALToastView.toast(in: self.view, withText:"Audio Unmuted")
            
            
        }else if (Int(statusCode) == Int(r5_status_video_mute.rawValue))
        {
            //print("=======r5_status_video_mute")
            /*let hasAudio = !(self.subscribeStream?.pauseAudio)!;
             if (hasAudio) {
             self.subscribeStream?.pauseAudio = true
             }*/
            ALToastView.toast(in: self.view, withText:"Video Muted")
            
        }
        else if (Int(statusCode) == Int(r5_status_video_unmute.rawValue))
        {
            //print("=======r5_status_video_unmute")
            /*let hasAudio = !(self.subscribeStream?.pauseAudio)!;
             if (hasAudio) {
             self.subscribeStream?.pauseAudio = false
             }*/
            ALToastView.toast(in: self.view, withText:"Video Unmuted")
            
        }
        else if (Int(statusCode) == Int(r5_status_disconnected.rawValue))
        {
            //print("=======r5_status_disconnected")
            //ALToastView.toast(in: self.view, withText:"Video Disconnected")
            
        }
        else if (Int(statusCode) == Int(r5_status_stop_streaming.rawValue))
        {
            //print("=======r5_status_stop_streaming")
            ALToastView.toast(in: self.view, withText:"Stream Stopped")
        }
    }
    @objc func onMetaData(data : String){
        
    }
    @objc func repeatMethod(){
        print("====repeatMethod")
        if(!publisherIsDisconnected){
            getGuestDetailInGraphql(.returnCacheDataAndFetch)
        }
    }
    func getGuestDetailInGraphql(_ cachePolicy: CachePolicy) {
        print("====streamVideoCode:",streamVideoCode)
        viewActivity.isHidden = false
        
        let listQuery = GetMulticreatorshareddataQuery(id:streamVideoCode)
        //1872_1595845007395_mc2
        //58_1594894849561_multi_creator_test_event
        
        appSyncClient?.fetch(query: listQuery, cachePolicy: cachePolicy) { result, error in
            self.viewActivity.isHidden = true
            
            if let error = error {
                print("Error fetching data: \(error)")
                return
            }
            
            // print("--result:",result)
            if((result != nil)  && (result?.data != nil)){
                // print("--data:",result?.data)
                let data = result?.data
                let multiData = data?.getMulticreatorshareddata
                if(multiData != nil){
                    let multiDataJSON = self.convertToDictionary(text: multiData?.data ?? "")
                    let guestList = multiDataJSON?["guestList"] as? [Any] ?? [Any]() ;
                    
                    print("guestList:",guestList)
                    print("duplicateStreamList:",self.duplicateStreamList)
                    
                    print("guestList count:",guestList.count)
                    self.streamlist = [[String:Any]]()
                    self.offlineStream = [[String:Any]]()
                    for (index,_) in guestList.enumerated() {
                        if (index < 4){
                            let guest = guestList[index] as! [String:Any]
                            let onlineStatus = guest["onlineStatus"] as? Bool ?? false
                            let liveStatus = guest["liveStatus"] as? Bool ?? false
                            let useVideo = guest["useVideo"]as? Bool ?? false
                            //it should uncomment when subscribe issue resolved
                            if(onlineStatus && liveStatus && useVideo) {
                                self.streamlist.append(guest)
                            } else {
                                self.offlineStream.append(guest)
                            }
                            //self.streamlist.append(guest)
                        }
                    }
                    //print("streamlist:",self.streamlist)
                    //print("duplicateStreamList:",self.duplicateStreamList)
                    
                    var equal = false
                    if (self.streamlist as AnyObject).isEqual(self.duplicateStreamList as AnyObject) {
                        equal = true
                    }
                    //to avid may times API calling, we are checking, prev obj and current obj are same or not.
                    if(self.streamlist.count > 0 && !equal){
                        print("Not equal")
                        self.pickerView.reloadComponent(0)//for load creators for Tip
                        self.findStream()
                    }else{
                        print("equal")
                        if(self.streamlist.count > 0){
                            self.lblStreamUnavailable.isHidden = true
                            self.btnPlayStream.isHidden = true
                        }else{
                            self.lblStreamUnavailable.isHidden = false
                            self.btnPlayStream.isHidden = false
                            
                            if(self.isStreamStarted || self.stream_status == "completed"){
                                self.lblLive.isHidden = true
                                self.viewControls?.isHidden = true
                                //self.lblStreamUnavailable.text = "publisher has unpublished/paused video. Please try again later."
                                self.lblStreamUnavailable.text = "The stream has ended."
                                if (self.timer != nil)
                                {
                                    print("stoptimer executed")
                                    self.timer!.invalidate()
                                    self.timer = nil
                                }
                                
                            }else{
                                self.lblStreamUnavailable.text = "Please wait for the host to start the live stream"
                            }
                        }
                    }
                }else{
                    print("--getMulticreatorshareddata null")
                    
                    self.lblStreamUnavailable.isHidden = false
                    self.btnPlayStream.isHidden = false
                }
                self.duplicateStreamList = self.streamlist
            }
            // Remove existing records if we're either loading from cache, or loading fresh (e.g., from a refresh)
        }
    }
    @IBAction func playStream(_ sender: Any){
        print("playStream called")
        getGuestDetailInGraphql(.returnCacheDataAndFetch)
        
    }
    func startSubscription() throws {
        do{
            let subscriptionRequest = OnUpdateMulticreatorshareddataSubscription(id: streamVideoCode)
            newCommentsSubscriptionWatcher =
                try appSyncClient?.subscribe(subscription: subscriptionRequest) { [weak self] result, transaction, error in
                    print("Received comment subscription callback on event \(self?.streamVideoCode)")
                    
                    guard let self = self else {
                        print("EventDetails view controller has been deallocated since subscription was started, aborting")
                        return
                    }
                    
                    guard error == nil else {
                        print("Error in comment subscription for event \(self.streamVideoCode): \(error!.localizedDescription)")
                        return
                    }
                    
                    guard let result = result else {
                        print("Result unexpectedly nil in comment subscription for event \(self.streamVideoCode)")
                        return
                    }
                    
            }
        }
        catch {
            print (error.localizedDescription)
        }
        
        
        
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
    func adjustViews(){
        let count = streamlist.count
        switch count {
        case 0:
            view1?.isHidden = true
            view2?.isHidden = true
            view3?.isHidden = true
            view4?.isHidden = true
        case 1:
            view1?.isHidden = false
            view2?.isHidden = true
            view3?.isHidden = true
            view4?.isHidden = true
            NSLayoutConstraint.setMultiplier(1.0, of: &(widthFirstView)!)
            NSLayoutConstraint.setMultiplier(1.0, of: &(heightFirstView)!)
            NSLayoutConstraint.setMultiplier(0.0, of: &(widthSecondView)!)
            NSLayoutConstraint.setMultiplier(0.0, of: &(heightSecondView)!)
            NSLayoutConstraint.setMultiplier(0.0, of: &(widthThirdView)!)
            NSLayoutConstraint.setMultiplier(0.0, of: &(heightThirdView)!)
            NSLayoutConstraint.setMultiplier(0.0, of: &(widthFourthView)!)
            NSLayoutConstraint.setMultiplier(0.0, of: &(heightFourthView)!)
        case 2:
            view1?.isHidden = false
            view2?.isHidden = false
            view3?.isHidden = true
            view4?.isHidden = true
            NSLayoutConstraint.setMultiplier(0.5, of: &(widthFirstView)!)
            NSLayoutConstraint.setMultiplier(1.0, of: &(heightFirstView)!)
            NSLayoutConstraint.setMultiplier(0.5, of: &(widthSecondView)!)
            NSLayoutConstraint.setMultiplier(1.0, of: &(heightSecondView)!)
            NSLayoutConstraint.setMultiplier(0.0, of: &(widthThirdView)!)
            NSLayoutConstraint.setMultiplier(0.0, of: &(heightThirdView)!)
            NSLayoutConstraint.setMultiplier(0.0, of: &(widthFourthView)!)
            NSLayoutConstraint.setMultiplier(0.0, of: &(heightFourthView)!)
        case 3:
            view1?.isHidden = false
            view2?.isHidden = false
            view3?.isHidden = false
            view4?.isHidden = true
            NSLayoutConstraint.setMultiplier(0.5, of: &(widthFirstView)!)
            NSLayoutConstraint.setMultiplier(0.5, of: &(heightFirstView)!)
            NSLayoutConstraint.setMultiplier(0.5, of: &(widthSecondView)!)
            NSLayoutConstraint.setMultiplier(0.5, of: &(heightSecondView)!)
            NSLayoutConstraint.setMultiplier(0.5, of: &(widthThirdView)!)
            NSLayoutConstraint.setMultiplier(0.5, of: &(heightThirdView)!)
            NSLayoutConstraint.setMultiplier(0.0, of: &(widthFourthView)!)
            NSLayoutConstraint.setMultiplier(0.0, of: &(heightFourthView)!)
        case 4:
            view1?.isHidden = false
            view2?.isHidden = false
            view3?.isHidden = false
            view4?.isHidden = false
            
            NSLayoutConstraint.setMultiplier(0.5, of: &(widthFirstView)!)
            NSLayoutConstraint.setMultiplier(0.5, of: &(heightFirstView)!)
            NSLayoutConstraint.setMultiplier(0.5, of: &(widthSecondView)!)
            NSLayoutConstraint.setMultiplier(0.5, of: &(heightSecondView)!)
            NSLayoutConstraint.setMultiplier(0.5, of: &(widthThirdView)!)
            NSLayoutConstraint.setMultiplier(0.5, of: &(heightThirdView)!)
            NSLayoutConstraint.setMultiplier(0.5, of: &(widthFourthView)!)
            NSLayoutConstraint.setMultiplier(0.5, of: &(heightFourthView)!)
        default:
            print("default")
        }
        self.view1!.layoutIfNeeded()
        self.view2!.layoutIfNeeded()
        self.view3!.layoutIfNeeded()
        self.view4!.layoutIfNeeded()
        self.viewStream!.layoutIfNeeded()
        //        print("view1 frame:",view1?.frame)
        //        print("view2 frame:",view2?.frame)
        //        print("view3 frame:",view3?.frame)
        //        print("view4 frame:",view4?.frame)
        
        
    }
    func findStream( ){
        adjustViews()
        var errorCount = 0
        for(index,_) in streamlist.enumerated(){
            let guest = streamlist[index]
            let streamName = guest["auth_code"] as? String ?? ""
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
            
            print("url:",url)
            //let url = "https://livestream.arevea.tv/streammanager/api/4.0/event/live/1588788669277_somethingnew?action=subscribe"
            //print("findStream url:",url)
            //let stream = "1588832196500_taylorswiftevent"
            
            AF.request(url,method: .get, encoding: JSONEncoding.default)
                .responseJSON { response in
                    switch response.result {
                    case .success(let value):
                        DispatchQueue.main.async {
                            //print(value)
                        }
                        if let json = value as? [String: Any] {
                            if json["errorMessage"] != nil{
                                let errorMsg = json["errorMessage"]
                                //                                let tagView = 10*(index + 1)
                                //                                print("tagView1:",tagView)
                                //                                let superView = self.viewStream.viewWithTag(tagView)
                                //ALToastView.toast(in:self.view, withText:"Unable to locate stream. Broadcast has probably not started for this stream")
                                let userName = guest["full_name"] as? String ?? ""
                                let errorMsg1 = "Video streaming is currently unavailable for : " + userName
                                errorCount = errorCount + 1
                                if(index == 0){
                                   self.lblNoStream1.text = ""
                                }else if(index == 1){
                                   self.lblNoStream2.text = ""
                                }else if(index == 2){
                                   self.lblNoStream3.text = ""
                                }else if(index == 3){
                                   self.lblNoStream4.text = ""
                                }
                                // ALToastView.toast(in: superView, withText:errorMsg as? String ?? "")
                                // "Unable to locate stream. Broadcast has probably not started for this stream: " + streamName
                                print("errorMessage:",errorMsg)
                                //comment these two lines
                                
                            }else{
                                if(index == 0){
                                    self.lblNoStream1.text = ""
                                }else if(index == 1){
                                    self.lblNoStream2.text = ""
                                }else if(index == 2){
                                    self.lblNoStream3.text = ""
                                }else if(index == 3){
                                    self.lblNoStream4.text = ""
                                }
                                let serverAddress = json["serverAddress"] as? String ?? ""
                                print("serverAddress:",serverAddress)
                                self.lblLive.isHidden = false
                                self.lblStreamUnavailable.isHidden = true
                                self.btnPlayStream.isHidden = true
                                self.viewControls?.isHidden = false
                                
                                if(!self.isStreamStarted){
                                    self.isStreamStarted = true
                                    self.addOverLay()
                                    self.timer = Timer.scheduledTimer(timeInterval: 15.0, target: self, selector: #selector(self.repeatMethod), userInfo: nil, repeats: true)
                                    self.startSession()
                                }
                                self.config(url: serverAddress,stream:streamName,index: index)
                            }
                        }
                        
                    case .failure(let error):
                        print(error)
                    }
                    if (errorCount == self.streamlist.count){
                        print("====equal")
                        self.lblNoStream1.text = ""
                        self.lblNoStream2.text = ""
                        self.lblNoStream3.text = ""
                        self.lblNoStream4.text = ""
                        self.lblStreamUnavailable.isHidden = false
                        self.lblStreamUnavailable.text = "The stream has ended."
                        self.btnPlayStream.isHidden = false
                        
                        if (self.timer != nil)
                        {
                            print("stoptimer executed")
                            self.timer!.invalidate()
                            self.timer = nil
                        }
                        
                    }
            }
        }
        
    }
    func getConfig(url:String)->R5Configuration{
        // Set up the configuration
        let config = R5Configuration()
        let userName = Testbed.getParameter(param: "username") as! String
        let password = Testbed.getParameter(param: "password") as! String
        config.parameters = "username=" + userName + ";password=" + password + ";"
        config.host = url;//"livestream.arevea.tv";
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
    // MARK: - config
    func config(url:String,stream:String,index:Int){
        let streamInfo = ["Stream": "started"]
        NotificationCenter.default.post(name: .didReceiveStreamData, object: self, userInfo: streamInfo)
        let screenSize = self.viewStream.bounds.size
        let count = streamlist.count
        var width = CGFloat(0)
        var height = CGFloat(0)
        
        let firstView1 = getNewR5VideoViewController(rect: self.view1!.frame)
        print("index:",index)
        print("stream frame:",firstView1.view.frame)
        //self.addChild(firstView1)
        //view.addSubview((firstView1.view)!)
        let tagView = 10*(index + 1)
        print("tagView1:",tagView)
        let superView = self.viewStream.viewWithTag(tagView)
        superView?.layer.borderColor = UIColor.lightGray.cgColor
        superView?.layer.borderWidth = 1
        superView?.addSubview((firstView1.view)!)
        //self.viewStream.bringSubviewToFront(self.viewOverlay!)
        //self.viewOverlay?.backgroundColor = .green
        self.viewStream.bringSubviewToFront(self.webView)
        
        firstView1.showDebugInfo(false)
        //firstView1.view.center = center
        let config = getConfig(url: url)
        // Set up the connection and stream
        let connection = R5Connection(config: config)
        if(index == 0){
            subscribeStream1 = R5Stream(connection: connection)
            subscribeStream1!.delegate = self
            subscribeStream1?.client = self;
            firstView1.attach(subscribeStream1)
            subscribeStream1!.play(stream, withHardwareAcceleration:false)
            let guest = streamlist[index]
            let useAudio = guest["useAudio"] as? Bool ?? false
            /*if(!useAudio){
             if( self.subscribeStream1 != nil && self.subscribeStream1?.audioController != nil) {
             self.subscribeStream1?.audioController.volume = 0
             }
             }*/
            
        }else if(index == 1){
            subscribeStream2 = R5Stream(connection: connection)
            subscribeStream2!.delegate = self
            subscribeStream2?.client = self;
            firstView1.attach(subscribeStream2)
            subscribeStream2!.play(stream, withHardwareAcceleration:false)
            let guest = streamlist[index]
            let useAudio = guest["useAudio"] as? Bool ?? false
            /*if(!useAudio){
             if( self.subscribeStream2 != nil && self.subscribeStream2?.audioController != nil) {
             self.subscribeStream2?.audioController.volume = 0
             }
             }*/
        }else if(index == 2){
            subscribeStream3 = R5Stream(connection: connection)
            subscribeStream3!.delegate = self
            subscribeStream3?.client = self;
            firstView1.attach(subscribeStream3)
            subscribeStream3!.play(stream, withHardwareAcceleration:false)
            let guest = streamlist[index]
            let useAudio = guest["useAudio"] as? Bool ?? false
            /*if(!useAudio){
             if( self.subscribeStream3 != nil && self.subscribeStream3?.audioController != nil) {
             self.subscribeStream3?.audioController.volume = 0
             }
             }*/
        }else{
            subscribeStream4 = R5Stream(connection: connection)
            subscribeStream4!.delegate = self
            subscribeStream4?.client = self;
            firstView1.attach(subscribeStream4)
            subscribeStream4!.play(stream, withHardwareAcceleration:false)
            let guest = streamlist[index]
            let useAudio = guest["useAudio"] as? Bool ?? false
            /*if(!useAudio){
             if( self.subscribeStream4 != nil && self.subscribeStream4?.audioController != nil) {
             self.subscribeStream4?.audioController.volume = 0
             }
             }*/
        }
        
    }
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                //print(error.localizedDescription)
            }
        }
        return nil
    }
    func closeStream(){
        if( self.subscribeStream1 != nil ){
            self.subscribeStream1!.stop()
        }
        if( self.subscribeStream2 != nil ){
            self.subscribeStream2!.stop()
        }
        if( self.subscribeStream3 != nil ){
            self.subscribeStream3!.stop()
        }
        if( self.subscribeStream4 != nil ){
            self.subscribeStream4!.stop()
        }
    }
    func popToDashBoard(){
        delayWithSeconds(0.5, completion: {
            print("vc:",self.navigationController!.viewControllers)
            for controller in self.navigationController!.viewControllers as Array {
                if controller.isKind(of: DashBoardVC.self) {
                    if(UIDevice.current.userInterfaceIdiom == .phone){
                        let value = UIInterfaceOrientation.portrait.rawValue
                        UIDevice.current.setValue(value, forKey: "orientation")
                    }
                    self.closeStream()
                    if(self.isStreamStarted){
                        self.endSession()
                    }
                    self.navigationController!.popToViewController(controller, animated: true)
                    break
                }
            }
        })
    }
    func showConfirmation(strMsg: String){
        let alert = UIAlertController(title: "Alert", message: strMsg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            self.popToDashBoard()
            
        }))
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
    @IBAction func back(_ sender: Any) {
        print("back called")
        if(isStreamStarted){
            showConfirmation(strMsg: "Are you sure you want to close the video?")
        }else{
            popToDashBoard()
        }
        
    }
    @IBAction func viewBGTap() {
        print("viewBGTap called")
        setBtnDefaultBG()
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent // .default
    }
    
    // MARK: - Button Actions
    @IBAction func tapInfo(){
        print("info")
        setBtnDefaultBG()
        let orange = UIColor.init(red: 255, green: 155, blue: 90)
        btnInfo?.layer.borderColor = orange.cgColor
        viewInfo.isHidden = false
    }
    @IBAction func tapShare(){
        print("share")
        setBtnDefaultBG()
        let orange = UIColor.init(red: 255, green: 155, blue: 90)
        btnShare?.layer.borderColor = orange.cgColor
        
        let url = appDelegate.websiteURL + "/event/" + self.strSlug
        print(url)
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
    @IBAction func tapTips(){
        print("tips")
        setBtnDefaultBG()
        let orange = UIColor.init(red: 255, green: 155, blue: 90)
        btnTips?.layer.borderColor = orange.cgColor
        viewTips.isHidden = false
        
        selectedCreatorForTip = -1
        pickerView.reloadComponent(0)
        txtTipCreator.text = ""
        if(streamlist.count == 0){
            viewTipsCreators.isHidden = true
            lblNoDataTips.isHidden = false
        }else{
            viewTipsCreators.isHidden = false
            lblNoDataTips.isHidden = true
        }
    }
    @IBAction func tapDonations(){
        print("donations")
        setBtnDefaultBG()
        let orange = UIColor.init(red: 255, green: 155, blue: 90)
        btnDonations?.layer.borderColor = orange.cgColor
        viewDonations.isHidden = false
    }
    @IBAction func tapEmoji(){
        print("emoji")
        setBtnDefaultBG()
        let orange = UIColor.init(red: 255, green: 155, blue: 90)
        btnEmoji?.layer.borderColor = orange.cgColor
    }
    @IBAction func tapChat(){
        print("chat")
        setBtnDefaultBG()
        let orange = UIColor.init(red: 255, green: 155, blue: 90)
        btnChat?.layer.borderColor = orange.cgColor
        viewComments.isHidden = false
        
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
    @IBAction func closeTips(){
        selectedCreatorForTip = -1
        pickerView.reloadComponent(0)
        txtTipCreator.text = ""
        viewTips.isHidden = true
        btnTips?.layer.borderColor = UIColor.black.cgColor
    }
    @IBAction func proceedTip(){
        if(selectedCreatorForTip == -1){
            showAlert(strMsg: "Please select creator")
        }else{
            let guestInfo = self.streamlist[selectedCreatorForTip]
            //let firstName = guestInfo["first_name"] as? String ?? ""
            var guestAuthCode = guestInfo["auth_code"]as? String ?? ""
            print("guestAuthCode:",guestAuthCode)
            print("aryTipGuestList:",aryTipGuestList)
            var guestId = 0
            var firstName = ""
            var lastName = ""
            for (index,e) in aryTipGuestList.enumerated(){
                let elemenet = aryTipGuestList[index] as? [String:Any] ?? [:]
                let auth = elemenet["auth_code"]as? String ?? ""
                if(auth ==  guestAuthCode){
                    guestId = elemenet["id"]as? Int ?? 0
                    firstName = elemenet["first_name"]as? String ?? ""
                    lastName = elemenet["last_name"]as? String ?? ""
                    print("equal and its id:",guestId)
                    break
                }
            }
            if(guestId != 0){
                guestAuthCode = String(guestId)
            }
            //let lastName = guestInfo["last_name"]as? String ?? ""
            //proceedToPayment(type: "performer_tip",charityId: 0)
            
            let user_id = UserDefaults.standard.string(forKey: "user_id");
            let strUserId = user_id ?? "1"
            var queryString = "stream_id=" + String(streamId) + "&user_id=" + strUserId//ppv
            queryString =  queryString + "&guest_id=" + guestAuthCode + "&guest_first_name=" + firstName + "&guest_last_name=" + lastName
            let urlOpen = appDelegate.paymentRedirectionURL + "/" + "performer_tip" + "?" + queryString
            guard let url = URL(string: urlOpen) else { return }
            print("url to open:",url)
            UIApplication.shared.open(url)
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
        tableView.deselectRow(at: indexPath, animated: true)
    }
    // MARK: Tip Methods
    @objc func payDonation(_ sender: UIButton) {
        let charity = self.aryCharityInfo[sender.tag] as? [String:Any]
        let charityId = charity?["id"] as? Int ?? 0
        proceedToPayment(type: "charity_donation",charityId:String(charityId))
        
    }
    func proceedToPayment(type:String,charityId:String){
        //let url: String = appDelegate.baseURL +  "/proceedToPayment"
        let user_id = UserDefaults.standard.string(forKey: "user_id");
        let strUserId = user_id ?? "1"
        var queryString = "stream_id=" + String(streamId) + "&user_id=" + strUserId//ppv
        if(type == "performer_tip"){
            queryString =  queryString + "&guest_id=" + charityId
        }else if(type == "charity_donation"){
            queryString = queryString + "&charity_id=" + charityId
        }
        let urlOpen = appDelegate.paymentRedirectionURL + "/" + type + "?" + queryString
        guard let url = URL(string: urlOpen) else { return }
        print("url to open:",url)
        UIApplication.shared.open(url)
    }
    
    // MARK: - Send Bird Methods
    func sendBirdChatConfig(){
        channelName = streamVideoCode
        //print("channelName in sendBirdChatConfig:",channelName)
        SBDOpenChannel.getWithUrl(channelName, completionHandler: { (openChannel, error) in
            guard error == nil else {   // Error.
                let errorDesc = "Chat Error:" + error!.localizedDescription
                //print("Send Bird Error:\(String(describing: error))")
                print(errorDesc)
                //self.sbdError = error ?? error?.localizedDescription as! SBDError
                self.sendBirdErrorCode = error?.code ?? 0
                //self.showAlert(strMsg:errorDesc )
                //print("sendBirdErrorCode:",sendBirdErrorCode)
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
        //print("channelName_Emoji in sendBirdChatConfig:",channelName_Emoji)
        SBDOpenChannel.getWithUrl(channelName_Emoji, completionHandler: { (openChannel, error) in
            guard error == nil else {   // Error.
                let errorDesc = "Chat Error:" + error!.localizedDescription
                //print("Send Bird Error:\(error!)")
                //print(errorDesc)
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
        print("msgs:",self.messages)
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
                            //print("self.emojis:",self.emojis)
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
                showAlert(strMsg: "Channel is not available, Please try again later.")
                //              showAlert(strMsg: "\(self.sbdError)")
            }
            return
        }
        
        print("channelName:",channelName)
        guard let channel = self.channel else {
            showAlert(strMsg: "Channel is not available, Please try again later.")
            return
        }
        print("channelName2:",self.channel?.name);
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
            //print("sendBirdErrorCode:",sendBirdErrorCode_Emoji)
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
        
        //print("channelName:",channelName_Emoji)
        guard let channel_emoji = self.channel_emoji else {
            showAlert(strMsg: "Channel is not available, Please try again later.")
            txtEmoji.resignFirstResponder()
            return
        }
        animateEmoji()
        //print("channel_emoji name:",self.channel_emoji?.name ?? "");
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
        print("currentRowNumber:",currentRowNumber)
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
        // //print("bug fr:",self.imgEmoji.frame)
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
    func delay(_ delay:Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }
    // MARK: Text Field Delegate Methods
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if(txtEmoji == textField){
        }
        
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
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
    // MARK: - Emoji Delegates
    //  Converted to Swift 5.2 by Swiftify v5.2.28138 - https://swiftify.com/
    @objc func txtEmojiTap(textField: UITextField) {
        setBtnDefaultBG()
        let orange = UIColor.init(red: 255, green: 155, blue: 90)
        btnEmoji?.layer.borderColor = orange.cgColor
    }
    func emojiKeyBoardView(_ emojiKeyBoardView: AGEmojiKeyboardView?, didUseEmoji emoji: String?) {
        imgEmoji.image = emoji?.image()
        sendEmoji(strEmoji: emoji ?? "")
        
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
    @IBAction func pauseAudio() {
        let imgBtn = btnAudio.image(for: .normal)
        if ((imgBtn?.isEqual(UIImage.init(named: "unmute")))!)
        {
            btnAudio?.setImage(UIImage.init(named: "mute"), for: .normal);
            if( self.subscribeStream1 != nil && self.subscribeStream1?.audioController != nil) {
                self.subscribeStream1?.audioController.volume = 0
                ALToastView.toast(in: self.view, withText:"Pausing Audio")
            }
            if( self.subscribeStream2 != nil && self.subscribeStream2?.audioController != nil) {
                self.subscribeStream2?.audioController.volume = 0
            }
            if( self.subscribeStream3 != nil && self.subscribeStream3?.audioController != nil) {
                self.subscribeStream3?.audioController.volume = 0
            }
            if( self.subscribeStream4 != nil && self.subscribeStream4?.audioController != nil) {
                self.subscribeStream4?.audioController.volume = 0
            }
        }
        else{
            btnAudio?.setImage(UIImage.init(named: "unmute"), for: .normal);
            if(self.subscribeStream1 != nil && self.subscribeStream1?.audioController != nil) {
                self.subscribeStream1?.audioController.volume = sliderVolume.value / 100
                ALToastView.toast(in: self.view, withText:"Playing Audio")
            }
            if(self.subscribeStream2 != nil && self.subscribeStream2?.audioController != nil) {
                self.subscribeStream2?.audioController.volume = sliderVolume.value / 100
            }
            if(self.subscribeStream3 != nil && self.subscribeStream3?.audioController != nil) {
                self.subscribeStream3?.audioController.volume = sliderVolume.value / 100
            }
            if(self.subscribeStream4 != nil && self.subscribeStream4?.audioController != nil) {
                self.subscribeStream4?.audioController.volume = sliderVolume.value / 100
            }
        }
    }
    @IBAction func pauseVideo() {
        
        let imgBtn = btnVideo?.image(for: .normal)
        if ((imgBtn?.isEqual(UIImage.init(named: "pause")))!)
        {
            btnVideo?.setImage(UIImage.init(named: "play"), for: .normal);
            if(self.subscribeStream1 != nil && self.subscribeStream1?.audioController != nil) {
                self.subscribeStream1?.audioController.volume = 0
            }
            if(self.subscribeStream1?.pauseVideo != nil){
                let hasVideo1 = !(self.subscribeStream1?.pauseVideo)!;
                if (hasVideo1) {
                    self.subscribeStream1?.pauseVideo = true
                    ALToastView.toast(in: self.view, withText:"Pausing Video")
                }
            }
            if(self.subscribeStream2 != nil && self.subscribeStream2?.audioController != nil) {
                self.subscribeStream2?.audioController.volume = 0
            }
            if(self.subscribeStream2?.pauseVideo != nil){
                let hasVideo1 = !(self.subscribeStream2?.pauseVideo)!;
                if (hasVideo1) {
                    self.subscribeStream2?.pauseVideo = true
                }
            }
            if(self.subscribeStream3 != nil && self.subscribeStream3?.audioController != nil) {
                self.subscribeStream3?.audioController.volume = 0
            }
            if(self.subscribeStream3?.pauseVideo != nil){
                let hasVideo1 = !(self.subscribeStream3?.pauseVideo)!;
                if (hasVideo1) {
                    self.subscribeStream3?.pauseVideo = true
                }
            }
            if(self.subscribeStream4 != nil && self.subscribeStream4?.audioController != nil) {
                self.subscribeStream4?.audioController.volume = 0
            }
            if(self.subscribeStream4?.pauseVideo != nil){
                let hasVideo1 = !(self.subscribeStream4?.pauseVideo)!;
                if (hasVideo1) {
                    self.subscribeStream4?.pauseVideo = true
                }
            }
            
            
        }
        else{
            btnVideo?.setImage(UIImage.init(named: "pause"), for: .normal);
            if(self.subscribeStream1 != nil && self.subscribeStream1?.audioController != nil) {
                self.subscribeStream1?.audioController.volume = sliderVolume.value / 100
            }
            if(self.subscribeStream1?.pauseVideo != nil){
                let hasVideo1 = !(self.subscribeStream1?.pauseVideo)!;
                if (hasVideo1) {
                    self.subscribeStream1?.pauseVideo = false
                    ALToastView.toast(in: self.view, withText:"Playing Video")
                }
            }
            
            if(self.subscribeStream2 != nil && self.subscribeStream2?.audioController != nil) {
                self.subscribeStream2?.audioController.volume = sliderVolume.value / 100
            }
            if(self.subscribeStream2?.pauseVideo != nil){
                let hasVideo1 = !(self.subscribeStream2?.pauseVideo)!;
                if (hasVideo1) {
                    self.subscribeStream2?.pauseVideo = false
                }
            }
            if(self.subscribeStream3 != nil && self.subscribeStream3?.audioController != nil) {
                self.subscribeStream3?.audioController.volume = sliderVolume.value / 100
            }
            if(self.subscribeStream3?.pauseVideo != nil){
                let hasVideo1 = !(self.subscribeStream3?.pauseVideo)!;
                if (hasVideo1) {
                    self.subscribeStream3?.pauseVideo = false
                }
            }
            if(self.subscribeStream4 != nil && self.subscribeStream4?.audioController != nil) {
                self.subscribeStream4?.audioController.volume = sliderVolume.value / 100
            }
            if(self.subscribeStream4?.pauseVideo != nil){
                let hasVideo1 = !(self.subscribeStream4?.pauseVideo)!;
                if (hasVideo1) {
                    self.subscribeStream4?.pauseVideo = false
                }
            }
        }
    }
    
    @IBAction func sliderValueDidChange() {
        if(self.subscribeStream1 != nil && self.subscribeStream1?.audioController != nil){
            self.subscribeStream1?.audioController.volume = sliderVolume.value / 100
        }
        if(self.subscribeStream2 != nil && self.subscribeStream2?.audioController != nil){
            self.subscribeStream2?.audioController.volume = sliderVolume.value / 100
        }
        if(self.subscribeStream3 != nil && self.subscribeStream3?.audioController != nil){
            self.subscribeStream3?.audioController.volume = sliderVolume.value / 100
        }
        if(self.subscribeStream4 != nil && self.subscribeStream4?.audioController != nil){
            self.subscribeStream4?.audioController.volume = sliderVolume.value / 100
        }
    }
    // MARK: Picker DataSource & Delegate Methods
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.streamlist.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let selectedObj = self.streamlist[row]
        let name = selectedObj["full_name"] as? String ?? ""
        return name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedObj = self.streamlist[row]
        let name = selectedObj["full_name"] as? String ?? ""
        txtTipCreator.text = name
        selectedCreatorForTip = row
    }
    func addOverLay(){
        let htmlString = "<html>\n" +
            "<body style='margin:0;padding:0;background:transparent;'>\n" +
            "<iframe width=\"100%\" height=\"100%\" src=\"https://app.singular.live/appinstances/" + self.app_id_for_adds + "/outputs/Output/onair\" frameborder=\"0\" allow=\"accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture\" allowfullscreen>\n" +
            "</iframe>\n" +
            "</body>\n" +
        "</html>";
        print("htmlString:",htmlString)
        self.webView.loadHTMLString(htmlString, baseURL: nil)
        self.webView.isHidden = false
        self.viewStream.bringSubviewToFront(self.webView)
    }
    func addOverLay1(){
        let htmlString = "<html>\n" +
            "<body style='margin:0;padding:0;background:transparent;'>\n" +
            "<iframe width=\"100%\" height=\"100%\" src=\"https://app.singular.live/appinstances/419608/outputs/Output/onair\" frameborder=\"0\" allow=\"accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture\" allowfullscreen>\n" +
            "</iframe>\n" +
            "</body>\n" +
        "</html>";
        print("htmlString in ol1:",htmlString)
        self.webView.loadHTMLString(htmlString, baseURL: nil)
        self.webView.isHidden = false
        self.viewStream.bringSubviewToFront(self.webView)
    }
    func myList(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let url: String = appDelegate.ol_lambda_url +  "/startSession"
        let user_id = UserDefaults.standard.string(forKey: "user_id");
        let inputData: [String: Any] = ["userid":user_id ?? ""]
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
                        print("myList JSON:",json)
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
    
    // MARK: Handler for Metrics
    
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
                        print("startSession JSON:",json)
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
        print("endSession params:",params)
        
        let headers: HTTPHeaders = ["Content-type": "multipart/form-data","access_token": session_token,appDelegate.x_api_key: appDelegate.x_api_value]
        
        AF.request(url, method: .post,parameters: params, encoding: JSONEncoding.default,headers:headers)
            .responseJSON { response in
                self.viewActivity.isHidden = true
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any] {
                        print("endSession JSON:",json)
                        if (json["statusCode"]as? String == "200"){
                            
                        }else{
                            let strError = json["message"] as? String
                            //print("strError1:",strError ?? "")
                            self.showAlert(strMsg: strError ?? "")
                        }
                        
                    }
                    
                case .failure(let error):
                    //print(error)
                    self.showAlert(strMsg: error.localizedDescription)
                }
        }
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        if(UIDevice.current.userInterfaceIdiom == .phone){
            let value = UIInterfaceOrientation.landscapeRight.rawValue
            UIDevice.current.setValue(value, forKey: "orientation")
        }
        AppDelegate.AppUtility.lockOrientation(.landscapeRight)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        AppDelegate.AppUtility.lockOrientation(.landscape, andRotateTo: .landscapeRight)
        viewStream.layoutIfNeeded()
    }
    override func viewWillDisappear(_ animated: Bool) {
        AppDelegate.AppUtility.lockOrientation(.all)
        if (timer != nil)
        {
            print("stoptimer executed")
            timer!.invalidate()
            timer = nil
        }
        if (timerNet != nil)
        {
            print("stop timer net executed")
            timerNet!.invalidate()
            timerNet = nil
        }
        // reachability.stopNotifier()
        // NotificationCenter.default.removeObserver(self, name: .reachabilityChanged, object: reachability)
        
    }
}

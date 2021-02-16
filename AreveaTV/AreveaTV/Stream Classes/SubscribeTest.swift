//
//  SubscribeTestViewController.swift
//  R5ProTestbed
//
//  Created by Andy Zupko on 12/16/15.
//  Copyright © 2015 Infrared5. All rights reserved.
//

import UIKit
import R5Streaming
import Alamofire

@objc(SubscribeTest)
class SubscribeTest: BaseTest {
    var slider = UISlider()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var current_rotation = 0;
    var audioBtn: UIButton? = nil
    var videoBtn: UIButton? = nil
    var lblLive = UILabel()

    var finished = false
    var publisherIsInBackground = false
    var publisherIsDisconnected = false
    var serverAddress = ""
    var viewControls = UIView()
    var viewOverlay = UIView()
    var streamName = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        addOverlay()
    }
    func showAlert(strMsg: String){
        let alert = UIAlertController(title: "Alert", message: strMsg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
    func metaLive(){
        print("==metaLive")
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
                    DispatchQueue.main.async {
                        ////print("metaLive Response:",value)
                        if let json = value as? [String: Any] {
                            if json["errorMessage"] != nil{
                                // ALToastView.toast(in: self.view, withText:errorMsg as? String ?? "")
                                //let error = "Unable to locate stream. Broadcast has probably not started for this stream: " + stream1
                                // ALToastView.toast(in: self.view, withText: error)
                                let streamInfo = ["Stream": "not_available"]
                                NotificationCenter.default.post(name: .didReceiveStreamData, object: self, userInfo: streamInfo)
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

                                    let streamInfo = ["Stream": "not_available"]
                                    NotificationCenter.default.post(name: .didReceiveStreamData, object: self, userInfo: streamInfo)
                                }
                            }
                        }
                    }
                    
                    
                case .failure(let error):
                    //print("error occured in metaLive:",error)
                    let streamInfo = ["Stream": "not_available"]
                    NotificationCenter.default.post(name: .didReceiveStreamData, object: self, userInfo: streamInfo)
                }
        }
        
    }
    func screenShare(streamName: String){
        let netAvailable = appDelegate.isConnectedToInternet()
        if(!netAvailable){
            showAlert(strMsg: "Please check your internet connection!")
            return
        }
        let port = String(Testbed.getParameter(param:"port") as! Int);
        let host = Testbed.getParameter(param:"host") as! String;
        let version = Testbed.getParameter(param:"sm_version") as! String;
        let context = Testbed.getParameter(param:"context") as! String;
        let stream1 = streamName + "_shared_screen";
        let url = "https://" + host + ":" + port + "/streammanager/api/" + version + "/event/" +
            context + "/" + stream1 + "?action=subscribe&region=" + appDelegate.strRegionCode;

        //let url = "https://" + host  + "/streammanager/api/" + version + "/event/" +
           // context + "/" + streamName + "?action=subscribe&region=" + appDelegate.strRegionCode;
        
        //print("url:",url)
        //let url = "https:// livestream.arevea.com/streammanager/api/4.0/event/live/1588788669277_somethingnew?action=subscribe"
        ////print("findStream url:",url)
        //let stream = "1588832196500_taylorswiftevent"
        
        AF.request(url,method: .get, encoding: JSONEncoding.default)
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    DispatchQueue.main.async {
                        print("screenShare res:",value)
                    }
                    if let json = value as? [String: Any] {
                        if json["errorMessage"] != nil{
                            // ALToastView.toast(in: self.view, withText:errorMsg as? String ?? "")
                            //let error = "Unable to locate stream. Broadcast has probably not started for this stream: " + stream1
                            DispatchQueue.main.async {
                                // ALToastView.toast(in: self.view, withText: error)
                                let streamInfo = ["Stream": "not_available"]
                                NotificationCenter.default.post(name: .didReceiveStreamData, object: self, userInfo: streamInfo)
                            }
                        }else{
                            self.serverAddress = json["serverAddress"] as? String ?? ""
                            self.config(url: self.serverAddress,stream:streamName,start: true)
                        }
                    }
                    
                case .failure(let error):
                    print(error)
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
        
        print("url:",url)
        //let url = "https:// livestream.arevea.com/streammanager/api/4.0/event/live/1588788669277_somethingnew?action=subscribe"
        ////print("findStream url:",url)
        //let stream = "1588832196500_taylorswiftevent"
        
        AF.request(url,method: .get, encoding: JSONEncoding.default)
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    DispatchQueue.main.async {
                        ////print(value)
                    }
                    if let json = value as? [String: Any] {
                        if json["errorMessage"] != nil{
                            // ALToastView.toast(in: self.view, withText:errorMsg as? String ?? "")
                            //let error = "Unable to locate stream. Broadcast has probably not started for this stream: " + stream1
                            DispatchQueue.main.async {
                                // ALToastView.toast(in: self.view, withText: error)
                                let streamInfo = ["Stream": "not_available"]
                                NotificationCenter.default.post(name: .didReceiveStreamData, object: self, userInfo: streamInfo)
                            }
                        }else{
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
        let streamInfo = ["Stream": "started"]
        NotificationCenter.default.post(name: .didReceiveStreamData, object: self, userInfo: streamInfo)
        
        let config = getConfig(url: url)
        // Set up the connection and stream
        let connection = R5Connection(config: config)
        self.subscribeStream = R5Stream(connection: connection)
        
        let stats = self.subscribeStream?.getDebugStats()
        //print("---stats:",stats as Any)
        self.subscribeStream!.delegate = self
        self.subscribeStream?.client = self;
        // self.subscribeStream.subscribeToAudio = YES;
        
        currentView?.attach(subscribeStream)
        if(start){
            addControls()
        }
        streamName = stream
        self.subscribeStream!.play(stream, withHardwareAcceleration:false)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        metaLive()
        setupDefaultR5VideoViewController()
        
        //need to comment the below line after testing
       //addControls()
        
        //self.subscribeStream!.audioController.setPlaybackGain(0);
        //setPlaybackGain(0) means mute
        //setPlaybackGain(1.0f); means unmute
        NotificationCenter.default.addObserver(self, selector: #selector(orientationHandler(_:)), name: .StreamOrienationChange, object: nil)
        
        
    }
    @objc func orientationHandler(_ notification:Notification) {
        // Do something now
        ////print("====StreamNotificationHandler")
        if let data = notification.userInfo as? [String: String]
        {
            for (_,value) in data
            {
                //key screen_share
                //value true/false
                ////print("key: \(key)")
                ////print("value: \(value)")
                if (value == "true"){
                   // //print("==screens share true")
                    currentView?.view.frame = self.view.frame

                    var frameControls = viewControls.frame
                    let viewHeight = self.view.frame.size.height - 40
                    frameControls.origin.y = viewHeight
                    viewControls.frame = frameControls
                    
                    var frameSlider = slider.frame
                    let sliderWidth = self.view.frame.size.width/2
                    frameSlider.size.width = sliderWidth
                    slider.frame = frameSlider
                    
                    var frameLive = lblLive.frame
                    let liveX = self.view.frame.size.width - 100
                    frameLive.origin.x = liveX
                    lblLive.frame = frameLive
                    
                    
                }else{
                    // //print("==screens share false")
                    var frameView = self.view.frame
                    frameView.size.width = (self.view.frame.size.width * 0.45)
                    
                    currentView?.view.frame = frameView
                    currentView?.view.layer.borderWidth = 1.0
                    currentView?.view.layer.borderColor = UIColor.gray.cgColor
                    
                    var frameControls = viewControls.frame
                    let viewHeight = (currentView?.view.frame.size.height)! - 40
                    frameControls.origin.y = viewHeight
                    viewControls.frame = frameControls
                    
                    var frameSlider = slider.frame
                    let sliderWidth = (currentView?.view.frame.size.width ?? 0)/2
                    frameSlider.size.width = sliderWidth
                    slider.frame = frameSlider
                    
                    var frameLive = lblLive.frame
                    let liveX = (currentView?.view.frame.size.width)!  - 100
                    frameLive.origin.x = liveX
                    lblLive.frame = frameLive

                }
               
            }
        }
    }
    func addOverlay(){
        //adding overlay with opacity to see back buttons andcontrols proplery on light stream bg
        let screenSize = UIScreen.main.bounds
        let frame = CGRect(x: 0.0, y: 0.0, width: screenSize.width, height: screenSize.height)
        viewOverlay = UIView(frame: frame)
        viewOverlay.backgroundColor =  UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.15)
        self.view.addSubview(viewOverlay)
    }
    func addControls(){
        
        let screenSize = currentView?.view.bounds.size
        var btnHeight = 30
        
        lblLive = UILabel(frame: CGRect(x: 15, y: 50, width: 80, height: btnHeight))
        lblLive.font = UIFont.boldSystemFont(ofSize: 17)
        if(UIDevice.current.userInterfaceIdiom == .pad){
            lblLive.font = UIFont.boldSystemFont(ofSize: 25)
            btnHeight = 40
        }
        lblLive.text = "LIVE"
        lblLive.textAlignment = .center
        lblLive.backgroundColor = .red
        lblLive.textColor = .white
        self.view.addSubview(lblLive)
        
        var btnWidth = 20
        var btnY = 10
        if(UIDevice.current.userInterfaceIdiom == .pad){
            btnWidth = 30
            btnY = 5
        }
        viewControls = UIView(frame: CGRect(x: 0, y: (screenSize?.height ?? 0.0) - 40, width: screenSize?.width ?? 0.0, height: 40))
        
        //viewControls.backgroundColor = .red
        self.view.addSubview(viewControls)
        
        
        
        videoBtn = UIButton(frame: CGRect(x: 20, y: btnY, width: btnWidth, height: btnWidth))
        videoBtn?.backgroundColor = UIColor.clear
        videoBtn?.setTitle("", for: UIControl.State.normal)
        videoBtn?.setImage(UIImage.init(named: "pause"), for: .normal);
        videoBtn?.layer.cornerRadius = 15;
        viewControls.addSubview(videoBtn!)
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(pauseVideo))
        videoBtn?.addGestureRecognizer(tap1)
        
        audioBtn = UIButton(frame: CGRect(x: 60, y: btnY, width: btnWidth, height: btnWidth))
        audioBtn?.backgroundColor = UIColor.clear
        audioBtn?.setTitle("", for: UIControl.State.normal)
        audioBtn?.setImage(UIImage.init(named: "unmute"), for: .normal);
        audioBtn?.layer.cornerRadius = 15;
        viewControls.addSubview(audioBtn!)
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(pauseAudio))
        audioBtn?.addGestureRecognizer(tap2)
        let width = (screenSize?.width ?? 0.0) / 2
        slider = UISlider(frame: CGRect(x:100, y:btnY, width:Int(width), height:btnWidth))
        slider.minimumValue = 0
        slider.maximumValue = 100
        slider.isContinuous = true
        slider.tintColor = UIColor.white
        slider.value = 50
        slider.addTarget(self, action: #selector(sliderValueDidChange(sender:)), for: .valueChanged)
        viewControls.addSubview(slider)
        self.view.bringSubviewToFront(viewOverlay)
        self.view.bringSubviewToFront(viewControls)
    }
    @objc func sliderValueDidChange(sender:UISlider!) {
        if(self.subscribeStream != nil && self.subscribeStream?.audioController != nil) {
            self.subscribeStream?.audioController.volume = slider.value / 100
        }
    }
    @objc func pauseAudio() {
        //let hasAudio = !(self.subscribeStream?.pauseAudio)!;
        // self.subscribeStream?.pauseAudio = hasAudio;
        let imgBtn = audioBtn?.image(for: .normal)
        if ((imgBtn?.isEqual(UIImage.init(named: "unmute")))!)
        {
            audioBtn?.setImage(UIImage.init(named: "mute"), for: .normal);
            if(self.subscribeStream != nil && self.subscribeStream?.audioController != nil) {
            self.subscribeStream?.audioController.volume = 0
            ALToastView.toast(in: self.view, withText:"Pausing Audio")
            }
        }
        else{
            audioBtn?.setImage(UIImage.init(named: "unmute"), for: .normal);
            if( self.subscribeStream != nil && self.subscribeStream?.audioController != nil) {
            self.subscribeStream?.audioController.volume = slider.value / 100
            ALToastView.toast(in: self.view, withText:"Playing Audio")
            }
        }
    }
    @objc func pauseVideo() {
        
        let imgBtn = videoBtn?.image(for: .normal)
        if ((imgBtn?.isEqual(UIImage.init(named: "pause")))!)
        {
            videoBtn?.setImage(UIImage.init(named: "play"), for: .normal);
            if( self.subscribeStream != nil) {
                ALToastView.toast(in: self.view, withText:"Pausing Video")
                self.subscribeStream?.deactivate_display()
            }
            
        }
        else{
            videoBtn?.setImage(UIImage.init(named: "pause"), for: .normal);
                ALToastView.toast(in: self.view, withText:"Playing Video")
            self.subscribeStream?.activate_display()

        }
    }
    
    @objc func handleSingleTap(_ recognizer : UITapGestureRecognizer) {
        let hasAudio = !(self.subscribeStream?.pauseAudio)!;
        let hasVideo = !(self.subscribeStream?.pauseVideo)!;
        if (hasAudio && hasVideo) {
            self.subscribeStream?.pauseAudio = true
            self.subscribeStream?.pauseVideo = false
           // ALToastView.toast(in: self.view, withText:"Pausing Audio")
        }
        else if (hasVideo && !hasAudio) {
            self.subscribeStream?.pauseVideo = true
            self.subscribeStream?.pauseAudio = false
          //  ALToastView.toast(in: self.view, withText:"Pausing Video")
        }
        else if (!hasVideo && hasAudio) {
            self.subscribeStream?.pauseVideo = true
            self.subscribeStream?.pauseAudio = true
          //  ALToastView.toast(in: self.view, withText:"Pausing Audio/Video")
        }
        else {
            self.subscribeStream?.pauseVideo = false
            self.subscribeStream?.pauseAudio = false
          //  ALToastView.toast(in: self.view, withText:"Resuming Audio/Video")
        }
    }
    func updateOrientation(value: Int) {
        if current_rotation == value {
            return
        }
        current_rotation = value
        currentView?.view.layer.transform = CATransform3DMakeRotation(CGFloat(value), 0.0, 0.0, 0.0);
    }
    
    @objc func onMetaData(data : String) {
        let props = data.split(separator: ";").map(String.init)
        props.forEach { (value: String) in
            let kv = value.split(separator: "=").map(String.init)
            if (kv[0] == "orientation") {
                updateOrientation(value: Int(kv[1])!)
            }
        }
    }
    
    // MARK: Handler for Stream Events
    override func onR5StreamStatus(_ stream: R5Stream!, withStatus statusCode: Int32, withMessage msg: String!) {
        super.onR5StreamStatus(stream, withStatus: statusCode, withMessage: msg)
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
        if (Int(statusCode) == Int(r5_status_disconnected.rawValue)) {
            self.cleanup()
        } else if ((Int(statusCode) == Int(r5_status_netstatus.rawValue) && msg == "NetStream.Play.UnpublishNotify") || ((Int(statusCode) == Int(r5_status_netstatus.rawValue) && msg == "NetStream.Play.StreamDry"))){
            
            // publisher has unpublished. possibly from background/interrupt.
            // if (publisherIsInBackground) {
            publisherIsDisconnected = true
            // Begin reconnect sequence...
            let view = currentView
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                if(self.subscribeStream != nil) {
                    view?.attach(nil)
                    self.subscribeStream?.delegate = nil;
                    self.subscribeStream!.stop()
                    //ALToastView.toast(in: self.view, withText:"publisher has unpublished. possibly from background/interrupt")
                    
                    let streamInfo = ["Stream": "stopped"]
                    NotificationCenter.default.post(name: .didReceiveStreamData, object: self, userInfo: streamInfo)
                }
                // self.reconnect()
            }
            // }
            
        } else if ((Int(statusCode) == Int(r5_status_netstatus.rawValue) && msg == "NetStream.Play.SufficientBW")) {
            ////print("=======sufficient band Width")
        }else if ((Int(statusCode) == Int(r5_status_netstatus.rawValue) && msg == "NetStream.Play.InSufficientBW")) {
            ALToastView.toast(in: self.view, withText:"Poor internet connection")
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
    }
    func publisherBackground(msg: String) {
        NSLog("(publisherBackground) the msg: %@", msg)
        publisherIsInBackground = true
        //ALToastView.toast(in: self.view, withText:"Publish Background")
    }
    
    func publisherForeground(msg: String) {
        NSLog("(publisherForeground) the msg: %@", msg)
        publisherIsInBackground = false
       // ALToastView.toast(in: self.view, withText:"Publisher Foreground")
    }
    
    func publisherInterrupt(msg: String) {
        // Most likely will not receive this...
        NSLog("(publisherInterrupt) the msg: %@", msg)
        publisherIsDisconnected = true
        //ALToastView.toast(in: self.view, withText:"Publisher Interrupt")
        // Begin reconnect sequence...
        let view = currentView
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            if(self.subscribeStream != nil) {
                view?.attach(nil)
                self.subscribeStream?.delegate = nil;
                self.subscribeStream!.stop()
            }
           // self.reconnect()
        }
    }
    func reconnect () {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            if self.finished {
                return
            }
        }
        metaLive()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.finished = true
        super.viewWillDisappear(animated)
    }
    
    
}

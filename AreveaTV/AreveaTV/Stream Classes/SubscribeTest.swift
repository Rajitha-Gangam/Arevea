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
    var slider: UISlider?
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    var current_rotation = 0;
    var audioBtn: UIButton? = nil
    var videoBtn: UIButton? = nil
    var finished = false
    var publisherIsInBackground = false
    var publisherIsDisconnected = false
    var serverAddress = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    func findStream(){
        
        let port = String(Testbed.getParameter(param:"port") as! Int);
        let host = Testbed.getParameter(param:"host") as! String;
        let version = Testbed.getParameter(param:"sm_version") as! String;
        let context = Testbed.getParameter(param:"context") as! String;
        let stream1 = Testbed.getParameter(param:"stream1") as! String;
        
        let url = "https://" + host  + "/streammanager/api/" + version + "/event/" +
            context + "/" + stream1 + "?action=subscribe&region=" + appDelegate.strRegionCode;
        //let url = "https://livestream.arevea.tv/streammanager/api/4.0/event/live/1588788669277_somethingnew?action=subscribe"
        print("url",url)
        //let stream = "1588832196500_taylorswiftevent"
        
        AF.request(url,method: .get, encoding: JSONEncoding.default)
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    DispatchQueue.main.async {
                        print(value)
                    }
                    if let json = value as? [String: Any] {
                        if json["errorMessage"] != nil{
                            // ALToastView.toast(in: self.view, withText:errorMsg as? String ?? "")
                            let error = "Unable to locate stream. Broadcast has probably not started for this stream: " + stream1
                            DispatchQueue.main.async {
                                ALToastView.toast(in: self.view, withText: error)
                            }
                        }else{
                            self.serverAddress = json["serverAddress"] as? String ?? ""
                            self.config(url: self.serverAddress,stream:stream1)
                        }
                    }
                
                case .failure(let error):
                    print(error)
                }
        }
    }
    func config(url:String,stream:String){
        let streamInfo = ["Stream": "Started"]
        NotificationCenter.default.post(name: .didReceiveStreamData, object: self, userInfo: streamInfo)

        let config = getConfig(url: url)
        // Set up the connection and stream
        let connection = R5Connection(config: config)
        self.subscribeStream = R5Stream(connection: connection)
        self.subscribeStream!.delegate = self
        self.subscribeStream?.client = self;
        // self.subscribeStream.subscribeToAudio = YES;
        
        currentView?.attach(subscribeStream)
        addControls()
        
        self.subscribeStream!.play(stream, withHardwareAcceleration:false)
        //addControls()
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        findStream()
        setupDefaultR5VideoViewController()
        
        
        
        //self.subscribeStream!.audioController.setPlaybackGain(0);
        //setPlaybackGain(0) means mute
        //setPlaybackGain(1.0f); means unmute
        
        
    }
    func addControls(){
        let screenSize = currentView?.view.bounds.size
        
        audioBtn = UIButton(frame: CGRect(x: 20, y: (screenSize?.height ?? 0.0) - 40, width: 30, height: 30))
        audioBtn?.backgroundColor = UIColor.clear
        audioBtn?.setTitle("", for: UIControl.State.normal)
        audioBtn?.setImage(UIImage.init(named: "unmute.png"), for: .normal);
        audioBtn?.layer.cornerRadius = 15;
        view.addSubview(audioBtn!)
        let tap = UITapGestureRecognizer(target: self, action: #selector(pauseAudio))
        audioBtn?.addGestureRecognizer(tap)
        
        //        videoBtn = UIButton(frame: CGRect(x: (screenSize.width * 0.6) - 120, y: screenSize.height - 40, width: 50, height: 40))
        //        videoBtn?.backgroundColor = UIColor.darkGray
        //        videoBtn?.setTitle("video", for: UIControl.State.normal)
        //        view.addSubview(videoBtn!)
        //        let tap2 = UITapGestureRecognizer(target: self, action: #selector(pauseVideo))
        //        videoBtn?.addGestureRecognizer(tap2)
        slider = UISlider(frame: CGRect(x:70, y:(screenSize?.height ?? 0.0) - 40, width:(screenSize?.width ?? 0.0) - 90, height:20))
        slider?.minimumValue = 0
        slider?.maximumValue = 100
        slider?.isContinuous = true
        slider?.tintColor = UIColor.white
        slider?.value = 50
        slider?.addTarget(self, action: #selector(sliderValueDidChange(sender:)), for: .valueChanged)
        self.view.addSubview(slider!)
    }
    @objc func sliderValueDidChange(sender:UISlider!) {
        self.subscribeStream?.audioController.volume = slider!.value / 100
    }
    @objc func pauseAudio() {
        let hasAudio = !(self.subscribeStream?.pauseAudio)!;
        self.subscribeStream?.pauseAudio = hasAudio;
        let imgBtn = audioBtn?.image(for: .normal)
        if ((imgBtn?.isEqual(UIImage.init(named: "unmute.png")))!)
        {
            audioBtn?.setImage(UIImage.init(named: "mute.png"), for: .normal);
            ALToastView.toast(in: self.view, withText:"Pausing Audio")
        }
        else{
            audioBtn?.setImage(UIImage.init(named: "unmute.png"), for: .normal);
            ALToastView.toast(in: self.view, withText:"Playing Audio")
        }
    }
    @objc func pauseVideo() {
        let hasVideo = !(self.subscribeStream?.pauseVideo)!;
        self.subscribeStream?.pauseVideo = hasVideo;
        ALToastView.toast(in: self.view, withText:"Pausing Video")
    }
    
    @objc func handleSingleTap(_ recognizer : UITapGestureRecognizer) {
        let hasAudio = !(self.subscribeStream?.pauseAudio)!;
        let hasVideo = !(self.subscribeStream?.pauseVideo)!;
        
        if (hasAudio && hasVideo) {
            self.subscribeStream?.pauseAudio = true
            self.subscribeStream?.pauseVideo = false
            
            ALToastView.toast(in: self.view, withText:"Pausing Audio")
        }
        else if (hasVideo && !hasAudio) {
            self.subscribeStream?.pauseVideo = true
            self.subscribeStream?.pauseAudio = false
            ALToastView.toast(in: self.view, withText:"Pausing Video")
        }
        else if (!hasVideo && hasAudio) {
            self.subscribeStream?.pauseVideo = true
            self.subscribeStream?.pauseAudio = true
            ALToastView.toast(in: self.view, withText:"Pausing Audio/Video")
        }
        else {
            self.subscribeStream?.pauseVideo = false
            self.subscribeStream?.pauseAudio = false
            ALToastView.toast(in: self.view, withText:"Resuming Audio/Video")
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
        ALToastView.toast(in: self.view, withText:s)
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
                    ALToastView.toast(in: self.view, withText:"publisher has unpublished. possibly from background/interrupt")
                    
                    let streamInfo = ["Stream": "Stopped"]
                           NotificationCenter.default.post(name: .didReceiveStreamData, object: self, userInfo: streamInfo)
                }
                self.reconnect()
            }
            // }
            
        } else if ((Int(statusCode) == Int(r5_status_netstatus.rawValue) && msg == "NetStream.Play.SufficientBW")) {
            print("=======sufficient band Width")
        }else if ((Int(statusCode) == Int(r5_status_netstatus.rawValue) && msg == "NetStream.Play.InSufficientBW")) {
            ALToastView.toast(in: self.view, withText:"Poor internet connection")
        }else if (Int(statusCode) == Int(r5_status_audio_mute.rawValue))
        {
            print("=======r5_status_audio_mute")
            let hasAudio = !(self.subscribeStream?.pauseAudio)!;
            if (hasAudio) {
                self.subscribeStream?.pauseAudio = true
            }
        }
        else if (Int(statusCode) == Int(r5_status_audio_unmute.rawValue))
        {
            print("=======r5_status_audio_unmute")
            let hasAudio = !(self.subscribeStream?.pauseAudio)!;
            if (hasAudio) {
                self.subscribeStream?.pauseAudio = false
            }
            
        }else if (Int(statusCode) == Int(r5_status_video_mute.rawValue))
        {
            print("=======r5_status_video_mute")
            let hasAudio = !(self.subscribeStream?.pauseAudio)!;
            if (hasAudio) {
                self.subscribeStream?.pauseAudio = true
            }
        }
        else if (Int(statusCode) == Int(r5_status_video_unmute.rawValue))
        {
            print("=======r5_status_video_unmute")
            let hasAudio = !(self.subscribeStream?.pauseAudio)!;
            if (hasAudio) {
                self.subscribeStream?.pauseAudio = false
            }
            
        }
        else if (Int(statusCode) == Int(r5_status_disconnected.rawValue))
        {
            print("=======r5_status_disconnected")
            
        }
        else if (Int(statusCode) == Int(r5_status_stop_streaming.rawValue))
        {
            print("=======r5_status_stop_streaming")
        }
    }
    func publisherBackground(msg: String) {
        NSLog("(publisherBackground) the msg: %@", msg)
        publisherIsInBackground = true
        ALToastView.toast(in: self.view, withText:"Publish Background")
    }
    
    func publisherForeground(msg: String) {
        NSLog("(publisherForeground) the msg: %@", msg)
        publisherIsInBackground = false
        ALToastView.toast(in: self.view, withText:"Publisher Foreground")
    }
    
    func publisherInterrupt(msg: String) {
        // Most likely will not receive this...
        NSLog("(publisherInterrupt) the msg: %@", msg)
        publisherIsDisconnected = true
        ALToastView.toast(in: self.view, withText:"Publisher Interrupt")
        
        // Begin reconnect sequence...
        let view = currentView
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            if(self.subscribeStream != nil) {
                view?.attach(nil)
                self.subscribeStream?.delegate = nil;
                self.subscribeStream!.stop()
            }
            self.reconnect()
        }
    }
    func reconnect () {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            if self.finished {
                return
            }
        }
        findStream()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.finished = true
        super.viewWillDisappear(animated)
    }
    
    
}

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

@objc(ScreenShareVC)
class ScreenShareVC: BaseTest {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var current_rotation = 0;

    var finished = false
    var publisherIsInBackground = false
    var publisherIsDisconnected = false
    var serverAddress = ""
    var streamName = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    func showAlert(strMsg: String){
        let alert = UIAlertController(title: "Alert", message: strMsg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
   
    func screenShare(){
        print("==screenShare in stream")
        let netAvailable = appDelegate.isConnectedToInternet()
        if(!netAvailable){
            showAlert(strMsg: "Please check your internet connection!")
            return
        }
        let port = String(Testbed.getParameter(param:"port") as! Int);
        let host = Testbed.getParameter(param:"host") as! String;
        let version = Testbed.getParameter(param:"sm_version") as! String;
        let context = Testbed.getParameter(param:"context") as! String;
        let stream1 = Testbed.getParameter(param:"stream1") as! String;
        let streamName = stream1 + "_shared_screen";
        
        let url = "https://" + host  + "/streammanager/api/" + version + "/event/" +
            context + "/" + streamName + "?action=subscribe&region=" + appDelegate.strRegionCode;

        //let url = "https://" + host  + "/streammanager/api/" + version + "/event/" +
           // context + "/" + streamName + "?action=subscribe&region=" + appDelegate.strRegionCode;
        
        print("url:",url)
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
                                let streamInfo = ["screenshare": "not_available"]
                                NotificationCenter.default.post(name: .didReceiveScreenShareData, object: self, userInfo: streamInfo)
                            }
                        }else{
                            let streamInfo = ["screenshare": "started"]
                            NotificationCenter.default.post(name: .didReceiveScreenShareData, object: self, userInfo: streamInfo)

                            self.serverAddress = json["serverAddress"] as? String ?? ""
                            self.config(url: self.serverAddress,stream:streamName,start: true)
                        }
                    }
                    
                case .failure(let error):
                    print("==screenshare error:",error)
                }
        }
    }
    
    func config(url:String,stream:String,start:Bool){
       // let streamInfo = ["StreamShare": "started"]
      //  NotificationCenter.default.post(name: .didReceiveScreenShareData, object: self, userInfo: streamInfo)
        
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
        
        streamName = stream
        self.subscribeStream!.play(stream, withHardwareAcceleration:false)
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        screenShare()
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
                //key orientation
                //value portrait/landscape
                ////print("key: \(key)")
                ////print("value: \(value)")
                if (value == "portrait"){
                   // //print("==portrait")
                }else{
                  //  //print("==landscape")
                }
                
            }
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
            //self.cleanup()
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
                    
                    let streamInfo = ["screenshare": "stopped"]
                    NotificationCenter.default.post(name: .didReceiveScreenShareData, object: self, userInfo: streamInfo)
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
           // ALToastView.toast(in: self.view, withText:"Audio Muted")

        }
        else if (Int(statusCode) == Int(r5_status_audio_unmute.rawValue))
        {
            ////print("=======r5_status_audio_unmute")
            /*let hasAudio = !(self.subscribeStream?.pauseAudio)!;
            if (hasAudio) {
                self.subscribeStream?.pauseAudio = false
            }*/
           // ALToastView.toast(in: self.view, withText:"Audio Unmuted")

            
        }else if (Int(statusCode) == Int(r5_status_video_mute.rawValue))
        {
            ////print("=======r5_status_video_mute")
            /*let hasAudio = !(self.subscribeStream?.pauseAudio)!;
            if (hasAudio) {
                self.subscribeStream?.pauseAudio = true
            }*/
           // ALToastView.toast(in: self.view, withText:"Video Muted")

        }
        else if (Int(statusCode) == Int(r5_status_video_unmute.rawValue))
        {
            ////print("=======r5_status_video_unmute")
            /*let hasAudio = !(self.subscribeStream?.pauseAudio)!;
            if (hasAudio) {
                self.subscribeStream?.pauseAudio = false
            }*/
           // ALToastView.toast(in: self.view, withText:"Video Unmuted")

        }
        else if (Int(statusCode) == Int(r5_status_disconnected.rawValue))
        {
            ////print("=======r5_status_disconnected")
           // ALToastView.toast(in: self.view, withText:"Video Disconnected")

        }
        else if (Int(statusCode) == Int(r5_status_stop_streaming.rawValue))
        {
            ////print("=======r5_status_stop_streaming")
          //  ALToastView.toast(in: self.view, withText:"Stream Stopped")
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
            /*if(self.subscribeStream != nil) {
                view?.attach(nil)
                self.subscribeStream?.delegate = nil;
                self.subscribeStream!.stop()
            }*/
           // self.reconnect()
        }
    }
    func reconnect () {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            if self.finished {
                return
            }
        }
       // screenShare()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.finished = true
        super.viewWillDisappear(animated)
    }
    
    
}

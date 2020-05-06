//
//  SubscribeTestViewController.swift
//  R5ProTestbed
//
//  Created by Andy Zupko on 12/16/15.
//  Copyright © 2015 Infrared5. All rights reserved.
//

import UIKit
import R5Streaming

@objc(SubscribeTest)
class SubscribeTest: BaseTest {
    var slider: UISlider?

    var current_rotation = 0;
    var audioBtn: UIButton? = nil
    var videoBtn: UIButton? = nil
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        setupDefaultR5VideoViewController()
        
        let config = getConfig()
        // Set up the connection and stream
        let connection = R5Connection(config: config)
        self.subscribeStream = R5Stream(connection: connection)
        self.subscribeStream!.delegate = self
        self.subscribeStream?.client = self;
       // self.subscribeStream.subscribeToAudio = YES;

        currentView?.attach(subscribeStream)
        
        self.subscribeStream!.play(Testbed.getParameter(param: "stream1") as! String, withHardwareAcceleration:Testbed.getParameter(param: "hwaccel_on") as! Bool)
        
         //self.subscribeStream!.audioController.setPlaybackGain(0);
        //setPlaybackGain(0) means mute
        //setPlaybackGain(1.0f); means unmute
        
        //addControls()
        
    }
    func addControls(){
        let screenSize = currentView?.view.bounds.size
                
                audioBtn = UIButton(frame: CGRect(x: ((screenSize?.width ?? 0.0) * 0.6) - 100, y: (screenSize?.height ?? 0.0) - 100, width: 50, height: 50))
                audioBtn?.backgroundColor = UIColor.darkGray
                audioBtn?.setTitle("", for: UIControl.State.normal)
                audioBtn?.setImage(UIImage.init(named: "mute.png"), for: .normal);
                view.addSubview(audioBtn!)
                let tap = UITapGestureRecognizer(target: self, action: #selector(pauseAudio))
                audioBtn?.addGestureRecognizer(tap)
                
        //        videoBtn = UIButton(frame: CGRect(x: (screenSize.width * 0.6) - 120, y: screenSize.height - 40, width: 50, height: 40))
        //        videoBtn?.backgroundColor = UIColor.darkGray
        //        videoBtn?.setTitle("video", for: UIControl.State.normal)
        //        view.addSubview(videoBtn!)
        //        let tap2 = UITapGestureRecognizer(target: self, action: #selector(pauseVideo))
        //        videoBtn?.addGestureRecognizer(tap2)
                slider = UISlider(frame: CGRect(x:40, y:(screenSize?.height ?? 0.0) - 40, width:(screenSize?.width ?? 0.0) - 80, height:20))
                slider?.minimumValue = 0
                slider?.maximumValue = 100
                slider?.isContinuous = true
                slider?.tintColor = UIColor.blue
                slider?.value = 100
                slider?.addTarget(self, action: #selector(sliderValueDidChange(sender:)), for: .valueChanged)
                self.view.addSubview(slider!)
    }
    @objc func sliderValueDidChange(sender:UISlider!) {
           self.subscribeStream?.audioController.volume = slider!.value / 100
       }
    @objc func pauseAudio() {
        
        let hasAudio = !(self.subscribeStream?.pauseAudio)!;
        self.subscribeStream?.pauseAudio = hasAudio;
        if (hasAudio){
            audioBtn?.setImage(UIImage.init(named: "mute.png"), for: .normal);
            ALToastView.toast(in: self.view, withText:"Pausing Audio")
        }else{
            audioBtn?.setImage(UIImage.init(named: "unmute.png"), for: .normal);
            ALToastView.toast(in: self.view, withText:"Playing Audio")

        }
        
    }
    
    
    @objc func pauseVideo() {
        
        let hasVideo = !(self.subscribeStream?.pauseVideo)!;
        self.subscribeStream?.pauseVideo = hasVideo;
        ALToastView.toast(in: self.view, withText:"Pausing Video")
        
    }

    func handleSingleTap(_ recognizer : UITapGestureRecognizer) {

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
    
    override func onR5StreamStatus(_ stream: R5Stream!, withStatus statusCode: Int32, withMessage msg: String!) {
        super.onR5StreamStatus(stream, withStatus: statusCode, withMessage: msg)

        if( Int(statusCode) == Int(r5_status_start_streaming.rawValue) ){
            
            let session : AVAudioSession = AVAudioSession.sharedInstance()
            let cat = session.category
            let opt = session.categoryOptions
            
            let s =  String(format: "AV: %@ (%d)",  cat.rawValue, opt.rawValue)
            ALToastView.toast(in: self.view, withText:s)
            
//            self.subscribeStream?.setFrameListener({data, format, size, width, height in
//                uncomment for frameListener stress testing
//            })
        }
        
        if( Int(statusCode) == Int(r5_status_video_render_start.rawValue) ){
            let f = Int(stream.getFormat().rawValue)
            let s =  String(format: "Video Format: (%d)", f)
            ALToastView.toast(in: self.view, withText:s)
        }
    }
    
}

//
//  StreamDetailVC.swift
//  R5ProTestbed
//
//  Created by Rajitha Gangam on 20/04/20.
//  Copyright © 2020 All rights reserved.
//

import UIKit
import R5Streaming

@objc(StreamDetailVC)
class StreamDetailVC: BaseTest {
    @IBOutlet weak var viewStream: UIView!

    var current_rotation = 0;

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
        
        currentView?.attach(subscribeStream)
        
        self.subscribeStream!.play("stream1" , withHardwareAcceleration:false )
        
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
    @IBAction func back(){
        self.navigationController?.popViewController(animated: false)
    }
    
}

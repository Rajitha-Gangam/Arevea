//
//  MultiStreamVC.swift
//  AreveaTV
//
//  Created by apple on 7/16/20.
//  Copyright © 2020 apple. All rights reserved.
//

import UIKit


class MultiStreamVC: UIViewController {
    // MARK: - Variables Declaration
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var backPressed = false
    @IBOutlet weak var heightTopView: NSLayoutConstraint?
    @IBOutlet weak var viewTop: UIView!
    weak var delegate: OpenChanannelChatDelegate?
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var viewActivity: UIView!
    @IBOutlet weak var viewStream: UIView!
    
    var orgId = 0;
    var performerId = 0;
    var streamId = 0;
    var strTitle = ""
    var detailStreamItem: NSDictionary? {
        didSet {
            // Update the view.
            // self.configureView()
        }
    }
    var r5ViewController : BaseTest? = nil
    // MARK: - View Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        lblTitle.text = strTitle
        viewActivity.isHidden = true
        setLiveStreamConfig()
        
    }
    func setLiveStreamConfig(){
        
        let session_token = UserDefaults.standard.string(forKey: "session_token");
        let user_email = UserDefaults.standard.string(forKey: "user_email");
        
        let path = Bundle.main.path(forResource: "R5options", ofType: "plist")
        let dicPlist = NSMutableDictionary(contentsOfFile: path!)
        let dicGlobalProperties = dicPlist?.value(forKey: "GlobalProperties") as? NSMutableDictionary
        
        let license_key = dicGlobalProperties?["license_key"] as? String
        let server_port = dicGlobalProperties?["server_port"] as? String
        let bitrate = dicGlobalProperties?["bitrate"] as? Int
        let host = dicGlobalProperties?["host"] as? String
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
        //        Testbed.setStreamName(name: streamVideoCode)
        //        Testbed.setStream1Name(name: streamVideoCode)
        Testbed.setStream2Name(name: stream2 ?? "")
        Testbed.setHost(name: host ?? "");
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
        configureStreamView()
    }
    func configureStreamView() {
        // Update the user interface for the detail item.
        // Access the static shared interface to ensure it's loaded
        /* _ = Testbed.sharedInstance
         self.detailStreamItem = Testbed.testAtIndex(index: 1)
         if(self.detailStreamItem != nil){
         //print("props:",self.detailStreamItem!["LocalProperties"] as? NSMutableDictionary)
         
         Testbed.setLocalOverrides(params: self.detailStreamItem!["LocalProperties"] as? NSMutableDictionary)
         let className = self.detailStreamItem!["class"] as! String
         let mClass = NSClassFromString(className) as! BaseTest.Type;
         
         r5ViewController  = mClass.init()
         r5ViewController?.view.frame = self.viewStream.bounds
         self.viewStream.addSubview(r5ViewController!.view)
         self.addChild(r5ViewController!)
         //self.viewLiveStream.bringSubviewToFront(webView)
         //self.viewLiveStream.bringSubviewToFront(btnRotationStream)
         }*/
        let storyboard = UIStoryboard(name: "Main", bundle: nil);
        let vc = storyboard.instantiateViewController(withIdentifier: "SubscribeTwoStreams") as! SubscribeTwoStreams
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    
    @IBAction func payTip(_ sender: Any) {
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true);
        backPressed = false
        
    }
    @IBAction func back(_ sender: Any) {
        if (!backPressed){
            backPressed = true
            self.navigationController?.popViewController(animated: true)
        }
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent // .default
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}

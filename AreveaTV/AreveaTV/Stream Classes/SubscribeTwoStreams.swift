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
@objc(SubscribeTwoStreams)
class SubscribeTwoStreams: BaseTest {
    @IBOutlet weak var view1: UIView?
    @IBOutlet weak var view2: UIView?
    @IBOutlet weak var view3: UIView?
    @IBOutlet weak var view4: UIView?

    var secondView : R5VideoViewController? = nil
    var subscribeStream2 : R5Stream? = nil
    var appSyncClient: AWSAppSyncClient?
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var superIndex = 0
    @IBOutlet weak var heightTopView: NSLayoutConstraint?
    @IBOutlet weak var viewTop: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var viewActivity: UIView!
    @IBOutlet weak var viewStream: UIView!
    var streamlist = [[String:Any]]()
    var offlineStream = [[String:Any]]()
    var strTitle = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        appSyncClient = appDelegate.appSyncClient
        getGuestDetailInGraphql(.returnCacheDataAndFetch)
        
        view1?.layer.borderColor = UIColor.black.cgColor
        view1?.layer.borderWidth = 1
        
        view2?.layer.borderColor = UIColor.black.cgColor
        view2?.layer.borderWidth = 1
        
        view3?.layer.borderColor = UIColor.black.cgColor
        view3?.layer.borderWidth = 1
        
        view4?.layer.borderColor = UIColor.black.cgColor
        view4?.layer.borderWidth = 1
        lblTitle.text = strTitle
        
        viewActivity.isHidden = true

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
       
    }
    @objc func onMetaData(data : String){
           
    }
       
       override func closeTest() {
           super.closeTest()
           
           if( self.subscribeStream2 != nil ){
               self.subscribeStream2!.stop()
           }
       }
    func getGuestDetailInGraphql(_ cachePolicy: CachePolicy) {
        let listQuery = GetMulticreatorshareddataQuery(id: "1872_1595845007395_mc2")
        //1872_1595845007395_mc2
        //58_1594894849561_multi_creator_test_event
        appSyncClient?.fetch(query: listQuery, cachePolicy: cachePolicy) { result, error in
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
                    print("guestList count:",guestList.count)
                    self.streamlist = [[String:Any]]()
                    self.offlineStream = [[String:Any]]()
                    for (index,_) in guestList.enumerated() {
                        let guest = guestList[index] as! [String:Any]
                        let onlineStatus = guest["onlineStatus"] as? Bool ?? false
                        let liveStatus = guest["liveStatus"] as? Bool ?? false
                        if(onlineStatus && liveStatus) {
                            let auth_code = guest["auth_code"] as? String ?? ""
                            self.streamlist.append(["auth_code":auth_code])
                        } else {
                            let auth_code = guest["auth_code"] as? String ?? ""
                            self.offlineStream.append(["auth_code":auth_code])
                            self.streamlist.append(["auth_code":auth_code])
                            // this.unSubscribe_Subscriber(e.auth_code);
                        }
                        self.findStream()
                    }
                }else{
                    print("--getMulticreatorshareddata null")
                }
            }
            // Remove existing records if we're either loading from cache, or loading fresh (e.g., from a refresh)
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
    func findStream( ){
        for(index,_) in streamlist.enumerated(){
            print("==index:",index)
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
                            let tag = 10*(index + 1)
                            let superView = self.viewStream.viewWithTag(tag)

                             ALToastView.toast(in: superView, withText:errorMsg as? String ?? "")
                            _ = "Unable to locate stream. Broadcast has probably not started for this stream: " + streamName
                            print("errorMessage:",errorMsg)
                            //comment these two lines
                            let serverAddress = "livestream.arevea.tv"
                            self.config(url: serverAddress,stream:streamName,index: index)

                        }else{
                            let serverAddress = json["serverAddress"] as? String ?? ""
                            print("serverAddress:",serverAddress)
                            self.config(url: serverAddress,stream:streamName,index: index)
                        }
                    }
                    
                case .failure(let error):
                    print(error)
                }
        }
        }
    }
    func config(url:String,stream:String,index:Int){
        let streamInfo = ["Stream": "started"]
        NotificationCenter.default.post(name: .didReceiveStreamData, object: self, userInfo: streamInfo)
        let screenSize = self.view.bounds.size
       
        let firstView1 = getNewR5VideoViewController(rect: CGRect( x: 0, y: 0, width: screenSize.width/2, height: screenSize.height / 2 ))
        
        //self.addChild(firstView1)
        //view.addSubview((firstView1.view)!)
        let tag = 10*(index + 1)
        let superView = self.viewStream.viewWithTag(tag)
        superView?.addSubview((firstView1.view)!)
        
        firstView1.showDebugInfo(false)
        //firstView1.view.center = center
        let config = getConfig(url: url)
        // Set up the connection and stream
        let connection = R5Connection(config: config)
        let subscribeStream1 = R5Stream(connection: connection)
        subscribeStream1!.delegate = self
        subscribeStream1?.client = self;
        firstView1.attach(subscribeStream1)
        subscribeStream1!.play(stream, withHardwareAcceleration:false)
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
    
   @IBAction func back(_ sender: Any) {
    print("back called")
    self.navigationController?.popViewController(animated: true)
   }
    override var preferredStatusBarStyle: UIStatusBarStyle {
           return .lightContent // .default
       }
}

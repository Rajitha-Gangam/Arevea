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
    var firstView : R5VideoViewController? = nil
    var secondView : R5VideoViewController? = nil
    var subscribeStream2 : R5Stream? = nil
    var appSyncClient: AWSAppSyncClient?
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        appSyncClient = appDelegate.appSyncClient
        getGuestDetailInGraphql(.returnCacheDataAndFetch)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let screenSize = self.view.bounds.size
        
        firstView = getNewR5VideoViewController(rect: CGRect( x: 0, y: 0, width: screenSize.width, height: screenSize.height / 2 ))
        self.addChild(firstView!)
        view.addSubview((firstView?.view)!)
        //firstView?.showDebugInfo(Testbed.getParameter(param: "debug_view") as! Bool)
        firstView?.showDebugInfo(false)

        firstView?.view.center = CGPoint( x: screenSize.width/2, y: screenSize.height/4 )
        
        let config = getConfig(url: "livestream.arevea.tv")
        // Set up the connection and stream
        let connection = R5Connection(config: config)
        self.subscribeStream = R5Stream(connection: connection)
        self.subscribeStream!.delegate = self
        self.subscribeStream?.client = self;
        
        firstView?.attach(subscribeStream)
        firstView?.view.backgroundColor = .red
        self.subscribeStream!.audioController = R5AudioController()
        
        self.subscribeStream!.play(Testbed.getParameter(param: "stream1") as? String, withHardwareAcceleration:Testbed.getParameter(param: "hwaccel_on") as! Bool)
        
        secondView = getNewR5VideoViewController(rect: CGRect( x: 0, y: screenSize.height / 2, width: screenSize.width, height: screenSize.height / 2 ))
        self.addChild(secondView!)
        view.addSubview((secondView?.view)!)
        //secondView?.showDebugInfo(Testbed.getParameter(param: "debug_view") as! Bool)
        secondView?.showDebugInfo(false)
        secondView?.view.center = CGPoint( x: screenSize.width/2, y: 3 * (screenSize.height/4) )
        secondView?.view.backgroundColor = .green

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            
            let connection2 = R5Connection(config: config)
            
            self.subscribeStream2 = R5Stream(connection: connection2 )
            self.subscribeStream2!.delegate = self
            self.subscribeStream2?.client = self;
            
            self.secondView?.attach(self.subscribeStream2)
            
            self.subscribeStream2?.audioController = R5AudioController()
            
            self.subscribeStream2?.play(Testbed.getParameter(param: "stream2") as? String, withHardwareAcceleration:Testbed.getParameter(param: "hwaccel_on") as! Bool)
            
        }
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
        
        /*let listQuery = GetMulticreatorshareddataQuery(id: "1872_1595845007395_mc2")
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
                    var streamlist = [[String:Any]]()
                    var offlineStream = [[String:Any]]()
                    for (index,_) in guestList.enumerated() {
                        var guest = guestList[index] as! [String:Any]
                        let onlineStatus = guest["onlineStatus"] as? Bool ?? false
                        let liveStatus = guest["liveStatus"] as? Bool ?? false
                        
                        if(onlineStatus && liveStatus) {
                            let auth_code = guest["auth_code"] as? String ?? ""
                            streamlist.append(["auth_code":auth_code])
                        } else {
                            let auth_code = guest["auth_code"] as? String ?? ""
                            offlineStream.append(["auth_code":auth_code])
                            streamlist.append(["auth_code":auth_code])

                            // this.unSubscribe_Subscriber(e.auth_code);
                        }
                    }
                    for(index,_) in streamlist.enumerated(){
                        var guest = guestList[index] as! [String:Any]
                        let auth_code = guest["auth_code"] as? String ?? ""
                        self.findStream(streamName: auth_code)
                      /*  let url = "https://" + host  + "/streammanager/api/" + version + "/event/" +
                            context + "/" + auth_code + "?action=subscribe&region=" + appDelegate.strRegionCode;
                        
                        print("url:",url)*/


                    }
                    
                }else{
                    print("--getMulticreatorshareddata null")
                }
                
            }
            // Remove existing records if we're either loading from cache, or loading fresh (e.g., from a refresh)
        }*/
    }
    func showAlert(strMsg: String){
        let alert = UIAlertController(title: "Alert", message: strMsg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        
        DispatchQueue.main.async {
            self.present(alert, animated: true)
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
                            // ALToastView.toast(in: self.view, withText:errorMsg as? String ?? "")
                            //let error = "Unable to locate stream. Broadcast has probably not started for this stream: " + stream1
                            print("errorMessage:",json["errorMessage"])
                            DispatchQueue.main.async {
                                // ALToastView.toast(in: self.view, withText: error)
                                let streamInfo = ["Stream": "not_available"]
                                NotificationCenter.default.post(name: .didReceiveStreamData, object: self, userInfo: streamInfo)
                            }
                        }else{
                            let serverAddress = json["serverAddress"] as? String ?? ""
                            print("serverAddress:",serverAddress)
                            self.config(url: serverAddress,stream:streamName)
                        }
                    }
                    
                case .failure(let error):
                    print(error)
                }
        }
    }
    func config(url:String,stream:String){
        let streamInfo = ["Stream": "started"]
        NotificationCenter.default.post(name: .didReceiveStreamData, object: self, userInfo: streamInfo)
        
        let config = getConfig(url: url)
        // Set up the connection and stream
        let connection = R5Connection(config: config)
        self.subscribeStream = R5Stream(connection: connection)
        
        let stats = self.subscribeStream?.getDebugStats()
        print("---stats:",stats as Any)
        self.subscribeStream!.delegate = self
        self.subscribeStream?.client = self;
        // self.subscribeStream.subscribeToAudio = YES;
        
        currentView?.attach(subscribeStream)
       // addControls()
        
        self.subscribeStream!.play(stream, withHardwareAcceleration:false)
        
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
    
   
}

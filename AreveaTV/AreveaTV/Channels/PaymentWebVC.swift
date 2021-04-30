//
//  PaymentWebVC.swift
//  AreveaTV
//
//  Created by apple on 4/29/21.
//  Copyright © 2021 apple. All rights reserved.
//

import UIKit
import WebKit
import Alamofire
import SendBirdSDK

class PaymentWebVC: UIViewController ,UIWebViewDelegate, OpenChanannelChatDelegate{
    @IBOutlet weak var viewActivity: UIView!
    @IBOutlet weak var heightTopView: NSLayoutConstraint?
    @IBOutlet weak var viewTop: UIView!
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet weak var webView: UIWebView!
    var isCameFrom = ""
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var strURL = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        print("strURL:",strURL)
        // Do any additional setup after loading the view.
        if let url = URL(string: strURL){
            let request = URLRequest(url: url as URL)
            webView.delegate = self
            webView.loadRequest(request)
            
            viewActivity.isHidden = false
        }
    }
    func showAlert(strMsg: String){
        let alert = UIAlertController(title: "Alert", message: strMsg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    // MARK: - Webview Delegates
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent // .default
    }
    func popToDashBoard(){
        for controller in self.navigationController!.viewControllers as Array {
            if controller.isKind(of: DashBoardVC.self) {
                self.navigationController!.popToViewController(controller, animated: true)
                break
            }
        }
    }
    func getTicketDetails(){
        print("==getTicketDetails")
        // let params: [String: Any] = ["userid":user_id ?? "","performer_id":"101","stream_id": "0"]
        let url: String = appDelegate.baseURL +  "/getTicketDetails"
        let headers: HTTPHeaders
        headers = [appDelegate.x_api_key: appDelegate.x_api_value]
        let params: [String: Any] = ["ticket_key": appDelegate.strTicketKey]
        print("getTicketDetails params:",params)
        
        AF.request(url, method: .post,parameters: params, encoding: JSONEncoding.default,headers:headers)
            .responseJSON { [self] response in
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any] {
                        print("getTicketDetails JSON:",json)
                        if (json["statusCode"]as? String == "200" ){
                            let data = json["Data"] as? [String: Any] ?? [:]
                            let userInfo = data["UserInfo"] as? [String: Any] ?? [:]
                            let streamInfo1 = data["stream_info"] as? [String: Any] ?? [:]
                            let streamInfo = streamInfo1["stream_info"] as? [String: Any] ?? [:]
                            let strSlug = streamInfo1["slug"] as? String ?? ""
                            let userID = userInfo["id"]as? String ?? ""
                            print("streamInfo:",streamInfo)
                            UserDefaults.standard.set(userID, forKey: "user_id")
                            UserDefaults.standard.set(userInfo["access_token"], forKey: "session_token")
                            UserDefaults.standard.set("guest-user", forKey: "user")
                            
                            let fn = userInfo["user_first_name"] as? String ?? ""
                            let ln = userInfo["user_last_name"]as? String ?? ""
                            let displayName = userInfo["user_display_name"]as? String ?? ""
                            let strName = String((fn.first ?? "A")) + String((ln.first ?? "B"))
                            appDelegate.USER_NAME = strName;
                            appDelegate.USER_NAME_FULL = (fn ) + " " + (ln )
                            appDelegate.USER_DISPLAY_NAME = displayName
                            appDelegate.isLiveLoad = "1"
                            gotoSchedule(streamInfo: streamInfo)
                        }else{
                            let strMsg = json["message"] as? String ?? ""
                            //self.showAlert(strMsg: strMsg)
                        }
                        
                    }
                case .failure(let error):
                    let errorDesc = error.localizedDescription.replacingOccurrences(of: "URLSessionTask failed with error:", with: "")
                //self.showAlert(strMsg: errorDesc)
                
                }
            }
    }
    func gotoSchedule(streamInfo:[String:Any]){
        print("gotoSchedule")
        let storyboard = UIStoryboard(name: "Main", bundle: nil);
        let stream_video_title = streamInfo["stream_video_title"] as? String ?? "Channel Details"
        
        let vc = storyboard.instantiateViewController(withIdentifier: "ScheduleVC") as! ScheduleVC
        let orgId = streamInfo["organization_id"] as? Int ?? 0
        let streamId = streamInfo["id"] as? Int ?? 0
        let performerId = streamInfo["performer_id"] as? Int ?? 0
        let channelName = streamInfo["channel_name"] as? String ?? ""
        appDelegate.strSlug = streamInfo["slug"] as? String ?? "";
        
        appDelegate.orgId = orgId
        appDelegate.streamId = streamId
        //vc.chatDelegate = self
        appDelegate.performerId = performerId
        appDelegate.strTitle = stream_video_title
        //vc.isCameFromGetTickets = true
        appDelegate.channel_name_subscription = channelName
        appDelegate.isGuest = true
        if(!appDelegate.isVOD){
            appDelegate.isUpcoming = true
        }
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    // MARK: Send Bird Methods
    func sendBirdConnect(streamInfo:[String:Any]) {
        
        // self.view.endEditing(true)
        if SBDMain.getConnectState() == .open {
            SBDMain.disconnect {
                //                    DispatchQueue.main.async {
                //                        //self.setUIsForDefault()
                //                    }
                self.sendBirdConnect(streamInfo: streamInfo)
            }
            ////print("sendBirdConnect disconnect")
        }
        else {
            let userId = UserDefaults.standard.string(forKey: "user_id");
            let nickname = appDelegate.USER_NAME_FULL
            let userDefault = UserDefaults.standard
            userDefault.setValue(userId, forKey: "sendbird_user_id")
            userDefault.setValue(nickname, forKey: "sendbird_user_nickname")
            
            //self.setUIsWhileConnecting()
            
            ConnectionManager.login(userId: userId ?? "1", nickname: nickname) { user, error in
                guard error == nil else {
                    DispatchQueue.main.async {
                        // self.setUIsForDefault()
                    }
                    // self.showAlert(strMsg:error?.localizedDescription ?? "" )
                    return
                }
                
                DispatchQueue.main.async {
                    self.gotoSchedule(streamInfo: streamInfo)
                }
            }
        }
    }
    
    // MARK: - Webview Delegates
    func webViewDidStartLoad(_ webView: UIWebView) {
        print("webViewDidStartLoad")
        
        viewActivity.isHidden = false
        let url = webView.request?.url?.absoluteString
        print("open url in app del:",url)
        
        if(url == appDelegate.websiteURL){
            popToDashBoard()
        }
        else if (url?.range(of:"/schedule/") != nil) {
            if(appDelegate.isGuest && self.isCameFrom == ""){
                let link = url?.components(separatedBy: "/schedule/")//https://preprod.arevea.tv/schedule/1844-120076432-aw0T2PqSZg3C
                if(link?.count ?? 0 > 1){
                    let ticketKey: String = link?[1] ?? ""
                    print("ticketKey:",ticketKey)
                    appDelegate.isVOD = false
                    appDelegate.strTicketKey = ticketKey
                    getTicketDetails()
                }
            }else{
                self.navigationController?.popViewController(animated: true)
            }
            
        }else if url?.range(of:"/stream/") != nil {
            if(appDelegate.isGuest && self.isCameFrom == ""){
                let link = url?.components(separatedBy: "/stream/")//https://preprod.arevea.tv/stream/7246-101059655-4JADmNVFYiBb/stage=7247
                if(link?.count ?? 0 > 1){
                    let ticketKey: String = link?[1] ?? ""//
                    let ticketKey1 = ticketKey.components(separatedBy: "/")//7246-101059655-4JADmNVFYiBb/stage=7247
                    print("ticketKey:",ticketKey)
                    print("ticketKey1:",ticketKey1)
                    print("ticketKey2:",ticketKey1[0])
                    appDelegate.isVOD = false
                    appDelegate.strTicketKey = ticketKey1[0]
                    getTicketDetails()
                }
            }else{
                self.navigationController?.popViewController(animated: true)
            }
        }else if url?.range(of:"/watch/") != nil {
            if(appDelegate.isGuest && self.isCameFrom == ""){
                let link = url?.components(separatedBy: "/watch/")
                if(link?.count ?? 0 > 1){
                    let ticketKey: String = link?[1] ?? ""
                    print("ticketKey:",ticketKey)
                    appDelegate.isVOD = true
                    appDelegate.strTicketKey = ticketKey
                    getTicketDetails()
                }
            }else{
                self.navigationController?.popViewController(animated: true)
                
            }
        }else if(url?.range(of:"cancel-payment") != nil){
            self.navigationController?.popViewController(animated: true)
            
        }
        
    }
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error)
    {
        print("didFailLoadWithError")
        viewActivity.isHidden = true
        // self.showAlert(strMsg:error.localizedDescription)
    }
    func webViewDidFinishLoad(_ webView: UIWebView) {
        print("webViewDidFinishLoad")
        viewActivity.isHidden = true
        
    }
    
}

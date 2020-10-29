//
//  FBLoginVC.swift
//  AreveaTV
//
//  Created by apple on 10/28/20.
//  Copyright © 2020 apple. All rights reserved.
//

import UIKit
import WebKit
import Alamofire
import SendBirdSDK

class FBLoginVC: UIViewController,WKNavigationDelegate {
    @IBOutlet weak var webView:WKWebView!
    @IBOutlet weak var viewActivity: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var strSocialMedia = ""
    @IBOutlet weak var lblHeader:UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        var strURL = ""
        // Do any additional setup after loading the view.
        if(strSocialMedia == "fb"){
            lblHeader.text = "Sign in with Facebook"
            strURL = "https://areveatv-sandbox.onelogin.com/access/initiate?iss=facebook&target_link_uri=" + appDelegate.websiteURL + "/mobile-callback/"
        }else  if(strSocialMedia == "linkedin"){
            lblHeader.text = "Sign in with LinkedIn"
            strURL = "https://areveatv-sandbox.onelogin.com/access/initiate?iss=linkedin&target_link_uri=" + appDelegate.websiteURL + "/mobile-callback/"
        }else  if(strSocialMedia == "google"){
            lblHeader.text = "Sign in with Google"

            webView.customUserAgent = "MyCustomUserAgent";
            strURL = "https://areveatv-sandbox.onelogin.com/access/initiate?iss=https://accounts.google.com&target_link_uri=" + appDelegate.websiteURL + "/mobile-callback/"
        }
        let link = URL(string:strURL)!

        let request = URLRequest(url: link)
        viewActivity.isHidden = false
        webView.navigationDelegate = self
        webView.load(request)
    }
    
    func showAlert(strMsg: String){
        let alert = UIAlertController(title: "Alert", message: strMsg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        viewActivity.isHidden = false
        print("didStartProvisionalNavigation \(webView.url)");
        let webViewURL = webView.url
        let strURL = String(describing: webViewURL!)
        print("strURL:",strURL)

        if (strURL.contains("response_type=code&scope=openid")||strURL.contains( appDelegate.websiteURL + "/?code=")){
            self.webView.isHidden = true
        }
    }
    func webView(_ webView: WKWebView!, didFinish navigation: WKNavigation!) {
        viewActivity.isHidden = true
        print("Finished navigating to url \(webView.url)");
        let webViewURL = webView.url
        print("webViewURL:",webViewURL)
        let strURL = String(describing: webViewURL!)
        print("strURL:",strURL)

        if (strURL.contains(appDelegate.websiteURL + "/?code=")){
            let URL = strURL.components(separatedBy: "=")
            let code = URL.count > 1 ? URL[1] : ""
            print("code:",code)
            fanAuth(code: code)
        }

      }
    func clearCache() {
            HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
            print("[WebCacheCleaner] All cookies deleted")
            
            WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
                records.forEach { record in
                    WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
                    print("[WebCacheCleaner] Record \(record) deleted")
                }
            }
        }
    // MARK: Handler for events(events) API
    func fanAuth(code:String){
        print("fanAuth cld")
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let url: String = appDelegate.profileURL + "/fanAuth"
        //print("getEvents input:",inputData)
       viewActivity.isHidden = false
        let inputData: [String: Any] = ["code":code,"redirect_uri": appDelegate.websiteURL + "/"]
        print("fanAuth input:",inputData)

       viewActivity.isHidden = false
        //let ol_access_token = "55b8bd17f0070ab1d17854d85ba75e33ddd678888470f0c17922fe2d4d92ed5f"
        let headers: HTTPHeaders = [
            "Authorization": "Bearer " + appDelegate.ol_access_token,
            "Accept": "application/json"
        ]
        AF.request(url, method: .post,parameters: inputData, encoding: JSONEncoding.default,headers:headers)
            .responseJSON { response in
                DispatchQueue.main.async {
                    self.viewActivity.isHidden = true
                    switch response.result {
                    case .success(let value):
                        print("response.result:",value)
                        if let json = value as? [String: Any] {
                            print("fanAuth JSON:",json)
                            if(json["status"] as? Int == 0){
                                let user = json["user"] as? [String:Any] ?? [:]
                                //print("user:",user)
                                let username = user["email"] as? String ?? ""
                                UserDefaults.standard.set(username, forKey: "user_email")

                                if (user["is_verified"] as? String == "0"){
                                    let storyboard = UIStoryboard(name: "Main", bundle: nil);
                                    let vc = storyboard.instantiateViewController(withIdentifier: "ConfirmSignUpVC") as! ConfirmSignUpVC
                                    self.navigationController?.pushViewController(vc, animated: true)
                                }else{
                                    /* self.delayWithSeconds(2.0){
                                     self.viewActivity.isHidden = false
                                     self.getUser();
                                     }*/
                                    let userID = user["id"]as? String ?? ""
                                    //print("====userId:",userID)
                                    UserDefaults.standard.set(userID, forKey: "user_id")
                                    UserDefaults.standard.set(user["user_type"], forKey: "user_type")
                                    UserDefaults.standard.set(user["session_token"], forKey: "session_token")
                                    let fn = user["user_first_name"] as? String ?? ""
                                    let ln = user["user_last_name"]as? String ?? ""
                                    let displayName = user["user_display_name"]as? String ?? ""
                                    
                                    let strName = String((fn.first ?? "A")) + String((ln.first ?? "B"))
                                    self.appDelegate.USER_NAME = strName;
                                    self.appDelegate.USER_NAME_FULL = (fn ?? "") + " " + (ln ?? "")
                                    self.appDelegate.USER_DISPLAY_NAME = displayName
                                    
                                    UserDefaults.standard.set(self.appDelegate.USER_NAME, forKey: "USER_NAME")
                                    UserDefaults.standard.set(self.appDelegate.USER_NAME_FULL, forKey: "USER_NAME_FULL")
                                    UserDefaults.standard.set(displayName, forKey: "user_display_name")
                                    self.createDeviceToken()
                                    self.sendBirdConnect()
                                    let date_of_birth = user["date_of_birth"]as? String ?? ""
                                    let user_phone_number = user["user_phone_number"]as? String ?? ""
                                    let storyboard = UIStoryboard(name: "Main", bundle: nil);
                                    self.clearCache()
                                    //if anyone of below fields are empty, then we should navigate to Profile otherwise Dashbaord
                                    if(date_of_birth != "" && username != "" &&  displayName != "" &&  fn != "" && ln != "" && user_phone_number != ""){
                                        DispatchQueue.main.async {
                                            let vc = storyboard.instantiateViewController(withIdentifier: "DashBoardVC") as! DashBoardVC
                                            self.navigationController?.pushViewController(vc, animated: true)
                                        }
                                    }else{
                                        DispatchQueue.main.async {
                                            let vc = storyboard.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
                                            vc.isCameFrom = "login_social"
                                            self.navigationController?.pushViewController(vc, animated: true)
                                        }
                                    }
                                    
                                }
                                //user.custom_attributes.is_user_verify
                            }else{
                                let strMsg = json["message"] as? String ?? ""
                                self.showAlert(strMsg: strMsg)
                                
                            }

                        }
                    case .failure(let error):
                        let errorDesc = error.localizedDescription.replacingOccurrences(of: "URLSessionTask failed with error:", with: "")
                        print("getEvents errorDesc:",errorDesc)
                       self.showAlert(strMsg: errorDesc)
                       self.viewActivity.isHidden = true
                        
                    }
                }
        }
    }
    @IBAction func back(_ sender: Any) {
        self.navigationController!.popViewController(animated: true)
    }
    func createDeviceToken(){
        print("===createDeviceToken")
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let url: String = appDelegate.FCMBaseURL + "/createDeviceToken"
        //print("getEvents input:",inputData)
        //viewActivity.isHidden = false
       let user_id = UserDefaults.standard.string(forKey: "user_id");
        let inputData: [String: Any] = ["user_id":user_id ?? "","device_token":appDelegate.strFCMToken]
        print("inputData of createDeviceToken:",inputData)
        let headers: HTTPHeaders
        headers = [appDelegate.x_api_key: appDelegate.x_api_value]
        AF.request(url, method: .post,parameters: inputData, encoding: JSONEncoding.default,headers:headers)
            .responseJSON { response in
                DispatchQueue.main.async {
                    //self.viewActivity.isHidden = true
                    switch response.result {
                    case .success(let value):
                        if let json = value as? [String: Any] {
                            print("createDeviceToken JSON:",json)
                            if (json["statusCode"]as? String == "200" ){
                                let arn  = json["data"] as? String ?? "";
                                print("arn:",arn)
                                UserDefaults.standard.set(arn, forKey: "arn")
                            }else{
                                
                            }
                            //self.tblMain.reloadSections([1], with: .none)
                            // self.tblMain.reloadData()
                        }
                    case .failure(let error):
                        let errorDesc = error.localizedDescription.replacingOccurrences(of: "URLSessionTask failed with error:", with: "")
                        //print("getEvents errorDesc:",errorDesc)
//                        self.showAlert(strMsg: errorDesc)
//                        self.viewActivity.isHidden = true
                        
                    }
                }
        }
    }
    func sendBirdConnect() {
        if SBDMain.getConnectState() == .open {
            SBDMain.disconnect {
                self.sendBirdConnect()
            }
        }
        else {
            //viewActivity.isHidden = false
            let userId = UserDefaults.standard.string(forKey: "user_id");
            let nickname = appDelegate.USER_NAME_FULL
            let userDefault = UserDefaults.standard
            userDefault.setValue(userId, forKey: "sendbird_user_id")
            userDefault.setValue(nickname, forKey: "sendbird_user_nickname")
            ConnectionManager.login(userId: userId ?? "1", nickname: nickname) { user, error in
                self.viewActivity.isHidden = true
                guard error == nil else {
                    DispatchQueue.main.async {
                    }
                    return
                }
               
            }
        }
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

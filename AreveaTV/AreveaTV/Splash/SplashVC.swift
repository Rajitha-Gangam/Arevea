//
//  SplashViewController.swift
//  aws_amplify_integration
//
//  Created by Calin Cristian on 27/03/2019.
//  Copyright © 2019 Calin Cristian Ciubotariu. All rights reserved.
//

import UIKit
import AWSMobileClient
import SendBirdSDK
import AWSAPIGateway
import AWSAuthCore
import AWSCognito
import Alamofire

class SplashVC: UIViewController {
    // MARK: - Variables Declaration
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var netAvailable = true
    @IBOutlet weak var viewActivity: UIView!
    var isLoad = false
    // MARK: - View Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        viewActivity.isHidden = true
        //assignbackground();
        self.navigationController?.isNavigationBarHidden = true
        isLoad = true
        delayWithSeconds(2.0){}
        getToken()
        
        var timer = Timer()
        timer = Timer.scheduledTimer(timeInterval: 36000.0, target: self, selector: #selector(repeatMethod), userInfo: nil, repeats: true)// 10 hours = 36000.0 seconds
        
        if(UIDevice.current.userInterfaceIdiom == .phone){
            let value = UIInterfaceOrientation.portrait.rawValue
            UIDevice.current.setValue(value, forKey: "orientation")
        }
    }
    @objc func repeatMethod(){
        isLoad = false
        getToken()
    }
    func getToken(){
        
        let url: String = appDelegate.ol_base_url + "/auth/oauth2/v2/token"
        let client_details = "client_id:" + appDelegate.ol_client_id + ",client_secret:" + appDelegate.ol_client_secret
        let inputData = ["grant_type":"client_credentials"]
        viewActivity.isHidden = false
        let headers: HTTPHeaders = [
            "Authorization": client_details,
            "Accept": "application/json"
        ]
        AF.request(url, method: .post,parameters: inputData, encoding: JSONEncoding.default,headers:headers)
            .responseJSON { response in
                self.viewActivity.isHidden = true
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any] {
                        print("getToken JSON:",json)
                        self.appDelegate.ol_access_token = json["access_token"] as? String ?? ""
                        UserDefaults.standard.set(self.appDelegate.ol_access_token, forKey: "ol_access_token")
                        if(self.isLoad){
                            self.initOL()
                        }
                    }
                case .failure(let error):
                    let errorDesc = error.localizedDescription.replacingOccurrences(of: "URLSessionTask failed with error:", with: "")
                    //self.showAlert(strMsg: errorDesc)
                    // self.viewActivity.isHidden = true
                    
                }
        }
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        // Create a service configuration
        let serviceConfiguration = AWSServiceConfiguration(region: AWSRegionType.USWest2,
                                                           credentialsProvider: AWSMobileClient.default())
        // Initialize the API client using the service configuration
        AreveaAPIClient.registerClient(withConfiguration: serviceConfiguration!, forKey: appDelegate.AWSCognitoIdentityPoolId)
    }
    
    func showAlert(strMsg: String){
        let alert = UIAlertController(title: "Alert", message: strMsg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
    func delayWithSeconds(_ seconds: Double, completion: @escaping () -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            completion()
        }
    }
    func initOL(){
        // UserDefaults.standard.set("101059776", forKey: "user_id")
        
        let userId = UserDefaults.standard.string(forKey: "user_id")
        if (userId != nil && userId != "0")  {
            self.sendBirdConnect()
        }else{
            let storyboard = UIStoryboard(name: "Main", bundle: nil);
            let vc = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    func initAWS(){
        let netAvailable = appDelegate.isConnectedToInternet()
        if(!netAvailable){
            showAlert(strMsg: "Please check your internet connection!")
            return
        }
        //self.viewActivity.isHidden = false
        
        AWSMobileClient.default().initialize { (userState, error) in
            if let error = error {
                //print("error: \(error.localizedDescription)")
                return
            }
            
            guard let userState = userState else {
                return
            }
            //self.viewActivity.isHidden = true
            
            //print("The user is \(userState.rawValue).")
            
            
            // Check if user availability
            switch userState {
            case .signedIn:
                NSLog("signedIn");
                if UserDefaults.standard.string(forKey: "user_id") != nil  {
                    self.sendBirdConnect()
                }else{
                    //if user is in signed in state, but app deleted, then we do not user values
                    AWSMobileClient.default().signOut() { error in
                        if let error = error {
                            //print(error)
                            return
                        }
                    }
                    let storyboard = UIStoryboard(name: "Main", bundle: nil);
                    let vc = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            default:
                NSLog("default");
                let storyboard = UIStoryboard(name: "Main", bundle: nil);
                let vc = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    func assignbackground(){
        let background = UIImage(named: "splash")
        var imageView : UIImageView!
        imageView = UIImageView(frame: view.bounds)
        imageView.contentMode =  UIView.ContentMode.scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = background
        imageView.center = view.center
        view.addSubview(imageView)
        self.view.sendSubviewToBack(imageView)
    }
    func sendBirdConnect() {
        
        // self.view.endEditing(true)
        if SBDMain.getConnectState() == .open {
            SBDMain.disconnect {
                //                DispatchQueue.main.async {
                //                    //self.setUIsForDefault()
                //                }
                self.sendBirdConnect()
            }
            //print("sendBirdConnect disconnect")
        }
        else {
            // viewActivity.isHidden = false
            
            let userId = UserDefaults.standard.string(forKey: "user_id");
            let nickname = appDelegate.USER_NAME_FULL
            
            let userDefault = UserDefaults.standard
            userDefault.setValue(userId, forKey: "sendbird_user_id")
            userDefault.setValue(nickname, forKey: "sendbird_user_nickname")
            
            //self.setUIsWhileConnecting()
            
            ConnectionManager.login(userId: userId ?? "1", nickname: nickname) { user, error in
                // self.viewActivity.isHidden = true
                
                guard error == nil else {
                    DispatchQueue.main.async {
                        // self.setUIsForDefault()
                    }
                    // self.showAlert(strMsg:error?.localizedDescription ?? "" )
                    return
                }
                
                DispatchQueue.main.async {
                    // self.setUIsForDefault()
                    //print("Logged In With SendBird Successfully")
                    let storyboard = UIStoryboard(name: "Main", bundle: nil);
                    let vc = storyboard.instantiateViewController(withIdentifier: "DashBoardVC") as! DashBoardVC
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent // .default
    }
    override func viewWillDisappear(_ animated: Bool) {
        AppDelegate.AppUtility.lockOrientation(.all)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        AppDelegate.AppUtility.lockOrientation(.portrait)
    }
    
}

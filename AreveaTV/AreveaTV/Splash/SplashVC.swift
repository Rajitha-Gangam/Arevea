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

class SplashVC: UIViewController {
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        assignbackground();
        self.navigationController?.isNavigationBarHidden = true
        
        //        activityIndicator.isHidden = false
        //        activityIndicator.startAnimating()
        delayWithSeconds(2.0){
            self.initAWS();
        }
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    func delayWithSeconds(_ seconds: Double, completion: @escaping () -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            completion()
        }
    }
    func initAWS(){
        AWSMobileClient.sharedInstance().initialize { (userState, error) in
            if let error = error {
                print("error: \(error.localizedDescription)")
                return
            }
            
            guard let userState = userState else {
                return
            }
            
            print("The user is \(userState.rawValue).")
            
            // self.activityIndicator.stopAnimating()
            
            // Check if user availability
            switch userState {
            case .signedIn:
                NSLog("signedIn");
                if UserDefaults.standard.string(forKey: "user_id") != nil  {
                    self.sendBirdConnect()
                }else{
                    //if user is in signed in state, but app deleted, then we do not user values
                    AWSMobileClient.sharedInstance().signOut() { error in
                        if let error = error {
                            print(error)
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
            print("sendBirdConnect disconnect")
        }
        else {
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
            let userId = UserDefaults.standard.string(forKey: "user_id");
            let nickname = appDelegate.USER_NAME_FULL
            
            let userDefault = UserDefaults.standard
            userDefault.setValue(userId, forKey: "sendbird_user_id")
            userDefault.setValue(nickname, forKey: "sendbird_user_nickname")
            
            //self.setUIsWhileConnecting()
            
            ConnectionManager.login(userId: userId ?? "1", nickname: nickname) { user, error in
                self.activityIndicator.isHidden = true;
                self.activityIndicator.stopAnimating();
                guard error == nil else {
                    DispatchQueue.main.async {
                        // self.setUIsForDefault()
                    }
                    // self.showAlert(strMsg:error?.localizedDescription ?? "" )
                    return
                }
                
                DispatchQueue.main.async {
                    // self.setUIsForDefault()
                    print("Logged In With SendBird Successfully")
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
}

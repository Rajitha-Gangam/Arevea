//
//  SplashViewController.swift
//  aws_amplify_integration
//
//  Created by Calin Cristian on 27/03/2019.
//  Copyright © 2019 Calin Cristian Ciubotariu. All rights reserved.
//

import UIKit
import AWSMobileClient
class SplashVC: UIViewController {
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
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
                // Show home page
                NSLog("signedIn");
                let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "DashBoardVC") as? DashBoardVC
                self.navigationController?.pushViewController(vc!, animated: true)
                break
            default:
                NSLog("default");
                let storyboard = UIStoryboard(name: "Main", bundle: nil);
                let vc = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                self.navigationController?.pushViewController(vc, animated: true)
                break
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
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent // .default
    }
}

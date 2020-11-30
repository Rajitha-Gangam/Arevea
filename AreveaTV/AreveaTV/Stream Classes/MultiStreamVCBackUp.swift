//
//  MultiStreamVCBackUp.swift
//  AreveaTV
//
//  Created by apple on 11/10/20.
//  Copyright © 2020 apple. All rights reserved.
//

import UIKit
import UIKit
import R5Streaming
import Alamofire
import AWSAppSync
import SendBirdSDK
import  WebKit
import Reachability

class MultiStreamVCBackUp: UIViewController {
    // MARK: - Variables Declaration
    
    var aryStreamInfo = [String: Any]()
    
    
    @IBOutlet weak var heightTopView: NSLayoutConstraint?
    @IBOutlet weak var viewTop: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var viewActivity: UIView!
    @IBOutlet weak var viewStream: UIView!
    @IBOutlet weak var lblStreamUnavailable: UILabel!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var strTitle = ""
    var orgId = 0;
    var performerId = 0;
    var streamId = 0;
    var streamVideoCode = ""
    var strSlug = "";
    @IBOutlet weak var imgStreamThumbNail: UIImageView!
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        print("viewDidLoad:",viewDidLoad)
        super.viewDidLoad()
        lblTitle.text = strTitle
        viewActivity.isHidden = true
        if(UIDevice.current.userInterfaceIdiom == .pad){
            self.imgStreamThumbNail.image = UIImage.init(named: "sample-event")
        }else{
            self.imgStreamThumbNail.image = UIImage.init(named: "sample_vod_square")
        }
        
        LiveEventById()
    }
    func LiveEventById() {
        /*viewVOD.isHidden = false
         viewLiveStream.isHidden = true
         lblAmount.text = ""
         self.showVideo(strURL: "http://demo.unified-streaming.com/video/tears-of-steel/tears-of-steel.ism/.m3u8");
         return*/
        
        viewActivity.isHidden = false
        let netAvailable = appDelegate.isConnectedToInternet()
        if(!netAvailable){
            showAlert(strMsg: "Please check your internet connection!")
            return
        }
        
        let url: String = appDelegate.baseURL +  "/LiveEventById"
        let user_id = UserDefaults.standard.string(forKey: "user_id");
        var streamIdLocal = "0"
        if (streamId != 0){
            streamIdLocal = String(streamId)
        }
        let headers: HTTPHeaders
        headers = [appDelegate.x_api_key: appDelegate.x_api_value]
        
        let params: [String: Any] = ["userid":user_id ?? "","performer_id":performerId,"stream_id": streamIdLocal]
        print("liveEvents params msb:",params)
        // let params: [String: Any] = ["userid":user_id ?? "","performer_id":"101","stream_id": "0"]
        AF.request(url, method: .post,parameters: params, encoding: JSONEncoding.default,headers:headers)
            .responseJSON { [self] response in
                self.viewActivity.isHidden = true
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any] {
                        print("LiveEventById JSON:",json)
                        if (json["statusCode"]as? String == "200"){
                            let data = json["Data"] as? [String:Any]
                            self.aryStreamInfo = data?["stream_info"] as? [String:Any] ?? [:]
                            let stream_info_key_exists = self.aryStreamInfo["id"]
                            if (stream_info_key_exists != nil){
                                let streamObj = self.aryStreamInfo
                                self.strSlug = streamObj["slug"] as? String ?? "";

                                let streamBannerURL = streamObj["video_banner_image"] as? String ?? ""
                                if let urlBanner = URL(string: streamBannerURL){
                                    var imageName = "sample_vod_square"
                                    if(UIDevice.current.userInterfaceIdiom == .pad){
                                        imageName = "sample-event"
                                    }
                                    self.imgStreamThumbNail.sd_setImage(with:urlBanner, placeholderImage: UIImage(named: imageName))
                                }
                            }
                        }
                        else{
                            let strError = json["message"] as? String
                            ////print("strError1:",strError ?? "")
                            self.showAlert(strMsg: strError ?? "")
                        }
                    }
                case .failure(let error):
                    let errorDesc = error.localizedDescription.replacingOccurrences(of: "URLSessionTask failed with error:", with: "")
                    self.showAlert(strMsg: errorDesc)
                    self.viewActivity.isHidden = true
                }
            }
    }
    func popToDashBoard(){
        //print("vc:",self.navigationController!.viewControllers)
        //self.showAlert(strMsg: String(self.navigationController!.viewControllers.count))
        for controller in self.navigationController!.viewControllers as Array {
            if controller.isKind(of: DashBoardVC.self) {
                self.navigationController!.popToViewController(controller, animated: true)
                if(UIDevice.current.userInterfaceIdiom == .phone){
                    NSLog("==orientation")
                    let value = UIInterfaceOrientation.portrait.rawValue
                    UIDevice.current.setValue(value, forKey: "orientation")
                }
                break
            }
        }
    }
    func showAlert(strMsg: String){
        let alert = UIAlertController(title: "Alert", message: strMsg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
    
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)

    }
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        if(UIDevice.current.userInterfaceIdiom == .phone){
            let value = UIInterfaceOrientation.landscapeRight.rawValue
            UIDevice.current.setValue(value, forKey: "orientation")
        }
        AppDelegate.AppUtility.lockOrientation(.landscapeRight)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        AppDelegate.AppUtility.lockOrientation(.landscape, andRotateTo: .landscapeRight)
        viewStream.layoutIfNeeded()
    }
    
    @IBAction func copyText(_ sender: Any){
        let url = appDelegate.websiteURL + "/event/" + self.strSlug
        print("Copy Button tapped:",url)

        UIPasteboard.general.string = url// or use  sender.titleLabel.text
        showAlert(strMsg: "Copied")
    }
}

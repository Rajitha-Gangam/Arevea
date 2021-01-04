//
//  ChannelDetailVC.swift
//  AreveaTV
//
//  Created by apple on 4/25/20.
//  Copyright © 2020 apple. All rights reserved.
//

import UIKit
import AVFoundation
import Alamofire
import AVKit

class ChannelDetailVC: UIViewController,UICollectionViewDataSource,UITableViewDataSource,UITableViewDelegate,UIWebViewDelegate,UICollectionViewDelegateFlowLayout,OpenChanannelChatDelegate{
    // MARK: - Variables Declaration
    
    @IBOutlet weak var scrollButtons: UIScrollView!
    @IBOutlet weak var buttonCVC: UICollectionView!
    
    @IBOutlet weak var viewBottom: UIView!
    @IBOutlet weak var viewInfo: UIView!
    @IBOutlet weak var viewAudios: UIView!
    @IBOutlet weak var viewVideos: UIView!
    @IBOutlet weak var viewUpcoming: UIView!
    @IBOutlet weak var viewSubscriptions: UIView!
    
    @IBOutlet weak var tblVideos: UITableView!
    @IBOutlet weak var tblAudios: UITableView!
    @IBOutlet weak var tblUpcoming: UITableView!
    @IBOutlet weak var tblSubscriptions: UITableView!
    @IBOutlet weak var txtProfile: UITextView!
    var arySubscriptionDetails = [Any]();
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    @IBOutlet weak var viewLiveStream: UIView!
    var dicPerformerInfo = [String: Any]()
    var aryStreamInfo = [Any]()
    var aryUserSubscriptionInfo = [Any]()
    var orgId = 0;
    var performerId = 0;
    var aryVideos = [Any]();
    var aryAudios = [Any]();
    var aryUpcoming = [Any]();
    var arySubscriptions = [Any]();
    
    var audioList: [String] = []
    var videoPlayer = AVPlayer()
    var streamVideoCode = ""
    var orgInfo = [String:Any]()
    var streamId = 0;
    var buttonNames = ["EVENTS","INFO","VIDEOS","AUDIOS","SUBSCRIBE"]//"SUBSCRIBE"
    var playerItem:AVPlayerItem?
    var player:AVPlayer?
    var slider: UISlider?
    var isLoaded = 0;
    var channel_name = ""
    var videoUrl = ""
    var backPressed = false
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var imgPerformerProfile :UIImageView!
    
    @IBOutlet weak var txtVideoDesc_Info: UITextView!
    @IBOutlet weak var lblVideoTitle_Info: UILabel!
    
    @IBOutlet weak var lblNoDataUpcoming: UILabel!
    @IBOutlet weak var lblNoDataVideos: UILabel!
    @IBOutlet weak var lblNoDataAudios: UILabel!
    @IBOutlet weak var lblNoDataSubscriptions: UILabel!
    
    @IBOutlet weak var lblTitle: UILabel!
    // MARK: - Live Chat Inputs
    @IBOutlet weak var liveStreamHeight: NSLayoutConstraint!
    
    weak var delegate: OpenChanannelChatDelegate?
    var paymentAmount = 0
    var streamPaymentMode = ""
    var strTitle = ""
    @IBOutlet weak var viewActivity: UIView!
    var isVOD = false;
    @IBOutlet weak var imgStreamThumbNail: UIImageView!
    var isStream = true;
    var isUpcoming = false;
    var isVideo = false;
    var isAudio = false;
    var fromSubscribed = false;
    @IBOutlet weak var heightTopView: NSLayoutConstraint?
    @IBOutlet weak var viewTop: UIView!
    var subscription_details = false
    var jsonCurrencyList = [String:Any]()

    // MARK: - View Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        viewActivity.isHidden = true
        // Do any additional setup after loading the view.
        registerNibs();
        ////print("detail item in channnel page:\(detailItem)")
        
        lblNoDataUpcoming.text = "No events found"
        lblNoDataVideos.text = "No videos found"
        lblNoDataAudios.text = "No audios found"
        lblTitle.text = strTitle
        if(UIDevice.current.userInterfaceIdiom == .pad){
            heightTopView?.constant = 60;
            viewTop.layoutIfNeeded()
            viewLiveStream.layoutIfNeeded()
        }
        self.imgStreamThumbNail.image = UIImage(named: "user")
        self.imgStreamThumbNail.contentMode = .scaleAspectFit
        self.txtProfile.text = ""
        self.lblNoDataSubscriptions.text = ""
        if(self.channel_name == ""){
                   self.channel_name = " "
               }

        if let path = Bundle.main.path(forResource: "currencies", ofType: "json") {
                    do {
                        let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                        let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                        if let jsonResult = jsonResult as? Dictionary<String, AnyObject>
                            {
                            // do stuff
                            jsonCurrencyList = jsonResult
                        }
                    } catch {
                        // handle error
                    }
                }

    }
    
    
    func registerNibs() {
        if(UIDevice.current.userInterfaceIdiom == .pad){
            let nib = UINib(nibName: "ButtonsCVC-iPad", bundle: nil)
            buttonCVC?.register(nib, forCellWithReuseIdentifier:"ButtonsCVC")
        }else{
            let nib = UINib(nibName: "ButtonsCVC", bundle: nil)
            buttonCVC?.register(nib, forCellWithReuseIdentifier:"ButtonsCVC")
        }
        
        if let flowLayout = self.buttonCVC?.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.estimatedItemSize = CGSize(width: 1, height: 1)
        }
        
        tblAudios.register(UINib(nibName: "VideoCell", bundle: nil), forCellReuseIdentifier: "VideoCell");
        tblVideos.register(UINib(nibName: "VideoCell", bundle: nil), forCellReuseIdentifier: "VideoCell")
        tblUpcoming.register(UINib(nibName: "UpcomingCell", bundle: nil), forCellReuseIdentifier: "UpcomingCell")
        tblSubscriptions.register(UINib(nibName: "SubscriptionCell", bundle: nil), forCellReuseIdentifier: "SubscriptionCell")
        
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true);
        backPressed = false
        self.imgPerformerProfile.layer.cornerRadius = self.imgPerformerProfile.frame.size.width/2
        self.imgPerformerProfile.layer.borderColor = UIColor.gray.cgColor
        self.imgPerformerProfile.layer.borderWidth = 1.0
        performerEvents();
        getPerformerInfo();
        getChannelSubscriptionPlans();
        getSubscriptionStatus();
        
        if(isLoaded == 0 || appDelegate.isLiveLoad == "1"){
            let netAvailable = appDelegate.isConnectedToInternet()
            if(!netAvailable){
                showAlert(strMsg: "Please check your internet connection!")
                return
            }
            isLoaded = 1;
            appDelegate.isLiveLoad = "0";
            performerVideos();
            performerAudios();
            
        }
        hideViews();
        var tag = 11
        
        if(fromSubscribed){
            //bottom first object should show
            tag = 14
            viewSubscriptions.isHidden = false
        }else{
            if(isAudio){
                tag = 13
                viewAudios.isHidden = false
            }else if(isUpcoming){
                tag = 10
                viewUpcoming.isHidden = false
            }else if(isVideo){
                tag = 12
                viewVideos.isHidden = false
            }else{
                viewInfo.isHidden = false
            }
        }
        //bottom first object should show
        let infoLine = self.buttonCVC.viewWithTag(tag) as? UILabel
        let btnText = self.buttonCVC.viewWithTag(tag + 10) as? UIButton
        let orange = UIColor(red: 95, green: 84, blue: 55);
        infoLine?.backgroundColor = orange;
        infoLine?.isHidden = false;
        btnText?.setTitleColor(orange, for: .normal)
        
        
        
        let viewHeight = self.view.frame.size.height * 0.35
        liveStreamHeight.constant = CGFloat(viewHeight)
        self.viewLiveStream.layoutIfNeeded()
        
        
    }
    
    @IBAction func back(_ sender: Any) {
        if (!backPressed){
            backPressed = true
            self.navigationController?.popViewController(animated: true)
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
    // MARK: - Collection View Data Source
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return buttonNames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ButtonsCVC",for: indexPath) as? ButtonsCVC {
            let name = buttonNames[indexPath.row]
            cell.configureCell(name: name)
            cell.btn.addTarget(self, action: #selector(btnPress(_:)), for: .touchUpInside)
            cell.btn.tag = 20 + (indexPath.row);
            cell.lblLine.tag = 10 + (indexPath.row);
            //cell.btn.setTitleColor(.white, for: .normal)
            return cell
        }
        return UICollectionViewCell()
    }
    
    
    //MARK: Main function, handling bottom views logic based on selection here
    func hideViews(){
        print("hideViews")
        viewInfo.isHidden = true;
        viewAudios.isHidden = true;
        viewVideos.isHidden = true;
        viewUpcoming.isHidden = true;
        viewSubscriptions.isHidden = true;
        
        for (index,_) in buttonNames.enumerated() {
            let lineTag = 10 + index;
            let btnTag = 20 + index;
            let lblLine = self.buttonCVC.viewWithTag(lineTag) as? UILabel
            let btnText = self.buttonCVC.viewWithTag(btnTag) as? UIButton
            lblLine?.isHidden = true;
            btnText?.setTitleColor(.white, for: .normal)
        }
    }
    @objc func btnPress(_ sender: UIButton) {
        hideViews();
        let title = sender.titleLabel?.text!
        for (index,_) in buttonNames.enumerated() {
            let name = buttonNames[index]
            let lineTag = 10 + index;
            let btnTag = 20 + index;
            let lblLine = self.buttonCVC.viewWithTag(lineTag) as? UILabel
            let btnText = self.buttonCVC.viewWithTag(btnTag) as? UIButton
            if (name == title){
                //print("btnTag:",btnTag)
                let orange = UIColor(red: 95, green: 84, blue: 55);
                lblLine?.backgroundColor = orange;
                lblLine?.isHidden = false;
                btnText?.setTitleColor(orange, for: .normal)
            }else{
                lblLine?.isHidden = true;
                btnText?.setTitleColor(.white, for: .normal)
            }
        }
        switch title?.lowercased() {
        case "info":
            viewInfo.isHidden = false;
        case "audios":
            viewAudios.isHidden = false;
        case "videos":
            viewVideos.isHidden = false;
        case "events":
            viewUpcoming.isHidden = false;
        case "subscribe":
            print("subscribe")
            viewSubscriptions.isHidden = false;
        default:
            break
        }
    }
    
    
    //MARK: Private Functions
    
    // Create function for your button
    @objc func playPauseTapped(sender: UIButton) {
        
        if player?.rate == 0
        {
            player!.play()
            if #available(iOS 13.0, *) {
                sender.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            } else {
                // Fallback on earlier versions
            }
        } else {
            player!.pause()
            if #available(iOS 13.0, *) {
                sender.setImage(UIImage(systemName: "play.fill"), for: .normal)
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    @objc func sliderChanged(sender: UISlider) {
        
        let seconds : Int64 = Int64(sender.value)
        let targetTime:CMTime = CMTimeMake(value: seconds, timescale: 1)
        
        player!.seek(to: targetTime)
        
        player!.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, preferredTimescale: 1), queue: DispatchQueue.main) { (CMTime) -> Void in
            if self.player!.currentItem?.status == .readyToPlay {
                let time : Float64 = CMTimeGetSeconds(self.player!.currentTime());
                sender.value = Float ( time );
            }
        }
        let btn = self.view.viewWithTag(100+(sender.tag)) as? UIButton
        
        if player?.rate == 0
        {
            player!.play()
            if #available(iOS 13.0, *) {
                btn!.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            } else {
                // Fallback on earlier versions
            }
        }
        else {
            //            player!.pause()
            //            if #available(iOS 13.0, *) {
            //                btn.setImage(UIImage(systemName: "play.fill"), for: .normal)
            //            } else {
            //                // Fallback on earlier versions
            //            }
        }
    }
    //MARK:Tableview Delegates and Datasource Methods
    
    func numberOfSections(in tableView: UITableView) ->  Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tableView == tblAudios)
        {
            if (self.aryAudios.count > 0){
                self.lblNoDataAudios.isHidden = true
                tblAudios.isHidden = false
            }else{
                self.lblNoDataAudios.isHidden = false
                tblAudios.isHidden = true
            }
            return aryAudios.count;
        }else if (tableView == tblUpcoming ){
            if (self.aryUpcoming.count > 0){
                lblNoDataUpcoming.isHidden = true
            }else{
                lblNoDataUpcoming.isHidden = false
            }
            return aryUpcoming.count;
        }else if (tableView == tblSubscriptions ){
            if (self.arySubscriptions.count > 0){
                lblNoDataSubscriptions.isHidden = true
            }else{
                lblNoDataSubscriptions.isHidden = false
            }
            return arySubscriptions.count;
        }
        else if(tableView == tblVideos){
            if (self.aryVideos.count > 0){
                self.lblNoDataVideos.isHidden = true
                tblVideos.isHidden = false
                
            }else{
                self.lblNoDataVideos.isHidden = false
                tblVideos.isHidden = true
                
            }
            return aryVideos.count;
        }
        
        return 0;
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) ->  CGFloat {
        if (tableView == tblVideos){
            if(UIDevice.current.userInterfaceIdiom == .pad){
                return 500;
            }
            return 300;
        }else if  (tableView == tblAudios){
            if(UIDevice.current.userInterfaceIdiom == .pad){
                return 500;
            }
            return 300;
        }else if  (tableView == tblUpcoming){
            return 105;
        }else if  (tableView == tblSubscriptions){
            return 170;
        }
        return 44;
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (tableView == tblVideos || tableView == tblAudios){
            let cell = tableView.dequeueReusableCell(withIdentifier: "VideoCell") as! VideoCell
            cell.btnVideo.tag = indexPath.row
            cell.btnVideo1.tag = indexPath.row
            var upcoming = [String : Any]();
            if(tableView == tblVideos){
                upcoming = self.aryVideos[indexPath.row] as? [String : Any] ?? [:];
            }
            if(tableView == tblAudios){
                upcoming = self.aryAudios[indexPath.row] as? [String : Any] ?? [:];
                cell.btnVideo.addTarget(self, action: #selector(playAudioBtnTapped(_:)), for: .touchUpInside)
                cell.btnVideo1.addTarget(self, action: #selector(playAudioBtnTapped(_:)), for: .touchUpInside)
            }else{
                cell.btnVideo.addTarget(self, action: #selector(playVideoBtnTapped(_:)), for: .touchUpInside)
                cell.btnVideo1.addTarget(self, action: #selector(playVideoBtnTapped(_:)), for: .touchUpInside)
            }
            let streamInfo = upcoming["stream_info"] as? [String : Any];
            let strURL = streamInfo?["video_thumbnail_image"] as? String ?? "";
            let videoTitle = streamInfo?["stream_video_title"] as? String ?? "";
            cell.lblTitle.text = videoTitle
            //print("--vod strURL:",strURL);
            if let urlVideoThumbImage = URL(string: strURL){
                var imagePlaceHolder = "sample-details"
                if(UIDevice.current.userInterfaceIdiom == .pad){
                    imagePlaceHolder = "sample_vod_land"
                }
                // self.videoThumbNail(from: urlVideoThumbImage, button: cell.btnVideo)
                cell.btnVideo.sd_setBackgroundImage(with:urlVideoThumbImage, for:
                                                        UIControl.State.normal, placeholderImage: UIImage(named:
                                                                                                            imagePlaceHolder))
            }else{
                if(UIDevice.current.userInterfaceIdiom == .pad){
                    cell.btnVideo.setImage((UIImage.init(named: "sample_vod_land")), for: .normal)
                }else{
                    cell.btnVideo.setImage((UIImage.init(named: "sample-details")), for: .normal)
                }
            }
            return cell
        }else if (tableView == tblSubscriptions){
            let cell = tableView.dequeueReusableCell(withIdentifier: "SubscriptionCell") as! SubscriptionCell
            cell.viewContent.layer.borderColor = UIColor.gray.cgColor
            cell.viewContent.layer.borderWidth = 1.0
            cell.btnUnSubscribe.layer.borderColor = UIColor.gray.cgColor
            cell.btnUnSubscribe.layer.borderWidth = 1.0
            
            cell.btnSubscribe.tag = indexPath.row
            cell.btnSubscribe.addTarget(self, action: #selector(subscribeBtnPressed(_:)), for: .touchUpInside)
            cell.btnUnSubscribe.tag = indexPath.row
            cell.btnUnSubscribe.addTarget(self, action: #selector(unSubscribeBtnPressed(_:)), for: .touchUpInside)
            
            cell.btnCheck.isHidden = true
            cell.btnSubscribe.isHidden = false
            cell.btnUnSubscribe.isHidden = true
            
            let subscribeObj = self.arySubscriptions[indexPath.row] as? [String : Any] ?? [:];
            print("==cell for subscribeObj:",subscribeObj)
            
            let feature_details = subscribeObj["feature_details"] as? [Any] ?? [Any]() ;
            // print("feature_details count:",feature_details.count)
            var userIndex = -1
            var creatorIndex = -1
            let tier_amounts = subscribeObj["tier_amounts"] as? String ?? ""

            let aryTierAmounts = self.convertToArray(text: tier_amounts)
            for(j,_)in aryTierAmounts!.enumerated(){
                let object = aryTierAmounts?[j] as? [String : Any] ?? [String:Any]()
                let currency_type1 = object["currency_type"]as? String ?? "";
                if(appDelegate.userCurrencyCode == currency_type1){
                    userIndex = j
                }
//                if(self.currencyType == currency_type1){
//                    creatorIndex = j
//                }
            }
            var index = -1
            if(userIndex != -1){
                index = userIndex
            }else {
                index = creatorIndex
            }
            if(index != -1){
                let object = aryTierAmounts?[index] as? [String : Any] ?? [String:Any]()
                let tier_amount = object["payment_amount"] as? Double ?? 0.0
                let currency_type = object["currency_type"] as? String ?? ""
                let currencySymbol1 = jsonCurrencyList[currency_type] as? String
                let currencySymbol = currencySymbol1 ?? "$"
                let amount = String(format: "%.02f", tier_amount)
                let amountWithCurrencyType = currencySymbol  + amount
                cell.lblAmount.text = amountWithCurrencyType
            }
            
            var tier_amount = subscribeObj["tier_amount"] as? Double ?? 0.0
            // print("amount:",amount)
            var currency_type = subscribeObj["currency"] as? String ?? ""
            print("currency_type1:",currency_type)
            let currencySymbol1 = jsonCurrencyList[currency_type] as? String
            var currencySymbol = currencySymbol1 ?? "$"
            let tier_amount_mode = subscribeObj["tier_amount_mode"] as? String ?? ""
            
            // print("tier_amount_mode:",tier_amount_mode)
            cell.lblAmountMode.text = tier_amount_mode
            var subscription_status = false
            print("==arySubscriptionDetails:",arySubscriptionDetails)
            if(arySubscriptionDetails.count > 0){
                let subscribeObj1 = self.arySubscriptionDetails[0] as? [String : Any] ?? [:];
                subscription_status = subscribeObj1["subscription_status"] as? Bool ?? false
                tier_amount = subscribeObj1["subscription_amount"] as? Double ?? 0.0
                let currency_type1 = subscribeObj1["currency"] as? String ?? ""
                let currencySymbol1 = jsonCurrencyList[currency_type1] as? String
                currencySymbol = currencySymbol1 ?? "$"
            }
            let amount = String(format: "%.02f", tier_amount)
            let amountWithCurrencyType = currencySymbol + amount
            cell.lblAmount.text = amountWithCurrencyType
            
            //if user subscribed
            if(subscription_status){
                let orange = UIColor(red: 95, green: 84, blue: 55);
                cell.viewContent.layer.borderColor = orange.cgColor
                cell.viewContent.layer.borderWidth = 2.0
                cell.btnCheck.isHidden = false
                cell.btnSubscribe.isHidden = true
                cell.btnUnSubscribe.isHidden = false
            }else{
                //if user not subscribed
                cell.btnSubscribe.setTitle("SUBSCRIBE", for: .normal)
                //if user subscribed and cancelled plan
                if(subscription_details){
                    cell.btnSubscribe.setTitle("REACTIVATE", for: .normal)
                }
            }
            for (index,_) in feature_details.enumerated() {
                let feature_details = feature_details[index] as? [String : Any] ?? [:];
                if(index < 4){
                    switch index {
                    case 0:
                        cell.lbl1.text = feature_details["feature_name"] as? String ?? ""
                    case 1:
                        cell.lbl2.text = feature_details["feature_name"] as? String ?? ""
                    case 2:
                        cell.lbl3.text = feature_details["feature_name"] as? String ?? ""
                    case 3:
                        cell.lbl4.text = feature_details["feature_name"] as? String ?? ""
                    default:
                        print("default")
                    }
                }
            }
            return cell
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "UpcomingCell") as! UpcomingCell
            //2020-04-26T19:28:49.000Z
            let upcoming = self.aryUpcoming[indexPath.row] as? [String : Any];
            ////print("--upcoming:",item)
            let streamInfo = upcoming?["stream_info"] as? [String : Any];
            
            cell.lblTitle.text = streamInfo?["stream_video_title"] as? String;
            let streamStatus = streamInfo?["stream_status"] as? String;
            cell.btnStatus.setTitle("NEW", for: .normal)
            let gray = UIColor(red: 95, green: 84, blue: 55);
            cell.btnStatus.backgroundColor = gray
            if(streamStatus == "inprogress"){
                cell.btnStatus.setTitle("LIVE", for: .normal)
                let orange = UIColor(red: 253, green: 107, blue: 4);
                cell.btnStatus.backgroundColor = orange
            }
            let isoDate = streamInfo?["publish_date_time"] as? String ?? ""
            let formatter = DateFormatter()
            formatter.timeZone = NSTimeZone(abbreviation: "UTC") as TimeZone?
            //formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            if let date = formatter.date(from: isoDate) {
                let formatter1 = DateFormatter()
                formatter1.dateFormat = "dd MMM yyyy, hh:mm a"
                cell.lblDate.text = formatter1.string(from: date)
            }else{
                //print ("invalid date");
                cell.lblDate.text = "";
            }
            cell.lblPayment.text = streamInfo?["stream_payment_mode"] as? String;
            //cell.lblPayment.text = String(item["streamPayment"]as! Int) + " USD"
            cell.lblDesc.text = streamInfo?["stream_video_description"] as? String;
            let stream_payment_mode = streamInfo?["stream_payment_mode"] as? String;
            if(stream_payment_mode == "paid"){
                var currency_type = streamInfo?["currency_type"] as? String ?? ""
                let currencySymbol1 = jsonCurrencyList[currency_type] as? String
                       let currencySymbol = currencySymbol1 ?? "$"
               
                var amount = "0.0"
                
                if (streamInfo?["stream_payment_amount"] as? Double) != nil {
                    amount = String(streamInfo?["stream_payment_amount"] as? Double ?? 0.0)
                }else if (streamInfo?["stream_payment_amount"] as? String) != nil {
                    amount = String(streamInfo?["stream_payment_amount"] as? String ?? "0.0")
                }
                
                let payment =  currencySymbol + amount
                cell.lblPayment.text = payment
            }else{
                cell.lblPayment.text = "Free"
            }
            let video_thumbnail_image = streamInfo?["video_banner_image"] as? String ?? ""
            if let urlBanner = URL(string: video_thumbnail_image){
                cell.imgEvent.sd_setImage(with: urlBanner, placeholderImage: UIImage(named: "default-event"))
            }else{
                cell.imgEvent.image = UIImage.init(named: "default-event")
            }
            return cell
        }
        
    }
    func convertToArray(text: String) -> [Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [Any] ?? []
            } catch {
                ////print(error.localizedDescription)
            }
        }
        return nil
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //           let storyboard = UIStoryboard(name: "Main", bundle: nil);
        //           let vc = storyboard.instantiateViewController(withIdentifier: "ChannelDetailVC") as! ChannelDetailVC
        //           self.navigationController?.pushViewController(vc, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
        if (tableView == tblUpcoming){
            let upcoming = self.aryUpcoming[indexPath.row] as? [String : Any];
            print("upcoming:",upcoming)
            let streamInfo = upcoming?["stream_info"] as? [String : Any] ?? [:];
            let number_of_creators = streamInfo["number_of_creators"] as? Int ?? 0
            let performerId = streamInfo["performer_id"]as? Int ?? 0
            let streamId = streamInfo["id"] as? Int ?? 0
            //let streamVideoCode = streamInfo?["stream_video_code"] as? String ?? ""
            let orgId = streamInfo["organization_id"]as? Int ?? 0
            isUpcoming = true
            isVideo = false
            isAudio = false
            LiveEventById(streamInfo: streamInfo,upcoming: true)
            
        }else if  (tableView == tblVideos){
            
            playVideoFromList(row: indexPath.row)
        }
        else if  (tableView == tblAudios){
            playAudioFromList(row: indexPath.row)
        } else if  (tableView == tblSubscriptions){
        }
    }
    @objc func playVideoBtnTapped(_ sender: UIButton)
    {
        playVideoFromList(row: sender.tag)
    }
    @objc func playAudioBtnTapped(_ sender: UIButton)
    {
        playAudioFromList(row: sender.tag)
    }
    @objc func playVideoFromList(row:Int){
        
        let upcoming = self.aryVideos[row] as? [String : Any];
        print("upcoming:",upcoming)
        let streamInfo = upcoming?["stream_info"] as? [String : Any] ?? [:];
        isUpcoming = false
        isVideo = true
        isAudio = false
        LiveEventById(streamInfo: streamInfo, upcoming: false)
        
        /*let performerId = streamInfo?["performer_id"]as? Int ?? 0
         let streamId = streamInfo?["id"] as? Int ?? 0
         let orgId = streamInfo?["organization_id"]as? Int ?? 0
         ////print("self.streamVideoCode:",self.streamVideoCode)
         let url = streamInfo?["video_url"] as? String ?? ""
         videoUrl = url
         isVOD = true;
         let storyboard = UIStoryboard(name: "Main", bundle: nil);
         let vc = storyboard.instantiateViewController(withIdentifier: "StreamDetailVC") as! StreamDetailVC
         vc.streamId = streamId
         vc.orgId = orgId
         vc.delegate = self
         appDelegate.isLiveLoad = "1"
         vc.performerId = performerId;
         vc.strTitle = streamInfo?["stream_video_title"] as? String ?? "Channel Details"
         vc.isVOD = true;
         self.navigationController?.pushViewController(vc, animated: true)*/
        
        
    }
    @objc func playAudioFromList(row:Int){
        let upcoming = self.aryAudios[row] as? [String : Any];
        print("audio:",upcoming)
        let streamInfo = upcoming?["stream_info"] as? [String : Any];
        let performerId = streamInfo?["performer_id"]as? Int ?? 0
        let streamId = streamInfo?["id"] as? Int ?? 0
        let orgId = streamInfo?["organization_id"]as? Int ?? 0
        ////print("self.streamVideoCode:",self.streamVideoCode)
        let url = streamInfo?["video_url"] as? String ?? ""
        let channelName = streamInfo?["channel_name"] as? String ?? ""
        print("::channelName:",channelName)
        videoUrl = url
        let storyboard = UIStoryboard(name: "Main", bundle: nil);
        let vc = storyboard.instantiateViewController(withIdentifier: "StreamDetailVC") as! StreamDetailVC
        vc.streamId = streamId
        vc.delegate = self
        appDelegate.isLiveLoad = "1"
        vc.performerId = performerId;
        vc.strTitle = streamInfo?["stream_video_title"] as? String ?? "Channel Details"
        vc.isAudio = true;
        vc.orgId = orgId
        let  videoUrl = streamInfo?["video_url"] as? String ?? ""
        //print("videoUrl:",videoUrl)
        vc.strAudioSource = videoUrl
        vc.channel_name_subscription = channelName
        isUpcoming = false
        isVideo = false
        isAudio = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @objc func subscribeBtnPressed(_ sender: UIButton){
        //for subscribe
        if(!subscription_details){
            subscribe(row:sender.tag)
        }
        //for reactivate
        else{
            reActivateChannelSubscription(row: sender.tag)
        }
    }
    func subscribe(row:Int){
        print("row:",row)
        //print("row:",row)
        let subscribeObj = self.arySubscriptions[row] as? [String : Any] ?? [:];
        //print("subscribeObj:",subscribeObj)
        let planId = subscribeObj["id"] as? Int ?? 0
        //print("planId:",planId)
        let user_id = UserDefaults.standard.string(forKey: "user_id");
        let strUserId = user_id ?? "1"
        // https://dev1.arevea.com/subscribe-payment?channel_name=chirantan-patel&user_id=101097275&plan_id=1311
        let inputs = "&user_id=" + strUserId + "&plan_id=" + String(planId)
        let urlOpen = appDelegate.websiteURL + "/subscribe-payment?channel_name=" + self.channel_name + inputs
        guard let url = URL(string: urlOpen) else { return }
        print("url to open:",url)
        UIApplication.shared.open(url)
        
    }
    func LiveEventById(streamInfo:[String: Any],upcoming:Bool) {
        print("streamInfo:",streamInfo)
        let performerId = streamInfo["performer_id"]as? Int ?? 0
        let streamId = streamInfo["id"] as? Int ?? 0
        //let streamVideoCode = streamInfo?["stream_video_code"] as? String ?? ""
        let orgId = streamInfo["organization_id"]as? Int ?? 0
        print("streamId:",streamId)
        let channelName = streamInfo["channel_name"] as? String ?? ""
        let user_id = UserDefaults.standard.string(forKey: "user_id");
        var streamIdLocal = "0"
        if (streamId != 0){
            streamIdLocal = String(streamId)
        }
        let stream_video_title = streamInfo["streamTitle"] as? String ?? "Channel Details"
        
        let params: [String: Any] = ["userid":user_id ?? "","performer_id":performerId,"stream_id": streamIdLocal]
        viewActivity.isHidden = false
        let netAvailable = appDelegate.isConnectedToInternet()
        if(!netAvailable){
            showAlert(strMsg: "Please check your internet connection!")
            return
        }
        let url: String = appDelegate.baseURL +  "/LiveEventById"
        
        let headers: HTTPHeaders
        headers = [appDelegate.x_api_key: appDelegate.x_api_value]
        
        print("liveEvents params1:",params)
        AF.request(url, method: .post,parameters: params, encoding: JSONEncoding.default,headers:headers)
            .responseJSON { [self] response in
                self.viewActivity.isHidden = true
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any] {
                        //print("LiveEventById JSON1:",json)
                        if (json["statusCode"]as? String == "200"){
                            let data = json["Data"] as? [String:Any]
                            let resultData = data ?? [:]
                            let aryStreamInfo = data?["stream_info"] as? [String:Any] ?? [:]
                            let stream_info_key_exists = aryStreamInfo["id"]
                            if (stream_info_key_exists != nil){
                                let streamObj = aryStreamInfo
                                let stream_status = streamObj["stream_status"] as? String ?? ""
                                let user_subscription_info = data?["user_subscription_info"] != nil
                                if(user_subscription_info){
                                    self.aryUserSubscriptionInfo = data?["user_subscription_info"] as? [Any] ?? [Any]()
                                }
                                var isVOD = false
                                if (streamObj["stream_vod"]as? String == "stream"){
                                    isVOD = false
                                }else{
                                    isVOD = true
                                }
                                var isup = true
                                if(!upcoming){
                                    isup = false
                                    isVOD = true
                                }
                                if (self.aryUserSubscriptionInfo.count == 0){
                                    let vc = storyboard!.instantiateViewController(withIdentifier: "EventRegistrationVC") as! EventRegistrationVC
                                    appDelegate.isLiveLoad = "1"
                                    vc.orgId = orgId
                                    vc.streamId = streamId
                                    //vc.delegate = self
                                    vc.performerId = performerId
                                    vc.strTitle = stream_video_title
                                    vc.isVOD = isVOD
                                    vc.isUpcoming = upcoming
                                    vc.channel_name_subscription = channelName
                                    //for vod
                                    if(!isup){
                                        let url = streamInfo["video_url"] as? String ?? ""
                                        videoUrl = url
                                        vc.isVOD = true;
                                    }
                                    // vc.channel_name_subscription = channelName
                                    self.navigationController?.pushViewController(vc, animated: true)
                                }else{
                                    let vc = storyboard!.instantiateViewController(withIdentifier: "StreamDetailVC") as! StreamDetailVC
                                    appDelegate.isLiveLoad = "1"
                                    vc.orgId = orgId
                                    print("==streamId:",streamId)
                                    vc.streamId = streamId
                                    vc.delegate = self
                                    vc.performerId = performerId
                                    vc.strTitle = stream_video_title
                                    vc.channel_name_subscription = channelName
                                    vc.isVOD = isVOD
                                    vc.isUpcoming = upcoming
                                    if(!isup){
                                        let url = streamInfo["video_url"] as? String ?? ""
                                        videoUrl = url
                                        vc.isVOD = true;
                                    }
                                    self.navigationController?.pushViewController(vc, animated: true)
                                }
                            }
                        }else{
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
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent // .default
    }
    
    func showAlert(strMsg: String){
        let alert = UIAlertController(title: "Alert", message: strMsg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    
    
    
    func videoThumbNail(from url: URL, button: UIButton) {
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            ////print(response?.suggestedFilename ?? url.lastPathComponent)
            DispatchQueue.main.async() { [weak self] in
                button.setImage(UIImage(data: data), for: .normal)
                button.imageView?.contentMode = .scaleAspectFill
            }
        }
    }
    
    
    func performerEvents(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let url: String = appDelegate.baseURL +  "/performerEvents"
        let inputData: [String: Any] = ["performerId": performerId,"orgId": orgId]
        let session_token = UserDefaults.standard.string(forKey: "session_token") ?? ""
        let headers : HTTPHeaders = [
            "Content-Type": "application/json",
            appDelegate.x_api_key:appDelegate.x_api_value,
            "Authorization": "Bearer " + session_token
        ]
        viewActivity.isHidden = false
        AF.request(url, method: .post,parameters: inputData, encoding: JSONEncoding.default,headers:headers)
            .responseJSON { response in
                self.viewActivity.isHidden = true
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any] {
                        print("performerEvents JSON:",json)
                        if (json["statusCode"]as? String == "200" ){
                            ////print(json["message"] as? String ?? "")
                            self.aryUpcoming = json["Data"] as? [Any] ?? [Any]() ;
                            ////print("upcoming count:",self.aryUpcoming.count);
                            self.tblUpcoming.reloadData();
                        }else{
                            let strMsg = json["message"] as? String ?? ""
                           // self.showAlert(strMsg: strMsg)
                        }
                        
                    }
                case .failure(let error):
                    let errorDesc = error.localizedDescription.replacingOccurrences(of: "URLSessionTask failed with error:", with: "")
                    self.showAlert(strMsg: errorDesc)
                    self.viewActivity.isHidden = true
                    
                }
            }
    }
    func performerVideos(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let url: String = appDelegate.baseURL +  "/performerVideos"
        
        let inputData: [String: Any] = ["channel_name": self.channel_name,"orgId": orgId,"type": "video"]
        // print("performerVideos params:",inputData)
        let session_token = UserDefaults.standard.string(forKey: "session_token") ?? ""
        let headers : HTTPHeaders = [
            "Content-Type": "application/json",
            appDelegate.x_api_key:appDelegate.x_api_value,
            "Authorization": "Bearer " + session_token
        ]
        viewActivity.isHidden = false
        AF.request(url, method: .post,parameters: inputData, encoding: JSONEncoding.default,headers:headers)
            .responseJSON { response in
                self.viewActivity.isHidden = true
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any] {
                        // print("performerVideos JSON:",json)
                        if (json["statusCode"]as? String == "200" ){
                            ////print(json["message"] as? String ?? "")
                            self.aryVideos = json["Data"] as? [Any] ?? [Any]() ;
                            ////print("videos:",self.aryVideos)
                            self.tblVideos.reloadData();
                        }else{
                            let strMsg = json["message"] as? String ?? ""
                            //self.showAlert(strMsg: strMsg)
                        }
                        
                    }
                case .failure(let error):
                    let errorDesc = error.localizedDescription.replacingOccurrences(of: "URLSessionTask failed with error:", with: "")
                    self.showAlert(strMsg: errorDesc)
                    self.viewActivity.isHidden = true
                    
                }
            }
    }
    func performerAudios(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let url: String = appDelegate.baseURL +  "/performerVideos"
        let inputData: [String: Any] = ["channel_name": self.channel_name,"orgId": orgId,"type": "audio"]
        let session_token = UserDefaults.standard.string(forKey: "session_token") ?? ""
        let headers : HTTPHeaders = [
            "Content-Type": "application/json",
            appDelegate.x_api_key:appDelegate.x_api_value,
            "Authorization": "Bearer " + session_token
        ]
        viewActivity.isHidden = false
        AF.request(url, method: .post,parameters: inputData, encoding: JSONEncoding.default,headers:headers)
            .responseJSON { response in
                self.viewActivity.isHidden = true
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any] {
                        //print("performerAudios JSON:",json)
                        if (json["statusCode"]as? String == "200" ){
                            ////print(json["message"] as? String ?? "")
                            self.aryAudios = json["Data"] as? [Any] ?? [Any]() ;
                            ////print("audios count:",self.aryVideos.count)
                            self.tblAudios.reloadData();
                        }else{
                            let strMsg = json["message"] as? String ?? ""
                           // self.showAlert(strMsg: strMsg)
                        }
                        
                    }
                case .failure(let error):
                    let errorDesc = error.localizedDescription.replacingOccurrences(of: "URLSessionTask failed with error:", with: "")
                    self.showAlert(strMsg: errorDesc)
                    self.viewActivity.isHidden = true
                    
                }
            }
    }
    
    
    // MARK: Handler for getCategoryOrganisations API
    func getPerformerInfo(){
        let netAvailable = appDelegate.isConnectedToInternet()
        if(!netAvailable){
            showAlert(strMsg: "Please check your internet connection!")
            return
        }
        viewActivity.isHidden = false
        let url: String = appDelegate.baseURL +  "/getPerformerInfo"
        let params: [String: Any] = ["performer_id": performerId]
        let headers: HTTPHeaders
        headers = [appDelegate.x_api_key: appDelegate.x_api_value]
        AF.request(url, method: .post,parameters: params, encoding: JSONEncoding.default,headers:headers)
            .responseJSON { response in
                self.viewActivity.isHidden = true
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any] {
                        // print("getPerformerInfo JSON:",json)
                        if (json["statusCode"]as? String == "200"){
                            
                            ////print(json["message"] as? String ?? "")
                            let data = json["Data"] as? [Any] ?? [Any]()
                            if(data.count > 0){
                                let obj = data[0] as? [String:Any] ?? [:]
                                let performer_info = obj["performer_details"] != nil
                                if(performer_info){
                                    self.dicPerformerInfo = obj["performer_details"] as? [String : Any] ?? [String:Any]()
                                    let performerName = self.dicPerformerInfo["performer_display_name"] as? String ?? ""
                                    //self.channel_name = self.dicPerformerInfo["channel_name"] as? String ?? ""
                                    
                                    var performer_bio = self.dicPerformerInfo["performer_bio"] as? String ?? ""
                                    performer_bio = performer_bio.htmlToString
                                    
                                    self.txtProfile.text = performerName + "\n" + performer_bio
                                    
                                    ////print("self.app_id_for_adds:",self.app_id_for_adds)
                                    let strURL = self.dicPerformerInfo["performer_profile_pic"]as? String ?? ""
                                    if let urlPerformer = URL(string: strURL){
                                        self.downloadImage(from:urlPerformer )
                                    }else{
                                        self.imgStreamThumbNail.image = UIImage(named: "user")
                                        self.imgPerformerProfile.image = UIImage(named: "user")
                                    }
                                }else{
                                    self.txtProfile.text = ""
                                }
                            }
                            
                        }else{
                            let strError = json["message"] as? String
                            ////print("strError1:",strError ?? "")
                            //self.showAlert(strMsg: strError ?? "")
                        }
                        
                    }
                    
                case .failure(let error):
                    let errorDesc = error.localizedDescription.replacingOccurrences(of: "URLSessionTask failed with error:", with: "")
                    self.showAlert(strMsg: errorDesc)
                    self.viewActivity.isHidden = true
                    
                }
            }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        NotificationCenter.default.removeObserver(self)
        AppDelegate.AppUtility.lockOrientation(.all)
        fromSubscribed = false
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    open override var shouldAutorotate:Bool {
        get {
            return true
        }
    }
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        get {
            return [UIInterfaceOrientationMask.all]
        }
    }
    func navigationControllerSupportedInterfaceOrientations(_ navigationController: UINavigationController) -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.all
    }
    // MARK: Handler for getChannelSubscriptionPlans API
    func getChannelSubscriptionPlans(){
        //channel_name_subscription = "dev-tv-2019"
        let netAvailable = appDelegate.isConnectedToInternet()
        if(!netAvailable){
            showAlert(strMsg: "Please check your internet connection!")
            return
        }
        viewActivity.isHidden = false
        let url: String = appDelegate.FCMBaseURL +  "/getChannelSubscriptionPlans"
        let user_id = UserDefaults.standard.string(forKey: "user_id");
        //below line need to update
        let params: [String: Any] = ["user_id":user_id ?? "","channel_name":channel_name,"channel_url":channel_name]
        print("getChannelSubscriptionPlans params:",params)
        let headers: HTTPHeaders
        headers = [appDelegate.x_api_key: appDelegate.x_api_value]
        AF.request(url, method: .post,parameters: params, encoding: JSONEncoding.default,headers:headers)
            .responseJSON { [self] response in
                self.viewActivity.isHidden = true
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any] {
                        print("getChannelSubscriptionPlans JSON:",json)
                        if (json["statusCode"]as? String == "200"){
                            self.lblNoDataSubscriptions.text = "No subscriptions found"
                            
                            self.arySubscriptions = []
                            let data = json["Data"] as? [Any] ?? [Any]();
                            // print("Data:",data)
                            if (data.count > 0){
                                let selectedObj = data[0] as? [String: Any] ?? [:]
                                let plans = selectedObj["plans"] as? [String: Any] ?? [:]
                                self.arySubscriptions = plans["subscriptionsData"] as? [Any] ?? [Any]();
                            }
                            subscription_details = false
                            arySubscriptionDetails = json["subscription_details"] as? [Any] ?? [Any]();
                            if(arySubscriptionDetails.count > 0){
                                subscription_details = true
                            }
                            self.tblSubscriptions.reloadData()
                        }else{
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
    // MARK: Handler for getSubscriptionStatus API
    func getSubscriptionStatus(){
        let netAvailable = appDelegate.isConnectedToInternet()
        if(!netAvailable){
            showAlert(strMsg: "Please check your internet connection!")
            return
        }
        viewActivity.isHidden = false
        let url: String = appDelegate.FCMBaseURL +  "/getSubscriptionStatus"
        let user_id = UserDefaults.standard.string(forKey: "user_id");
        let params: [String: Any] = ["user_id":user_id ?? "","channel_url":self.channel_name]
        print("getSubscriptionStatus params:",params)
        let headers: HTTPHeaders
        headers = [appDelegate.x_api_key: appDelegate.x_api_value]
        AF.request(url, method: .post,parameters: params, encoding: JSONEncoding.default,headers:headers)
            .responseJSON { response in
                self.viewActivity.isHidden = true
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any] {
                        print("getSubscriptionStatus JSON:",json)
                        if (json["statusCode"]as? String == "200"){
                            
                        }else{
                            let strError = json["message"] as? String
                            ////print("strError1:",strError ?? "")
                            //self.showAlert(strMsg: strError ?? "")
                        }
                        
                    }
                    
                case .failure(let error):
                    let errorDesc = error.localizedDescription.replacingOccurrences(of: "URLSessionTask failed with error:", with: "")
                    self.showAlert(strMsg: errorDesc)
                    self.viewActivity.isHidden = true
                    
                }
            }
    }
    
    // MARK: - Send Bird Methods
    override func viewWillAppear(_ animated: Bool) {
        AppDelegate.AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    deinit {
        //print("Remove NotificationCenter Deinit")
        NotificationCenter.default.removeObserver(self)
    }
    
    func downloadImage(from url: URL) {
        //print("Download Started")
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            //print(response?.suggestedFilename ?? url.lastPathComponent)
            //print("Download Finished")
            DispatchQueue.main.async() { [weak self] in
                self?.imgPerformerProfile.image = UIImage(data: data)
                self?.imgPerformerProfile.contentMode = .scaleToFill
                
                self?.imgStreamThumbNail.image = UIImage(data: data)
                self?.imgStreamThumbNail.contentMode = .scaleAspectFit
                
                self?.imgPerformerProfile.layer.cornerRadius = (self?.imgPerformerProfile.frame.size.width)!/2
            }
        }
    }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        AppDelegate.AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
    }
    @objc func unSubscribeBtnPressed(_ sender: UIButton){
        let row = sender.tag
        let subscribeObj = self.arySubscriptions[row] as? [String : Any] ?? [:];
        let performer_id = subscribeObj["performer_id"] as? Int ?? 0
        //print("==performer_id:",performer_id)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let url: String = appDelegate.paymentBaseURL +  "/cancelChannelSubscription"
        let inputData: [String: Any] = ["performer_id":performer_id]
        print("cancelChannelSubscription params:",inputData)
        let session_token = UserDefaults.standard.string(forKey: "session_token") ?? ""
        let headers : HTTPHeaders = [
            "Content-Type": "application/json",
            appDelegate.x_api_key:appDelegate.x_api_value,
            "Authorization": "Bearer " + session_token
        ]
        viewActivity.isHidden = false
        AF.request(url, method: .post,parameters: inputData, encoding: JSONEncoding.default,headers:headers)
            .responseJSON { response in
                self.viewActivity.isHidden = true
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any] {
                        print("cancelChannelSubscription JSON:",json)
                        if (json["status"]as? Int == 0){
                            self.viewActivity.isHidden = true
                            //////print(json["message"] as? String ?? "")
                            self.showAlert(strMsg: "Successfully unsubscribed.")
                            self.getChannelSubscriptionPlans()
                        }else{
                            let strMsg = json["message"] as? String ?? ""
                            self.showAlert(strMsg: strMsg)
                        }
                    }
                case .failure(let error):
                    let errorDesc = error.localizedDescription.replacingOccurrences(of: "URLSessionTask failed with error:", with: "")
                    self.showAlert(strMsg: errorDesc)
                    self.viewActivity.isHidden = true
                    
                }
            }
    }
    func reActivateChannelSubscription(row:Int){
        let subscribeObj = self.arySubscriptions[row] as? [String : Any] ?? [:];
        let performer_id = subscribeObj["performer_id"] as? Int ?? 0
        // print("subscribeObj:",subscribeObj)
        //print("==performer_id:",performer_id)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let url: String = appDelegate.paymentBaseURL +  "/reActivateChannelSubscription"
        let inputData: [String: Any] = ["performer_id":performer_id]
        print("reActivateChannelSubscription params:",inputData)
        let session_token = UserDefaults.standard.string(forKey: "session_token") ?? ""
        let headers : HTTPHeaders = [
            "Content-Type": "application/json",
            appDelegate.x_api_key:appDelegate.x_api_value,
            "Authorization": "Bearer " + session_token
        ]
        viewActivity.isHidden = false
        AF.request(url, method: .post,parameters: inputData, encoding: JSONEncoding.default,headers:headers)
            .responseJSON { response in
                self.viewActivity.isHidden = true
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any] {
                        print("reActivateChannelSubscription JSON:",json)
                        if (json["status"]as? Int == 0){
                            self.viewActivity.isHidden = true
                            //////print(json["message"] as? String ?? "")
                            self.showAlert(strMsg: "Successfully reactivated.")
                            self.getChannelSubscriptionPlans()
                        }else{
                            let strMsg = json["message"] as? String ?? ""
                            self.showAlert(strMsg: strMsg)
                        }
                    }
                case .failure(let error):
                    let errorDesc = error.localizedDescription.replacingOccurrences(of: "URLSessionTask failed with error:", with: "")
                    self.showAlert(strMsg: errorDesc)
                    self.viewActivity.isHidden = true
                    
                }
            }
    }
    @objc func applicationDidBecomeActive(notification: NSNotification) {
        getSubscriptionStatus()
        getChannelSubscriptionPlans()
    }
}

extension String {
    func image() -> UIImage? {
        let size = CGSize(width: 45, height: 45)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        UIColor.clear.set()
        let rect = CGRect(origin: .zero, size: size)
        UIRectFill(CGRect(origin: .zero, size: size))
        (self as AnyObject).draw(in: rect, withAttributes: [.font: UIFont.systemFont(ofSize: 40)])
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return NSAttributedString() }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return NSAttributedString()
        }
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
    
}
extension Array where Element : Equatable  {
    public mutating func removeObject(_ item: Element) {
        if let index = self.firstIndex(of: item) {
            self.remove(at: index)
        }
    }
}
extension Notification.Name {
    static let didReceiveStreamData = Notification.Name("didReceiveStreamData")
    static let didReceiveScreenShareData = Notification.Name("didReceiveScreenShareData")
    
    static let StreamOrienationChange = Notification.Name("StreamOrienationChange")
    
}

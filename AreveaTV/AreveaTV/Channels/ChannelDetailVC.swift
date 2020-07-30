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
import SendBirdSDK
import MUXSDKStats;
import CoreLocation


class ChannelDetailVC: UIViewController,UICollectionViewDataSource,UITableViewDataSource,UITableViewDelegate,CollectionViewCellDelegate,UIWebViewDelegate,UICollectionViewDelegateFlowLayout,CLLocationManagerDelegate, OpenChanannelChatDelegate{
    // MARK: - Variables Declaration
    
    @IBOutlet weak var scrollButtons: UIScrollView!
    @IBOutlet weak var buttonCVC: UICollectionView!
    @IBOutlet weak var viewVOD: UIView!
    
    @IBOutlet weak var viewBottom: UIView!
    @IBOutlet weak var viewInfo: UIView!
    @IBOutlet weak var viewAudios: UIView!
    @IBOutlet weak var viewVideos: UIView!
    @IBOutlet weak var viewUpcoming: UIView!
    
    @IBOutlet weak var tblVideos: UITableView!
    @IBOutlet weak var tblAudios: UITableView!
    @IBOutlet weak var tblUpcoming: UITableView!
    @IBOutlet weak var txtProfile: UITextView!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    @IBOutlet weak var btnPayPerView: UIButton!
    @IBOutlet weak var webView: UIWebView!
    var r5ViewController : BaseTest? = nil
    @IBOutlet weak var viewLiveStream: UIView!
    var dicPerformerInfo = [String: Any]()
    var aryStreamInfo = [Any]()
    var aryUserSubscriptionInfo = [Any]()
    var orgId = 0;
    var performerId = 0;
    var aryVideos = [Any]();
    var aryAudios = [Any]();
    var aryUpcoming = [Any]();
    var audioList: [String] = []
    var videoPlayer = AVPlayer()
    var streamVideoCode = ""
    
    var streamId = 0;
    var buttonNames = ["EVENTS","INFO","VIDEOS","AUDIOS"]
    var detailItem = [String:Any]();
    var playerItem:AVPlayerItem?
    var player:AVPlayer?
    var slider: UISlider?
    var isLoaded = 0;
    var detailStreamItem: NSDictionary? {
        didSet {
            // Update the view.
            // self.configureView()
        }
    }
    var videoUrl = ""
    var backPressed = false
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var imgPerformerProfile :UIImageView!
    
    @IBOutlet weak var txtVideoDesc_Info: UITextView!
    @IBOutlet weak var lblVideoTitle_Info: UILabel!
    
    @IBOutlet weak var lblNoDataUpcoming: UILabel!
    @IBOutlet weak var lblNoDataVideos: UILabel!
    @IBOutlet weak var lblNoDataAudios: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    
    
    
    // MARK: - Live Chat Inputs
   
    var age_limit = 0;
    @IBOutlet weak var liveStreamHeight: NSLayoutConstraint!

    @IBOutlet weak var VODHeight: NSLayoutConstraint!
    
    weak var delegate: OpenChanannelChatDelegate?
    var paymentAmount = 0
    var streamPaymentMode = ""
    var strTitle = ""
    @IBOutlet weak var viewActivity: UIView!
    var isVOD = false;
    
    @IBOutlet weak var imgStreamThumbNail: UIImageView!
    @IBOutlet weak var btnPlayStream: UIButton!
    @IBOutlet weak var btnRotationStream: UIButton!

    @IBOutlet weak var lblStreamUnavailable: UILabel!
    @IBOutlet weak var lblVODUnavailable: UILabel!
    
    var isStream = true;
    var isUpcoming = false;
    private let editor = VideoEditor()
   
    var app_id_for_adds = ""
    @IBOutlet weak var heightTopView: NSLayoutConstraint?
    @IBOutlet weak var viewTop: UIView!
    var locationManager:CLLocationManager!
    
    var aryCountries = [["region_code":"blr1","countries":["india","sri lanka","bangaldesh","pakistan","china"]],["region_code":"tor1","countries":["canada"]],["region_code":"fra1","countries":["germany"]],["region_code":"lon1","countries":["england"]],["region_code":"sgp1","countries":["singapore"]],["region_code":"sfo1","countries":["United States"]],["region_code":"sfo2","countries":["United States"]],["region_code":"ams2","countries":["netherlands"]],["region_code":"ams3","countries":["netherlands"]],["region_code":"nyc1","countries":["United States"]],["region_code":"nyc2","countries":["United States"]],["region_code":"nyc3","countries":["United States"]]]
    var strCountry = "India"//United States
    var strRegionCode = "blr1"//sfo1
    var isIpadLandScape = false
    
    var btnRotationStreamTap = false
    
    var btnRotationVODTap = false
    @IBOutlet var btnRotationVOD:UIButton!
    
    var onLoad  = false
    
    // MARK: - View Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        viewActivity.isHidden = true
        // Do any additional setup after loading the view.
        registerNibs();
        //print("detail item in channnel page:\(detailItem)")
        
        viewLiveStream.isHidden = true;
        lblNoDataUpcoming.text = "No results found"
        lblNoDataVideos.text = "No results found"
        lblNoDataAudios.text = "No results found"
        lblTitle.text = strTitle
        //sendBirdConnect()
        // txtComment.textInputMode?.primaryLanguage = "emoji"
        //imgEmoji.isHidden = true
        
        //self.textView.inputView = emojiKeyboardView;
       
        
        webView.isHidden = true
        hideViews();
        
        if(UIDevice.current.userInterfaceIdiom == .pad){
            heightTopView?.constant = 60;
            viewTop.layoutIfNeeded()
            viewLiveStream.layoutIfNeeded()
        }
        /*locationManager = CLLocationManager()
         locationManager.delegate = self
         locationManager.desiredAccuracy = kCLLocationAccuracyBest
         locationManager.requestAlwaysAuthorization()
         
         if CLLocationManager.locationServicesEnabled(){
         locationManager.startUpdatingLocation()
         }*/
        self.webView.backgroundColor = .clear
        self.webView.isOpaque = false
        //btnRotationStream.isHidden = true
        
        if(UIDevice.current.userInterfaceIdiom == .pad && UIDevice.current.orientation.isLandscape){
            isIpadLandScape = true
        }
        onLoad = true

    }
    
    
    @IBAction func test(){
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        //adding observer
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(StreamNotificationHandler(_:)), name: .didReceiveStreamData, object: nil)
        self.btnRotationStream.isHidden = true

    }
    
    @objc func StreamNotificationHandler(_ notification:Notification) {
        // Do something now
        //print("====StreamNotificationHandler")
        if let data = notification.userInfo as? [String: String]
        {
            for (key,value) in data
            {
                //key Stream
                //value Stopped/Started
                //print("key: \(key)")
                //print("value: \(value)")
                
                if (value == "started"){
                    btnPlayStream.isHidden = true;
                    /*let htmlString = "<html>\n" +
                        "   <body style='margin:0;padding:0;background:transparent;'>\n" +
                        "     <iframe width=\"100%\" height=\"100%\" src=\"https://app.singular.live/appinstances/" + self.app_id_for_adds + "/outputs/Output/onair\" frameborder=\"0\" allow=\"accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture\" allowfullscreen>\n" +
                        "     </iframe>\n" +
                        "   </body>\n" +
                    "</html>";
                    print("htmlString:",htmlString)
                    self.webView.loadHTMLString(htmlString, baseURL: nil)
                    self.webView.delegate = self
                    self.webView.isHidden = false
                    
                    self.viewLiveStream.bringSubviewToFront(self.webView)*/
                }else if(value == "stopped"){
                    //lblStreamUnavailable.text = "publisher has unpublished. possibly from background/interrupt"
                    btnPlayStream.isHidden = true;
                }else if(value == "not_available"){
                    if (viewLiveStream.isHidden == false){
                        lblStreamUnavailable.text = "Video streaming is currently unavailable. Please try again later"
                        btnPlayStream.setImage(UIImage.init(named: "refresh-icon.png"), for: .normal)
                        btnPlayStream.isHidden = false;
                    }
                }
            }
        }
    }
    @objc func applicationDidBecomeActive(notification: NSNotification) {
        // Application is back in the foreground
        //print("====applicationDidBecomeActive")
        //if user comes from payment redirection, need to refresh stream/vod
        liveEvents()
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
        
        tblAudios.register(UINib(nibName: "AudioCell", bundle: nil), forCellReuseIdentifier: "AudioCell");
        tblVideos.register(UINib(nibName: "VideoCell", bundle: nil), forCellReuseIdentifier: "VideoCell")
        tblUpcoming.register(UINib(nibName: "UpcomingCell", bundle: nil), forCellReuseIdentifier: "UpcomingCell")
        
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true);
        backPressed = false
        self.btnPlayStream.isHidden = true
        self.imgPerformerProfile.layer.cornerRadius = self.imgPerformerProfile.frame.size.width/2
        if(UIDevice.current.userInterfaceIdiom == .pad){
            self.imgStreamThumbNail.image = UIImage.init(named: "default-vod.png")
        }else{
            self.imgStreamThumbNail.image = UIImage.init(named: "default-vod-square.png")
        }
        if(isLoaded == 0 || appDelegate.isLiveLoad == "1"){
            let netAvailable = appDelegate.isConnectedToInternet()
            if(!netAvailable){
                showAlert(strMsg: "Please check your internet connection!")
                return
            }
            isLoaded = 1;
            appDelegate.isLiveLoad = "0";
            liveEvents();
            performerVideos();
            performerAudios();
            performerEvents();
            //getPerformerOrgInfo();
            //bottom first object should show
              let infoLine = self.buttonCVC.viewWithTag(11) as? UILabel
                let btnText = self.buttonCVC.viewWithTag(21) as? UIButton
                let orange = UIColor(red: 255, green: 115, blue: 90);
                infoLine?.backgroundColor = orange;
                btnText?.setTitleColor(orange, for: .normal)
                viewInfo.isHidden = false
        }
        let viewHeight = self.view.frame.size.height*0.35
        liveStreamHeight.constant = CGFloat(viewHeight)
        VODHeight.constant = CGFloat(viewHeight)
        self.viewLiveStream.layoutIfNeeded()
        self.viewVOD.layoutIfNeeded()
        
    }
   
    
    func showVideo(strURL : String){
        if let url = URL(string: strURL){
            videoPlayer = AVPlayer(url: url)
            let controller = AVPlayerViewController()
            controller.player = videoPlayer
            controller.allowsPictureInPicturePlayback = true
            controller.view.frame = self.viewVOD.bounds
            controller.videoGravity = AVLayerVideoGravity.resize
            self.viewVOD.addSubview(controller.view)
            self.addChild(controller)
            btnPlayStream.isHidden = true;
            viewLiveStream.isHidden = true;
            viewVOD.isHidden = false;
            videoPlayer.play()
            
            //            let player = AVPlayer(url: url)
            //            let controller=AVPlayerViewController()
            //            controller.player=player
            //            controller.view.frame = self.viewVideo.frame
            //            self.viewVideo.addSubview(controller.view)
            //            self.addChild(controller)
            //            player.play()
            
            //388266
            
            
            // Environment and player data that persists until the player is destroyed
            let playerData = MUXSDKCustomerPlayerData(environmentKey:"dev")
            playerData?.viewerUserId = "1234"
            playerData?.experimentName = "player_test_A"
            playerData?.playerName = "My Main Player"
            playerData?.playerVersion = "1.0.0"
            
            // Video metadata (cleared with videoChangeForPlayer:withVideoData:)
            let videoData = MUXSDKCustomerVideoData()
            videoData.videoId = "abcd123"
            videoData.videoTitle = "My Great Video"
            videoData.videoSeries = "Weekly Great Videos"
            videoData.videoDuration = 120000 // in milliseconds
            videoData.videoIsLive = false
            videoData.videoCdn = "cdn"
            
            MUXSDKStats.monitorAVPlayerViewController(controller, withPlayerName: "Player Name", playerData: playerData!, videoData: videoData)
        }else{
            //print("Invalid URL")
            showAlert(strMsg: "Unable to play video due to invalid URL.")
        }
    }
    
    func stopVideo(){
        videoPlayer.pause()
        videoPlayer.replaceCurrentItem(with: nil)
    }
    @IBAction func back(_ sender: Any) {
        if (!backPressed){
            backPressed = true
            closeStream()
            stopVideo()
            if(!isIpadLandScape){
                if (btnRotationStreamTap){
                    let value = UIInterfaceOrientation.portrait.rawValue
                    UIDevice.current.setValue(value, forKey: "orientation")
                }
            }
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
        
        viewInfo.isHidden = true;
        viewAudios.isHidden = true;
        viewVideos.isHidden = true;
        viewUpcoming.isHidden = true;
        
      
        
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
                print("btnTag:",btnTag)
                let orange = UIColor(red: 255, green: 115, blue: 90);
                lblLine?.backgroundColor = orange;
                btnText?.setTitleColor(orange, for: .normal)
            }else{
                lblLine?.backgroundColor = .white;
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
            }else{
                self.lblNoDataAudios.isHidden = false
            }
            return aryAudios.count;
        }else if (tableView == tblUpcoming ){
            if (self.aryUpcoming.count > 0){
                lblNoDataUpcoming.isHidden = true
            }else{
                lblNoDataUpcoming.isHidden = false
            }
            return aryUpcoming.count;
        }
        else if(tableView == tblVideos){
            if (self.aryVideos.count > 0){
                self.lblNoDataVideos.isHidden = true
            }else{
                self.lblNoDataVideos.isHidden = false
            }
            return aryVideos.count;
        }
       
        return 0;
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) ->  CGFloat {
        if (tableView == tblVideos){
            return 150;
        }else if  (tableView == tblAudios){
            return 80;
        }else if  (tableView == tblUpcoming){
            return 138;
        }
        return 44;
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (tableView == tblVideos){
            let cell = tableView.dequeueReusableCell(withIdentifier: "VideoCell") as! VideoCell
            cell.btnVideo.addTarget(self, action: #selector(playVideoBtnTapped(_:)), for: .touchUpInside)
            cell.btnVideo.tag = indexPath.row
            
            cell.btnVideo1.addTarget(self, action: #selector(playVideoBtnTapped(_:)), for: .touchUpInside)
            cell.btnVideo1.tag = indexPath.row
            let upcoming = self.aryVideos[indexPath.row] as? [String : Any];
            let strURL = upcoming?["videoThumbImage"] as? String ?? "";
            let videoTitle = upcoming?["videoTitle"] as? String ?? "";
            cell.lblTitle.text = videoTitle
            print("--vod strURL:",strURL);
            if let urlVideoThumbImage = URL(string: strURL){
                self.videoThumbNail(from: urlVideoThumbImage, button: cell.btnVideo)
            }else{
                cell.btnVideo.setImage((UIImage.init(named: "default-vod.png")), for: .normal)
            }
            
            return cell
            
        }else if (tableView == tblUpcoming){
            let cell = tableView.dequeueReusableCell(withIdentifier: "UpcomingCell") as! UpcomingCell
            //2020-04-26T19:28:49.000Z
            let item = self.aryUpcoming[indexPath.row] as? [String : Any];
            //print("--upcoming:",item)
            cell.lblTitle.text = item?["streamTitle"] as? String;
            let streamStatus = item?["streamStatus"] as? String;
            
            
            cell.lblStreamStatus.text = "NEW"
            cell.lblStreamStatus.backgroundColor = .lightGray
            if(streamStatus == "inprogress"){
                cell.lblStreamStatus.text = "LIVE"
                let orange = UIColor(red: 255, green: 115, blue: 90);
                cell.lblStreamStatus.backgroundColor = orange
            }
            

            let isoDate = item?["publishedOn"] as? String ?? ""
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
            
            cell.lblPayment.text = item?["streamPaymentMode"] as? String;
            //cell.lblPayment.text = String(item["streamPayment"]as! Int) + " USD"
            cell.lblSession.text = item?["sessionType"]as? String;
            return cell
            
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AudioCell") as! AudioCell
            let audio = self.aryAudios[indexPath.row] as? [String : Any];
           // print("audio:",audio)
            let strURL = audio?["videoUrl"] as? String ?? ""
            cell.lblTitle.text = audio?["videoTitle"] as? String ?? ""
            if let url = URL(string: strURL){
                let playerItem:AVPlayerItem = AVPlayerItem(url: url)
                player = AVPlayer(playerItem: playerItem)
                cell.audioSlider.minimumValue = 0
                let duration : CMTime = playerItem.asset.duration
                let seconds : Float64 = CMTimeGetSeconds(duration)
                cell.audioSlider.maximumValue = Float(seconds)
                cell.audioSlider.isContinuous = false
                cell.audioSlider.addTarget(self, action: #selector(sliderChanged(sender:)), for: .valueChanged)
                cell.btnPlayOrPause.addTarget(self, action: #selector(playPauseTapped(sender:)), for: .touchUpInside)
                cell.audioSlider.tag = indexPath.row
                cell.btnPlayOrPause.tag = 100+(indexPath.row)
            }else{
                
            }
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //           let storyboard = UIStoryboard(name: "Main", bundle: nil);
        //           let vc = storyboard.instantiateViewController(withIdentifier: "ChannelDetailVC") as! ChannelDetailVC
        //           self.navigationController?.pushViewController(vc, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
        if (tableView == tblUpcoming){
            closeStream()
            stopVideo()
            lblStreamUnavailable.text = "";
            btnPlayStream.isHidden = true;
            
            let upcoming = self.aryUpcoming[indexPath.row] as? [String : Any];
            self.performerId = upcoming?["performer_id"]as? Int ?? 0
            self.streamId = upcoming?["videoId"] as? Int ?? 0
            self.streamVideoCode = upcoming?["streamCode"] as? String ?? ""
            isVOD = false;
            isUpcoming = true;
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil);
            let vc = storyboard.instantiateViewController(withIdentifier: "StreamDetailVC") as! StreamDetailVC
            vc.streamId = self.streamId
            vc.delegate = self
            appDelegate.isLiveLoad = "1"
            vc.performerId = self.performerId;
            vc.strTitle = upcoming?["streamTitle"] as? String ?? "Channel Details"
            vc.isVOD = false;
            vc.isUpcoming = true;
            self.navigationController?.pushViewController(vc, animated: true)

        }else if  (tableView == tblVideos){
            playVideoFromList(row: indexPath.row)
        }
    }
    @objc func playVideoBtnTapped(_ sender: UIButton)
    {
        playVideoFromList(row: sender.tag)
    }
    @objc func playVideoFromList(row:Int){
        stopVideo()
        closeStream()
        let upcoming = self.aryVideos[row] as? [String : Any];
        self.orgId = upcoming?["organization_id"]as? Int ?? 0
        self.performerId = upcoming?["performer_id"]as? Int ?? 0
        self.streamId = upcoming?["videoId"] as? Int ?? 0
        self.streamVideoCode = upcoming?["videoCode"] as? String ?? ""
        //print("self.streamVideoCode:",self.streamVideoCode)
        let url = upcoming?["videoUrl"] as? String ?? ""
        videoUrl = url
        isVOD = true;
        let storyboard = UIStoryboard(name: "Main", bundle: nil);
        let vc = storyboard.instantiateViewController(withIdentifier: "StreamDetailVC") as! StreamDetailVC
        vc.streamId = self.streamId
        vc.delegate = self
        appDelegate.isLiveLoad = "1"
        vc.performerId = self.performerId;
        vc.strTitle = upcoming?["videoTitle"] as? String ?? "Channel Details"
        vc.isVOD = true;
        vc.isUpcoming = false;
        self.navigationController?.pushViewController(vc, animated: true)
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
    
    
    // MARK: Handler for allCategories API, using for filters
    func getURL(url:String){
        
        let url: String = appDelegate.baseURL +  "/getUrl"
        let params: [String: Any] = ["url": url]
        
        viewActivity.isHidden = false
        let headers: HTTPHeaders
        headers = [appDelegate.securityKey: appDelegate.securityValue]
        
        AF.request(url, method: .post,  parameters: params, encoding: JSONEncoding.default,headers:headers)
            .responseJSON { response in
                self.viewActivity.isHidden = true
                
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any] {
                        //print("json:",json)
                        if (json["statusCode"]as? String == "200"){
                            let signed_url = json["signed_url"] as? String ?? ""
                            self.showVideo(strURL: signed_url);
                        }else{
                            let strError = json["message"] as? String
                            //print(strError ?? "")
                            self.showAlert(strMsg: strError ?? "")
                        }
                    }
                case .failure(let error):
                    //print(error)
                    self.showAlert(strMsg: error.localizedDescription)
                }
        }
    }
    
    func collectionView(collectionviewcell: DBCollectionViewCell?, index: Int, didTappedInTableViewCell: DashBoardCell) {
        
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent // .default
    }
    
    // MARK: Comments Methods
    
    
   
    
   
    // MARK: Tip Methods
    
    
    @IBAction func payPerView(_ sender: Any) {
        let user_id = UserDefaults.standard.string(forKey: "user_id");
        let params = ["paymentType": "pay_per_view", "user_id": user_id ?? "1", "stream_id": streamId] as [String : Any]
        proceedToPayment(params: params)
        
    }
    func proceedToPayment(params:[String:Any]){
        //let url: String = appDelegate.baseURL +  "/proceedToPayment"
        let url = "https://qa.arevea.tv/api/payment/v1/proceedToPayment"
        let params = params;
        //print("params:",params)
        let session_token = UserDefaults.standard.string(forKey: "session_token") ?? ""
        let headers: HTTPHeaders = [
            "Authorization": "Bearer " + session_token,
            "Accept": "application/json"
        ]
        viewActivity.isHidden = false
        AF.request(url, method: .post,  parameters: params,encoding: JSONEncoding.default, headers: headers)
            .responseJSON { response in
                self.viewActivity.isHidden = true
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any] {
                        //print("proceedToPayment json:",json)
                        
                        if (json["token"]as? String != nil){
                            let token = json["token"]as? String ?? ""
                            let urlOpen = "https://qa.arevea.tv/payment/" + token
                            guard let url = URL(string: urlOpen) else { return }
                            UIApplication.shared.open(url)
                        }else{
                            let strError = json["message"] as? String
                            ////print(strError ?? "")
                            self.showAlert(strMsg: strError ?? "")
                        }
                    }
                case .failure(let error):
                    ////print(error)
                    self.showAlert(strMsg: error.localizedDescription)
                }
        }
    }
    @IBAction func subscribe(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil);
        let vc = storyboard.instantiateViewController(withIdentifier: "SubscriptionPlanVC") as! SubscriptionPlanVC
        vc.comingfrom = "channel_details"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @objc func share(_ sender: Any) {
        
        let qa = "https://qa.arevea.tv/channel/";
        let performerInfo = self.strTitle + "/" + String(self.performerId) + "/live/";
        let vodInfo = self.streamVideoCode + "/" + String(self.streamId)
        let url = qa + performerInfo + vodInfo
        print(url)
        let textToShare = [url]
        // set up activity view controller
        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
        activityViewController.excludedActivityTypes = [.airDrop]
        
        if let popoverController = activityViewController.popoverPresentationController {
            popoverController.sourceRect = CGRect(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2, width: 0, height: 0)
            popoverController.sourceView = self.view
            popoverController.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
        }
        
        self.present(activityViewController, animated: true, completion: nil)
        
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
    func downloadImage(from url: URL, imageView: UIImageView) {
        //print("Download Started")
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            //print(response?.suggestedFilename ?? url.lastPathComponent)
            //print("Download Finished")
            DispatchQueue.main.async() { [weak self] in
                imageView.image = UIImage(data: data)
                imageView.contentMode = .scaleAspectFill
            }
        }
    }
    
    func downloadPerformerPic(from url: URL) {
        //print("Download Started")
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            //print(response?.suggestedFilename ?? url.lastPathComponent)
            //print("Download Finished")
            DispatchQueue.main.async() { [weak self] in
                self?.imgPerformerProfile.image = UIImage(data: data)
                self?.imgPerformerProfile.contentMode = .scaleAspectFill
                self?.imgStreamThumbNail.image = UIImage(data: data)
                self?.imgStreamThumbNail.contentMode = .scaleAspectFill

            }
        }
    }
    
    func videoThumbNail(from url: URL, button: UIButton) {
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            //print(response?.suggestedFilename ?? url.lastPathComponent)
            DispatchQueue.main.async() { [weak self] in
                button.setImage(UIImage(data: data), for: .normal)
                button.imageView?.contentMode = .scaleAspectFill
            }
        }
    }
    
    // MARK: Handler for getUser API, using for filters
    func liveEvents() {
        /* viewVOD.isHidden = false
         viewLiveStream.isHidden = true
         self.showVideo(strURL: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4");
         return*/
        
        let netAvailable = appDelegate.isConnectedToInternet()
        if(!netAvailable){
            showAlert(strMsg: "Please check your internet connection!")
            return
        }
        viewActivity.isHidden = false
        let httpMethodName = "POST"
        let URLString: String = "/liveEvents"
        let user_id = UserDefaults.standard.string(forKey: "user_id");
        var streamIdLocal = "0"
        if (streamId != 0){
            streamIdLocal = String(streamId)
        }
        let params: [String: Any] = ["userid":user_id ?? "","performer_id":performerId,"stream_id": streamIdLocal]
        print("liveEvents params:",params)
        // let params: [String: Any] = ["userid":user_id ?? "","performer_id":"101","stream_id": "0"]
        
        let headerParameters = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        // Construct the request object
        let apiRequest = AWSAPIGatewayRequest(httpMethod: httpMethodName,
                                              urlString: URLString,
                                              queryParameters: [:],
                                              headerParameters: headerParameters,
                                              httpBody: params)
        // Fetch the Cloud Logic client to be used for invocation
        let invocationClient = AreveaAPIClient.client(forKey:appDelegate.AWSCognitoIdentityPoolId)
        invocationClient.invoke(apiRequest).continueWith { (task: AWSTask) -> Any? in
            if let error = task.error {
                //print("Error occurred: \(error)")
                self.showAlert(strMsg: error as? String ?? error.localizedDescription)
                // Handle error here
                return nil
            }
            // Handle successful result here
            let result = task.result!
            let responseString = String(data: result.responseData!, encoding: .utf8)
            let data = responseString!.data(using: .utf8)!
            do {
                let resultObj = try JSONSerialization.jsonObject(with: data, options : .allowFragments)
                DispatchQueue.main.async {
                    self.viewActivity.isHidden = true
                    self.btnPlayStream.isHidden = true
                    self.viewLiveStream.isHidden = false
                    if let json = resultObj as? [String: Any] {
                        print("liveEvents json:",json);
                        if (json["statusCode"]as? String == "200"){
                            //print(json["message"] as? String ?? "")
                            let data = json["Data"] as? [String:Any]
                            
                            let performer_info = data?["performer_info"] != nil
                            if(performer_info){
                                self.dicPerformerInfo = data?["performer_info"] as? [String : Any] ?? [String:Any]()
                                let performerName = self.dicPerformerInfo["performer_display_name"] as? String ?? ""
                                var performer_bio = self.dicPerformerInfo["performer_bio"] as? String ?? ""
                                performer_bio = performer_bio.htmlToString
                                
                                self.txtProfile.text = performerName + "\n" + performer_bio
                                self.app_id_for_adds = self.dicPerformerInfo["app_id"] as? String ?? "0"
                                
                                //print("self.app_id_for_adds:",self.app_id_for_adds)
                                let strURL = self.dicPerformerInfo["performer_profile_pic"]as? String ?? ""
                                if let urlPerformer = URL(string: strURL){
                                    self.downloadPerformerPic(from: urlPerformer as URL)
                                }else{
                                    self.imgStreamThumbNail.image = UIImage(named: "default")
                                }
                            }else{
                                self.txtProfile.text = ""
                            }
                        }else{
                            let strError = json["message"] as? String
                            //print("strError1:",strError ?? "")
                            self.showAlert(strMsg: strError ?? "")
                            self.viewVOD.isHidden = false
                            self.viewLiveStream.isHidden = true;
                        }
                        
                    }
                }
            } catch let error as NSError {
                //print(error)
                self.showAlert(strMsg: error.localizedDescription)
            }
            return nil
        }
    }
    
    
    // MARK: Handler for performerEvents API, using for upcoming schedules
    func performerEvents(){
        let netAvailable = appDelegate.isConnectedToInternet()
        if(!netAvailable){
            showAlert(strMsg: "Please check your internet connection!")
            return
        }
        viewActivity.isHidden = false
        let httpMethodName = "POST"
        let URLString: String = "/performerEvents"
        let params: [String: Any] = ["performerId": performerId,"orgId": orgId]
        //print("performerEvents params:",params);
        let headerParameters = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        // Construct the request object
        let apiRequest = AWSAPIGatewayRequest(httpMethod: httpMethodName,
                                              urlString: URLString,
                                              queryParameters: [:],
                                              headerParameters: headerParameters,
                                              httpBody: params)
        // Fetch the Cloud Logic client to be used for invocation
        let invocationClient = AreveaAPIClient.client(forKey:appDelegate.AWSCognitoIdentityPoolId)
        invocationClient.invoke(apiRequest).continueWith { (task: AWSTask) -> Any? in
            if let error = task.error {
                //print("Error occurred: \(error)")
                self.showAlert(strMsg: error as? String ?? error.localizedDescription)
                // Handle error here
                return nil
            }
            // Handle successful result here
            let result = task.result!
            let responseString = String(data: result.responseData!, encoding: .utf8)
            let data = responseString!.data(using: .utf8)!
            do {
                let resultObj = try JSONSerialization.jsonObject(with: data, options : .allowFragments)
                DispatchQueue.main.async {
                    self.viewActivity.isHidden = true
                    // //print(resultObj)
                    if let json = resultObj as? [String: Any] {
                        //print("performerEvents json:",json);
                        if (json["statusCode"]as? String == "200"){
                            //print(json["message"] as? String ?? "")
                            self.aryUpcoming = json["Data"] as? [Any] ?? [Any]() ;
                            //print("upcoming count:",self.aryUpcoming.count);
                            self.tblUpcoming.reloadData();
                        }else{
                            let strError = json["message"] as? String
                            //print("strError2:",strError ?? "")
                            self.showAlert(strMsg: strError ?? "")
                        }
                    }
                }
            } catch let error as NSError {
                //print(error)
                self.showAlert(strMsg: error.localizedDescription)
            }
            return nil
        }
    }
    // MARK: Handler for performerEvents API, using for upcoming schedules
    func performerVideos(){
        let netAvailable = appDelegate.isConnectedToInternet()
        if(!netAvailable){
            showAlert(strMsg: "Please check your internet connection!")
            return
        }
        viewActivity.isHidden = false
        let httpMethodName = "POST"
        let URLString: String = "/performerVideos"
        let params: [String: Any] = ["performerId":performerId,"orgId": orgId,"type": "video"]
        //print("performerVideos params:",params)
        //let params: [String: Any] = ["performerId":"23","orgId": "11","type": "video"]
        
        let headerParameters = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        // Construct the request object
        let apiRequest = AWSAPIGatewayRequest(httpMethod: httpMethodName,
                                              urlString: URLString,
                                              queryParameters: [:],
                                              headerParameters: headerParameters,
                                              httpBody: params)
        // Fetch the Cloud Logic client to be used for invocation
        let invocationClient = AreveaAPIClient.client(forKey:appDelegate.AWSCognitoIdentityPoolId)
        invocationClient.invoke(apiRequest).continueWith { (task: AWSTask) -> Any? in
            if let error = task.error {
                //print("Error occurred: \(error)")
                self.showAlert(strMsg: error as? String ?? error.localizedDescription)
                // Handle error here
                return nil
            }
            // Handle successful result here
            let result = task.result!
            let responseString = String(data: result.responseData!, encoding: .utf8)
            let data = responseString!.data(using: .utf8)!
            do {
                let resultObj = try JSONSerialization.jsonObject(with: data, options : .allowFragments)
                DispatchQueue.main.async {
                    self.viewActivity.isHidden = true
                    
                    //print(resultObj)
                    if let json = resultObj as? [String: Any] {
                        // //print("performerVideos json:",json);
                        print("videos count:",self.aryVideos.count);
                        
                        if (json["statusCode"]as? String == "200"){
                            //print(json["message"] as? String ?? "")
                            self.aryVideos = json["Data"] as? [Any] ?? [Any]() ;
                            //print("videos:",self.aryVideos)
                            self.tblVideos.reloadData();
                        }else{
                            let strError = json["message"] as? String
                            //print("performerVideos strError:",strError ?? "")
                            self.showAlert(strMsg: strError ?? "")
                        }
                        
                        
                    }
                }
                
            } catch let error as NSError {
                //print(error)
                self.showAlert(strMsg: error.localizedDescription)
            }
            return nil
        }
    }
    // MARK: Handler for performerEvents API, using for upcoming schedules
    func performerAudios(){
        let netAvailable = appDelegate.isConnectedToInternet()
        if(!netAvailable){
            showAlert(strMsg: "Please check your internet connection!")
            return
        }
        viewActivity.isHidden = false
        let httpMethodName = "POST"
        let URLString: String = "/performerVideos"
        let params: [String: Any] = ["performerId": performerId,"orgId": orgId,"type": "audio"]
        //print("performerAudios params:",params)
        
        let headerParameters = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        // Construct the request object
        let apiRequest = AWSAPIGatewayRequest(httpMethod: httpMethodName,
                                              urlString: URLString,
                                              queryParameters: [:],
                                              headerParameters: headerParameters,
                                              httpBody: params)
        // Fetch the Cloud Logic client to be used for invocation
        let invocationClient = AreveaAPIClient.client(forKey:appDelegate.AWSCognitoIdentityPoolId)
        invocationClient.invoke(apiRequest).continueWith { (task: AWSTask) -> Any? in
            if let error = task.error {
                //print("Error occurred: \(error)")
                self.showAlert(strMsg: error as? String ?? error.localizedDescription)
                // Handle error here
                return nil
            }
            // Handle successful result here
            let result = task.result!
            let responseString = String(data: result.responseData!, encoding: .utf8)
            let data = responseString!.data(using: .utf8)!
            do {
                let resultObj = try JSONSerialization.jsonObject(with: data, options : .allowFragments)
                DispatchQueue.main.async {
                    //print(resultObj)
                    self.viewActivity.isHidden = true
                    
                    if let json = resultObj as? [String: Any] {
                        //print("performerAudios json:",json);
                        if (json["statusCode"]as? String == "200"){
                            //print(json["message"] as? String ?? "")
                            self.aryAudios = json["Data"] as? [Any] ?? [Any]() ;
                            //print("audios count:",self.aryVideos.count)
                            self.tblAudios.reloadData();
                        }else{
                            let strError = json["message"] as? String
                            //print("performerAudios strError:",strError ?? "")
                            self.showAlert(strMsg: strError ?? "")
                        }
                        
                        
                    }
                }
            } catch let error as NSError {
                //print(error)
                self.showAlert(strMsg: error.localizedDescription)
            }
            return nil
        }
    }
    // MARK: Handler for getCategoryOrganisations API
    func getPerformerOrgInfo(){
        let netAvailable = appDelegate.isConnectedToInternet()
        if(!netAvailable){
            showAlert(strMsg: "Please check your internet connection!")
            return
        }
        viewActivity.isHidden = false
        let httpMethodName = "POST"
        let URLString: String = "/getPerformerOrgInfo"
        let params: [String: Any] = ["performer_id": performerId]
        let headerParameters = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        // Construct the request object
        let apiRequest = AWSAPIGatewayRequest(httpMethod: httpMethodName,
                                              urlString: URLString,
                                              queryParameters: [:],
                                              headerParameters: headerParameters,
                                              httpBody: params)
        // Fetch the Cloud Logic client to be used for invocation
        let invocationClient = AreveaAPIClient.client(forKey:appDelegate.AWSCognitoIdentityPoolId)
        invocationClient.invoke(apiRequest).continueWith { (task: AWSTask) -> Any? in
            if let error = task.error {
                //print("Error occurred: \(error)")
                self.showAlert(strMsg: error as? String ?? error.localizedDescription)
                // Handle error here
                return nil
            }
            // Handle successful result here
            let result = task.result!
            let responseString = String(data: result.responseData!, encoding: .utf8)
            let data = responseString!.data(using: .utf8)!
            do {
                let resultObj = try JSONSerialization.jsonObject(with: data, options : .allowFragments)
                DispatchQueue.main.async {
                    //print(resultObj)
                    self.viewActivity.isHidden = true
                    
                    if let json = resultObj as? [String: Any] {
                        //print("getPerformerOrgInfo json:",json);
                        if (json["statusCode"]as? String == "200"){
                            
                        }else{
                            let strError = json["message"] as? String
                            //print("strError:",strError ?? "")
                            self.showAlert(strMsg: strError ?? "")
                        }
                        
                        
                    }
                }
            } catch let error as NSError {
                //print(error)
                self.showAlert(strMsg: error.localizedDescription)
            }
            return nil
        }
    }
    // MARK: - Stream Methods
    
    func setLiveStreamConfig(){
        let netAvailable = appDelegate.isConnectedToInternet()
        if(!netAvailable){
            showAlert(strMsg: "Please check your internet connection!")
        }
        
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
        Testbed.setStreamName(name: streamVideoCode)
        Testbed.setStream1Name(name: streamVideoCode)
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
        
        
        self.configureStreamView()
    }
    func configureStreamView() {
        // Update the user interface for the detail item.
        // Access the static shared interface to ensure it's loaded
        _ = Testbed.sharedInstance
        self.detailStreamItem = Testbed.testAtIndex(index: 0)
        if(self.detailStreamItem != nil){
            //print("props:",self.detailStreamItem!["LocalProperties"] as? NSMutableDictionary)
            
            Testbed.setLocalOverrides(params: self.detailStreamItem!["LocalProperties"] as? NSMutableDictionary)
            let className = self.detailStreamItem!["class"] as! String
            let mClass = NSClassFromString(className) as! BaseTest.Type;
            
            r5ViewController  = mClass.init()
            r5ViewController?.view.frame = self.viewLiveStream.bounds
            self.viewLiveStream.addSubview(r5ViewController!.view)
            self.addChild(r5ViewController!)
            self.viewLiveStream.bringSubviewToFront(webView)
            self.viewLiveStream.bringSubviewToFront(btnRotationStream)
        }
    }
    @objc func showInfo(){
        let alert = UIAlertView()
        alert.title = "Info"
        alert.message = self.detailItem["description"] as? String
        alert.addButton(withTitle: "OK")
        alert.show()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        
        self.navigationController?.isNavigationBarHidden = true
        NotificationCenter.default.removeObserver(self)
    }
    func closeStream(){
        self.viewLiveStream.isHidden = true;
        // if( r5ViewController != nil ){
        r5ViewController?.closeTest()
        //     r5ViewController = nil
        // }
    }
    var shouldClose:Bool{
        get{
            if(r5ViewController != nil){
                return (r5ViewController?.shouldClose)!
            }
            else{
                return true
            }
        }
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
    // MARK: - Send Bird Methods
    
    
    
   
    @IBAction func playStream(_ sender: Any){
        //print("playStream called")
        self.setLiveStreamConfig();
    }
    // MARK: - Emoji Delegates
    
    //  Converted to Swift 5.2 by Swiftify v5.2.28138 - https://swiftify.com/
    
   
    // MARK: - Webview Delegates
    func webViewDidStartLoad(_ webView: UIWebView) {
        //viewActivity.isHidden = false
    }
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error)
    {
        //viewActivity.isHidden = true
        self.showAlert(strMsg:error.localizedDescription)
    }
    func webViewDidFinishLoad(_ webView: UIWebView) {
        //viewActivity.isHidden = true
    }
    deinit {
        print("Remove NotificationCenter Deinit")
        NotificationCenter.default.removeObserver(self)
    }
    //MARK: - location delegate methods
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let netAvailable = appDelegate.isConnectedToInternet()
        if(!netAvailable){
            return
        }
        let userLocation :CLLocation = locations[0] as CLLocation
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(userLocation) { (placemarks, error) in
            if (error != nil){
                //print("error in reverseGeocode")
            }
            let placemark = placemarks! as [CLPlacemark]
            if placemark.count>0{
                let placemark = placemarks![0]
                //print("country:",placemark.country!)
                self.strCountry = placemark.country!
                self.getRegion()
            }
        }
        
    }
    func getRegion(){
        for (i,_) in aryCountries.enumerated(){
            let element = aryCountries[i]
            let countryNames = element["countries"] as! [Any];
            for (j,_) in countryNames.enumerated() {
                let country = countryNames[j] as! String
                if(country.lowercased() == strCountry.lowercased()){
                    //print("equal:",country)
                    strRegionCode = element["region_code"]as! String
                    return
                }
            }
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        //print("Error \(error)")
    }
    
    @IBAction func landscapeStream() {
        print("lanscape:",btnRotationStreamTap)
        btnRotationStreamTap = !btnRotationStreamTap
        
        if(isIpadLandScape){
            print("iPad already landscape")
            if (btnRotationStreamTap){
                btnRotationStream.setImage(UIImage.init(named: "small_view.png"), for: .normal)
                liveStreamHeight.constant = self.view.frame.size.height - 100//header height
                print("height of view1:",self.view.frame.size.height)
                self.viewLiveStream.layoutIfNeeded()
            }else{
                btnRotationStream.setImage(UIImage.init(named: "full_view.png"), for: .normal)
                let viewHeight = self.view.frame.size.height*0.35
                print("height of view:",self.view.frame.size.height)
                liveStreamHeight.constant = viewHeight
                self.viewLiveStream.layoutIfNeeded()
            }
        }else{
            if (btnRotationStreamTap){
                let value = UIInterfaceOrientation.landscapeRight.rawValue
                UIDevice.current.setValue(value, forKey: "orientation")
                btnRotationStream.setImage(UIImage.init(named: "small_view.png"), for: .normal)
                if(UIDevice.current.userInterfaceIdiom == .pad){
                    liveStreamHeight.constant = self.view.frame.size.height - 100//header height
                }else{
                    liveStreamHeight.constant = self.view.frame.size.height - 44//header height
                }
                print("height of view1:",self.view.frame.size.height)
                self.viewLiveStream.layoutIfNeeded()
                let orientation = ["orientation": "landscape"]
                
                NotificationCenter.default.post(name: .StreamOrienationChange, object: self, userInfo: orientation)
                
            }else{
                let value = UIInterfaceOrientation.portrait.rawValue
                UIDevice.current.setValue(value, forKey: "orientation")
                btnRotationStream.setImage(UIImage.init(named: "full_view.png"), for: .normal)
                let viewHeight = self.view.frame.size.height*0.35
                print("height of view:",self.view.frame.size.height)
                liveStreamHeight.constant = viewHeight
                self.viewLiveStream.layoutIfNeeded()
                let orientation = ["orientation": "portrait"]
                
                NotificationCenter.default.post(name: .StreamOrienationChange, object: self, userInfo: orientation)
                
            }
        }
        
        
    }
    @IBAction func landscapeVideo() {
        print("lanscape:",btnRotationStreamTap)
        btnRotationStreamTap = !btnRotationStreamTap
        
        if(isIpadLandScape){
            print("iPad already landscape")
            if (btnRotationStreamTap){
                btnRotationStream.setImage(UIImage.init(named: "small_view.png"), for: .normal)
                liveStreamHeight.constant = self.view.frame.size.height - 100//header height
                print("height of view1:",self.view.frame.size.height)
                self.viewLiveStream.layoutIfNeeded()
            }else{
                btnRotationStream.setImage(UIImage.init(named: "full_view.png"), for: .normal)
                let viewHeight = self.view.frame.size.height*0.35
                print("height of view:",self.view.frame.size.height)
                liveStreamHeight.constant = viewHeight
                self.viewLiveStream.layoutIfNeeded()
            }
        }else{
            if (btnRotationStreamTap){
                let value = UIInterfaceOrientation.landscapeRight.rawValue
                UIDevice.current.setValue(value, forKey: "orientation")
                btnRotationStream.setImage(UIImage.init(named: "small_view.png"), for: .normal)
                if(UIDevice.current.userInterfaceIdiom == .pad){
                    liveStreamHeight.constant = self.view.frame.size.height - 100//header height
                }else{
                    liveStreamHeight.constant = self.view.frame.size.height - 44//header height
                }
                print("height of view1:",self.view.frame.size.height)
                self.viewLiveStream.layoutIfNeeded()
            }else{
                let value = UIInterfaceOrientation.portrait.rawValue
                UIDevice.current.setValue(value, forKey: "orientation")
                btnRotationStream.setImage(UIImage.init(named: "full_view.png"), for: .normal)
                let viewHeight = self.view.frame.size.height*0.35
                print("height of view:",self.view.frame.size.height)
                liveStreamHeight.constant = viewHeight
                self.viewLiveStream.layoutIfNeeded()
            }
        }
        
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
    static let StreamOrienationChange = Notification.Name("StreamOrienationChange")
    
}

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


class ChannelDetailVC: UIViewController,UICollectionViewDataSource,UITableViewDataSource,UITableViewDelegate,CollectionViewCellDelegate,UIWebViewDelegate,UICollectionViewDelegateFlowLayout,OpenChanannelChatDelegate{
    // MARK: - Variables Declaration
    
    @IBOutlet weak var scrollButtons: UIScrollView!
    @IBOutlet weak var buttonCVC: UICollectionView!
    
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
    var playerItem:AVPlayerItem?
    var player:AVPlayer?
    var slider: UISlider?
    var isLoaded = 0;
   
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
   
    @IBOutlet weak var heightTopView: NSLayoutConstraint?
    @IBOutlet weak var viewTop: UIView!
    
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
        if(UIDevice.current.userInterfaceIdiom == .pad){
            heightTopView?.constant = 60;
            viewTop.layoutIfNeeded()
            viewLiveStream.layoutIfNeeded()
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
        
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true);
        backPressed = false
        self.imgPerformerProfile.layer.cornerRadius = self.imgPerformerProfile.frame.size.width/2
        if(UIDevice.current.userInterfaceIdiom == .pad){
            self.imgStreamThumbNail.image = UIImage.init(named: "sample-event")
        }else{
            self.imgStreamThumbNail.image = UIImage.init(named: "sample_vod_square")
        }
        liveEvents();

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
            performerEvents();
            //getPerformerOrgInfo();
            hideViews();

            //bottom first object should show
               let infoLine = self.buttonCVC.viewWithTag(11) as? UILabel
                         let btnText = self.buttonCVC.viewWithTag(21) as? UIButton
                         let orange = UIColor(red: 255, green: 139, blue: 50);
                         infoLine?.backgroundColor = orange;
                         infoLine?.isHidden = false;
                         btnText?.setTitleColor(orange, for: .normal)
                         viewInfo.isHidden = false
        }
        let viewHeight = self.view.frame.size.height*0.35
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
        viewInfo.isHidden = true;
        viewAudios.isHidden = true;
        viewVideos.isHidden = true;
        viewUpcoming.isHidden = true;
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
                print("btnTag:",btnTag)
                let orange = UIColor(red: 255, green: 139, blue: 50);
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
                if(UIDevice.current.userInterfaceIdiom == .pad){
                cell.btnVideo.setImage((UIImage.init(named: "sample_vod_land")), for: .normal)
                }else{
                    cell.btnVideo.setImage((UIImage.init(named: "sample-details")), for: .normal)
                }
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
            //audios
           let cell = tableView.dequeueReusableCell(withIdentifier: "VideoCell") as! VideoCell
           cell.btnVideo.addTarget(self, action: #selector(playAudioBtnTapped(_:)), for: .touchUpInside)
           cell.btnVideo.tag = indexPath.row
           cell.btnVideo1.addTarget(self, action: #selector(playAudioBtnTapped(_:)), for: .touchUpInside)
           cell.btnVideo1.tag = indexPath.row
           let upcoming = self.aryAudios[indexPath.row] as? [String : Any];
           let strURL = upcoming?["videoThumbImage"] as? String ?? "";
           let videoTitle = upcoming?["videoTitle"] as? String ?? "";
           cell.lblTitle.text = videoTitle
           print("--vod strURL:",strURL);
           if let urlVideoThumbImage = URL(string: strURL){
               self.videoThumbNail(from: urlVideoThumbImage, button: cell.btnVideo)
           }else{
            if(UIDevice.current.userInterfaceIdiom == .pad){
               cell.btnVideo.setImage((UIImage.init(named: "sample_vod_land")), for: .normal)
            }else{
                cell.btnVideo.setImage((UIImage.init(named: "sample-details")), for: .normal)
            }
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
            vc.isUpcoming = true;
            self.navigationController?.pushViewController(vc, animated: true)

        }else if  (tableView == tblVideos){
            playVideoFromList(row: indexPath.row)
        }
        else if  (tableView == tblVideos){
            playVideoFromList(row: indexPath.row)
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
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @objc func playAudioFromList(row:Int){
        let upcoming = self.aryAudios[row] as? [String : Any];
        self.orgId = upcoming?["organization_id"]as? Int ?? 0
        self.performerId = upcoming?["performer_id"]as? Int ?? 0
        self.streamId = upcoming?["videoId"] as? Int ?? 0
        self.streamVideoCode = upcoming?["videoCode"] as? String ?? ""
        //print("self.streamVideoCode:",self.streamVideoCode)
        let url = upcoming?["videoUrl"] as? String ?? ""
        videoUrl = url
        let storyboard = UIStoryboard(name: "Main", bundle: nil);
        let vc = storyboard.instantiateViewController(withIdentifier: "StreamDetailVC") as! StreamDetailVC
        vc.streamId = self.streamId
        vc.delegate = self
        appDelegate.isLiveLoad = "1"
        vc.performerId = self.performerId;
        vc.strTitle = upcoming?["videoTitle"] as? String ?? "Channel Details"
        vc.isAudio = true;
        let  videoUrl = upcoming?["videoUrl"] as? String ?? ""
        print("videoUrl:",videoUrl)
        vc.strAudioSource = videoUrl
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func collectionView(collectionviewcell: DBCollectionViewCell?, index: Int, didTappedInTableViewCell: DashBoardCell) {
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
                                
                                //print("self.app_id_for_adds:",self.app_id_for_adds)
                                let strURL = self.dicPerformerInfo["performer_profile_pic"]as? String ?? ""
                                if let urlPerformer = URL(string: strURL){
                                    self.downloadPerformerPic(from: urlPerformer as URL)
                                }else{
                                    self.imgStreamThumbNail.image = UIImage(named: "user")
                                }
                            }else{
                                self.txtProfile.text = ""
                            }
                        }else{
                            let strError = json["message"] as? String
                            //print("strError1:",strError ?? "")
                            self.showAlert(strMsg: strError ?? "")
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
    
    
    override func viewWillDisappear(_ animated: Bool) {
        
        self.navigationController?.isNavigationBarHidden = true
        NotificationCenter.default.removeObserver(self)
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
    
    
    
   
    
   
    deinit {
        print("Remove NotificationCenter Deinit")
        NotificationCenter.default.removeObserver(self)
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

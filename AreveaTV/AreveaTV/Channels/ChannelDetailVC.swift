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
extension Notification.Name {
    static let didReceiveStreamData = Notification.Name("didReceiveStreamData")
}
class ChannelDetailVC: UIViewController,UICollectionViewDataSource,UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,CollectionViewCellDelegate,OpenChanannelChatDelegate,OpenChannelMessageTableViewCellDelegate{
    // MARK: - Variables Declaration
    
    @IBOutlet weak var scrollButtons: UIScrollView!
    @IBOutlet weak var buttonCVC: UICollectionView!
    @IBOutlet weak var viewVOD: UIView!
    
    @IBOutlet weak var viewBottom: UIView!
    @IBOutlet weak var viewComments: UIView!
    @IBOutlet weak var viewInfo: UIView!
    @IBOutlet weak var viewTip: UIView!
    @IBOutlet weak var viewAudios: UIView!
    @IBOutlet weak var viewVideos: UIView!
    @IBOutlet weak var viewProfile: UIView!
    @IBOutlet weak var viewUpcoming: UIView!
    @IBOutlet weak var viewFollowers: UIView!
    
    @IBOutlet weak var tblComments: UITableView!
    @IBOutlet weak var tblVideos: UITableView!
    @IBOutlet weak var tblAudios: UITableView!
    @IBOutlet weak var tblUpcoming: UITableView!
    @IBOutlet weak var tblFollowers: UITableView!
    @IBOutlet weak var tblDonations: UITableView!
    @IBOutlet weak var txtProfile: UITextView!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    @IBOutlet weak var btnUserName: UIButton!
    @IBOutlet weak var btnPayPerView: UIButton!
    
    var r5ViewController : BaseTest? = nil
    @IBOutlet weak var viewLiveStream: UIView!
    var dicPerformerInfo = [String: Any]()
    var aryCharityInfo = [Any]()
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
    var buttonNames = ["Info", "Donate", "Share","Profile","Upcoming", "Videos", "Audios"]
    
    var aryComments = [["name":"Cameron","desc":"Lorem Ipsum is simply dummy text of the printing and typesetting industry"],["name":"Daisy Austin","desc":"Lorem Ipsum is simply dummy text of the printing and typesetting industry"],["name":"Cameron","desc":"Lorem Ipsum is simply dummy text of the printing and typesetting industry"],["name":"Daisy Austin","desc":"Lorem Ipsum is simply dummy text of the printing and typesetting industry"],["name":"Cameron","desc":"Lorem Ipsum is simply dummy text of the printing and typesetting industry"],["name":"Daisy Austin","desc":"Lorem Ipsum is simply dummy text of the printing and typesetting industry"]]
    
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
    @IBOutlet weak var imgPerformer :UIImageView!
    @IBOutlet weak var lblVideoDesc: UILabel!
    @IBOutlet weak var lblVideoTitle: UILabel!
    @IBOutlet weak var lblVideoDesc_Info: UILabel!
    @IBOutlet weak var lblVideoTitle_Info: UILabel!
    
    @IBOutlet weak var lblNoDataComments: UILabel!
    @IBOutlet weak var lblNoDataDonations: UILabel!
    @IBOutlet weak var lblNoDataUpcoming: UILabel!
    @IBOutlet weak var lblNoDataVideos: UILabel!
    @IBOutlet weak var lblNoDataAudios: UILabel!
    @IBOutlet weak var lblNoDataFollowers: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    
    
    // MARK: - Live Chat Inputs
    var channel: SBDOpenChannel?
    var hasPrevious: Bool?
    var minMessageTimestamp: Int64 = Int64.max
    var isLoading: Bool = false
    var messages: [SBDBaseMessage] = []
    var initialLoading: Bool = true
    var scrollLock: Bool = false
    var resendableMessages: [String:SBDBaseMessage] = [:]
    var preSendMessages: [String:SBDBaseMessage] = [:]
    var stopMeasuringVelocity: Bool = false
    var lastOffsetCapture: TimeInterval = 0
    var isScrollingFast: Bool = false
    var lastOffset: CGPoint = CGPoint(x: 0, y: 0)
    var keyboardShown: Bool = false
    var keyboardHeight: CGFloat = 0
    var firstKeyboardShown: Bool = true
    @IBOutlet weak var inputMessageTextField: UITextField!
    @IBOutlet weak var sendUserMessageButton: UIButton!
    @IBOutlet weak var inputMessageInnerContainerViewBottomMargin: NSLayoutConstraint!
    
    let coverImageData: Data? = nil
    weak var delegate: OpenChanannelChatDelegate?
    var channelName = ""
    var paymentAmount = 0
    var streamPaymentMode = ""
    var strTitle = ""
    @IBOutlet weak var viewActivity: UIView!
    var isVOD = false;
    @IBOutlet weak var btnViewStream: UIButton!
    var superPerformerID = 0;
    var superOrgID = 0;
    // MARK: - View Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        viewActivity.isHidden = true
        // Do any additional setup after loading the view.
        registerNibs();
        addDoneButton()
        //print("detail item in channnel page:\(detailItem)")
        hideViews();
        //bottom first object should show
        viewInfo.isHidden = false;
        viewLiveStream.isHidden = true;
        lblNoDataComments.text = "No results found"
        lblNoDataDonations.text = "No results found"
        lblNoDataUpcoming.text = "No results found"
        lblNoDataVideos.text = "No results found"
        lblNoDataAudios.text = "No results found"
        lblNoDataFollowers.text = "No results found"
        lblTitle.text = strTitle
        //sendBirdConnect()
        btnViewStream.isHidden = true
        
        superOrgID = orgId;
        superPerformerID = performerId;
    }
    //Handler for View Live Stream Button Action
    @IBAction func showLiveStream(){
        stopVideo()
        self.btnViewStream.isHidden = true;
        self.viewVOD.isHidden = true
        self.viewLiveStream.isHidden = false;
        isVOD = false;
        performerId = superPerformerID
        orgId = superOrgID
        streamId = 0;
        liveEvents()
    }
    // MARK: Send Bird Methods
    func sendBirdConnect() {
        
        // self.view.endEditing(true)
        if SBDMain.getConnectState() == .open {
            SBDMain.disconnect {
                //                    DispatchQueue.main.async {
                //                        //self.setUIsForDefault()
                //                    }
                self.sendBirdConnect()
            }
            print("sendBirdConnect disconnect")
        }
        else {
            print("sendBirdConnect")

            viewActivity.isHidden = false
            let userId = UserDefaults.standard.string(forKey: "user_id");
            let nickname = appDelegate.USER_NAME_FULL
            
            let userDefault = UserDefaults.standard
            userDefault.setValue(userId, forKey: "sendbird_user_id")
            userDefault.setValue(nickname, forKey: "sendbird_user_nickname")
            
            //self.setUIsWhileConnecting()
            
            ConnectionManager.login(userId: userId ?? "1", nickname: nickname) { user, error in
                self.viewActivity.isHidden = true
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
                    
                }
            }
        }
    }
    
    func sendBirdChatConfig(){
        channelName = streamVideoCode
        SBDOpenChannel.getWithUrl(channelName, completionHandler: { (openChannel, error) in
            guard error == nil else {   // Error.
                return
            }
            
            self.channel = openChannel
            self.title = self.channel?.name
            self.loadPreviousMessages(initial: true)
            openChannel?.enter(completionHandler: { (error) in
                guard error == nil else {   // Error.
                    return
                }
            })
        })
        channel?.getMyMutedInfo(completionHandler: { (isMuted, description, startAt, endAt, duration, error) in
            if isMuted {
                //self.sendUserMessageButton.isEnabled = false
                //self.inputMessageTextField.isEnabled = false
                self.inputMessageTextField.placeholder = "You are muted"
            } else {
                self.sendUserMessageButton.isEnabled = true
                self.inputMessageTextField.isEnabled = true
                self.inputMessageTextField.placeholder = "Type a message.."
            }
        })
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        self.btnUserName.setTitle(appDelegate.USER_NAME, for: .normal)
        //adding observer
           NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(StreamNotificationHandler(_:)), name: .didReceiveStreamData, object: nil)
    }
    @objc func StreamNotificationHandler(_ notification:Notification) {
        // Do something now
        print("====StreamNotificationHandler")
        if let data = notification.userInfo as? [String: String]
        {
            for (key,value) in data
            {
                //key Stream
                //value Stopped/Started
                print("key: \(key)")
                print("value: \(value)")
                if (value == "Started"){
                    let name = buttonNames[0]
                    if (name != "Comments"){
                        buttonNames.insert("Comments", at: 0)
                        buttonCVC.reloadData()
                    }
                }else{
                    let name = buttonNames[0]
                    if (name == "Comments"){
                        buttonNames.remove(at: 0)
                        buttonCVC.reloadData()
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
        let nib = UINib(nibName: "ButtonsCVC", bundle: nil)
        buttonCVC?.register(nib, forCellWithReuseIdentifier:"ButtonsCVC")
        if let flowLayout = self.buttonCVC?.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.estimatedItemSize = CGSize(width: 1, height: 1)
        }
        
        tblComments.register(UINib(nibName: "OpenChannelUserMessageTableViewCell", bundle: nil), forCellReuseIdentifier: "OpenChannelUserMessageTableViewCell");
        tblAudios.register(UINib(nibName: "AudioCell", bundle: nil), forCellReuseIdentifier: "AudioCell");
        tblVideos.register(UINib(nibName: "VideoCell", bundle: nil), forCellReuseIdentifier: "VideoCell")
        tblUpcoming.register(UINib(nibName: "UpcomingCell", bundle: nil), forCellReuseIdentifier: "UpcomingCell")
        tblFollowers.register(UINib(nibName: "DashBoardCell", bundle: nil), forCellReuseIdentifier: "DashBoardCell")
        tblDonations.register(UINib(nibName: "CharityCell", bundle: nil), forCellReuseIdentifier: "CharityCell")
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true);
        backPressed = false
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
            //  showVideo(strURL: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4");
        }
        let commentsLine = self.buttonCVC.viewWithTag(10) as? UILabel
        commentsLine?.backgroundColor = .red;
    }
    func showVideo(strURL : String){
        if let url = URL(string: strURL){
            videoPlayer = AVPlayer(url: url)
            let controller = AVPlayerViewController()
            controller.player = videoPlayer
            controller.view.frame = self.viewVOD.bounds
            self.viewVOD.addSubview(controller.view)
            self.addChild(controller)
            
            viewLiveStream.isHidden = true;
            viewVOD.isHidden = false;
            btnViewStream.isHidden = false;
            videoPlayer.play()
            
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
            print("Invalid URL")
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
            cell.lblLine.tag = 10 + (indexPath.row);
            //cell.btn.setTitleColor(.white, for: .normal)
            return cell
        }
        return UICollectionViewCell()
    }
    //MARK: Main function, handling bottom views logic based on selection here
    func hideViews(){
        viewComments.isHidden = true;
        viewInfo.isHidden = true;
        viewTip.isHidden = true;
        viewAudios.isHidden = true;
        viewVideos.isHidden = true;
        viewProfile.isHidden = true;
        viewUpcoming.isHidden = true;
        viewFollowers.isHidden = true;
    }
    @objc func btnPress(_ sender: UIButton) {
        hideViews();
        let title = sender.titleLabel?.text!
        for (index,_) in buttonNames.enumerated() {
            let name = buttonNames[index]
            let btnTag = 10 + index;
            let tmpLbl = self.buttonCVC.viewWithTag(btnTag) as? UILabel
            if (name == title){
                tmpLbl?.backgroundColor = .red;
            }else{
                tmpLbl?.backgroundColor = .white;
            }
        }
        switch title {
        case "Comments":
            viewComments.isHidden = false;
        case "Info":
            viewInfo.isHidden = false;
        case "Donate":
            viewTip.isHidden = false;
        case "Share":
            share(sender);
        case "Audios":
            viewAudios.isHidden = false;
        case "Videos":
            viewVideos.isHidden = false;
        case "Profile":
            viewProfile.isHidden = false;
        case "Upcoming":
            viewUpcoming.isHidden = false;
        case "Followers":
            viewFollowers.isHidden = false;
        default:
            print("default")
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
        if (tableView == tblVideos){
            return aryVideos.count;
        }
        return 1
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (tableView == tblVideos){
            return 44
        }
        return 0;
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 44))
        let darkGreen = UIColor(red: 1, green: 29, blue: 39);
        view.backgroundColor = darkGreen;
        let label = UILabel(frame: CGRect(x: 15, y: 0, width: tableView.bounds.width - 30, height: 44))
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textColor = UIColor.white;
        //
        let section = self.aryVideos[section] as? [String : Any];
        let categoryName = section?["videoTitle"] as? String;
        label.text = categoryName;
        view.addSubview(label)
        let button = UIButton(frame: CGRect(x: 100, y: 100, width: 100, height: 50))
        button.backgroundColor = .clear
        button.setTitle("", for: .normal)
        button.setImage(UIImage(named: ""), for: .normal)
        self.view.addSubview(button)
        return view
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
            return 1;
        }
        else if(tableView == tblDonations){
            if (self.aryCharityInfo.count > 0){
                self.lblNoDataDonations.isHidden = true
            }else{
                self.lblNoDataDonations.isHidden = false
            }
            return aryCharityInfo.count;
        }
        else if(tableView == tblComments){
            if (self.messages.count > 0){
                lblNoDataComments.isHidden = true
            }else{
                lblNoDataComments.isHidden = false
            }
            return self.messages.count;
        }
        return 0;
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) ->  CGFloat {
        if (tableView == tblVideos){
            return 150;
        }else if  (tableView == tblAudios){
            return 80;
        }else if  (tableView == tblUpcoming){
            return 150;
        }else if  (tableView == tblFollowers){
            return 180;
        }else if  (tableView == tblDonations){
            return 130;
        }
        else if  (tableView == tblComments){
            return 60;
        }
        return 44;
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (tableView == tblVideos){
            let cell = tableView.dequeueReusableCell(withIdentifier: "VideoCell") as! VideoCell
            cell.btnVideo.addTarget(self, action: #selector(playVideoBtnTapped(_:)), for: .touchUpInside)
            cell.btnVideo.tag = indexPath.section
            
            cell.btnVideo1.addTarget(self, action: #selector(playVideoBtnTapped(_:)), for: .touchUpInside)
            cell.btnVideo1.tag = indexPath.section
            let upcoming = self.aryVideos[indexPath.section] as? [String : Any];
            let strURL = upcoming?["videoThumbImage"] as? String ?? "";
           // print("strURL:",strURL);
//            if let urlVideoThumbImage = URL(string: strURL){
//                self.videoThumbNail(from: urlVideoThumbImage, button: cell.btnVideo1)
//            }
            return cell
            
        }else if (tableView == tblDonations){
            let cell = tableView.dequeueReusableCell(withIdentifier: "CharityCell") as! CharityCell
            cell.btnDonate.addTarget(self, action: #selector(payDonation(_:)), for: .touchUpInside)
            cell.btnDonate.tag = indexPath.row
            
            let charity = self.aryCharityInfo[indexPath.row] as? [String : Any];
            cell.lblCharityName.text = charity?["charity_name"] as? String ?? ""
            cell.lblCharityDesc.text = charity?["charity_description"] as? String ?? ""
            let strURL = charity?["charity_logo"]as? String ?? ""
            if let urlCharity = URL(string: strURL){
                self.downloadImage(from: urlCharity as URL, imageView: cell.imgCharity)
            }
            
            return cell
            
        }else if (tableView == tblUpcoming){
            let cell = tableView.dequeueReusableCell(withIdentifier: "UpcomingCell") as! UpcomingCell
            //2020-04-26T19:28:49.000Z
            let item = self.aryUpcoming[indexPath.row] as? [String : Any];
            cell.lblTitle.text = item?["streamTitle"] as? String;
            var isoDate = "";
            if ((item?["publishedOn"] as? String) != nil)
            {
                isoDate = item?["publishedOn"] as? String ?? ""
            }
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.000Z"
            if let date = formatter.date(from: isoDate) {
                let formatter1 = DateFormatter()
                formatter1.dateFormat = "dd MMM yyyy ,hh:mm a"
                cell.lblDate.text = formatter1.string(from: date)
            }else{
                //print ("invalid date");
                cell.lblDate.text = "";
            }
            
            cell.lblPayment.text = item?["streamPaymentMode"] as? String;
            //cell.lblPayment.text = String(item["streamPayment"]as! Int) + " USD"
            cell.lblSession.text = item?["streamType"]as? String;
            return cell
            
        }else if (tableView == tblFollowers){
            let cell = tblFollowers.dequeueReusableCell(withIdentifier: "DashBoardCell", for: indexPath) as! DashBoardCell
            let organizations = [["name":"David Guetta"],["name":"Martin Gatrix"]]
            let rowArray = organizations;
            cell.updateCellWith(row: rowArray,controller: "channel_detail")
            cell.cellDelegate = self
            return cell
        }else if (tableView == tblComments){
            var cell: UITableViewCell = UITableViewCell()
            
            if self.messages[indexPath.row] is SBDAdminMessage {
                if let adminMessage = self.messages[indexPath.row] as? SBDAdminMessage,
                    let adminMessageCell = tableView.dequeueReusableCell(withIdentifier: "OpenChannelUserMessageTableViewCell") as? OpenChannelUserMessageTableViewCell {
                    adminMessageCell.setMessage(adminMessage)
                    adminMessageCell.delegate = self
                    if indexPath.row > 0 {
                        //adminMessageCell.setPreviousMessage(self.messages[indexPath.row - 1])
                    }
                    
                    cell = adminMessageCell
                }
            }
            else if self.messages[indexPath.row] is SBDUserMessage {
                let userMessage = self.messages[indexPath.row] as! SBDUserMessage
                if let userMessageCell = tableView.dequeueReusableCell(withIdentifier: "OpenChannelUserMessageTableViewCell") as? OpenChannelUserMessageTableViewCell,
                    let sender = userMessage.sender {
                    userMessageCell.setMessage(userMessage)
                    userMessageCell.delegate = self
                    
                    if sender.userId == SBDMain.getCurrentUser()!.userId {
                        // Outgoing message
                        if let requestId = userMessage.requestId {
                            if self.resendableMessages[requestId] != nil {
                                userMessageCell.showElementsForFailure()
                            }
                            else {
                                userMessageCell.hideElementsForFailure()
                            }
                        }
                    }
                    else {
                        // Incoming message
                        userMessageCell.hideElementsForFailure()
                    }
                    
                    DispatchQueue.main.async {
                        guard let updateCell = tableView.cellForRow(at: indexPath) else { return }
                        guard updateCell is OpenChannelUserMessageTableViewCell else { return }
                        
                        //updateUserMessageCell.profileImageView.setProfileImageView(for: sender)
                    }
                    
                    cell = userMessageCell
                }
            }
            
            if indexPath.row == 0 && self.messages.count > 0 && self.initialLoading == false && self.isLoading == false {
                self.loadPreviousMessages(initial: false)
            }
            
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AudioCell") as! AudioCell
            let audio = self.aryAudios[indexPath.row] as? [String : Any];
            
            let url = URL(string: audio?["videoUrl"] as? String ?? "")
            cell.lblTitle.text = audio?["videoTitle"] as? String ?? ""
            let playerItem:AVPlayerItem = AVPlayerItem(url: url!)
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
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //           let storyboard = UIStoryboard(name: "Main", bundle: nil);
        //           let vc = storyboard.instantiateViewController(withIdentifier: "ChannelDetailVC") as! ChannelDetailVC
        //           self.navigationController?.pushViewController(vc, animated: true)
        if (tableView == tblUpcoming){
            closeStream()
            stopVideo()

            let upcoming = self.aryUpcoming[indexPath.row] as? [String : Any];
            self.performerId = upcoming?["performer_id"]as? Int ?? 0
            self.streamId = upcoming?["videoId"] as? Int ?? 0
            self.streamVideoCode = upcoming?["streamCode"] as? String ?? ""
            print("self.streamVideoCode:",self.streamVideoCode)
            isVOD = false;
            liveEvents()
            /*let streamVideoTitle = upcoming?["streamTitle"] as? String ?? ""
            let streamVideoDesc = upcoming?["streamDescription"] as? String ?? ""
            self.paymentAmount = upcoming?["streamPayment"]as? Int ?? 0
            self.lblVideoTitle.text = streamVideoTitle
            self.lblVideoTitle_Info.text = streamVideoTitle
            self.lblVideoDesc.text = streamVideoDesc
            self.lblVideoDesc_Info.text = streamVideoDesc
            self.streamPaymentMode = upcoming?["streamPaymentMode"] as? String ?? ""
            if (self.streamPaymentMode == "paid"){
                self.btnPayPerView.isHidden = false
            }else{
                self.btnPayPerView.isHidden = true
            }
            self.viewVOD.isHidden = true
            self.stopVideo()
            self.streamId = upcoming?["videoId"] as? Int ?? 0
            self.viewVOD.isHidden = true
            self.viewLiveStream.isHidden = false;
            self.setLiveStreamConfig();*/
        }else if  (tableView == tblVideos){
            playVideoFromList(section: indexPath.section)
        }
    }
    @objc func playVideoBtnTapped(_ sender: UIButton)
    {
        playVideoFromList(section: sender.tag)
    }
    @objc func playVideoFromList(section:Int){
        stopVideo()
        closeStream()
        let upcoming = self.aryVideos[section] as? [String : Any];
        //print("upcoming:",upcoming)
        self.orgId = upcoming?["organization_id"]as? Int ?? 0
        self.performerId = upcoming?["performer_id"]as? Int ?? 0
        self.streamId = upcoming?["videoId"] as? Int ?? 0
        self.streamVideoCode = upcoming?["videoCode"] as? String ?? ""
        print("self.streamVideoCode:",self.streamVideoCode)
        let url = upcoming?["videoUrl"] as? String ?? ""
        videoUrl = url
        isVOD = true;
        liveEvents()
        /*let streamVideoTitle = upcoming?["videoTitle"] as? String ?? ""
        let streamVideoDesc = upcoming?["videoDescription"] as? String ?? ""
        self.paymentAmount = upcoming?["videoPayment"]as? Int ?? 0
        self.lblVideoTitle.text = streamVideoTitle
        self.lblVideoTitle_Info.text = streamVideoTitle
        self.lblVideoDesc.text = streamVideoDesc
        self.lblVideoDesc_Info.text = streamVideoDesc
        self.streamPaymentMode = upcoming?["videoPaymentMode"] as? String ?? ""
        if (self.streamPaymentMode == "paid"){
            self.btnPayPerView.isHidden = false
        }else{
            self.btnPayPerView.isHidden = true
        }
        self.viewVOD.isHidden = false
        let url = upcoming?["videoUrl"] as? String ?? ""
        videoUrl = url
        print("videoUrl:",videoUrl)
        self.showVideo(strURL: videoUrl);
        */
        /*let vod_urls = upcoming?["vod_urls"] as? String ?? ""
        if (vod_urls != ""){
            let vod_urls = convertToDictionary(text: vod_urls)
            let strHigh = vod_urls?["1080p"] as? String ?? ""
            if (strHigh != ""){
                getURL(url: strHigh)
            }else{
                let strMedium = vod_urls?["720p"] as? String ?? ""
                if (strMedium != ""){
                    getURL(url: strMedium)
                }else{
                    getURL(url: videoUrl)
                }
            }
        }else{
            getURL(url: videoUrl)
        }*/
    }
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
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
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any] {
                        //print("json:",json)
                        if (json["statusCode"]as? String == "200"){
                            let signed_url = json["signed_url"] as? String ?? ""
                            self.showVideo(strURL: signed_url);
                            self.viewActivity.isHidden = true
                        }else{
                            let strError = json["message"] as? String
                            //print(strError ?? "")
                            self.showAlert(strMsg: strError ?? "")
                            self.viewActivity.isHidden = true
                        }
                    }
                case .failure(let error):
                    //print(error)
                    self.viewActivity.isHidden = true
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
    
    @objc func resignKB(_ sender: Any) {
        inputMessageTextField.resignFirstResponder();
        
    }
    func addDoneButton() {
        let toolbar =  UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 35))
        
        let flexButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action:#selector(resignKB(_:)))
        toolbar.setItems([flexButton, doneButton], animated: true)
        toolbar.sizeToFit()
        inputMessageTextField.inputAccessoryView = toolbar;
    }
    
    // MARK: Text Field Delegate Methods
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.animateTextField(textField: textField, up:true)
        
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.animateTextField(textField: textField, up:false)
        
        textField.resignFirstResponder();
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder();
        return true;
    }
    
    // MARK: Keyboard  Delegate Methods
    
    func animateTextField(textField: UITextField, up: Bool)
    {
        let movementDistance:CGFloat = -400
        var movement:CGFloat = 0
        if up
        {
            movement = movementDistance
        }
        else
        {
            movement = -movementDistance
        }
        UIView.animate(withDuration: 0.3, animations: {
            self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
        })
    }
    
    // MARK: Tip Methods
    
    @objc func payDonation(_ sender: UIButton) {
         let user_id = UserDefaults.standard.string(forKey: "user_id");
        let charity = self.aryCharityInfo[sender.tag] as? [String:Any]
        let charityId = charity?["id"] as? Int ?? 0
        let params = ["paymentType": "charity_donation", "user_id": user_id ?? "1", "stream_id": streamId,"charity_id":charityId] as [String : Any]
        proceedToPayment(params: params)
    }
    @IBAction func payTip(_ sender: Any) {
        let user_id = UserDefaults.standard.string(forKey: "user_id");
        let params = ["paymentType": "performer_tip", "user_id": user_id ?? "1", "performer_id":self.performerId] as [String : Any]
        proceedToPayment(params: params)


    }
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
                   switch response.result {
                   case .success(let value):
                       if let json = value as? [String: Any] {
                        //print("proceedToPayment json:",json)
                        self.viewActivity.isHidden = true
                        
                           if (json["token"]as? String != nil){
                            let token = json["token"]as? String ?? ""
                            let urlOpen = "https://qa.arevea.tv/payment/" + token
                            guard let url = URL(string: urlOpen) else { return }
                            UIApplication.shared.open(url)
                           }else{
                               let strError = json["message"] as? String
                               ////print(strError ?? "")
                               self.showAlert(strMsg: strError ?? "")
                               self.viewActivity.isHidden = true
                           }
                       }
                   case .failure(let error):
                       ////print(error)
                       self.showAlert(strMsg: error.localizedDescription)
                      self.viewActivity.isHidden = true
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
        let strTextToShare = "Video title: " + lblVideoTitle.text! + "\n" + "Video description: " + lblVideoDesc.text! + "\n" + "Performer name: " + self.strTitle + "\n"

        let textToShare = [strTextToShare]
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
    func getDataPerformer(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    func downloadImage(from url: URL, imageView: UIImageView) {
        //print("Download Started")
        getDataPerformer(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            //print("Download Finished")
            DispatchQueue.main.async() { [weak self] in
                imageView.image = UIImage(data: data)
                imageView.contentMode = .scaleAspectFill
            }
        }
    }
   
    func videoThumbNail(from url: URL, button: UIButton) {
        getDataPerformer(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            DispatchQueue.main.async() { [weak self] in
                button.setImage(UIImage(data: data), for: .normal)
                button.imageView?.contentMode = .scaleAspectFill
            }
        }
    }
    
    // MARK: Handler for getUser API, using for filters
    func liveEvents() {
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
                print("Error occurred: \(error)")
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
                    if let json = resultObj as? [String: Any] {
                       // print("liveEvents json:",json);
                        self.btnViewStream.isHidden = true;
                        if (json["statusCode"]as? String == "200"){
                            //print(json["message"] as? String ?? "")
                            self.viewActivity.isHidden = true
                            let data = json["Data"] as? [String:Any]
                            let stream_info = data?["stream_info"] != nil
                            if(stream_info){
                                self.aryStreamInfo = data?["stream_info"] as? [Any] ?? [Any]()
                                if (self.aryStreamInfo.count > 0){
                                    let streamObj = self.aryStreamInfo[0] as? [String:Any]
                                    self.streamId = streamObj?["id"] as? Int ?? 0
                                    
                                    self.streamVideoCode = streamObj?["stream_video_code"] as? String ?? ""
                                    let streamVideoTitle = streamObj?["stream_video_title"] as? String ?? ""
                                    let streamVideoDesc = streamObj?["stream_video_description"] as? String ?? ""
                                    
                                    self.sendBirdChatConfig()
                                    self.paymentAmount = streamObj?["stream_payment_amount"]as? Int ?? 0
                                    self.lblVideoTitle.text = streamVideoTitle
                                    self.lblVideoTitle_Info.text = streamVideoTitle
                                    
                                    self.lblVideoDesc.text = streamVideoDesc
                                    self.lblVideoDesc_Info.text = streamVideoDesc
                                    
                                    self.streamPaymentMode = streamObj?["stream_payment_mode"] as? String ?? ""
                                    
                                }
                            }else{
                                //if we get any error default, we are showing VOD
                                self.viewVOD.isHidden = false
                                self.viewLiveStream.isHidden = true;
                                self.lblVideoTitle.text = ""
                                self.lblVideoTitle_Info.text = ""
                                ALToastView.toast(in: self.viewVOD, withText:"VOD/Stream Info not found, Please contact admin")
                            }
                            let user_subscription_info = data?["user_subscription_info"] != nil
                            if(user_subscription_info){
                                self.aryUserSubscriptionInfo = data?["user_subscription_info"] as? [Any] ?? [Any]()
                            }
                            if (self.streamPaymentMode == "paid" && self.aryUserSubscriptionInfo.count == 0){
                                self.btnPayPerView.isHidden = false
                                self.viewVOD.isHidden = false
                                ALToastView.toast(in: self.viewVOD, withText:"Please pay the amount to view Video/Stream")
                                ALToastView.toast(in: self.viewLiveStream, withText:"Please pay the amount to view Video/Stream")
                            }else{
                                self.btnPayPerView.isHidden = true
                                if (self.aryStreamInfo.count > 0){
                                    let streamObj = self.aryStreamInfo[0] as? [String:Any]
                                    if (streamObj?["stream_vod"]as? String == "stream" && self.isVOD == false){
                                        self.viewVOD.isHidden = true
                                        self.viewLiveStream.isHidden = false;
                                        self.setLiveStreamConfig();
                                        
                                    }else{
                                        self.viewVOD.isHidden = false
                                        self.viewLiveStream.isHidden = true;
                                        var url = streamObj?["video_url"] as? String ?? ""
                                        if (self.isVOD){
                                            url = self.videoUrl
                                        }
                                        print("--vod url:",url)
                                        self.showVideo(strURL: url);
                                    }
                                }
                            }
                            let charities_info = data?["charities_info"] != nil
                            if(charities_info){
                                self.aryCharityInfo = data?["charities_info"] as? [Any] ?? [Any]()
                                self.tblDonations.reloadData()
                            }
                            let performer_info = data?["performer_info"] != nil
                            if(performer_info){
                                self.dicPerformerInfo = data?["performer_info"] as? [String : Any] ?? [String:Any]()
                                let performerName = self.dicPerformerInfo["performer_display_name"] as? String
                                self.txtProfile.text = performerName
                                
                                let strURL = self.dicPerformerInfo["performer_profile_pic"]as? String ?? ""
                                if let urlPerformer = URL(string: strURL){
                                    self.downloadImage(from: urlPerformer as URL, imageView: self.imgPerformer)
                                }
                            }else{
                                self.txtProfile.text = ""
                            }
                            
                        }else{
                            let strError = json["message"] as? String
                            print("strError1:",strError ?? "")
                            self.showAlert(strMsg: strError ?? "")
                            self.viewActivity.isHidden = true
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
                print("Error occurred: \(error)")
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
                    
                    // print(resultObj)
                    if let json = resultObj as? [String: Any] {
                        //print("performerEvents json:",json);
                        if (json["statusCode"]as? String == "200"){
                            //print(json["message"] as? String ?? "")
                            self.aryUpcoming = json["Data"] as? [Any] ?? [Any]() ;
                            print("upcoming count:",self.aryUpcoming.count);
                            self.tblUpcoming.reloadData();
                            self.viewActivity.isHidden = true
                        }else{
                            let strError = json["message"] as? String
                            print("strError2:",strError ?? "")
                            self.showAlert(strMsg: strError ?? "")
                            self.viewActivity.isHidden = true
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
                print("Error occurred: \(error)")
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
                    if let json = resultObj as? [String: Any] {
                        // print("performerVideos json:",json);
                        if (json["statusCode"]as? String == "200"){
                            //print(json["message"] as? String ?? "")
                            self.aryVideos = json["Data"] as? [Any] ?? [Any]() ;
                            //print("videos:",self.aryVideos)
                            self.tblVideos.reloadData();
                            self.viewActivity.isHidden = true
                        }else{
                            let strError = json["message"] as? String
                            print("strError:",strError ?? "")
                            self.showAlert(strMsg: strError ?? "")
                            self.viewActivity.isHidden = true
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
                print("Error occurred: \(error)")
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
                    if let json = resultObj as? [String: Any] {
                        //print("performerAudios json:",json);
                        if (json["statusCode"]as? String == "200"){
                            //print(json["message"] as? String ?? "")
                            self.aryAudios = json["Data"] as? [Any] ?? [Any]() ;
                            print("audios count:",self.aryVideos.count)
                            self.tblAudios.reloadData();
                            self.viewActivity.isHidden = true
                        }else{
                            let strError = json["message"] as? String
                            print("strError:",strError ?? "")
                            self.showAlert(strMsg: strError ?? "")
                            self.viewActivity.isHidden = true
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
            print("props:",self.detailStreamItem!["LocalProperties"] as? NSMutableDictionary)
            
            Testbed.setLocalOverrides(params: self.detailStreamItem!["LocalProperties"] as? NSMutableDictionary)
            let className = self.detailStreamItem!["class"] as! String
            let mClass = NSClassFromString(className) as! BaseTest.Type;
            
            r5ViewController  = mClass.init()
            r5ViewController?.view.frame = self.viewLiveStream.bounds
            self.viewLiveStream.addSubview(r5ViewController!.view)
            self.addChild(r5ViewController!)
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
        closeStream()
        stopVideo()
        self.navigationController?.isNavigationBarHidden = true
        NotificationCenter.default.removeObserver(self)
    }
    func closeStream(){
        if( r5ViewController != nil ){
            r5ViewController!.closeTest()
            r5ViewController = nil
        }
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
    
    
    
    func loadPreviousMessages(initial: Bool) {
        guard let channel = self.channel else { return }
        
        if self.isLoading {
            return
        }
        
        self.isLoading = true
        
        var timestamp: Int64 = 0
        
        if initial {
            self.hasPrevious = true
            timestamp = Int64.max
        }
        else {
            timestamp = self.minMessageTimestamp
        }
        
        if self.hasPrevious == false {
            return
        }
        
        channel.getPreviousMessages(byTimestamp: timestamp, limit: 30, reverse: !initial, messageType: .all, customType: nil, completionHandler: { (msgs, error) in
            if error != nil {
                self.isLoading = false
                
                return
            }
            
            guard let messages = msgs else { return }
            
            if messages.count == 0 {
                self.hasPrevious = false
            }
            
            if initial {
                if messages.count > 0 {
                    DispatchQueue.main.async {
                        self.messages.removeAll()
                        
                        for message in messages {
                            self.messages.append(message)
                            
                            if self.minMessageTimestamp > message.createdAt {
                                self.minMessageTimestamp = message.createdAt
                            }
                        }
                        
                        self.initialLoading = true
                        
                        self.tblComments.reloadData()
                        self.tblComments.layoutIfNeeded()
                        
                        //self.scrollToBottom(force: true)
                        self.initialLoading = false
                        self.isLoading = false
                    }
                }
            }
            else {
                if messages.count > 0 {
                    DispatchQueue.main.async {
                        var messageIndexPaths: [IndexPath] = []
                        var row: Int = 0
                        for message in messages {
                            self.messages.insert(message, at: 0)
                            
                            if self.minMessageTimestamp > message.createdAt {
                                self.minMessageTimestamp = message.createdAt
                            }
                            
                            messageIndexPaths.append(IndexPath(row: row, section: 0))
                            row += 1
                        }
                        
                        self.tblComments.reloadData()
                        self.tblComments.layoutIfNeeded()
                        
                        self.tblComments.scrollToRow(at: IndexPath(row: messages.count-1, section: 0), at: .top, animated: false)
                        self.isLoading = false
                    }
                }
            }
        })
    }
    @IBAction func clickSendUserMessageButton(_ sender: Any) {
        
        inputMessageTextField.resignFirstResponder()
        let messageText = inputMessageTextField.text!.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        if (messageText.count == 0){
            showAlert(strMsg: "Please enter message")
            return
        }
        print("channelName:",channelName)
        guard let channel = self.channel else {
            showAlert(strMsg: "Channel does not exist on send bird server to send message")
            return
        }
        self.inputMessageTextField.text = ""
        //self.sendUserMessageButton.isEnabled = false
        var preSendMessage: SBDUserMessage?
        preSendMessage = channel.sendUserMessage(messageText) { (userMessage, error) in
            if error != nil {
                DispatchQueue.main.async {
                    guard let preSendMsg = preSendMessage else { return }
                    guard let requestId = preSendMsg.requestId else { return }
                    
                    self.preSendMessages.removeValue(forKey: requestId)
                    self.resendableMessages[requestId] = preSendMsg
                    self.tblComments.reloadData()
                    // self.scrollToBottom(force: false)
                }
                return
            }
            
            guard let message = userMessage else { return }
            guard let requestId = message.requestId else { return }
            
            DispatchQueue.main.async {
                self.determineScrollLock()
                
                if let preSendMessage = self.preSendMessages[requestId] {
                    if let index = self.messages.firstIndex(of: preSendMessage) {
                        self.messages[index] = message
                        self.preSendMessages.removeValue(forKey: requestId)
                        self.tblComments.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
                        // self.scrollToBottom(force: false)
                    }
                }
            }
        }
        
        DispatchQueue.main.async {
            self.determineScrollLock()
            if let preSendMsg = preSendMessage {
                if let requestId = preSendMsg.requestId {
                    self.preSendMessages[requestId] = preSendMsg
                    self.messages.append(preSendMsg)
                    self.tblComments.reloadData()
                    // self.scrollToBottom(force: false)
                }
            }
        }
    }
    // MARK: - Keyboard
    func determineScrollLock() {
        if self.messages.count > 0 {
            if let indexPaths = self.tblComments.indexPathsForVisibleRows {
                if let lastVisibleCellIndexPath = indexPaths.last {
                    let lastVisibleRow = lastVisibleCellIndexPath.row
                    if lastVisibleRow != self.messages.count - 1 {
                        self.scrollLock = true
                    }
                    else {
                        self.scrollLock = false
                    }
                }
            }
        }
    }
    // MARK: Send Bird Methods
   
    
    
    
}

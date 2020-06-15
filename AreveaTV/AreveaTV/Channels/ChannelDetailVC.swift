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
class ChannelDetailVC: UIViewController,UICollectionViewDataSource,UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,CollectionViewCellDelegate,OpenChanannelChatDelegate,OpenChannelMessageTableViewCellDelegate,AGEmojiKeyboardViewDelegate, AGEmojiKeyboardViewDataSource{
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
    var buttonNames = ["Comments","Info", "Donate", "Share","Profile","Upcoming", "Audios","Videos"]
    
    
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
    var channel_emoji: SBDOpenChannel?
    var hasPrevious: Bool?
    var minMessageTimestamp: Int64 = Int64.max
    var isLoading: Bool = false
    var messages: [SBDBaseMessage] = []
    var emojis: [SBDBaseMessage] = []
    
    var initialLoading: Bool = true
    var scrollLock: Bool = false
    var resendableMessages: [String:SBDBaseMessage] = [:]
    var preSendMessages: [String:SBDBaseMessage] = [:]
    var resendableMessage_emojis: [String:SBDBaseMessage] = [:]
    var preSendMessage_emojis: [String:SBDBaseMessage] = [:]
    var stopMeasuringVelocity: Bool = false
    var lastOffsetCapture: TimeInterval = 0
    var isScrollingFast: Bool = false
    var lastOffset: CGPoint = CGPoint(x: 0, y: 0)
    var keyboardShown: Bool = false
    var keyboardHeight: CGFloat = 0
    var firstKeyboardShown: Bool = true
    @IBOutlet weak var txtComment: UITextField!
    @IBOutlet weak var txtEmoji: UITextField!
    
    @IBOutlet weak var sendUserMessageButton: UIButton!
    @IBOutlet weak var inputMessageInnerContainerViewBottomMargin: NSLayoutConstraint!
    
    let coverImageData: Data? = nil
    weak var delegate: OpenChanannelChatDelegate?
    var channelName = ""
    var channelName_Emoji = ""
    var paymentAmount = 0
    var streamPaymentMode = ""
    var strTitle = ""
    @IBOutlet weak var viewActivity: UIView!
    var isVOD = false;
    @IBOutlet weak var btnViewStream: UIButton!
    var superPerformerID = 0;
    var superOrgID = 0;
    @IBOutlet weak var imgStreamThumbNail: UIImageView!
    @IBOutlet weak var btnPlayStream: UIButton!
    @IBOutlet weak var lblStreamUnavailable: UILabel!
    @IBOutlet weak var lblVODUnavailable: UILabel!
    
    var isStream = true;
    var isChannelAvailable = false;
    var isChannelAvailable_emoji = false;
    var isUpcoming = false;
    private let editor = VideoEditor()
    private var pickedURL: URL?
    var sendBirdErrorCode = 0;
    var sendBirdErrorCode_Emoji = 0;
    var sbdError = SBDError()
    var sbdError_emoji = SBDError()
    
    @IBOutlet weak var imgEmoji: UIImageView!
    @IBOutlet weak var imgEmoji1: UIImageView!
    
    // MARK: - View Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        viewActivity.isHidden = true
        // Do any additional setup after loading the view.
        registerNibs();
        addDoneButton()
        //print("detail item in channnel page:\(detailItem)")
       
        viewLiveStream.isHidden = true;
        lblNoDataComments.text = ""
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
        // txtComment.textInputMode?.primaryLanguage = "emoji"
        //imgEmoji.isHidden = true
        let emojiKeyboardView = AGEmojiKeyboardView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 216), dataSource: self)
        emojiKeyboardView?.autoresizingMask = UIView.AutoresizingMask.flexibleHeight
        emojiKeyboardView?.delegate = self
        //self.textView.inputView = emojiKeyboardView;
        imgEmoji1.image = UIImage.init(named: "addemoji.png")
        txtEmoji.inputView = emojiKeyboardView
        txtEmoji.tintColor = UIColor.clear
        txtEmoji.addTarget(self, action: #selector(txtEmojiTap), for: .touchDown)
        hideViews();
        
    }
    @objc func txtEmojiTap(textField: UITextField) {
        if ((imgEmoji1.image?.isEqual(UIImage.init(named: "addemoji.png")))!)
        {
            imgEmoji1.image = UIImage.init(named: "closeemoji.png")
        }
        else{
            txtEmoji.resignFirstResponder()
            imgEmoji1.image = UIImage.init(named: "addemoji.png")
        }
    }
    //Handler for View Live Stream Button Action
    @IBAction func viewLiveStreamTapped(){
        stopVideo()
        self.btnViewStream.isHidden = true;
        self.viewVOD.isHidden = true
        self.viewLiveStream.isHidden = false;
        isVOD = false;
        isUpcoming = false;
        performerId = superPerformerID
        orgId = superOrgID
        streamId = 0;
        liveEvents()
    }
    @IBAction func test(){
        
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
            //print("sendBirdConnect disconnect")
        }
        else {
            //print("sendBirdConnect")
            
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
                    //print("Logged In With SendBird Successfully")
                    
                }
            }
        }
    }
    
    func sendBirdChatConfig(){
        channelName = streamVideoCode
        //print("channelName in sendBirdChatConfig:",channelName)
        SBDOpenChannel.getWithUrl(channelName, completionHandler: { (openChannel, error) in
            guard error == nil else {   // Error.
                let errorDesc = "Chat Error:" + error!.localizedDescription
                //print("Send Bird Error:\(error!)")
                //print(errorDesc)
                self.sbdError = error!
                self.sendBirdErrorCode = error?.code ?? 0
                //self.showAlert(strMsg:errorDesc )
                self.messages.removeAll()
                self.channel = nil
                self.isChannelAvailable = false
                self.tblComments.reloadData()
                return
            }
            self.channel = openChannel
            self.title = self.channel?.name
            //self.loadPreviousMessages(initial: true)
            openChannel?.enter(completionHandler: { (error) in
                guard error == nil else {   // Error.
                    return
                }
            })
        })
        channel?.getMyMutedInfo(completionHandler: { (isMuted, description, startAt, endAt, duration, error) in
            if isMuted {
                //self.sendUserMessageButton.isEnabled = false
                //self.txtComment.isEnabled = false
                self.txtComment.placeholder = "You are muted"
            } else {
                self.sendUserMessageButton.isEnabled = true
                self.txtComment.isEnabled = true
                self.txtComment.placeholder = "Type a message.."
            }
        })
    }
    func sendBirdEmojiConfig(){
        channelName_Emoji = streamVideoCode + "_emoji"
        //print("channelName_Emoji in sendBirdChatConfig:",channelName_Emoji)
        SBDOpenChannel.getWithUrl(channelName_Emoji, completionHandler: { (openChannel, error) in
            guard error == nil else {   // Error.
                let errorDesc = "Chat Error:" + error!.localizedDescription
                //print("Send Bird Error:\(error!)")
                //print(errorDesc)
                self.isChannelAvailable_emoji = false
                return
            }
            self.isChannelAvailable_emoji = true
            self.channel_emoji = openChannel
            self.title = self.channel_emoji?.name
            self.loadPreviousEmojis(initial: true)
            openChannel?.enter(completionHandler: { (error) in
                guard error == nil else {   // Error.
                    return
                }
            })
        })
        channel_emoji?.getMyMutedInfo(completionHandler: { (isMuted, description, startAt, endAt, duration, error) in
            if isMuted {
                //                ALToastView.toast(in: self.viewVOD, withText:"You are muted")
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
                    isChannelAvailable = true
                    tblComments.reloadData()
                }else if(value == "stopped"){
                    //lblStreamUnavailable.text = "publisher has unpublished. possibly from background/interrupt"
                    isChannelAvailable = false;
                    btnPlayStream.isHidden = true;
                    tblComments.reloadData()
                }else if(value == "not_available"){
                    lblStreamUnavailable.text = "Video streaming is currently unavailable. Please try again later"
                    btnPlayStream.setImage(UIImage.init(named: "refresh-icon.png"), for: .normal)
                    btnPlayStream.isHidden = false;
                    isChannelAvailable = false
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
            //getPerformerOrgInfo();
        }
        //bottom first object should show
               if(appDelegate.detailToShow == "performer"){
                   viewProfile.isHidden = false;
                   let profileLine = self.buttonCVC.viewWithTag(14) as? UILabel
                   profileLine?.backgroundColor = .red;
               }else if(appDelegate.detailToShow == "video"){
                   viewVideos.isHidden = false;
                   let videoLine = self.buttonCVC.viewWithTag(17) as? UILabel
                   videoLine?.backgroundColor = .red;
               }else if(appDelegate.detailToShow == "audio"){
                   viewAudios.isHidden = false;
                   let audioLine = self.buttonCVC.viewWithTag(16) as? UILabel
                   audioLine?.backgroundColor = .red;
               }else{
                   viewComments.isHidden = false;
                   let commentsLine = self.buttonCVC.viewWithTag(10) as? UILabel
                   commentsLine?.backgroundColor = .red;
               }
        
    }
    func delay(_ delay:Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }
    func animateEmojisLoop(_ iteration: Int = 0) {
        let i = iteration
        if (iteration < self.emojis.count){
            let userMessage = self.emojis[i] as! SBDUserMessage
            self.delay(2.0){
                let strEmojiText = userMessage.message
                self.imgEmoji.image = strEmojiText!.image()
                self.animateEmoji()
                return self.animateEmojisLoop(i + 1)
            }
        }
    }
    
    func animateEmoji() {
        self.imgEmoji.isHidden = false;
        var frameBug = self.imgEmoji.frame
        // //print("bug fr:",self.imgEmoji.frame)
        frameBug.origin.x = 200
        frameBug.origin.y = 200
        let xConst = frameBug.origin.x;
        let yConst = frameBug.origin.y;
        
        //self.bug.frame = frameBug
        UIView.animate(withDuration: 2.0, delay: 0, options: .curveLinear, animations: {
            self.imgEmoji.transform = CGAffineTransform(translationX: -xConst, y: -yConst)
            //self.bug.transform = CGAffineTransform(rotationAngle: .pi)
            
        }) { (success: Bool) in
            self.imgEmoji.transform = CGAffineTransform.identity
            self.imgEmoji.isHidden = true;
            //self.animateEmojis()
        }
    }
    
    func showVideo1(url : URL){
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
            btnViewStream.isHidden = false;
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
        txtEmoji.resignFirstResponder()
        hideViews();
        let title = sender.titleLabel?.text!
        for (index,_) in buttonNames.enumerated() {
            let name = buttonNames[index]
            let btnTag = 10 + index;
            let tmpLbl = self.buttonCVC.viewWithTag(btnTag) as? UILabel
            
            if (name == title){
                print("btnTag:",btnTag)
                tmpLbl?.backgroundColor = .red;
            }else{
                tmpLbl?.backgroundColor = .white;
            }
        }
        let tmpLbl1 = self.buttonCVC.viewWithTag(16) as? UILabel
        tmpLbl1?.backgroundColor = .green
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
            //            if (self.messages.count > 0){
            //                lblNoDataComments.isHidden = true
            //            }else{
            //                lblNoDataComments.isHidden = false
            //            }
            if (isChannelAvailable){
                tblComments.isHidden = false
                lblNoDataComments.text = ""
            }else{
                tblComments.isHidden = true
                lblNoDataComments.text = "Channel is unavailable"
                
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
            // //print("strURL:",strURL);
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
                        
                        // updateUserMessageCell.profileImageView.setProfileImageView(for: sender)
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
            //print("self.streamVideoCode:",self.streamVideoCode)
            isVOD = false;
            isUpcoming = true;
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
        txtEmoji.resignFirstResponder()
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
        //print("self.streamVideoCode:",self.streamVideoCode)
        let url = upcoming?["videoUrl"] as? String ?? ""
        videoUrl = url
        isVOD = true;
        btnViewStream.isHidden = false;
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
         //print("videoUrl:",videoUrl)
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
    
    @objc func resignKB(_ sender: Any) {
        txtComment.resignFirstResponder();
        
    }
    func addDoneButton() {
        let toolbar =  UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 35))
        
        let flexButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action:#selector(resignKB(_:)))
        toolbar.setItems([flexButton, doneButton], animated: true)
        toolbar.sizeToFit()
        txtComment.inputAccessoryView = toolbar;
    }
    
    // MARK: Text Field Delegate Methods
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if (txtComment == textField){
            self.animateTextField(textField: textField, up:true)
        }else if(txtEmoji == textField){
            imgEmoji.isHidden = true
        }
        
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if (txtComment == textField){
            self.animateTextField(textField: textField, up:false)
        }
        else if(txtEmoji == textField){
            
        }
        textField.resignFirstResponder();
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder();
        return true;
    }
    
    // MARK: Keyboard  Delegate Methods
    
    func animateTextField(textField: UITextField, up: Bool)
    {
        let movementDistance:CGFloat = -300
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
        txtEmoji.resignFirstResponder()
        let user_id = UserDefaults.standard.string(forKey: "user_id");
        let charity = self.aryCharityInfo[sender.tag] as? [String:Any]
        let charityId = charity?["id"] as? Int ?? 0
        let params = ["paymentType": "charity_donation", "user_id": user_id ?? "1", "stream_id": streamId,"charity_id":charityId] as [String : Any]
        proceedToPayment(params: params)
    }
    @IBAction func payTip(_ sender: Any) {
        let user_id = UserDefaults.standard.string(forKey: "user_id");
        let params = ["paymentType": "performer_tip", "user_id": user_id ?? "1", "performer_id":self.performerId,"stream_id": streamId] as [String : Any]
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
            //print(response?.suggestedFilename ?? url.lastPathComponent)
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
            //print(response?.suggestedFilename ?? url.lastPathComponent)
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
        //print("liveEvents params:",params)
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
                    if let json = resultObj as? [String: Any] {
                        //print("liveEvents json:",json);
                        self.btnViewStream.isHidden = true;
                        if (json["statusCode"]as? String == "200"){
                            //print(json["message"] as? String ?? "")
                            let data = json["Data"] as? [String:Any]
                            self.aryStreamInfo = data?["stream_info"] as? [Any] ?? [Any]()
                            if (self.aryStreamInfo.count > 0){
                                self.viewLiveStream.isHidden = false;
                                self.btnPlayStream.setImage(UIImage.init(named: "play-vod.png"), for: .normal)
                                self.btnPlayStream.isHidden = true;
                                let streamObj = self.aryStreamInfo[0] as? [String:Any]
                                self.streamId = streamObj?["id"] as? Int ?? 0
                                
                                self.streamVideoCode = streamObj?["stream_video_code"] as? String ?? ""
                                let streamVideoTitle = streamObj?["stream_video_title"] as? String ?? ""
                                let streamVideoDesc = streamObj?["stream_video_description"] as? String ?? ""
                                let streamBannerURL = streamObj?["video_thumbnail_image"] as? String ?? ""
                                if let urlBanner = URL(string: streamBannerURL){
                                    self.downloadImage(from: urlBanner as URL, imageView: self.imgStreamThumbNail)
                                }else{
                                    self.imgStreamThumbNail.image = UIImage.init(named: "default-vod.png")
                                }
                                self.sendBirdChatConfig()
                                self.sendBirdEmojiConfig()
                                self.paymentAmount = streamObj?["stream_payment_amount"]as? Int ?? 0
                                self.lblVideoTitle.text = streamVideoTitle
                                self.lblVideoTitle_Info.text = streamVideoTitle
                                
                                self.lblVideoDesc.text = streamVideoDesc
                                self.lblVideoDesc_Info.text = streamVideoDesc
                                
                                self.streamPaymentMode = streamObj?["stream_payment_mode"] as? String ?? ""
                                
                            }else{
                                //if we get any error default, we are showing VOD
                                self.viewVOD.isHidden = false
                                self.viewLiveStream.isHidden = true;
                                self.lblVideoTitle.text = ""
                                self.lblVideoTitle_Info.text = ""
                                self.lblVODUnavailable.text = "Stream Info not found"
                                //ALToastView.toast(in: self.viewVOD, withText:"Stream Info not found")
                            }
                            let user_subscription_info = data?["user_subscription_info"] != nil
                            if(user_subscription_info){
                                self.aryUserSubscriptionInfo = data?["user_subscription_info"] as? [Any] ?? [Any]()
                            }
                            if (self.streamPaymentMode == "paid" && self.aryUserSubscriptionInfo.count == 0){
                                //if user does not pay amount
                                self.btnPayPerView.isHidden = false
                                self.viewVOD.isHidden = false
                                self.isChannelAvailable = false;
                                self.tblComments.reloadData()
                            }else{
                                self.btnPayPerView.isHidden = true
                                if (self.aryStreamInfo.count > 0){
                                    let streamObj = self.aryStreamInfo[0] as? [String:Any]
                                    if (streamObj?["stream_vod"]as? String == "stream" && self.isVOD == false){
                                        self.viewVOD.isHidden = true
                                        self.viewLiveStream.isHidden = false;
                                        self.isStream = true;
                                        self.btnPlayStream.isHidden = false;
                                        self.lblStreamUnavailable.text = "";
                                        self.isChannelAvailable = false;
                                        if(self.isUpcoming){
                                            self.btnViewStream.isHidden = false;
                                        }else{
                                            self.btnViewStream.isHidden = true;
                                        }
                                    }else{
                                        self.lblVODUnavailable.text = ""
                                        self.viewVOD.isHidden = false
                                        self.viewLiveStream.isHidden = true;
                                        self.btnPlayStream.isHidden = true;
                                        self.isStream = false;
                                        let vod_urls = streamObj?["vod_urls"] as? String ?? ""
                                        var strURL = "";
                                        if (vod_urls != ""){
                                            let vod_urls = self.convertToDictionary(text: vod_urls)
                                            let strHigh = vod_urls?["1080p"] as? String ?? ""
                                            if (strHigh != ""){
                                                strURL = strHigh;
                                            }else{
                                                let strMedium = vod_urls?["720p"] as? String ?? ""
                                                if (strMedium != ""){
                                                    strURL = strMedium;
                                                }else{
                                                    let strLow = vod_urls?["540p"] as? String ?? ""
                                                    if (strLow != ""){
                                                        strURL = strLow;
                                                    }else{
                                                        let strLowest = vod_urls?["270p"] as? String ?? ""
                                                        if (strLowest != ""){
                                                            strURL = strLowest;
                                                        }else{
                                                            let video_url = streamObj?["video_url"] as? String ?? ""
                                                            strURL = video_url
                                                        }
                                                    }
                                                }
                                            }
                                        }else{
                                            let video_url = streamObj?["video_url"] as? String ?? ""
                                            strURL = video_url
                                        }
                                        //print("strURL:",strURL)
                                        self.isChannelAvailable = true;
                                        self.tblComments.reloadData()
                                        self.showVideo(strURL: strURL);
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
                        //print("videos count:",self.aryVideos.count);
                        
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
        self.viewLiveStream.isHidden = true;
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
                        
                        self.scrollToBottom(force: true)
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
    func loadPreviousEmojis(initial: Bool) {
        guard let channel_emoji = self.channel_emoji else { return }
        
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
        
        channel_emoji.getPreviousMessages(byTimestamp: timestamp, limit: 30, reverse: !initial, messageType: .all, customType: nil, completionHandler: { (msgs, error) in
            if error != nil {
                self.isLoading = false
                
                return
            }
            
            guard let emojis = msgs else { return }
            
            if emojis.count == 0 {
                self.hasPrevious = false
            }
            
            if initial {
                if emojis.count > 0 {
                    DispatchQueue.main.async {
                        self.emojis.removeAll()
                        
                        for message in emojis {
                            self.emojis.append(message)
                            //print("self.emojis:",self.emojis)
                            if self.minMessageTimestamp > message.createdAt {
                                self.minMessageTimestamp = message.createdAt
                            }
                        }
                        
                        self.initialLoading = true
                        self.animateEmojisLoop()
                        //self.tblComments.reloadData()
                        self.initialLoading = false
                        self.isLoading = false
                    }
                }
            }
            else {
                if emojis.count > 0 {
                    DispatchQueue.main.async {
                        var messageIndexPaths: [IndexPath] = []
                        var row: Int = 0
                        for message in emojis {
                            self.emojis.insert(message, at: 0)
                            
                            if self.minMessageTimestamp > message.createdAt {
                                self.minMessageTimestamp = message.createdAt
                            }
                            
                            messageIndexPaths.append(IndexPath(row: row, section: 0))
                            row += 1
                        }
                        
                        //  self.tblComments.reloadData()
                        
                        self.isLoading = false
                    }
                }
            }
        })
    }
    @IBAction func sendChatMessage(_ sender: Any) {
        txtComment.resignFirstResponder()
        let messageText = txtComment.text!.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        if (messageText.count == 0){
            showAlert(strMsg: "Please enter message")
            return
        }
        
        if (!isChannelAvailable){
            //print("sendBirdErrorCode:",sendBirdErrorCode)
            switch sendBirdErrorCode {
            case 403100:
                showAlert(strMsg: "Application id disabled/expired, Please contact admin.")
            case 400300:
                showAlert(strMsg: "Deactivated user not accessible, Please contact admin.")
            case 400301:
                showAlert(strMsg: "User not found, Please contact admin.")
            case 400304:
                showAlert(strMsg: "Application id not found, Please contact admin.")
            case 400306:
                showAlert(strMsg: "Paid quota exceeded, Please contact admin.")
            case 400700:
                showAlert(strMsg: "Blocked user send not allowed, Please contact admin.")
            case 500910:
                showAlert(strMsg: "Rate limit exceeded, Please contact admin.")
                /* case 400201:
                 showAlert(strMsg: "Channel is not available, Please try again later.")*/
            default:
                showAlert(strMsg: "\(self.sbdError)")
            }
            return
        }
        
        //print("channelName:",channelName)
        guard let channel = self.channel else {
            showAlert(strMsg: "Channel is not available, Please try again later.")
            return
        }
        //print("channelName2:",self.channel?.name);
        self.txtComment.text = ""
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
                    self.scrollToBottom(force: false)
                    
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
                        self.scrollToBottom(force: false)
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
                    self.scrollToBottom(force: false)
                }
            }
        }
    }
    @IBAction func sendEmoji(strEmoji: String) {
        
        if (!isChannelAvailable_emoji){
            //print("sendBirdErrorCode:",sendBirdErrorCode_Emoji)
            switch sendBirdErrorCode_Emoji {
            case 403100:
                showAlert(strMsg: "Application id disabled/expired, Please contact admin.")
            case 400300:
                showAlert(strMsg: "Deactivated user not accessible, Please contact admin.")
            case 400301:
                showAlert(strMsg: "User not found, Please contact admin.")
            case 400304:
                showAlert(strMsg: "Application id not found, Please contact admin.")
            case 400306:
                showAlert(strMsg: "Paid quota exceeded, Please contact admin.")
            case 400700:
                showAlert(strMsg: "Blocked user send not allowed, Please contact admin.")
            case 500910:
                showAlert(strMsg: "Rate limit exceeded, Please contact admin.")
                /* case 400201:
                 showAlert(strMsg: "Channel is not available, Please try again later.")*/
            default:
                showAlert(strMsg: "\(self.sbdError_emoji)")
            }
            return
        }
        
        //print("channelName:",channelName_Emoji)
        guard let channel_emoji = self.channel_emoji else {
            showAlert(strMsg: "Channel is not available, Please try again later.")
            return
        }
        //print("channel_emoji name:",self.channel_emoji?.name ?? "");
        //self.sendUserMessageButton.isEnabled = false
        var preSendMessage: SBDUserMessage?
        preSendMessage = channel_emoji.sendUserMessage(strEmoji) { (userMessage, error) in
            if error != nil {
                DispatchQueue.main.async {
                    guard let preSendMsg = preSendMessage else { return }
                    guard let requestId = preSendMsg.requestId else { return }
                    
                    self.preSendMessage_emojis.removeValue(forKey: requestId)
                    self.resendableMessage_emojis[requestId] = preSendMsg
                    // self.tblComments.reloadData()
                }
                return
            }
            
            guard let message = userMessage else {
                return
                
            }
            guard let requestId = message.requestId else {
                return
                
            }
            
            DispatchQueue.main.async {
                self.determineScrollLock()
                
                if let preSendMessage = self.preSendMessage_emojis[requestId] {
                    if let index = self.emojis.firstIndex(of: preSendMessage) {
                        self.emojis[index] = message
                        self.preSendMessage_emojis.removeValue(forKey: requestId)
                        //  self.tblComments.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
                    }
                }
            }
        }
        
        DispatchQueue.main.async {
            self.determineScrollLock()
            if let preSendMsg = preSendMessage {
                if let requestId = preSendMsg.requestId {
                    self.preSendMessage_emojis[requestId] = preSendMsg
                    self.emojis.append(preSendMsg)
                    //                    self.tblComments.reloadData()
                    //                    self.scrollToBottom(force: false)
                }
            }
        }
    }
    // MARK: - Scroll
    func scrollToBottom(force: Bool) {
        if self.messages.count == 0 {
            return
        }
        
        if self.scrollLock && force == false {
            return
        }
        
        let currentRowNumber = self.tblComments.numberOfRows(inSection: 0)
        
        self.tblComments.scrollToRow(at: IndexPath(row: currentRowNumber - 1, section: 0), at: .bottom, animated: false)
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
    @IBAction func playStream(_ sender: Any){
        //print("playStream called")
        self.setLiveStreamConfig();
    }
    // MARK: - Emoji Delegates
    
    //  Converted to Swift 5.2 by Swiftify v5.2.28138 - https://swiftify.com/
    
    func emojiKeyBoardView(_ emojiKeyBoardView: AGEmojiKeyboardView?, didUseEmoji emoji: String?) {
        self.imgEmoji.isHidden = false;
        imgEmoji.image = emoji?.image()
        sendEmoji(strEmoji: emoji ?? "")
        animateEmoji()
        //txtEmoji?.text = "\(emoji ?? "")"
    }
    
    func emojiKeyBoardViewDidPressBackSpace(_ emojiKeyBoardView: AGEmojiKeyboardView?) {
    }
    
    func randomColor() -> UIColor? {
        return UIColor(
            red: CGFloat(drand48()),
            green: CGFloat(drand48()),
            blue: CGFloat(drand48()),
            alpha: CGFloat(drand48()))
    }
    
    func randomImage() -> UIImage? {
        let size = CGSize(width: 30, height: 10)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        
        let context = UIGraphicsGetCurrentContext()
        var fillColor = randomColor()
        if let cg = fillColor?.cgColor {
            context?.setFillColor(cg)
        }
        var rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        context?.fill(rect)
        
        fillColor = randomColor()
        if let cg = fillColor?.cgColor {
            context?.setFillColor(cg)
        }
        let xxx: CGFloat = 3
        rect = CGRect(x: xxx, y: xxx, width: size.width - 2 * xxx, height: size.height - 2 * xxx)
        context?.fill(rect)
        
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img
    }
    
    func emojiKeyboardView(_ emojiKeyboardView: AGEmojiKeyboardView?, imageForSelectedCategory category: AGEmojiKeyboardViewCategoryImage) -> UIImage? {
        let img = randomImage()
        img?.withRenderingMode(.alwaysOriginal)
        return img
    }
    
    func emojiKeyboardView(_ emojiKeyboardView: AGEmojiKeyboardView?, imageForNonSelectedCategory category: AGEmojiKeyboardViewCategoryImage) -> UIImage? {
        let img = randomImage()
        img?.withRenderingMode(.alwaysOriginal)
        return img
    }
    
    func backSpaceButtonImage(for emojiKeyboardView: AGEmojiKeyboardView?) -> UIImage? {
        let img = randomImage()
        img?.withRenderingMode(.alwaysOriginal)
        return img
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
}

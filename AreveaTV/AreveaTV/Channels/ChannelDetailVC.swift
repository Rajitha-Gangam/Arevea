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
import CoreLocation

class ChannelDetailVC: UIViewController,UICollectionViewDataSource,UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,CollectionViewCellDelegate,OpenChanannelChatDelegate,OpenChannelMessageTableViewCellDelegate,CLLocationManagerDelegate{
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
    var buttonNames = ["Comments", "Info", "Donate", "Share","Profile","Upcoming", "Videos", "Audios", "Followers"]
    
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
    var locationManager:CLLocationManager!
    var streamPaymentMode = ""
    // MARK: - View Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        registerNibs();
        addDoneButton()
        //print("detail item in channnel page:\(detailItem)")
        hideViews();
        viewComments.isHidden = false;
        viewLiveStream.isHidden = true;
        
        lblNoDataComments.text = "No results found"
        lblNoDataDonations.text = "No results found"
        lblNoDataUpcoming.text = "No results found"
        lblNoDataVideos.text = "No results found"
        lblNoDataAudios.text = "No results found"
        lblNoDataFollowers.text = "No results found"
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled(){
            locationManager.startUpdatingLocation()
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
        if(isLoaded == 0){
            isLoaded = 1;
            liveEvents();
            performerVideos();
            performerAudios();
            performerEvents();
            addVideo(strURL: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4");
        }
        
    }
    func addVideo(strURL : String){
        if let url = URL(string: strURL){
            videoPlayer = AVPlayer(url: url)
            let controller = AVPlayerViewController()
            controller.player = videoPlayer
            controller.view.frame = self.viewVOD.bounds
            self.viewVOD.addSubview(controller.view)
            self.addChild(controller)
        }
    }
    func playVideo(){
        videoPlayer.play()
    }
    func stopVideo(){
        videoPlayer.pause()
    }
    
    
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
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
            return aryAudios.count;
        }else if (tableView == tblUpcoming ){
            return aryUpcoming.count;
            
        }
        else if(tableView == tblVideos){
            return 1;
        }
        else if(tableView == tblDonations){
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
            return cell
            
        }else if (tableView == tblDonations){
            let cell = tableView.dequeueReusableCell(withIdentifier: "CharityCell") as! CharityCell
            cell.btnDonate.addTarget(self, action: #selector(payDonation(_:)), for: .touchUpInside)
            cell.btnDonate.tag = indexPath.row
            
            let charity = self.aryCharityInfo[indexPath.row] as? [String : Any];
            cell.lblCharityName.text = charity?["charity_name"] as? String ?? ""
            cell.lblCharityDesc.text = charity?["charity_description"] as? String ?? ""
            let strURL = charity?["charity_logo"]as? String ?? ""
            let urlCharity : NSURL = NSURL(string: strURL)!
            self.downloadImagePerformer(from: urlCharity as URL, imageView: cell.imgCharity)
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
                print ("invalid date");
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
            closeCurrentTest()
            let upcoming = self.aryUpcoming[indexPath.row] as? [String : Any];
            self.orgId = upcoming?["organization_id"]as? Int ?? 0
            self.performerId = upcoming?["performer_id"]as? Int ?? 0

            self.streamVideoCode = upcoming?["streamCode"] as? String ?? ""
            let streamVideoTitle = upcoming?["streamTitle"] as? String ?? ""
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
            self.setLiveStreamConfig();
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
        let upcoming = self.aryVideos[section] as? [String : Any];
        self.orgId = upcoming?["organization_id"]as? Int ?? 0
        self.performerId = upcoming?["performer_id"]as? Int ?? 0

        self.streamVideoCode = upcoming?["videoCode"] as? String ?? ""
        let streamVideoTitle = upcoming?["videoTitle"] as? String ?? ""
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
        self.streamId = upcoming?["videoId"] as? Int ?? 0

        let url = upcoming?["videoUrl"] as? String ?? ""
        addVideo(strURL: url);
        self.showVideo()
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
        let movementDistance:CGFloat = -130
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
        print("tag:",sender.tag)
        let storyboard = UIStoryboard(name: "Main", bundle: nil);
        let vc = storyboard.instantiateViewController(withIdentifier: "PaymentVC") as! PaymentVC
        vc.details = "donation"
        vc.orgId = self.orgId
        vc.performerId = self.performerId
        let charity = self.aryCharityInfo[sender.tag] as? [String:Any]
        vc.charityId = charity?["id"] as? Int ?? 0
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func payTip(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil);
        let vc = storyboard.instantiateViewController(withIdentifier: "PaymentVC") as! PaymentVC
        vc.details = "tip"
        vc.orgId = self.orgId
        vc.performerId = self.performerId
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func payPerView(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil);
        let vc = storyboard.instantiateViewController(withIdentifier: "PaymentVC") as! PaymentVC
        vc.details = "pay_per_view"
        vc.orgId = self.orgId
        vc.performerId = self.performerId
        vc.streamId = self.streamId
        UserDefaults.standard.set(self.paymentAmount, forKey: "plan_amount")
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func subscribe(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil);
        let vc = storyboard.instantiateViewController(withIdentifier: "SubscriptionPlanVC") as! SubscriptionPlanVC
        vc.comingfrom = "channel_details"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @objc func share(_ sender: Any) {
        let items = ["This app is my favorite"]
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(ac, animated: true)
    }
    @IBAction func goToStreamPage(_ sender: Any) {
        
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
    func downloadImagePerformer(from url: URL, imageView: UIImageView) {
        
        print("Download Started")
        getDataPerformer(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            DispatchQueue.main.async() { [weak self] in
                imageView.image = UIImage(data: data)
            }
        }
    }
    func videoThumbNail(from url: URL, btn: UIButton) {
        print("Download Started")
        getDataPerformer(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            DispatchQueue.main.async() { [weak self] in
                btn.setImage(UIImage(data: data), for: .normal)
            }
        }
    }
    
    // MARK: Handler for liveEvents API
    func liveEvents(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let url: String = appDelegate.baseURL +  "/liveEvents"
        print("liveEvents url:",url);
        let user_id = UserDefaults.standard.string(forKey: "user_id");
        let params: [String: Any] = ["userid":user_id ?? "","performer_id":performerId,"stream_id": "0"]

       // let params: [String: Any] = ["userid":77,"performer_id":44,"stream_id": "170"]
        print("liveEvents params:",params);
        
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        AF.request(url, method: .post,  parameters: params, encoding: JSONEncoding.default)
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any] {
                        //print("liveEvents json:",json);
                        
                        if (json["statusCode"]as? String == "200"){
                            print(json["message"] as? String ?? "")
                            self.activityIndicator.isHidden = true;
                            self.activityIndicator.stopAnimating();
                            let data = json["Data"] as? [String:Any]
                            let stream_info = data?["stream_info"] != nil
                            if(stream_info){
                                self.aryStreamInfo = data?["stream_info"] as? [Any] ?? [Any]()
                                if (self.aryStreamInfo.count > 0){
                                    let streamObj = self.aryStreamInfo[0] as? [String:Any]
                                    self.streamId = streamObj?["id"] as? Int ?? 0
                                    if (streamObj?["stream_vod"]as? String == "stream"){
                                        self.viewVOD.isHidden = true
                                        self.viewLiveStream.isHidden = false;
                                        self.setLiveStreamConfig();
                                    }else{
                                        self.viewVOD.isHidden = false
                                        self.viewLiveStream.isHidden = true;
                                        let url = streamObj?["video_url"] as? String ?? ""
                                        self.addVideo(strURL: url);
                                        self.showVideo()
                                    }
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
                                    if (self.streamPaymentMode == "paid"){
                                        self.btnPayPerView.isHidden = false
                                    }else{
                                        self.btnPayPerView.isHidden = true
                                    }
                                    
                                }
                            }else{
                                //if we get any error default, we are showing VOD
                                self.viewVOD.isHidden = false
                                self.playVideo()
                                self.viewLiveStream.isHidden = true;
                                self.lblVideoTitle.text = ""
                                self.lblVideoTitle_Info.text = ""
                                
                            }
                            let charities_info = data?["charities_info"] != nil
                            if(charities_info){
                                self.aryCharityInfo = data?["charities_info"] as? [Any] ?? [Any]()
                                if (self.aryCharityInfo.count > 0){
                                    self.lblNoDataDonations.isHidden = true
                                }else{
                                    self.lblNoDataDonations.isHidden = false
                                }
                            }
                            let performer_info = data?["performer_info"] != nil
                            if(performer_info){
                                self.dicPerformerInfo = data?["performer_info"] as? [String : Any] ?? [String:Any]()
                                let performerName = self.dicPerformerInfo["performer_display_name"] as? String
                                self.txtProfile.text = performerName
                                
                                let strURL = self.dicPerformerInfo["performer_profile_pic"]as? String ?? ""
                                let urlPerformer : NSURL = NSURL(string: strURL)!
                                
                                self.downloadImagePerformer(from: urlPerformer as URL, imageView: self.imgPerformer)
                                
                            }else{
                                self.txtProfile.text = ""
                            }
                            let user_subscription_info = data?["user_subscription_info"] != nil
                            if(user_subscription_info){
                                self.aryUserSubscriptionInfo = data?["user_subscription_info"] as? [Any] ?? [Any]()
                            }
                        }else{
                            let strError = json["message"] as? String
                            print("strError1:",strError ?? "")
                            self.showAlert(strMsg: strError ?? "")
                            self.activityIndicator.isHidden = true;
                            self.activityIndicator.stopAnimating();
                            
                            //if we get any error default, we are showing VOD
                            self.viewVOD.isHidden = false
                            self.playVideo()
                            self.viewLiveStream.isHidden = true;
                        }
                        
                    }
                case .failure(let error):
                    print(error)
                    self.activityIndicator.isHidden = true;
                    self.activityIndicator.stopAnimating();
                    self.showAlert(strMsg: error.localizedDescription)
                    
                    //if we get any error default, we are showing VOD
                    self.viewVOD.isHidden = false
                    self.playVideo()
                    self.viewLiveStream.isHidden = true;
                }
        }
    }
    
    // MARK: Handler for performerEvents API, using for upcoming schedules
    func performerEvents(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let url: String = appDelegate.baseURL +  "/performerEvents"
        print("performerEvents url:",url);
        
        let params: [String: Any] = ["performerId": performerId,"orgId": orgId]
        print("performerEvents params:",params);
        
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        AF.request(url, method: .post,  parameters: params, encoding: JSONEncoding.prettyPrinted)
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any] {
                        //print("performerEvents json:",json);
                        if (json["statusCode"]as? String == "200"){
                            print(json["message"] as? String ?? "")
                            self.aryUpcoming = json["Data"] as? [Any] ?? [Any]() ;
                            print("upcoming count:",self.aryUpcoming.count);
                            self.tblUpcoming.reloadData();
                            self.activityIndicator.isHidden = true;
                            self.activityIndicator.stopAnimating();
                        }else{
                            let strError = json["message"] as? String
                            print("strError2:",strError ?? "")
                            self.showAlert(strMsg: strError ?? "")
                            self.activityIndicator.isHidden = true;
                            self.activityIndicator.stopAnimating();
                        }
                    }
                case .failure(let error):
                    print(error)
                    self.activityIndicator.isHidden = true;
                    self.activityIndicator.stopAnimating();
                    self.showAlert(strMsg: error.localizedDescription)
                }
                if (self.aryUpcoming.count > 0){
                    self.lblNoDataUpcoming.isHidden = true
                }else{
                    self.lblNoDataUpcoming.isHidden = false
                }
        }
    }
    // MARK: Handler for performerVideos API,using for videos list in bottom
    func performerVideos(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let url: String = appDelegate.baseURL +  "/performerVideos"
        print("performerVideos url:",url);
         let params: [String: Any] = ["performerId":performerId,"orgId": orgId,"type": "video"]

        //let params: [String: Any] = ["performerId":44,"orgId": 28,"type": "video"]
        print("performerVideos params:",params);
        
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        AF.request(url, method: .post,  parameters: params, encoding: JSONEncoding.default)
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any] {
                        // print("performerVideos json:",json);
                        if (json["statusCode"]as? String == "200"){
                            print(json["message"] as? String ?? "")
                            self.aryVideos = json["Data"] as? [Any] ?? [Any]() ;
                            print("videos count:",self.aryVideos.count)
                            self.tblVideos.reloadData();
                            self.activityIndicator.isHidden = true;
                            self.activityIndicator.stopAnimating();
                        }else{
                            let strError = json["message"] as? String
                            print("strError:",strError ?? "")
                            self.showAlert(strMsg: strError ?? "")
                            self.activityIndicator.isHidden = true;
                            self.activityIndicator.stopAnimating();
                        }
                        if (self.aryVideos.count > 0){
                            self.lblNoDataVideos.isHidden = true
                        }else{
                            self.lblNoDataVideos.isHidden = false
                        }
                        
                    }
                case .failure(let error):
                    print(error)
                    self.activityIndicator.isHidden = true;
                    self.activityIndicator.stopAnimating();
                    self.showAlert(strMsg: error.localizedDescription)
                }
        }
    }
    // MARK: Handler for performerVideos API,using for audios list in bottom
    func performerAudios(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let url: String = appDelegate.baseURL +  "/performerVideos"
        print("performerAudios url:",url);
        let params: [String: Any] = ["performerId": performerId,"orgId": orgId,"type": "audio"]
        
        //let params: [String: Any] = ["performerId":"12","orgId": "1","type": "audio" ]
        print("performerAudios params:",params);
        
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        AF.request(url, method: .post,  parameters: params, encoding: JSONEncoding.default)
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any] {
                        //print("performerAudios json:",json);
                        if (json["statusCode"]as? String == "200"){
                            print(json["message"] as? String ?? "")
                            self.aryAudios = json["Data"] as? [Any] ?? [Any]() ;
                            print("videos count:",self.aryVideos.count)
                            self.tblAudios.reloadData();
                            self.activityIndicator.isHidden = true;
                            self.activityIndicator.stopAnimating();
                        }else{
                            let strError = json["message"] as? String
                            print("strError:",strError ?? "")
                            self.showAlert(strMsg: strError ?? "")
                            self.activityIndicator.isHidden = true;
                            self.activityIndicator.stopAnimating();
                        }
                        if (self.aryAudios.count > 0){
                            self.lblNoDataAudios.isHidden = true
                        }else{
                            self.lblNoDataAudios.isHidden = false
                        }
                        
                    }
                case .failure(let error):
                    print(error)
                    self.activityIndicator.isHidden = true;
                    self.activityIndicator.stopAnimating();
                    self.showAlert(strMsg: error.localizedDescription)
                }
        }
    }
    // MARK: - Stream Methods
    
    func setLiveStreamConfig(){
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
    @IBAction func showVideo(){
        viewLiveStream.isHidden = true;
        
        viewVOD.isHidden = false;
        playVideo()
    }
    @IBAction func showStream(){
        viewVOD.isHidden = true;
        stopVideo()
        
        viewLiveStream.isHidden = false;
    }
    override func viewWillDisappear(_ animated: Bool) {
        closeCurrentTest()
        self.navigationController?.isNavigationBarHidden = true
    }
    func closeCurrentTest(){
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
        guard let messageText = self.inputMessageTextField.text else { return }
        guard let channel = self.channel else { return }
        
        self.inputMessageTextField.text = ""
        //self.sendUserMessageButton.isEnabled = false
        
        if messageText.count == 0 {
            return
        }
        
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
    //MARK: - location delegate methods
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation :CLLocation = locations[0] as CLLocation
        
        print("user latitude = \(userLocation.coordinate.latitude)")
        print("user longitude = \(userLocation.coordinate.longitude)")
        
        print("lat:\(userLocation.coordinate.latitude)")
        print("lng:\(userLocation.coordinate.longitude)")
        
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(userLocation) { (placemarks, error) in
            if (error != nil){
                print("error in reverseGeocode")
            }
            let placemark = placemarks! as [CLPlacemark]
            if placemark.count>0{
                let placemark = placemarks![0]
                print("locality:",placemark.locality!)
                print("administrativeArea:",placemark.administrativeArea!)
                print("country:",placemark.country!)
            }
        }
        
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error \(error)")
    }
    
}

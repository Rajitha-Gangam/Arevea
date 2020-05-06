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

class ChannelDetailVC: UIViewController,UICollectionViewDataSource,UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,CollectionViewCellDelegate{
    // MARK: - Variables Declaration
    
    @IBOutlet weak var scrollButtons: UIScrollView!
    @IBOutlet weak var buttonCVC: UICollectionView!
    @IBOutlet weak var viewVOD: UIView!
    
    @IBOutlet weak var viewBottom: UIView!
    @IBOutlet weak var txtComments: UITextField!
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
    
    var r5ViewController : BaseTest? = nil
    @IBOutlet weak var viewLiveStream: UIView!
    var dicPerformerInfo = [String: Any]()
    var aryCharityInfo = [Any]()
    var aryStreamInfo = [Any]()
    var aryUserSubscriptionInfo = [Any]()
    var orgId = 0;
    var performerId = 0;
    var aryVideos = [Any]();
    var aryUpcoming = [Any]();
    var audioList: [String] = []
    var videoPlayer = AVPlayer()
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
    // MARK: - View Life Cycle
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        registerNibs();
        addDoneButton()
        //print("detail item in channnel page:\(detailItem)")
        hideViews();
        viewComments.isHidden = false;
        viewLiveStream.isHidden = true;
        
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
        
        tblComments.register(UINib(nibName: "CommentsCell", bundle: nil), forCellReuseIdentifier: "CommentsCell");
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
            addVideo();
        }
        
    }
    func addVideo(){
        if let url = URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"){
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
    func startPlayer() {
        let url = URL(string: "https://s3.amazonaws.com/kargopolov/kukushka.mp3")
        let playerItem:AVPlayerItem = AVPlayerItem(url: url!)
        player = AVPlayer(playerItem: playerItem)
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
        if player?.rate == 0 {
            player?.play()
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
            return 5;
        }else if (tableView == tblUpcoming ){
            return aryUpcoming.count;
            
        }
        else if(tableView == tblVideos || tableView == tblUpcoming){
            return 1;
        }
        else if(tableView == tblDonations){
            return 3;
        }
        return aryComments.count;
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
        return 44;
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (tableView == tblComments){
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentsCell", for: indexPath) as! CommentsCell
            let selectedItem = aryComments[indexPath.row]
            cell.lblName.text = selectedItem["name"];
            cell.lblDesc.text = selectedItem["desc"];
            return cell
        }else if (tableView == tblVideos){
            let cell = tableView.dequeueReusableCell(withIdentifier: "VideoCell") as! VideoCell
            return cell
            
        }else if (tableView == tblDonations){
            let cell = tableView.dequeueReusableCell(withIdentifier: "CharityCell") as! CharityCell
            cell.btnDonate.addTarget(self, action: #selector(payDonation(_:)), for: .touchUpInside)
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
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AudioCell") as! AudioCell
            let url = URL(string: "https://s3.amazonaws.com/kargopolov/kukushka.mp3")
            let playerItem:AVPlayerItem = AVPlayerItem(url: url!)
            player = AVPlayer(playerItem: playerItem)
            cell.audioSlider.minimumValue = 0
            let duration : CMTime = playerItem.asset.duration
            let seconds : Float64 = CMTimeGetSeconds(duration)
            cell.audioSlider.maximumValue = Float(seconds)
            cell.audioSlider.isContinuous = false
            cell.audioSlider.addTarget(self, action: #selector(sliderChanged(sender:)), for: .valueChanged)
            cell.btnPlayOrPause.addTarget(self, action: #selector(playPauseTapped(sender:)), for: .touchUpInside)
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //           let storyboard = UIStoryboard(name: "Main", bundle: nil);
        //           let vc = storyboard.instantiateViewController(withIdentifier: "ChannelDetailVC") as! ChannelDetailVC
        //           self.navigationController?.pushViewController(vc, animated: true)
        
    }
    func collectionView(collectionviewcell: DBCollectionViewCell?, index: Int, didTappedInTableViewCell: DashBoardCell) {
        
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent // .default
    }
    // MARK: Comments Methods
    
    @objc func resignKB(_ sender: Any) {
        txtComments.resignFirstResponder();
    }
    func addDoneButton() {
        let toolbar =  UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 35))
        
        let flexButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action:#selector(resignKB(_:)))
        toolbar.setItems([flexButton, doneButton], animated: true)
        toolbar.sizeToFit()
        txtComments.inputAccessoryView = toolbar;
    }
    @IBAction func sendComments(_ sender: Any) {
        txtComments.resignFirstResponder();
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
    
    @objc func payDonation(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil);
        let vc = storyboard.instantiateViewController(withIdentifier: "PaymentVC") as! PaymentVC
        vc.isTip = true;
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func payTip(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil);
        let vc = storyboard.instantiateViewController(withIdentifier: "PaymentVC") as! PaymentVC
        vc.isTip = true;
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
        let storyboard = UIStoryboard(name: "Main", bundle: nil);
        let vc = storyboard.instantiateViewController(withIdentifier: "StreamDetailVC") as! StreamDetailVC
        //it is very imp to get subscribe stream
        let object = Testbed.testAtIndex(index: 0)
        vc.detailItem = object
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func showAlert(strMsg: String){
        let alert = UIAlertController(title: "Alert", message: strMsg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
    // MARK: Handler for liveEvents API
    func liveEvents(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let url: String = appDelegate.baseURL +  "/liveEvents"
        print("liveEvents url:",url);
        let user_id = UserDefaults.standard.string(forKey: "user_id");
        let params: [String: Any] = ["userid":user_id ?? "","performer_id":performerId,"stream_id": "1"]
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
                                self.aryStreamInfo = data?["stream_info"] as! [Any]
                                if (self.aryStreamInfo.count > 0){
                                    let streamObj = self.aryStreamInfo[0] as? [String:Any]
                                    if (streamObj?["stream_vod"]as? String == "stream"){
                                        self.viewVOD.isHidden = true
                                        self.viewLiveStream.isHidden = false;
                                        self.setLiveStreamConfig();
                                    }else{
                                        self.viewVOD.isHidden = false
                                        self.playVideo()
                                        self.viewLiveStream.isHidden = true;
                                    }
                                }
                            }else{
                                //if we get any error default, we are showing VOD
                                self.viewVOD.isHidden = false
                                self.playVideo()
                                self.viewLiveStream.isHidden = true;
                            }
                            let charities_info = data?["charities_info"] != nil
                            if(charities_info){
                                self.aryCharityInfo = data?["charities_info"] as! [Any]
                            }
                            let performer_info = data?["performer_info"] != nil
                            if(performer_info){
                                self.dicPerformerInfo = data?["performer_info"] as! [String : Any]
                            }
                            let user_subscription_info = data?["user_subscription_info"] != nil
                            if(user_subscription_info){
                                self.aryUserSubscriptionInfo = data?["user_subscription_info"] as! [Any]
                                self.txtProfile.text = self.dicPerformerInfo["performer_display_name"] as? String
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
        }
    }
    // MARK: Handler for performerVideos API,using for videos list in bottom
    func performerVideos(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let url: String = appDelegate.baseURL +  "/performerVideos"
        print("performerVideos url:",url);
        
        let params: [String: Any] = ["performerId":performerId,"orgId": orgId,"type": "video"]
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
        
        let params: [String: Any] = ["performerId":performerId,"orgId": orgId,"type": "audio" ]
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
        Testbed.setLicenseKey(value:"YI8J-RDXS-DMLH-H5DZ")
        Testbed.setStream1Name(name: "stream1")
        Testbed.setStream2Name(name: "stream2")
        Testbed.setHost(ip: "vimal.cloudext.co");
        Testbed.setServerPort(port: "8,554")
        Testbed.setDebug(on: true)
        Testbed.setVideo(on: true)
        Testbed.setAudio(on: true)
        Testbed.setHWAccel(on: true)
        Testbed.setRecord(on: true)
        Testbed.setRecordAppend(on: true)
        self.configureStreamView()
    }
    func configureStreamView() {
        // Update the user interface for the detail item.
        // Access the static shared interface to ensure it's loaded
        _ = Testbed.sharedInstance
        self.detailStreamItem = Testbed.testAtIndex(index: 0)
        if(self.detailStreamItem != nil){
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
}

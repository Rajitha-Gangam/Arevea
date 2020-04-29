//
//  ChannelDetailVC.swift
//  AreveaTV
//
//  Created by apple on 4/25/20.
//  Copyright © 2020 apple. All rights reserved.
//

import UIKit
import AVFoundation

class ChannelDetailVC: UIViewController,UICollectionViewDataSource,UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,CollectionViewCellDelegate{
    @IBOutlet weak var scrollButtons: UIScrollView!
    @IBOutlet weak var buttonCVC: UICollectionView!
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

    var audioList: [String] = []
    var buttonNames = ["Comments", "Info", "Tip", "Share","Profile","Upcoming", "Videos", "Audios", "Followers"]
    
    var aryComments = [["name":"Cameron","desc":"Lorem Ipsum is simply dummy text of the printing and typesetting industry"],["name":"Daisy Austin","desc":"Lorem Ipsum is simply dummy text of the printing and typesetting industry"],["name":"Cameron","desc":"Lorem Ipsum is simply dummy text of the printing and typesetting industry"],["name":"Daisy Austin","desc":"Lorem Ipsum is simply dummy text of the printing and typesetting industry"],["name":"Cameron","desc":"Lorem Ipsum is simply dummy text of the printing and typesetting industry"],["name":"Daisy Austin","desc":"Lorem Ipsum is simply dummy text of the printing and typesetting industry"]]
    
    var detailItem = [String:Any]();
    var playerItem:AVPlayerItem?
    var player:AVPlayer?
    var slider: UISlider?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        registerCVNib();
        tblComments.register(UINib(nibName: "CommentsCell", bundle: nil), forCellReuseIdentifier: "CommentsCell");
        tblAudios.register(UINib(nibName: "AudioCell", bundle: nil), forCellReuseIdentifier: "AudioCell");
        tblVideos.register(UINib(nibName: "VideoCell", bundle: nil), forCellReuseIdentifier: "VideoCell")
        tblUpcoming.register(UINib(nibName: "UpcomingCell", bundle: nil), forCellReuseIdentifier: "UpcomingCell")
        tblFollowers.register(UINib(nibName: "DashBoardCell", bundle: nil), forCellReuseIdentifier: "DashBoardCell")

        
        addDoneButton()
        //print("detail item in channnel page:\(detailItem)")
        hideViews();
        viewComments.isHidden = false;
    }
    func registerCVNib() {
        let nib = UINib(nibName: "ButtonsCVC", bundle: nil)
        buttonCVC?.register(nib, forCellWithReuseIdentifier:"ButtonsCVC")
        if let flowLayout = self.buttonCVC?.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.estimatedItemSize = CGSize(width: 1, height: 1)
        }
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
    }
    @IBAction func btnPress(_ sender: UIButton) {
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
        case "Tip":
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
            sender.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        } else {
            player!.pause()
            sender.setImage(UIImage(systemName: "play.fill"), for: .normal)
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
            return 5
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
        label.textColor = UIColor.white
        label.text = "Throwing DJ Parties";
        view.addSubview(label)
        let button = UIButton(frame: CGRect(x: 100, y: 100, width: 100, height: 50))
        button.backgroundColor = .clear
        button.setTitle("", for: .normal)
        button.setImage(UIImage(named: ""), for: .normal)
        self.view.addSubview(button)
        return view
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tableView == tblAudios || tableView == tblUpcoming || tableView == tblFollowers)
        {
            return 5;
        }
        else if(tableView == tblVideos){
            return 1;
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
            
        }else if (tableView == tblUpcoming){
            let cell = tableView.dequeueReusableCell(withIdentifier: "UpcomingCell") as! UpcomingCell
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
    
    @IBAction func resignKB(_ sender: Any) {
        txtComments.resignFirstResponder();
    }
    func addDoneButton() {
        let toolbar = UIToolbar()
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
        let movementDistance:CGFloat = -300
        let movementDuration: Double = 0.3
        
        var movement:CGFloat = 0
        if up
        {
            movement = movementDistance
        }
        else
        {
            movement = -movementDistance
        }
        UIView.beginAnimations("animateTextField", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration)
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
        UIView.commitAnimations()
    }
    
    // MARK: Tip Methods
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
    @IBAction func share(_ sender: Any) {
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
}

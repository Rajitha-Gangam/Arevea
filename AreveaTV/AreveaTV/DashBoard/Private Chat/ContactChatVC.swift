//
//  ContactChatVC.swift
//  AreveaTV
//
//  Created by apple on 1/26/21.
//  Copyright © 2021 apple. All rights reserved.
//

import UIKit
import SendBirdSDK

class ContactChatVC: UIViewController , UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate,OpenChanannelChatDelegate,OpenChannelMessageTableViewCellDelegate{
    // MARK: - variables declaration
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    @IBOutlet weak var viewActivity: UIView!
    @IBOutlet weak var heightTopView: NSLayoutConstraint?
    @IBOutlet weak var viewTop: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var lblNoData: UILabel!
    @IBOutlet weak var tblComments: UITableView!
    var channelName = ""
    var sendBirdErrorCode = 0;
    @IBOutlet weak var lblNoDataComments: UILabel!
    var messages: [SBDBaseMessage] = []
    var channel: SBDGroupChannel?
    var isChannelAvailable = false;
    @IBOutlet weak var txtComment: UITextField!
    @IBOutlet weak var sendUserMessageButton: UIButton!
    var isLoading: Bool = false
    var hasPrevious: Bool?
    var minMessageTimestamp: Int64 = Int64.max
    var initialLoading: Bool = true
    var scrollLock: Bool = false
    var txtTopOfToolBarChat : UITextField!
    var resendableMessages: [String:SBDBaseMessage] = [:]
    var preSendMessages: [String:SBDBaseMessage] = [:]
    var contactId = ""
    var contactName = ""
    var contactObj = [String:Any]()
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var userName: UIButton!

    // MARK: - View Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        lblNoDataComments.text = ""
        addDoneButton()
        tblComments.register(UINib(nibName: "PvtChatCell", bundle: nil), forCellReuseIdentifier: "PvtChatCell")

        tblComments.rowHeight = 40
        tblComments.estimatedRowHeight = UITableView.automaticDimension
        self.isChannelAvailable = true
        print("==contactObj:",contactObj)
        let fullName = contactObj["name"] as? String ?? ""
        contactId = contactObj["contactid"] as? String ?? ""
        lblTitle.text = fullName

        var firstChar = ""
        if fullName.count == 0 {
            lblTitle.text = "Anonymous"
            firstChar = "A"
        }
        else {
            let fullNameArr = fullName.components(separatedBy: " ")
            let firstName: String = fullNameArr[0]
            var lastName = ""
            if (fullNameArr.count > 1){
                lastName = fullNameArr[1]
            }
            if (lastName == ""){
                firstChar = String(firstName.first!)
            }else{
                firstChar = String(firstName.first!) + String(lastName.first!)
            }
        }
        userName.setTitle(firstChar, for: .normal)
        
        print("===2contactId:",contactId)
        
        createChannel()
    }
    func addDoneButton() {
        let toolbar =  UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 35))
        toolbar.backgroundColor = .white
        txtTopOfToolBarChat =  UITextField(frame: CGRect(x: 50, y: 0, width: view.frame.size.width-150, height: 35))
        // let textfield =  UITextField()
        txtTopOfToolBarChat.placeholder = "Send a message"
        txtTopOfToolBarChat.delegate = self
        txtTopOfToolBarChat.backgroundColor = .clear
        //txtTopOfToolBarChat.isUserInteractionEnabled = false
        txtTopOfToolBarChat.borderStyle = UITextField.BorderStyle.none
        
        let textfieldBarButton = UIBarButtonItem.init(customView: txtTopOfToolBarChat)
        
        // UIToolbar expects an array of UIBarButtonItems:
        
        let flexButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        
        let cancel = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action:#selector(resignKB(_:)))
        
        let button = UIButton.init(type: .custom)
        //set image for button
        button.setImage(UIImage(named: "blue-send"), for: UIControl.State.normal)
        //add function for button
        button.addTarget(self, action: #selector(sendChatMessage), for: UIControl.Event.touchUpInside)
        //set frame
        button.frame = CGRect(x: view.frame.size.width-180, y: 0, width: 20, height: 20)
        let sendBtn = UIBarButtonItem(customView: button)
        toolbar.setItems([cancel,textfieldBarButton,flexButton,sendBtn], animated: true)
        toolbar.sizeToFit()
        txtComment.inputAccessoryView = toolbar;
        txtTopOfToolBarChat.inputAccessoryView = toolbar;
        
    }
    @objc func resignKB(_ sender: Any) {
        txtTopOfToolBarChat.text = ""
        txtComment.text = ""
        txtComment.resignFirstResponder();
        txtTopOfToolBarChat.resignFirstResponder()
    }
    func showAlert(strMsg: String){
        let alert = UIAlertController(title: "Alert", message: strMsg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
    @IBAction func back(_ sender: Any) {
        if(appDelegate.isPvtChatFromLeftMenu){
            self.navigationController?.popViewController(animated: true);

        }else{
            self.dismiss(animated: true, completion: nil)
        }
    }
    // MARK: Text Field Delegate Methods
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
       
        
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("textFieldDidEndEditing")
        //textField.resignFirstResponder();
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("textFieldShouldReturn")
        
        textField.resignFirstResponder();
        if (textField == txtComment || txtTopOfToolBarChat == textField){
            sendChatMessage()
        }
        return true;
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let textFieldText: NSString = (textField.text ?? "") as NSString
        let txtAfterUpdate = textFieldText.replacingCharacters(in: range, with: string)
        txtTopOfToolBarChat.text = txtAfterUpdate
        return true
    }
    func createChannel(){
        let USER_IDS = [contactId]
        SBDGroupChannel.createChannel(withUserIds: USER_IDS, isDistinct: true, completionHandler: { (groupChannel, error) in
            guard error == nil else {
                // Handle error.
                let errorDesc = "Create Channel Error:" + error!.localizedDescription
                print(errorDesc)
                return
            }

            // A group channel of the specified users is successfully created.
            // Through the "groupChannel" parameter of the callback method,
            // you can get the group channel's data from the result object that Sendbird server has passed to the callback method.
            let channelUrl = groupChannel?.channelUrl
            print("channelUrl:",channelUrl)
            self.channelName = channelUrl ?? ""

           self.sendBirdChatConfig()
            /*SBDGroupChannel.getWithUrl((self.channelName), completionHandler: { (groupChannel, error) in
                guard error == nil else {
                    // Handle error.
                    return
                }

                // Through the "groupChannel" parameter of the callback method,
                // the group channel object identified with the CHANNEL_URL is returned by Sendbird server,
                // and you can get the group channel's data from the result object.
                let channelName = groupChannel?.name
            })*/
        })
    }
    //MARK:Tableview Delegates and Datasource Methods
    
    func numberOfSections(in tableView: UITableView) ->  Int {
            return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(tableView == tblComments){
            if (isChannelAvailable && self.messages.count > 0){
                tblComments.isHidden = false
                lblNoDataComments.text = ""
            }else{
                tblComments.isHidden = true
                //lblNoDataComments.text = "Channel is unavailable"
                
            }
            return self.messages.count;
        }
        return 0;

    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) ->  CGFloat {
        if  (tableView == tblComments){
            return UITableView.automaticDimension
        }
        return 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell = UITableViewCell()

        if (tableView == tblComments){
            
            if self.messages[indexPath.row] is SBDAdminMessage {
                if let adminMessage = self.messages[indexPath.row] as? SBDAdminMessage,
                   let adminMessageCell = tableView.dequeueReusableCell(withIdentifier: "PvtChatCell") as? PvtChatCell {
                    adminMessageCell.setMessage(adminMessage)
                    adminMessageCell.delegate = self
                    //adminMessageCell.profileImageView
                    if indexPath.row > 0 {
                        //adminMessageCell.setPreviousMessage(self.messages[indexPath.row - 1])
                    }
                    cell = adminMessageCell
                }
            }
            else if self.messages[indexPath.row] is SBDUserMessage {
                let userMessage = self.messages[indexPath.row] as! SBDUserMessage
                if let userMessageCell = tableView.dequeueReusableCell(withIdentifier: "PvtChatCell") as? PvtChatCell,
                   let sender = userMessage.sender {
                    userMessageCell.setMessage(userMessage)
                    userMessageCell.delegate = self
                    
                    if sender.userId == SBDMain.getCurrentUser()?.userId {
                        // Outgoing message
                        let requestId = userMessage.requestId
                        if self.resendableMessages[requestId] != nil {
                            userMessageCell.showElementsForFailure()
                        }
                        else {
                            userMessageCell.hideElementsForFailure()
                        }
                    }
                    else {
                        // Incoming message
                        userMessageCell.hideElementsForFailure()
                    }
                    //userMessageCell.profileImageView
                    DispatchQueue.main.async {
                        guard let updateCell = tableView.cellForRow(at: indexPath) else { return }
                        guard updateCell is PvtChatCell else { return }
                        
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
        return cell

    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }

    @IBAction func sendChatMessage() {
        txtComment.resignFirstResponder()
        txtTopOfToolBarChat.resignFirstResponder()
        let messageText = txtComment.text!.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        if (messageText.count == 0){
            showAlert(strMsg: "Please enter message")
            return
        }
        self.txtComment.text = ""
        self.txtTopOfToolBarChat.text = ""
        
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
            case 400201:
                showAlert(strMsg: "Channel is not available, Please try again later.")
            default:
                showAlert(strMsg: "Channel is not available, Please try again later.")
            //              showAlert(strMsg: "\(self.sbdError)")
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
                    let requestId = preSendMsg.requestId
                    
                    self.preSendMessages.removeValue(forKey: requestId)
                    self.resendableMessages[requestId] = preSendMsg
                    self.tblComments.reloadData()
                    self.scrollToBottom(force: true)
                    
                }
                return
            }
            
            guard let message = userMessage else { return }
            let requestId = message.requestId
            
            DispatchQueue.main.async {
                self.determineScrollLock()
                
                if let preSendMessage = self.preSendMessages[requestId] {
                    if let index = self.messages.firstIndex(of: preSendMessage) {
                        self.messages[index] = message
                        self.preSendMessages.removeValue(forKey: requestId)
                        self.tblComments.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
                        self.scrollToBottom(force: true)
                    }
                }
            }
        }
        
        DispatchQueue.main.async {
            self.determineScrollLock()
            if let preSendMsg = preSendMessage {
                let requestId = preSendMsg.requestId
                self.preSendMessages[requestId] = preSendMsg
                self.messages.append(preSendMsg)
                self.tblComments.reloadData()
                self.scrollToBottom(force: true)
                
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    // MARK: - Send Bird methods

    func sendBirdChatConfig(){
        ////print("channelName in sendBirdChatConfig:",channelName)
        SBDGroupChannel.getWithUrl((self.channelName), completionHandler: { (groupChannel, error) in
            guard error == nil else {   // Error.
                let errorDesc = "Chat Error:" + error!.localizedDescription
                print("Send Bird Error:\(String(describing: error))")
                //print(errorDesc)
                //self.sbdError = error ?? error?.localizedDescription as! SBDError
                self.sendBirdErrorCode = error?.code ?? 0
                //self.showAlert(strMsg:errorDesc )
                ////print("sendBirdErrorCode:",sendBirdErrorCode)
                switch self.sendBirdErrorCode {
                case 403100:
                    self.lblNoDataComments.text = "Application id disabled/expired, Please contact admin."
                case 400300:
                    self.lblNoDataComments.text = "Deactivated user not accessible, Please contact admin."
                case 400301:
                    self.lblNoDataComments.text = "User not found, Please contact admin."
                case 400304:
                    self.lblNoDataComments.text = "Application id not found, Please contact admin."
                case 400306:
                    self.lblNoDataComments.text = "Paid quota exceeded, Please contact admin."
                case 400700:
                    self.lblNoDataComments.text = "Blocked user send not allowed, Please contact admin."
                case 500910:
                    self.lblNoDataComments.text = "Rate limit exceeded, Please contact admin."
                case 400201:
                    self.lblNoDataComments.text = "Channel is not available, Please try again later."
                default:
                    self.lblNoDataComments.text = "Channel is not available, Please try again later."
                //              showAlert(strMsg: "\(self.sbdError)")
                }
                // return
                self.messages.removeAll()
                self.channel = nil
                self.isChannelAvailable = false
                self.tblComments.reloadData()
                return
            }
            print("no error")
            self.channel = groupChannel
            self.title = self.channel?.name
            self.loadPreviousMessages(initial: true)
//            openChannel?.enter(completionHandler: { (error) in
//                guard error == nil else {   // Error.
//                    return
//                }
//            })
            
        })
        channel?.getMyMutedInfo(completionHandler: { (isMuted, description, startAt, endAt, duration, error) in
            if isMuted {
                //self.sendUserMessageButton.isEnabled = false
                //self.txtComment.isEnabled = false
                self.txtComment.placeholder = "You are muted"
            } else {
                self.sendUserMessageButton.isEnabled = true
                self.txtComment.isEnabled = true
                self.txtComment.placeholder = "Send a message"
            }
        })
    }
    func loadPreviousMessages(initial: Bool) {
        guard let channel = self.channel else { return }
        
        /* if self.isLoading {
         return
         }*/
        
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
            print("msgs:",msgs)
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
        //print("msgs:",self.messages)
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
}

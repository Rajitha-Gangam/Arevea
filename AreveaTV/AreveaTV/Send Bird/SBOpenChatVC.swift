//
//  SBOpenChatVC.swift
//  AreveaTV
//
//  Created by apple on 5/8/20.
//  Copyright © 2020 apple. All rights reserved.
//

import UIKit
import SendBirdSDK

class SBOpenChatVC: UIViewController,UITableViewDelegate,UITableViewDataSource,OpenChanannelChatDelegate {
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
    @IBOutlet weak var toastView: UIView!
    @IBOutlet weak var toastMessageLabel: UILabel!
    
    @IBOutlet weak var messageTableView: UITableView!
    @IBOutlet weak var loadingIndicatorView: UIActivityIndicatorView!
    let coverImageData: Data? = nil
    weak var delegate: OpenChanannelChatDelegate?
    var channelName = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // Do any additional setup after loading the view.
        //SBDMain.add(self as SBDChannelDelegate, identifier: self.description)
        
        
        
        
        //self.channel = channel!.name("1588782608325_chat_event_3")
//        if let channel = self.channel {
//            self.title = channel.name
//            print("channel.name:",channel.name);
//        }
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
        
        
        if let navigationController = self.navigationController {
            navigationController.isNavigationBarHidden = false
        }
        
        self.messageTableView.rowHeight = UITableView.automaticDimension
        self.messageTableView.estimatedRowHeight = 140
        self.messageTableView.delegate = self
        self.messageTableView.dataSource = self
        self.messageTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 14, right: 0)
        
        self.messageTableView.register(OpenChannelUserMessageTableViewCell.nib(), forCellReuseIdentifier: "OpenChannelUserMessageTableViewCell")
        
        
        // Input Text Field
        let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 0))
        let rightPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 0))
        self.inputMessageTextField.leftView = leftPaddingView
        self.inputMessageTextField.rightView = rightPaddingView
        self.inputMessageTextField.leftViewMode = .always
        self.inputMessageTextField.rightViewMode = .always
        self.inputMessageTextField.addTarget(self, action: #selector(self.inputMessageTextFieldChanged(_:)), for: .editingChanged)
       // self.sendUserMessageButton.isEnabled = false
        
        let messageViewTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard(recognizer:)))
        self.messageTableView.addGestureRecognizer(messageViewTapGestureRecognizer)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIWindow.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIWindow.keyboardWillHideNotification, object: nil)
        
        //self.view.bringSubviewToFront(self.loadingIndicatorView)
        //self.loadingIndicatorView.isHidden = true
        
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
                        
                        self.messageTableView.reloadData()
                        self.messageTableView.layoutIfNeeded()
                        
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
                        
                        self.messageTableView.reloadData()
                        self.messageTableView.layoutIfNeeded()
                        
                        self.messageTableView.scrollToRow(at: IndexPath(row: messages.count-1, section: 0), at: .top, animated: false)
                        self.isLoading = false
                    }
                }
            }
        })
    }
    @objc func inputMessageTextFieldChanged(_ sender: AnyObject) {
        if sender is UITextField {
            let textField = sender as! UITextField
            guard let text = textField.text else { return }
            if text.count > 0 {
                self.sendUserMessageButton.isEnabled = true
            }
            else {
                //self.sendUserMessageButton.isEnabled = false
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
        
        let currentRowNumber = self.messageTableView.numberOfRows(inSection: 0)
        
        self.messageTableView.scrollToRow(at: IndexPath(row: currentRowNumber - 1, section: 0), at: .bottom, animated: false)
    }
    
    func scrollToPosition(_ position: Int) {
        if self.messages.count == 0 {
            return
        }
        
        self.messageTableView.scrollToRow(at: IndexPath(row: position, section: 0), at: .top, animated: false)
    }
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell = UITableViewCell()
        
        if self.messages[indexPath.row] is SBDAdminMessage {
            if let adminMessage = self.messages[indexPath.row] as? SBDAdminMessage,
                let adminMessageCell = tableView.dequeueReusableCell(withIdentifier: "OpenChannelUserMessageTableViewCell") as? OpenChannelUserMessageTableViewCell {
                adminMessageCell.setMessage(adminMessage)
                adminMessageCell.delegate = self as! OpenChannelMessageTableViewCellDelegate
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
               // userMessageCell.delegate = self as! OpenChannelMessageTableViewCellDelegate
                
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
                    guard let updateUserMessageCell = updateCell as? OpenChannelUserMessageTableViewCell else { return }
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) ->  CGFloat {
        
        return 44;
        
    }
    
    // MARK: - UITableViewDelegate
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.stopMeasuringVelocity = false
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.messageTableView {
            if self.stopMeasuringVelocity == false {
                let currentOffset = scrollView.contentOffset
                let currentTime = Date.timeIntervalSinceReferenceDate
                let timeDiff = currentTime - self.lastOffsetCapture
                if timeDiff > 0.1 {
                    let distance = currentOffset.y - self.lastOffset.y
                    //The multiply by 10, / 1000 isn't really necessary.......
                    let scrollSpeedNotAbs = distance / 100
                    let scrollSpeed = abs(scrollSpeedNotAbs)
                    if scrollSpeed > 1.0 {
                        self.isScrollingFast = true
                    }
                    else {
                        self.isScrollingFast = false
                    }
                    
                    self.lastOffset = currentOffset
                    self.lastOffsetCapture = currentTime
                }
                
                if self.isScrollingFast {
                    self.hideKeyboardWhenFastScrolling()
                }
            }
        }
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
                    self.messageTableView.reloadData()
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
                        self.messageTableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
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
                    self.messageTableView.reloadData()
                    self.scrollToBottom(force: false)
                }
            }
        }
    }
    // MARK: - Keyboard
    func determineScrollLock() {
        if self.messages.count > 0 {
            if let indexPaths = self.messageTableView.indexPathsForVisibleRows {
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
    
    @objc func hideKeyboard(recognizer: UITapGestureRecognizer) {
        if recognizer.state == .ended {
            self.firstKeyboardShown = false
            self.view.endEditing(false)
        }
    }
    @objc func keyboardWillShow(_ notification: Notification) {
        self.determineScrollLock()
        
        if self.firstKeyboardShown == false {
            self.keyboardShown = true
        }
        self.firstKeyboardShown = false
        
        //let (height, duration, _) = Utils.getKeyboardAnimationOptions(notification: notification)
        
        self.keyboardHeight = 300 ?? 0
        
        DispatchQueue.main.async {
            UIView.animate(withDuration: 3.0 ?? 0, delay: 0, options: .curveEaseOut, animations: {
                if #available(iOS 11.0, *) {
                    self.inputMessageInnerContainerViewBottomMargin.constant = self.keyboardHeight - self.view.safeAreaInsets.bottom
                } else {
                    // Fallback on earlier versions
                }
                self.view.layoutIfNeeded()
            }, completion: nil)
            
            self.stopMeasuringVelocity = true
            self.scrollToBottom(force: false)
            self.keyboardShown = true
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        self.keyboardShown = false
        self.keyboardHeight = 0
        
        //let (_, duration, _) = Utils.getKeyboardAnimationOptions(notification: notification)
        
        DispatchQueue.main.async {
            UIView.animate(withDuration: 3.0 ?? 0, delay: 0, options: .curveEaseOut, animations: {
                self.inputMessageInnerContainerViewBottomMargin.constant = 0
                self.view.layoutIfNeeded()
            }, completion: nil)
            self.scrollToBottom(force: false)
        }
    }
    
    func hideKeyboardWhenFastScrolling() {
        if self.keyboardShown == false {
            return
        }
        
        //        DispatchQueue.main.async {
        //            UIView.animate(withDuration: 0.1, animations: {
        //                self.inputMessageInnerContainerViewBottomMargin.constant = 0
        //                self.view.layoutIfNeeded()
        //            })
        //            self.scrollToBottom(force: false)
        //        }
        self.view.endEditing(true)
        self.firstKeyboardShown = false
    }
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

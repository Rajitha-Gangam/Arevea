//
//  PvtChatCell.swift
//  AreveaTV
//
//  Created by apple on 4/15/21.
//  Copyright © 2021 apple. All rights reserved.
//

import UIKit
import SendBirdSDK

class PvtChatCell: OpenChannelMessageTableViewCell {
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var messageLabel1: UILabel!
    @IBOutlet weak var viewUser: UIView!
    @IBOutlet weak var viewReciever: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setMessage(_ message: SBDUserMessage) {
        self.msg = message
        print("==>self.msg:",self.msg)
        //self.resendButton.addTarget(self, action: #selector(OpenChannelUserMessageTableViewCell.clickResendUserMessageButton(_:)), for: .touchUpInside)
        
        let longClickMessageContainerGesture = UILongPressGestureRecognizer(target: self, action: #selector(OpenChannelUserMessageTableViewCell.longClickUserMessage(_:)))
       // self.messageContainerView.addGestureRecognizer(longClickMessageContainerGesture)
        
        self.messageLabel.text = message.message
        self.messageLabel1.text = message.message

        let userId = UserDefaults.standard.string(forKey: "user_id");
        let senderId = message.sender?.userId
        if(senderId == userId){
            self.viewUser.isHidden = false
            self.viewReciever.isHidden = true
        }else{
            self.viewUser.isHidden = true
            self.viewReciever.isHidden = false
        }


        super.setMessage(message)
    }

    func hideElementsForFailure() {
       
    }
    
    func showElementsForFailure() {
        
    }
    
    @objc func clickResendUserMessageButton(_ sender: AnyObject) {
        if let delegate = self.delegate, let msg = (self.msg as? SBDUserMessage) {
            if delegate.responds(to: #selector(OpenChannelMessageTableViewCellDelegate.didClickResendUserMessageButton(_:))) {
                delegate.didClickResendUserMessageButton!(msg)
            }
        }
    }
    
    @objc func longClickUserMessage(_ recognizer: UILongPressGestureRecognizer) {
        if let delegate = self.delegate, let msg = (self.msg as? SBDUserMessage) {
            if delegate.responds(to: #selector(OpenChannelMessageTableViewCellDelegate.didLongClickMessage(_:))) {
                delegate.didLongClickMessage!(msg)
            }
        }
    }
}

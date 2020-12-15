//
//  Q_And_A_AnswerCell.swift
//  AreveaTV
//
//  Created by apple on 12/15/20.
//  Copyright © 2020 apple. All rights reserved.
//

import UIKit
import SendBirdSDK

class Q_And_A_AnswerCell: Q_And_A_Cell {
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var sendingFailureContainerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func setMessage(_ message: SBDUserMessage) {
        self.msg = message
        
        //self.resendButton.addTarget(self, action: #selector(OpenChannelUserMessageTableViewCell.clickResendUserMessageButton(_:)), for: .touchUpInside)
        
        let longClickMessageContainerGesture = UILongPressGestureRecognizer(target: self, action: #selector(OpenChannelUserMessageTableViewCell.longClickUserMessage(_:)))
       // self.messageContainerView.addGestureRecognizer(longClickMessageContainerGesture)
        
        self.messageLabel.text = "A. " + message.message
        
        super.setMessage(message)
    }

    func hideElementsForFailure() {
       // self.resendButtonContainerView.isHidden = true
        //self.resendButton.isEnabled = false
        self.sendingFailureContainerView.isHidden = true
        //self.messageContainerViewBottomMargin.constant = 0
    }
    
    func showElementsForFailure() {
        //self.resendButtonContainerView.isHidden = false
        //self.resendButton.isEnabled = true
        self.sendingFailureContainerView.isHidden = false
        //self.messageContainerViewBottomMargin.constant = OpenChannelUserMessageTableViewCell.kMessageContainerViewBottomMarginNormal
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

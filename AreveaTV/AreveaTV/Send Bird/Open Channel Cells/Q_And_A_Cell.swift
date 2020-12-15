//
//  OpenChannelMessageTableViewCell.swift
//  SendBird-iOS
//
//  Created by Minhyuk Kim on 25/07/2019.
//  Copyright © 2019 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK

class Q_And_A_Cell: UITableViewCell {
    
    
    @IBOutlet weak var resendButtonContainerView: UIView!
    @IBOutlet weak var resendButton: UIButton!
    

    //@IBOutlet weak var messageContainerViewBottomMargin: NSLayoutConstraint!
    weak var delegate: OpenChannelMessageTableViewCellDelegate?
    var channel: SBDOpenChannel?
    var msg: SBDBaseMessage?
    var userColor = [String:Any]()
    var countUserColor = 0;
    var COLORLIST = [
        "#44d7b6",
        "#FF8935",
        "#f3af5a",
        "#846aa4",
        "#bf6780",
        "#b47f60",
        "#21accf",
        "#3d7dca",
        "#ed6c82",
        "#ee91a4",
        "#787ca9",
        "#5b868d",
        "#98bfaa",
        "#55d951",
        "#d0b2a0"
    ];
    //static let kMessageContainerViewBottomMarginNormal: CGFloat = 14.0
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    static func nib() -> UINib {
        return UINib(nibName: String(describing: self), bundle: Bundle(for: self))
    }
    func getColor(message:SBDBaseMessage) -> String {
        var color = "";
        if let sender = (self.msg as? SBDUserMessage)?.sender {
            if (!(userColor[sender.userId] != nil)) {
                color = COLORLIST[countUserColor];
                userColor[sender.userId] = COLORLIST[countUserColor];
                if (countUserColor > COLORLIST.count) {
                    countUserColor = 0;
                } else {
                    countUserColor += 1;
                }
            } else {
                color = userColor[sender.userId] as! String;
            }
        }
        return color;
    }
    
    
    func setMessage(_ message: SBDBaseMessage) {
        self.msg = message
    }
    
    func getMessage() -> SBDBaseMessage? {
        return self.msg
    }
    
    func showBottomMargin() {
        //        self.messageContainerViewBottomMargin.constant = OpenChannelImageVideoFileMessageTableViewCell.kMessageContainerViewBottomMarginNormal
    }
    
    func hideBottomMargin() {
        //self.messageContainerViewBottomMargin.constant = 0
    }
    
    @objc func longClickProfile(_ recognizer: UILongPressGestureRecognizer) {
        if let delegate = self.delegate {
            if delegate.responds(to: #selector(OpenChannelMessageTableViewCellDelegate.didLongClickUserProfile(_:))) {
                if let sender = (self.msg as? SBDFileMessage)?.sender {
                    delegate.didLongClickUserProfile!(sender)
                } else if let sender = (self.msg as? SBDUserMessage)?.sender {
                    delegate.didLongClickUserProfile!(sender)
                }
            }
        }
    }
    
    @objc func clickProfile(_ recognizer: UITapGestureRecognizer) {
        if let delegate = self.delegate {
            if delegate.responds(to: #selector(OpenChannelMessageTableViewCellDelegate.didClickUserProfile(_:))) {
                if let sender = (self.msg as? SBDFileMessage)?.sender {
                    delegate.didClickUserProfile!(sender)
                } else if let sender = (self.msg as? SBDUserMessage)?.sender {
                    delegate.didClickUserProfile!(sender)
                }
            }
        }
    }
}

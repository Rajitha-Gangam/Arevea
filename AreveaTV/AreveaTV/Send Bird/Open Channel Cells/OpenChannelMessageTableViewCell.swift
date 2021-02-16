//
//  OpenChannelMessageTableViewCell.swift
//  SendBird-iOS
//
//  Created by Minhyuk Kim on 25/07/2019.
//  Copyright © 2019 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK

class OpenChannelMessageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profileContainerView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userName: UIButton!

    @IBOutlet weak var nicknameLabel: UILabel!
    
    @IBOutlet weak var resendButtonContainerView: UIView!
    @IBOutlet weak var resendButton: UIButton!
    @IBOutlet weak var messageContainerView: UIView!
    @IBOutlet weak var profileImageWidth: NSLayoutConstraint!
    @IBOutlet weak var nicknameLabelWidth: NSLayoutConstraint!

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
        let appDelegate = UIApplication.shared.delegate as! AppDelegate

        let longClickProfileGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.longClickProfile(_:)))
        self.profileContainerView.addGestureRecognizer(longClickProfileGesture)
        
        let clickProfileGesture = UITapGestureRecognizer(target: self, action: #selector(self.clickProfile(_:)))
        self.profileContainerView.addGestureRecognizer(clickProfileGesture)
        
        //profileImageWidth
        if(UIDevice.current.userInterfaceIdiom == .pad){
            //profileImageWidth.constant = 50
//            self.userName.layer.cornerRadius = 25
//            self.profileImageView.layer.cornerRadius = 25
//            self.layoutIfNeeded()
        }
        if let sender = (self.msg as? SBDFileMessage)?.sender {
            sender.nickname = sender.nickname?.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
            if sender.nickname?.count == 0 {
                self.nicknameLabel.text = ""
            }
            else {
                self.nicknameLabel.text = sender.nickname ?? ""
            }
        } else if let sender = (self.msg as? SBDUserMessage)?.sender {

            sender.nickname = sender.nickname?.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)

            var firstChar = ""
            print("==sender.nickname:",sender.nickname)
            print("==sender.nickname count:",sender.nickname?.count)

            if sender.nickname?.count == 0 {
                /*if(appDelegate.isGuest){
                    self.nicknameLabel.text = "Guest"
                    firstChar = "G"
                }else{
                    self.nicknameLabel.text = "Anonymous"
                    firstChar = "A"
                }*/
            }
            else {
                self.nicknameLabel.text = sender.nickname ?? ""
                let fullNameArr = sender.nickname?.components(separatedBy: " ")
                let firstName: String = fullNameArr?[0] ?? " "
                var lastName = ""
                if (fullNameArr?.count ?? 0 > 1){
                    lastName = fullNameArr?[1] ?? ""
                }
                if (lastName == ""){
                    firstChar = String(firstName.first ?? "A")
                }else{
                    firstChar = String(firstName.first ?? "A") + String(lastName.first ?? " ")
                }
            }
            self.userName.setTitle(firstChar, for: .normal)
            
            if let profileUrl = sender.profileUrl {
                if let urlUserPic = URL(string: profileUrl){
                    self.profileImageView.sd_setImage(with: urlUserPic, placeholderImage: UIImage(named: ""))
                    self.profileImageView.isHidden = false
                    self.userName.isHidden = true
                }else{
                    //print("else:",profileUrl)
                    self.profileImageView.isHidden = true
                    self.userName.isHidden = false
                }
            }else{
                self.profileImageView.isHidden = true
                self.userName.isHidden = false
            }
//            self.profileImageView.isHidden = true
//            self.userName.isHidden = false
            if let hexColor = COLORLIST.randomElement() {
                let txtColor = UIColor(hexString: hexColor)
                self.nicknameLabel.textColor = txtColor
                self.userName.backgroundColor = txtColor

            }
            //self.nicknameLabel.intrinsicContentSize().width
            let nickName = self.nicknameLabel.text
            self.nicknameLabel.text = nickName! + " :"
            var rect: CGRect = nicknameLabel.frame //get frame of label
            rect.size = (nicknameLabel.text?.size(withAttributes: [NSAttributedString.Key.font: UIFont(name: nicknameLabel.font.fontName , size: nicknameLabel.font.pointSize)!]))! //Calculate as per label font
            nicknameLabelWidth.constant = rect.width + 2// set width to Constraint outlet
            nicknameLabel.layoutIfNeeded()

        }
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

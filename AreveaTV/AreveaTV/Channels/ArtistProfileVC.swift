//
//  ArtistProfileVC.swift
//  AreveaTV
//
//  Created by apple on 2/22/21.
//  Copyright © 2021 apple. All rights reserved.
//

import UIKit

class ArtistProfileVC: UIViewController {
    @IBOutlet weak var viewActivity: UIView!
    @IBOutlet weak var heightTopView: NSLayoutConstraint?
    @IBOutlet weak var viewTop: UIView!
    @IBOutlet var lblUserName: UILabel!
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var lblDesc: UILabel!
    @IBOutlet weak var btnUser: UIButton!

    @IBOutlet var imgSponsor: UIImageView!

    var isSpeaker = false
    var isHost = false
    var dicSpeakerInfo = [String: Any]()
    var dicPerformerInfo = [String: Any]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.imgSponsor.layer.borderColor = UIColor.white.cgColor
        var firstChar = ""

        if(isSpeaker){
            let speakerObj = dicSpeakerInfo
            let fn = speakerObj["first_name"] as? String ?? ""
            let ln = speakerObj["last_name"]as? String ?? ""
            let username = fn + " " + ln
            lblUserName.text = username
            
            if (ln == ""){
                firstChar = String(fn.first?.uppercased() ?? "A")
            }else{
                firstChar = String(fn.first?.uppercased() ?? "A") + String(ln.first?.uppercased() ?? " ")
            }
            btnUser.setTitle(firstChar, for: .normal)

            let user_type = speakerObj["user_type"]as? String ?? ""
            if( user_type == "creator"){
                lblDesc.text = "creator"
            }
            let profile_image = speakerObj["profile_image"]as? String ?? ""
               if let urlBanner = URL(string: profile_image){
                imgSponsor.sd_setImage(with: urlBanner, placeholderImage: UIImage(named: "user-white"))
                imgSponsor.isHidden = false
                btnUser.isHidden = true
               }
               else{
                imgSponsor.isHidden = true
                   btnUser.isHidden = false
               }
        }else if(isHost){
            let performerName = self.dicPerformerInfo["performer_display_name"] as? String ?? ""
            lblUserName.text = performerName
            let fullName = performerName.split{$0 == " "}.map(String.init)
            let fn = (fullName.count > 0) ? fullName[0] : ""
            let ln = (fullName.count > 1) ? fullName[1] : " "
            if (ln == ""){
                firstChar = String(fn.first?.uppercased() ?? "A")
            }else{
                firstChar = String(fn.first?.uppercased() ?? "A") + String(ln.first?.uppercased() ?? " ")
            }
            btnUser.setTitle(firstChar, for: .normal)

            
            let performerBio = self.dicPerformerInfo["performer_bio"] as? String ?? ""
            lblDesc.text = performerBio
            
             let  performer_profile_pic = self.dicPerformerInfo["performer_profile_pic"] as? String ?? ""
                if let urlBanner = URL(string: performer_profile_pic){
                    imgSponsor.sd_setImage(with: urlBanner, placeholderImage: UIImage(named: "user-white"))
                    imgSponsor.isHidden = false
                    btnUser.isHidden = true
                }else{
                    imgSponsor.isHidden = true
                    btnUser.isHidden = false
                }
        }
        lblTitle.text = lblUserName.text
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent // .default
    }
    @IBAction func back(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }

}

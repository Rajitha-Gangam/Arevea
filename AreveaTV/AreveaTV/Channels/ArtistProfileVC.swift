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
    @IBOutlet var imgSponsor: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.imgSponsor.layer.borderColor = UIColor.white.cgColor

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

//
//  MyEventsVC.swift
//  AreveaTV
//
//  Created by apple on 7/21/20.
//  Copyright © 2020 apple. All rights reserved.
//

import UIKit
import Alamofire

class TestVC: UIViewController,OpenChanannelChatDelegate,UITableViewDelegate,UITableViewDataSource {
    
    
    @IBOutlet weak var tblMain: UITableView!
    @IBOutlet weak var lblNoData: UILabel!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    @IBOutlet weak var viewActivity: UIView!
    @IBOutlet weak var heightTopView: NSLayoutConstraint?
    @IBOutlet weak var viewTop: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewActivity.isHidden = true
        tblMain.register(UINib(nibName: "MultiStreamGuestsCell", bundle: nil), forCellReuseIdentifier: "MultiStreamGuestsCell")
        lblNoData.isHidden = true;
        
        // Do any additional setup after loading the view.
        if(UIDevice.current.userInterfaceIdiom == .pad){
            heightTopView?.constant = 60;
            viewTop.layoutIfNeeded()
        }
        tblMain.layoutIfNeeded()
        
    }
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true);
    }
    func showAlert(strMsg: String){
        let alert = UIAlertController(title: "Alert", message: strMsg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        DispatchQueue.main.async {
        self.present(alert, animated: true)
        }
    }
    
    
    
    
    //MARK:Tableview Delegates and Datasource Methods
    
    func numberOfSections(in tableView: UITableView) ->  Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) ->  CGFloat {
        let screenRect = UIScreen.main.bounds
        let screenHeight = screenRect.size.height
        return screenHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblMain.dequeueReusableCell(withIdentifier: "MultiStreamGuestsCell", for: indexPath) as! MultiStreamGuestsCell
        let aryMyListData = ["one","two","three","four"]

        cell.updateCellWith(row: aryMyListData,controller: "my_events")
        //cell.cellDelegate = self
        return cell
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
    }
    // MARK: collectionView Delegate
    
   
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent // .default
    }
    override func viewWillDisappear(_ animated: Bool) {
        AppDelegate.AppUtility.lockOrientation(.all)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        AppDelegate.AppUtility.lockOrientation(.portrait)
    }
}


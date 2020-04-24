//
//  ChannelsVC.swift
//  AreveaTV
//
//  Created by apple on 4/23/20.
//  Copyright © 2020 apple. All rights reserved.
//

import UIKit

class ChannelsVC: UIViewController,UITableViewDelegate,UITableViewDataSource{
    @IBOutlet weak var tblMain: UITableView!
    @IBOutlet weak var lblTitle: UILabel!

    var detailItem: String = "";

    var aryMainMenu :[[String: String]] = [["name":"House","icon":"channel1.png"],["name":"Bass","icon":"channel2.png"],["name":"Bass","icon":"channel4.png"],["name":"House","icon":"channel3.png"],["name":"House","icon":"channel4.png"],
    ["name":"Bass","icon":"channel1.png"],
    ["name":"Bass","icon":"channel2.png"],
    ["name":"House","icon":"channel3.png"],
    ["name":"Bass","icon":"channel2.png"],
    ["name":"House","icon":"channel3.png"]];
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationController?.isNavigationBarHidden = true

        tblMain.register(UINib(nibName: "DashBoardCell", bundle: nil), forCellReuseIdentifier: "DashBoardCell")
        lblTitle.text = detailItem;

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);

    }
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true);
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    //MARK:Tableview Delegates and Datasource Methods
    
    func numberOfSections(in tableView: UITableView) ->  Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return 5
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) ->  CGFloat {
            return 200
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DashBoardCell", for: indexPath) as! DashBoardCell
        let selectedItem = aryMainMenu[indexPath.row]
        let selectedItem2 = aryMainMenu[indexPath.row + 1]
        let imageNamed = selectedItem["icon"];
        let imageNamed2 = selectedItem2["icon"];

        cell.image1.image = UIImage(named:imageNamed!)
        cell.image2.image = UIImage(named:imageNamed2!)
        return cell
    }
    func getColorByHex(rgbHexValue:UInt32, alpha:Double = 1.0) -> UIColor {
        let red = Double((rgbHexValue & 0xFF0000) >> 16) / 256.0
        let green = Double((rgbHexValue & 0xFF00) >> 8) / 256.0
        let blue = Double((rgbHexValue & 0xFF)) / 256.0

        return UIColor(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: CGFloat(alpha))
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
               
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent // .default
    }

}

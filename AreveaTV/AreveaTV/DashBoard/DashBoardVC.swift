//
//  DashBoard.swift
//  AreveaTV
//
//  Created by apple on 4/18/20.
//  Copyright © 2020 apple. All rights reserved.
//

import UIKit
import AWSMobileClient
import Alamofire

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}
class DashBoardVC: UIViewController,UITableViewDelegate,UITableViewDataSource,CollectionViewCellDelegate,UITextFieldDelegate{
    @IBOutlet weak var tblMain: UITableView!
    @IBOutlet weak var tblSide: UITableView!
    @IBOutlet weak var tblFilter: UITableView!
    @IBOutlet weak var viewSideMenu: UIView!
    @IBOutlet weak var txtCategory: UITextField!
    @IBOutlet weak var txtSubCategory: UITextField!
    @IBOutlet weak var txtGenres: UITextField!
    @IBOutlet weak var btnUserName: UIButton!
    @IBOutlet weak var lblUserName: UILabel!

    @IBOutlet weak var topConstaintTblMain: NSLayoutConstraint?
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var pickerView :UIPickerView!
    var aryData = [Any]();
    var arySubCategories = [Any]();
    var aryChannelData = [Any]();
    var aryFilterCategoriesData = [Any]();
    var aryFilterSubCategoriesData = [Any]();
    var aryFilterGenresData = [Any]();
    var isCategory = false;
    var isSubCategory = false;
    var isGenre = false;
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //    var arySideMenu : [[String: String]] = [["name":"Category","icon":"category-icon.png"],["name":"Channels","icon":"video-icon.png"],["name":"Artists","icon":"artists-icon.png"],["name":"Faq","icon":"faq-icon.png"],["name":"My Profile","icon":"default.png"],["name":"Logout","icon":"logout-icon.png"]]
    var arySideMenu : [[String: String]] = [["name":"Home","icon":"house.fill"],["name":"My Profile","icon":"person.circle.fill"],["name":"Logout","icon":"logout-icon.png"]];
    
    var aryMainMenu :[[String: String]] = [["name":"House","icon":"channel1.png"],["name":"Bass","icon":"channel1.png"],["name":"Artists","icon":"channel1.png"],["name":"Faq","icon":"channel1.png"],["name":"Logout","icon":"channel1.png"]];
    
    var arySections = [["name":"Live Events"],["name":"Artists"],["name":"Channels"],["name":"Continue Watching"]];
    
    
    //var aryFilterSections = ["Categories","Sub Categories","Genres"];
    var buttonNames = ["Comments", "Info", "Tip", "Share","Profile","Upcoming", "Videos", "Audios", "Followers"]
    
    var filterSections = ["Categories","Sub Categories","Genres"]
    //MARK:View Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationController?.isNavigationBarHidden = true
        
        tblMain.register(UINib(nibName: "DashBoardCell", bundle: nil), forCellReuseIdentifier: "DashBoardCell")
        tblSide.register(UINib(nibName: "SideMenuCell", bundle: nil), forCellReuseIdentifier: "SideMenuCell")
        tblFilter.register(UINib(nibName: "FilterCell", bundle: nil), forCellReuseIdentifier: "FilterCell")
        
        assignbackground();
        _ = Testbed.sharedInstance
        _ = Testbed.dictionary
        _ = Testbed.testAtIndex(index: 0)
        getCategoryOrganisations(inputData: ["":""]);
        //filterAPI();
        getProfile();
        //organizationChannels();
        
    }
    func assignbackground(){
        let background = UIImage(named: "sidemenu-bg")
        //        var imageView : UIImageView!
        //        imageView = UIImageView(frame: viewSideMenu.bounds)
        //        imageView.contentMode =  UIView.ContentMode.scaleAspectFill
        //        imageView.clipsToBounds = true
        //        imageView.image = background
        //        //imageView.center = viewSideMenu.center
        //        viewSideMenu.addSubview(imageView)
        //        self.viewSideMenu.sendSubviewToBack(imageView)
        self.viewSideMenu.backgroundColor = UIColor(patternImage:background!)
        
    }
    override func viewWillDisappear(_ animated: Bool) {
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        self.btnUserName.setTitle(appDelegate.USER_NAME, for: .normal)
    }
    func showAlert(strMsg: String){
        let alert = UIAlertController(title: "Alert1", message: strMsg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    // MARK: Handler for getProfile API, using for filters
    func getProfile(){
        let url: String = appDelegate.baseURL +  "/getProfile"
        let user_id = UserDefaults.standard.string(forKey: "user_id");
        let user_type = UserDefaults.standard.string(forKey: "user_type");
        let params: [String: Any] = ["user_id":user_id ?? "","user_type":user_type ?? ""]
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        AF.request(url, method: .post, parameters: params, encoding: JSONEncoding.default)
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any] {
                        print(json)
                        if (json["status"]as? Int == 0){
                            print(json["message"] ?? "")
                            var profile_data = [Any]()
                            profile_data = json["profile_data"] as? [Any] ?? [Any]()
                            if (profile_data.count > 0)
                            {
                                let  firstItem = profile_data[0] as? [String:Any]
                                let fn = firstItem?["user_first_name"] as? String
                                let ln = firstItem?["user_last_name"]as? String
                                let strName = String((fn?.first)!) + String((ln?.first)!)
                                self.appDelegate.USER_NAME = strName;
                                self.appDelegate.USER_NAME_FULL = (fn ?? "") + " " + (ln ?? "")
                                self.lblUserName.text = self.appDelegate.USER_NAME_FULL
                                self.btnUserName.setTitle(strName, for: .normal)
                            }
                            self.activityIndicator.isHidden = true;
                            self.activityIndicator.stopAnimating();
                        }else{
                            let strError = json["message"] as? String
                            print(strError ?? "")
                            self.showAlert(strMsg: strError ?? "")
                            self.activityIndicator.isHidden = true;
                            self.activityIndicator.stopAnimating();
                        }
                        
                    }
                case .failure(let error):
                    print(error)
                    self.activityIndicator.isHidden = true;
                    self.activityIndicator.stopAnimating();
                    self.showAlert(strMsg: error.localizedDescription)
                }
        }
    }
    // MARK: Handler for getCategoryOrganisations API
    func getCategoryOrganisations(inputData:[String: Any]){
        let url: String = appDelegate.baseURL +  "/getCategoryOrganisations"
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        print(inputData)
        
        AF.request(url, method: .post,  parameters: inputData, encoding: JSONEncoding.default)
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any] {
                        if (json["statusCode"]as? String == "200"){
                            print(json["message"] as? String ?? "")
                            
                            self.aryData = json["Data"] as? [Any] ?? [Any]();
                            if (self.aryData.count > 0){
                                let arySub = self.aryData[0] as? [String: Any]
                                self.arySubCategories = arySub?["subCategories"] as? [Any] ?? [Any]()
                            }
                            self.tblMain.reloadData();
                            self.activityIndicator.isHidden = true;
                            self.activityIndicator.stopAnimating();
                        }else{
                            let strError = json["message"] as? String
                            print(strError ?? "")
                            self.showAlert(strMsg: strError ?? "")
                            self.activityIndicator.isHidden = true;
                            self.activityIndicator.stopAnimating();
                        }
                        
                    }
                case .failure(let error):
                    print(error)
                    self.activityIndicator.isHidden = true;
                    self.activityIndicator.stopAnimating();
                    self.showAlert(strMsg: error.localizedDescription)
                }
        }
    }
    
    func logout()
    {
        AWSMobileClient.sharedInstance().signOut() { error in
            if let error = error {
                print(error)
                return
            }
        }
        var isLoginExists = false
        for controller in self.navigationController!.viewControllers as Array {
            if controller.isKind(of: LoginVC.self) {
                self.navigationController!.popToViewController(controller, animated: true)
                isLoginExists = true;
                break
            }
        }
        if (!isLoginExists){
            let storyboard = UIStoryboard(name: "Main", bundle: nil);
            let vc = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    func showConfirmation(strMsg: String){
        let alert = UIAlertController(title: "Alert", message: strMsg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            self.hideSideMenu()
            self.logout();
        }))
        DispatchQueue.main.async {
            self.present(alert, animated: true)
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
    //MARK:Tableview Delegates and Datasource Methods
    
    func numberOfSections(in tableView: UITableView) ->  Int {
        if (tableView == tblMain){
            return arySubCategories.count;
        }else  if (tableView == tblFilter){
            return 3;
        }
        return 1;
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (tableView == tblMain || tableView == tblFilter){
            return 44
        }
        return 0;
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if (tableView == tblMain || tableView == tblFilter ){
            let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 44))
            let darkGreen = UIColor(red: 1, green: 29, blue: 39);
            view.backgroundColor = darkGreen;
            var label = UILabel(frame: CGRect(x: 15, y: 0, width: tableView.bounds.width - 30, height: 44))
            
            if(tableView == tblFilter){
                view.backgroundColor = .black;
                label = UILabel(frame: CGRect(x: 15, y: 0, width: tableView.bounds.width - 30, height: 30))
            }
            label.font = UIFont.boldSystemFont(ofSize: 15)
            label.textColor = UIColor.white
            if(tableView == tblMain){
                let section = self.arySubCategories[section] as? [String : Any];
                let categoryName = section?["parent_category_name"] as? String;
                let name = section?["subCategory"] as? String;
                label.text = (categoryName ?? "") + " - " + (name ?? "");
                view.addSubview(label)
            }else{
                let name = filterSections[section]
                label.text = name;
                view.addSubview(label)
            }
            return view
        }
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 0))
        return view
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tableView == tblMain){
            return 1;
        }else if (tableView == tblFilter){
            return 1;
        }
        return arySideMenu.count;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) ->  CGFloat {
        if (tableView == tblMain){
            return 180;
        }else if (tableView == tblFilter){
            return 40;
        }
        return 44;
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // let cell = myTableView.dequeueReusableCell(withIdentifier: "DashBoardCell", for: indexPath) as! DashBoardCell
        if (tableView == tblMain){
            let cell = tblMain.dequeueReusableCell(withIdentifier: "DashBoardCell", for: indexPath) as! DashBoardCell
            let arySub = arySubCategories[indexPath.section] as? [String: Any]
            let organizations = arySub?["organizations"] as? [Any]
            _ = indexPath.row;
            
            guard let rowArray = organizations else { return cell };
            cell.updateCellWith(row: rowArray,controller: "dashboard")
            cell.cellDelegate = self
            return cell
        }else if (tableView == tblFilter){
            let cell = tblFilter.dequeueReusableCell(withIdentifier: "FilterCell", for: indexPath) as! FilterCell
            switch indexPath.section {
            case 0:
                if (aryFilterCategoriesData.count > 0){
                    cell.updateCellWith(row: aryFilterCategoriesData, item: "category");
                }
            case 1:
                if (aryFilterSubCategoriesData.count > 0){
                    cell.updateCellWith(row: aryFilterSubCategoriesData, item: "sub-category");
                }
            case 2:
                if (aryFilterGenresData.count > 0){
                    cell.updateCellWith(row: aryFilterGenresData, item: "genres");
                }
            default:
                print("default")
                
            }
            return cell;
            
        }
        else{
            let cell = tblSide.dequeueReusableCell(withIdentifier: "SideMenuCell", for: indexPath) as! SideMenuCell
            let selectedItem = arySideMenu[indexPath.row];
            cell.lblName.text =  selectedItem["name"];
            let imageNamed = selectedItem["icon"];
            if (indexPath.row == 0 || indexPath.row == 1){
                if #available(iOS 13.0, *) {
                    cell.imgItem.image = UIImage(systemName: imageNamed!)
                } else {
                    // Fallback on earlier versions
                };
                cell.imgItem.tintColor = .white;
            }else{
                cell.imgItem.image = UIImage(named:imageNamed!)
                
            }
            cell.backgroundColor = .clear
            return cell;
        }
        
    }
    func getColorByHex(rgbHexValue:UInt32, alpha:Double = 1.0) -> UIColor {
        let red = Double((rgbHexValue & 0xFF0000) >> 16) / 256.0
        let green = Double((rgbHexValue & 0xFF00) >> 8) / 256.0
        let blue = Double((rgbHexValue & 0xFF)) / 256.0
        
        return UIColor(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: CGFloat(alpha))
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if (tableView == tblMain){
            
        }
        else{
            let selectedItem = arySideMenu[indexPath.row];
            let name = selectedItem["name"];
            switch  name{
            case "Logout":
                showConfirmation(strMsg: "Are you sure you want to logout?")
            case "My Profile":
                hideSideMenu()
                let storyboard = UIStoryboard(name: "Main", bundle: nil);
                let vc = storyboard.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
                self.navigationController?.pushViewController(vc, animated: true)
            default:
                hideSideMenu()
                print ("default")
            }
            
        }
        
    }
    func showSideMenu(){
        viewSideMenu.isHidden = false;
        let movementDistance:CGFloat = self.view.frame.size.width - 70;
        var movement:CGFloat = 0
        movement = movementDistance
        UIView.animate(withDuration: 1.0, animations: {
            self.viewSideMenu.frame = self.viewSideMenu.frame.offsetBy(dx: movement, dy: 0)
        })
    }
    func hideSideMenu(){
        let movementDistance:CGFloat = self.view.frame.size.width - 70;
        var movement:CGFloat = 0
        movement = -movementDistance
        UIView.animate(withDuration: 1.0, animations: {
            self.viewSideMenu.frame = self.viewSideMenu.frame.offsetBy(dx: movement, dy: 0)
        })
    }
    @IBAction func sideMenuToggle(_ sender: Any) {
        showSideMenu();
    }
    @IBAction func viewBGTapped(_ sender: Any) {
        hideSideMenu()
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent // .default
    }
    func collectionView(collectionviewcell: DBCollectionViewCell?, index: Int, didTappedInTableViewCell: DashBoardCell) {
        hideSideMenu()
        let orgsList = didTappedInTableViewCell.rowWithItems
        let selectedOrg = orgsList[index] as? [String: Any]
        // print("item:\(String(describing: selectedOrg))")
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil);
        let vc = storyboard.instantiateViewController(withIdentifier: "ChannelsVC") as! ChannelsVC
        vc.orgId = selectedOrg?["id"] as? Int ?? 0
        if (selectedOrg?["organization_name"]as? String != nil){
            vc.organizationName = selectedOrg?["organization_name"] as! String
        }
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }
    
    // use delegate delegate
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "headerId", for: indexPath)
        var lblHeaher : UILabel!
        
        // as header is dequing that's why we need to check if label is there then no need to init label again and again
        if header.viewWithTag(101) == nil {
            lblHeaher = UILabel.init(frame: CGRect(x: 30, y: 0, width: 100, height: 40))
            lblHeaher.tag = 101
        }else{
            lblHeaher = header.viewWithTag(101) as? UILabel
        }
        
        
        lblHeaher.text = "category \(indexPath.row)"
        lblHeaher.textAlignment = .left
        lblHeaher.textColor = UIColor.white
        
        header.backgroundColor = .lightGray
        header.addSubview(lblHeaher)
        return header
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: 100, height: 40)
    }
    // MARK: Handler for allCategories API, using for filters
    func filterAPI(){
        let url: String = appDelegate.baseURL +  "/allCategories"
        let params: [String: Any] = [:]
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        AF.request(url, method: .post,  parameters: params, encoding: JSONEncoding.default)
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any] {
                        if (json["statusCode"]as? String == "200"){
                            print(json["message"] as? String ?? "")
                            self.aryFilterCategoriesData = json["Data"] as? [Any] ?? [Any]();
                            if (self.aryFilterCategoriesData.count > 0){
                                let selectedItem = self.aryFilterCategoriesData[0] as? [String : Any];
                                //let strCategory = selectedItem["category"] as? String;
                                self.aryFilterSubCategoriesData = selectedItem?["subcategory"] as? [Any] ?? [Any]();
                                self.aryFilterGenresData = selectedItem?["genre"] as? [Any] ?? [Any]();
                                self.tblFilter.reloadData();
                            }
                            self.activityIndicator.isHidden = true;
                            self.activityIndicator.stopAnimating();
                        }else{
                            let strError = json["message"] as? String
                            print(strError ?? "")
                            self.showAlert(strMsg: strError ?? "")
                            self.activityIndicator.isHidden = true;
                            self.activityIndicator.stopAnimating();
                        }
                        
                    }
                case .failure(let error):
                    print(error)
                    self.activityIndicator.isHidden = true;
                    self.activityIndicator.stopAnimating();
                    self.showAlert(strMsg: error.localizedDescription)
                }
        }
    }
    
    
}



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
class DashBoardVC: UIViewController,UITableViewDelegate,UITableViewDataSource,CollectionViewCellDelegate,UIPickerViewDataSource,UIPickerViewDelegate,UITextFieldDelegate{
    @IBOutlet weak var tblMain: UITableView!
    @IBOutlet weak var tblSide: UITableView!
    @IBOutlet weak var viewSideMenu: UIView!
    @IBOutlet weak var viewFilter: UIView!
    @IBOutlet weak var txtCategory: UITextField!
    @IBOutlet weak var txtSubCategory: UITextField!
    @IBOutlet weak var txtGenres: UITextField!
    @IBOutlet weak var topConstaintTblMain: NSLayoutConstraint?
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
    var arySideMenu : [[String: String]] = [["name":"Home","icon":"home.png"],["name":"My Profile","icon":"default.png"],["name":"Logout","icon":"logout-icon.png"]];
    
    var aryMainMenu :[[String: String]] = [["name":"House","icon":"channel1.png"],["name":"Bass","icon":"channel1.png"],["name":"Artists","icon":"channel1.png"],["name":"Faq","icon":"channel1.png"],["name":"Logout","icon":"channel1.png"]];
    
    var arySections = [["name":"Live Events"],["name":"Artists"],["name":"Channels"],["name":"Continue Watching"]];
    
    
    
    //MARK:View Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationController?.isNavigationBarHidden = true
        
        tblMain.register(UINib(nibName: "DashBoardCell", bundle: nil), forCellReuseIdentifier: "DashBoardCell")
        tblSide.register(UINib(nibName: "SideMenuCell", bundle: nil), forCellReuseIdentifier: "SideMenuCell")
        assignbackground();
        _ = Testbed.sharedInstance
        _ = Testbed.dictionary
        _ = Testbed.testAtIndex(index: 0)
        getCategoryOrganisations(inputData: [:]);
        filterAPI();
        //organizationChannels();
        txtCategory.rightViewMode = .always
        txtCategory.rightView = UIImageView(image: UIImage(named: "drop_down_white.png"));
        
        txtSubCategory.rightViewMode = .always
        txtSubCategory.rightView = UIImageView(image: UIImage(named: "drop_down_white.png"));
        
        txtGenres.rightViewMode = .always
        txtGenres.rightView = UIImageView(image: UIImage(named: "drop_down_white.png"));
        
        viewFilter.layer.borderColor = UIColor.white.cgColor;
        viewFilter.layer.cornerRadius = 5;
        viewFilter.layer.borderWidth = 1.0;
        
        createPickerView();
        dismissPickerView();
        
        viewFilter.isHidden = true;
        topConstaintTblMain?.constant = 2;
        tblMain.layoutIfNeeded()
        
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
        
    }
    func showAlert(strMsg: String){
        let alert = UIAlertController(title: "Alert1", message: strMsg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    func getCategoryOrganisations(inputData:[String: Any]){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let url: String = appDelegate.baseURL +  "/getCategoryOrganisations"
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        print(inputData)
        AF.request(url, method: .post,  parameters: inputData, encoding: JSONEncoding.default)
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any] {
                        if (json["statusCode"]as! String == "200"){
                            print(json["message"] as! String)
                            
                            self.aryData = json["Data"] as! [Any];
                            if (self.aryData.count > 0){
                                let arySub = self.aryData[0] as! [String: Any]
                                self.arySubCategories = arySub["subCategories"] as! [Any]
                            }
                            self.tblMain.reloadData();
                            self.activityIndicator.isHidden = true;
                            self.activityIndicator.stopAnimating();
                        }else{
                            let strError = json["message"] as! String
                            print(strError)
                            self.showAlert(strMsg: strError)
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
        }
        return 1;
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (tableView == tblMain){
            return 44
        }
        return 0;
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 44))
        let darkGreen = UIColor(red: 1, green: 29, blue: 39);
        view.backgroundColor = darkGreen;
        let label = UILabel(frame: CGRect(x: 15, y: 0, width: tableView.bounds.width - 30, height: 44))
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textColor = UIColor.white
        let section = self.arySubCategories[section] as! [String : Any];
        let categoryName = section["parent_category_name"] as! String;
        let name = section["subCategory"] as! String;
        label.text = categoryName + " - " + name;
        view.addSubview(label)
        let button = UIButton(frame: CGRect(x: 100, y: 100, width: 100, height: 50))
        button.backgroundColor = .clear
        button.setTitle("", for: .normal)
        button.setImage(UIImage(named: ""), for: .normal)
        
        
        self.view.addSubview(button)
        
        return view
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tableView == tblMain){
            return 1;
        }
        return arySideMenu.count;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) ->  CGFloat {
        if (tableView == tblMain){
            return 180
        }
        return 44;
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // let cell = myTableView.dequeueReusableCell(withIdentifier: "DashBoardCell", for: indexPath) as! DashBoardCell
        if (tableView == tblMain){
            let cell = tblMain.dequeueReusableCell(withIdentifier: "DashBoardCell", for: indexPath) as! DashBoardCell
            let arySub = arySubCategories[indexPath.section] as! [String: Any]
            let organizations = arySub["organizations"] as! [Any]
            let row = indexPath.row;
            let rowArray = organizations;
            cell.updateCellWith(row: rowArray,controller: "dashboard")
            cell.cellDelegate = self
            return cell
        }
        else{
            let cell = tblSide.dequeueReusableCell(withIdentifier: "SideMenuCell", for: indexPath) as! SideMenuCell
            let selectedItem = arySideMenu[indexPath.row];
            cell.lblName.text =  selectedItem["name"];
            let imageNamed = selectedItem["icon"];
            cell.imgItem.image = UIImage(named:imageNamed!)
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
            viewSideMenu.isHidden = true;
            let selectedItem = arySideMenu[indexPath.row];
            let name = selectedItem["name"];
            switch  name{
            case "Logout":
                logout();
            case "My Profile":
                let storyboard = UIStoryboard(name: "Main", bundle: nil);
                let vc = storyboard.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
                self.navigationController?.pushViewController(vc, animated: true)
            default:
                print ("default")
            }
            
        }
        
    }
    @IBAction func sideMenuToggle(_ sender: Any) {
        viewSideMenu.isHidden = false;
    }
    @IBAction func viewBGTapped(_ sender: Any) {
        NSLog("viewBGTapped")
        viewSideMenu.isHidden = true;
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent // .default
    }
    func collectionView(collectionviewcell: DBCollectionViewCell?, index: Int, didTappedInTableViewCell: DashBoardCell) {
        if (viewSideMenu.isHidden) {
            let colorsRow = didTappedInTableViewCell.rowWithItems
            let item = colorsRow[index]
            //print("item:\(item)")
            let storyboard = UIStoryboard(name: "Main", bundle: nil);
            let vc = storyboard.instantiateViewController(withIdentifier: "ChannelsVC") as! ChannelsVC
            self.navigationController?.pushViewController(vc, animated: true)
        }else{
            viewSideMenu.isHidden = true;
        }
    }
    // MARK: Picker  Methods
    func createPickerView() {
        pickerView = UIPickerView()
        pickerView.delegate = self;
        pickerView.dataSource = self;
        let darkGreen = UIColor(red: 1, green: 29, blue: 39);
        pickerView.backgroundColor = darkGreen;
        pickerView.tintColor = .white;
        txtCategory.inputView = pickerView
        txtGenres.inputView = pickerView
        txtSubCategory.inputView = pickerView
    }
    
    func dismissPickerView() {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let flexButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let button = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.action))
        toolBar.setItems([flexButton, button], animated: true)
        toolBar.isUserInteractionEnabled = true
        txtCategory.inputAccessoryView = toolBar
        txtSubCategory.inputAccessoryView = toolBar
        txtGenres.inputAccessoryView = toolBar
        
    }
    
    @objc func action() {
        tblMain.reloadData();
        view.endEditing(true)
    }
    // MARK: Picker DataSource & Delegate Methods
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (isCategory){
            return aryFilterCategoriesData.count;
        }else if (isSubCategory){
            return aryFilterSubCategoriesData.count;
        }else if (isGenre){
            return aryFilterGenresData.count;
        }
        return 0;
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        var strValue = "";
        if (isCategory){
            let selectedItem = aryFilterCategoriesData[row] as! [String : Any];
            strValue = selectedItem["category"] as! String;
        }else if (isSubCategory){
            let selectedItem = aryFilterSubCategoriesData[row] as! [String : Any];
            strValue = selectedItem["subCategory"] as! String;
        }else if (isGenre){
            let selectedItem = aryFilterGenresData[row] as! [String : Any];
            strValue = selectedItem["genres"] as! String;
        }
        return NSAttributedString(string: strValue, attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (isCategory){
            let selectedItem = self.aryFilterCategoriesData[row] as! [String : Any];
            let strCategory = selectedItem["category"] as? String;
            self.txtCategory.text = strCategory
            self.aryFilterSubCategoriesData = selectedItem["subcategory"] as! [Any];
            self.aryFilterGenresData = selectedItem["genre"] as! [Any];
            self.txtSubCategory.text = "";
            self.txtGenres.text = "";
        }else if (isSubCategory){
            let selectedItem = aryFilterSubCategoriesData[row] as! [String : Any];
            let strValue = selectedItem["subCategory"] as! String;
            self.txtSubCategory.text = strValue
        }else if (isGenre){
            let selectedItem = aryFilterGenresData[row] as! [String : Any];
            let strValue = selectedItem["genres"] as! String;
            self.txtGenres.text = strValue
        }
    }
    @IBAction func openFilter(_ sender: Any){
        if (viewFilter.isHidden){
            viewFilter.isHidden = false;
            topConstaintTblMain?.constant = 153;
            tblMain.layoutIfNeeded()
        }else{
            viewFilter.isHidden = true;
            topConstaintTblMain?.constant = 2;
            tblMain.layoutIfNeeded()
        }
        
    }
    @IBAction func applyFilter(_ sender: Any){
        viewFilter.isHidden = true;
        topConstaintTblMain?.constant = 2;
        tblMain.layoutIfNeeded()
        if (txtSubCategory.text!.count > 0){
            getCategoryOrganisations(inputData: ["category":txtSubCategory.text!])
        }
        else if (txtCategory.text!.count > 0){
            getCategoryOrganisations(inputData: ["category":txtCategory.text!])
        }
    }
    @IBAction func closeFilter(_ sender: Any){
        viewFilter.isHidden = true;
        topConstaintTblMain?.constant = 2;
        tblMain.layoutIfNeeded()
    }
    // MARK: Filters we are using this method
    func filterAPI(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let url: String = appDelegate.baseURL +  "/allCategories"
        let params: [String: Any] = [:]
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        AF.request(url, method: .post,  parameters: params, encoding: JSONEncoding.default)
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any] {
                        if (json["statusCode"]as! String == "200"){
                            print(json["message"] as! String)
                            self.aryFilterCategoriesData = json["Data"] as! [Any];
                            self.activityIndicator.isHidden = true;
                            self.activityIndicator.stopAnimating();
                        }else{
                            let strError = json["message"] as! String
                            print(strError)
                            self.showAlert(strMsg: strError)
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
    // MARK: Text Field Delegate Methods
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if (textField == txtCategory){
            isCategory = true;
            isSubCategory = false;
            isGenre = false;
            if (aryFilterCategoriesData.count == 0){
                showAlert(strMsg: "No categories found")
            }
        }else if (textField == txtSubCategory){
            isCategory = false;
            isSubCategory = true;
            isGenre = false;
            if (aryFilterSubCategoriesData.count == 0){
                showAlert(strMsg: "No sub categories available for selected category")
            }
        }else if (textField == txtGenres){
            isCategory = false;
            isSubCategory = false;
            isGenre = true;
            if (aryFilterGenresData.count == 0){
                showAlert(strMsg: "No genres available for selected category")
            }
        }
        pickerView.reloadAllComponents();
        
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder();
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder();
        return true;
    }
    
}



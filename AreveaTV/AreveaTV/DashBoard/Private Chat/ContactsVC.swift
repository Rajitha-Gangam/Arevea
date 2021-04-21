//
//  ContactsVC.swift
//  PopOverSample
//
//  Created by apple on 1/6/21.
//

import UIKit
import Alamofire

class ContactsVC: UIViewController, UITableViewDelegate, UITableViewDataSource,UISearchBarDelegate,RefreshContactsProtocol {
    @IBOutlet weak var viewActivity: UIView!
    @IBOutlet weak var heightTopView: NSLayoutConstraint?
    @IBOutlet weak var viewTop: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var lblNoData: UILabel!
    var aryListOfContacts = [Any]();
    var aryListOfSearchContacts = [Any]();
    var searchActive : Bool = false
    @IBOutlet weak var searchBar: UISearchBar!
    var framePopup : CGRect!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
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
    // Data model: These strings will be the data for the table view cells
    let animals: [String] = ["Horse", "Cow", "Camel", "Sheep", "Goat"]
    
    // cell reuse id (cells that scroll out of view can be reused)
    let cellReuseIdentifier = "cell"
    
    // don't forget to hook this up from the storyboard
    @IBOutlet var tblAllContacts: UITableView!
    @IBOutlet var btnAddContact: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Contacts"
        // Register the table view cell class and its reuse id
        
        // (optional) include this line if you want to remove the extra empty cell divider lines
        // self.tableView.tableFooterView = UIView()

        // This view controller itself will provide the delegate methods and row data for the table view.
        self.searchBar.delegate = self
        searchBar.placeholder = "Search with any keyword"
        let green = UIColor(red: 34, green: 44, blue: 54);
        let darkGreen = UIColor(red: 13, green: 17, blue: 21);

        searchBar.set(textColor: .white)
        searchBar.setTextField(color:green )
        searchBar.setPlaceholder(textColor: .gray)
        searchBar.setSearchImage(color: .white)
        searchBar.setClearButton(color: .black)
        searchBar.barTintColor = darkGreen

        if(UIDevice.current.userInterfaceIdiom == .pad){
            let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 25.0), NSAttributedString.Key.foregroundColor: darkGreen]
            UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = attributes
            
        }
        tblAllContacts.register(UINib(nibName: "ContactsCell", bundle: nil), forCellReuseIdentifier: "ContactsCell")
        btnAddContact.isHidden = true
        //listContacts()
    }
    override func viewWillAppear(_ animated: Bool) {
        print("viewWillAppear")
        listContacts()
    }
    override func viewDidAppear(_ animated: Bool) {
        print("viewDidAppear")
    }
    //this is delegate method, when contact added on Add contact page, and after comes to this page, need to refresh contacts
    func refreshAddedContacts() {
        print("refreshAddedContacts")
        listContacts()

    }
    
    @IBAction func back(_ sender: Any) {
        if(appDelegate.isPvtChatFromLeftMenu){
            self.navigationController?.popViewController(animated: true);
        }else{
            self.dismiss(animated: true, completion: nil)
        }
    }
   
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(searchActive){
            return self.aryListOfSearchContacts.count
        }
        return self.aryListOfContacts.count

    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // create a new cell if needed or reuse an old one
        let cell = tblAllContacts.dequeueReusableCell(withIdentifier: "ContactsCell", for: indexPath) as! ContactsCell
        var contact = [String:Any]()
        if(searchActive){
            contact = aryListOfSearchContacts[indexPath.row] as? [String : Any] ?? [String:Any]()
        }else{
            contact = aryListOfContacts[indexPath.row] as? [String : Any] ?? [String:Any]()
        }
        
        let fullName = contact["name"] as? String ?? ""

        // set the text from the data model
        cell.nicknameLabel.text = fullName
        
        var firstChar = ""
        if fullName.count == 0 {
            cell.nicknameLabel.text = "Anonymous"
            firstChar = "A"
        }
        else {
            let fullNameArr = fullName.components(separatedBy: " ")
            let firstName: String = fullNameArr[0]
            var lastName = ""
            if (fullNameArr.count > 1){
                lastName = fullNameArr[1]
            }
            if (lastName == ""){
                firstChar = String(firstName.first!)
            }else{
                firstChar = String(firstName.first!) + String(lastName.first!)
            }
        }
        cell.userName.setTitle(firstChar, for: .normal)
        cell.btnAdd.isHidden = true
        return cell
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
        btnAddContact.isHidden = true
        var contact = [String:Any]()
        if(searchActive){
            contact = aryListOfSearchContacts[indexPath.row] as? [String : Any] ?? [String:Any]()
        }else{
            contact = aryListOfContacts[indexPath.row] as? [String : Any] ?? [String:Any]()
        }
        if(appDelegate.isPvtChatFromLeftMenu){
            let storyboard = UIStoryboard(name: "Main", bundle: nil);
            let vc = storyboard.instantiateViewController(withIdentifier: "ContactChatVC") as! ContactChatVC
            vc.contactObj = contact
            self.navigationController?.pushViewController(vc, animated: true)
        }else{
            let storyboard = UIStoryboard(name: "Main", bundle: nil);
            let vc = storyboard.instantiateViewController(withIdentifier: "ContactChatVC") as! ContactChatVC
            vc.contactObj = contact

            let screenRect = UIScreen.main.bounds
            print("screenRect:",screenRect)
            let screenHeight = screenRect.size.height/2
            let screenWidth = screenRect.size.width - 100
            let popupVC = PopupViewController(contentController: vc, position:.bottomRight(CGPoint(x: 0, y: 30)), popupWidth: screenWidth, popupHeight: screenHeight)
            popupVC.backgroundAlpha = 0.3
            popupVC.backgroundColor = .black
            popupVC.canTapOutsideToDismiss = true
            popupVC.cornerRadius = 10
            popupVC.shadowEnabled = true
            //popupVC.delegate = self
            present(popupVC, animated: true, completion: nil)
        }
        

    }
    @IBAction func moreTap(_ sender: Any) {
        print("more clicked")
        btnAddContact.isHidden = false

    }
    @IBAction func AddContact(_ sender: Any) {
        print("add clicked")
        btnAddContact.isHidden = true
        if(appDelegate.isPvtChatFromLeftMenu){
            let storyboard = UIStoryboard(name: "Main", bundle: nil);
            let vc = storyboard.instantiateViewController(withIdentifier: "AddContactVC") as! AddContactVC
            self.navigationController?.pushViewController(vc, animated: true)
           
        }else{
            let contactsVC = self.storyboard?.instantiateViewController(withIdentifier: "AddContactVC") as? AddContactVC
            let screenRect = UIScreen.main.bounds
            print("screenRect:",screenRect)
            let screenHeight = screenRect.size.height/2
            let screenWidth = screenRect.size.width - 100
            contactsVC?.delegate = self
            let popupVC = PopupViewController(contentController: contactsVC!, position:.bottomRight(CGPoint(x: 0, y: 30)), popupWidth: screenWidth, popupHeight: screenHeight)
            popupVC.backgroundAlpha = 0.3
            popupVC.backgroundColor = .black
            popupVC.canTapOutsideToDismiss = true
            popupVC.cornerRadius = 10
            popupVC.shadowEnabled = true
            //popupVC.delegate = self
            present(popupVC, animated: true, completion: nil)
        }
        
    }
    
    
    func showAlert(strMsg: String){
        let alert = UIAlertController(title: "Alert", message: strMsg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
        
    }
    // MARK: Handler for events(events) API
    func listContacts(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let url: String = appDelegate.baseURL +  "/listContacts"
        //print("getEvents input:",inputData)
        let user_id = UserDefaults.standard.string(forKey: "user_id");
        let inputData: [String: Any] = ["userid":user_id ?? ""]

        viewActivity.isHidden = false
        let headers: HTTPHeaders
        headers = [appDelegate.x_api_key: appDelegate.x_api_value]
        AF.request(url, method: .post,parameters: inputData, encoding: JSONEncoding.default,headers:headers)
            .responseJSON { response in
                DispatchQueue.main.async {
                    self.viewActivity.isHidden = true
                    switch response.result {
                    case .success(let value):
                        if let json = value as? [String: Any] {
                            print("listContacts JSON:",json)
                            if (json["statusCode"]as? String == "200" ){
                                let aryContacts  = json["Data"] as? [Any] ?? [Any]();
                            self.aryListOfContacts = []
                                print("contacts count:",self.aryListOfContacts.count)
                                for(j,_)in aryContacts.enumerated(){
                                    let contact = aryContacts[j] as? [String : Any] ?? [String:Any]()
                                    print("contact:",contact)
                                    let contact_details = contact["contact_details"] as? [String : Any] ?? [String:Any]()
                                    let fullName = contact_details["name"] as? String ?? ""
                                    let contactId = contact["contactid"] as? String ?? ""

                                    let nameDic = ["name":fullName,"contactid":contactId]
                                    self.aryListOfContacts.append(nameDic)
                                }
                           self.tblAllContacts.reloadData()
                            }else{
                                let strMsg = json["message"] as? String ?? ""
                                self.showAlert(strMsg: strMsg)
                            }
                        }
                    case .failure(let error):
                        let errorDesc = error.localizedDescription.replacingOccurrences(of: "URLSessionTask failed with error:", with: "")
                        //print("getEvents errorDesc:",errorDesc)
                        self.showAlert(strMsg: errorDesc)
                        self.viewActivity.isHidden = true
                        
                    }
                }
            }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        btnAddContact.isHidden = true
        searchActive = false;
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchActive = false;
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = "";
        searchBar.resignFirstResponder()
        searchActive = false;
        aryListOfSearchContacts = []
        self.tblAllContacts.reloadData()
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            //when user press X icon
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                searchBar.resignFirstResponder()
            }
            searchActive = false;
            self.tblAllContacts.reloadData()
        }else{
            if (searchText.count > 0){
                searchActive = true;
                ////print("--count:",aryFilteredSubCategories.count)
                let predicate = NSPredicate(format:"name contains[c] %@", searchText)
                let filteredArray = (aryListOfContacts as NSArray).filtered(using: predicate)
                print("filteredArray:",filteredArray)
                aryListOfSearchContacts = filteredArray
                tblAllContacts.reloadData()
            }
        }
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        var searchText = (searchBar.text!).lowercased().trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        let encodedQuery = searchText.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed)
        searchText = encodedQuery!;
        searchText = searchText.replacingOccurrences(of: "'", with: "%27")
        searchText = searchText.replacingOccurrences(of: ":", with: "%3A")
        searchText = searchText.replacingOccurrences(of: "=", with: "%3D")
        searchText = searchText.replacingOccurrences(of: "/", with: "%252F")
        print("searchString:",searchText)
        if (searchText.count > 0){
            searchActive = true;
            ////print("--count:",aryFilteredSubCategories.count)
            let predicate = NSPredicate(format:"name contains[c] %@", searchText)
            let filteredArray = (aryListOfContacts as NSArray).filtered(using: predicate)
            print("filteredArray:",filteredArray)
            tblAllContacts.reloadData()
        }else{
            showAlert(strMsg: "Please enter search keyword")
        }
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent // .default
    }
    

}

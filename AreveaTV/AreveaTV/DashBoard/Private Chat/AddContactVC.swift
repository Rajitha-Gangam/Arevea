//
//  AddContactVC.swift
//  PopOverSample
//
//  Created by apple on 1/6/21.
//

import UIKit
import Alamofire
protocol RefreshContactsProtocol {
    func refreshAddedContacts()
}
class AddContactVC: UIViewController, UITableViewDelegate, UITableViewDataSource,UISearchBarDelegate {
    var delegate:RefreshContactsProtocol?

    @IBOutlet weak var viewActivity: UIView!
    @IBOutlet weak var heightTopView: NSLayoutConstraint?
    @IBOutlet weak var viewTop: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var lblNoData: UILabel!
    var aryListOfContacts = [Any]();
    var aryListOfSearchContacts = [Any]();
    var searchActive : Bool = false
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tblFilter: UITableView!
    var framePopup : CGRect!
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Contacts"
        // Register the table view cell class and its reuse id
        
        // (optional) include this line if you want to remove the extra empty cell divider lines
        // self.tableView.tableFooterView = UIView()

        // This view controller itself will provide the delegate methods and row data for the table view.
        self.searchBar.delegate = self
        searchBar.placeholder = "Search with any keyword"
        let darkGray = UIColor(red: 113, green: 109, blue: 123);

        searchBar.set(textColor: .white)
        searchBar.setTextField(color: darkGray)
        searchBar.setPlaceholder(textColor: darkGray)
        searchBar.setSearchImage(color: .white)
        searchBar.setClearButton(color: .black)
        if(UIDevice.current.userInterfaceIdiom == .pad){
            let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 25.0), NSAttributedString.Key.foregroundColor: darkGray]
            UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = attributes
            
        }
        tblAllContacts.register(UINib(nibName: "ContactsCell", bundle: nil), forCellReuseIdentifier: "ContactsCell")
    }
    @IBAction func back(_ sender: Any) {
        delegate?.refreshAddedContacts()
        self.dismiss(animated: true, completion: nil)
    }
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.aryListOfSearchContacts.count
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // create a new cell if needed or reuse an old one
        let cell = tblAllContacts.dequeueReusableCell(withIdentifier: "ContactsCell", for: indexPath) as! ContactsCell
        let contact = aryListOfSearchContacts[indexPath.row] as? [String : Any] ?? [String:Any]()
        let firstName = contact["user_first_name"] as? String ?? ""
        let lastName = contact["user_last_name"] as? String ?? ""

        let fullName = firstName + " " + lastName
        // set the text from the data model
        cell.nicknameLabel.text = fullName
        
        var firstChar = ""
        if fullName.count == 0 {
            cell.nicknameLabel.text = "Anonymous"
            firstChar = "A"
        }
        else {
            if (lastName == ""){
                firstChar = String(firstName.first!)
            }else{
                firstChar = String(firstName.first!) + String(lastName.first!)
            }
        }
        cell.userName.setTitle(firstChar, for: .normal)
        cell.btnAdd.tag = indexPath.row
        cell.btnAdd.addTarget(self, action: #selector(addFriend(_:)), for: .touchUpInside)
        return cell
    }
    
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
    }
    @IBAction func addFriend(_ sender: UIButton) {

        print("add btn clicked")
        print("tag:",sender.tag)
        let contact = aryListOfSearchContacts[sender.tag] as? [String : Any] ?? [String:Any]()
        print("selected contact:",contact)
        let user_id = UserDefaults.standard.string(forKey: "user_id");
        let contactId  = contact["id"] as? String ?? ""
        let groupname = "null"
        let user_display_name  = contact["user_display_name"] as? String ?? ""
        let user_phone_number  = contact["user_phone_number"] as? String ?? ""
        let email  = contact["email"] as? String ?? ""

        let inputData =
            ["userid": user_id ?? "",
             "contactid":contactId,
             "groupname":"null",
             "contact_details": [
                "name": user_display_name, "phone_number": user_phone_number, "email":email, "profile_pic":"null"
                ]] as [String : Any];
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let url: String = appDelegate.baseURL +  "/addFriend"
        //print("getEvents input:",inputData)

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
                            print("addFriend JSON:",json)
                            if (json["statusCode"]as? String == "200" ){
                                self.showAlert(strMsg: "Contact added successfully")

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
    
    func showAlert(strMsg: String){
        let alert = UIAlertController(title: "Alert", message: strMsg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
        
    }
    
    // MARK: Handler for events(events) API
    func searchContacts(searchText:String){
        print("searchText:",searchText)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let url: String = appDelegate.baseURL +  "/searchContacts"
        //print("getEvents input:",inputData)
        let inputData: [String: Any] = ["searchKey":searchText]

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
                            print("searchContacts JSON:",json)
                            if (json["statusCode"]as? String == "200" ){
                                let data  = json["Data"] as? [Any] ?? [Any]();
                                self.aryListOfSearchContacts = data
                                print("search count:",self.aryListOfSearchContacts.count)
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
            aryListOfSearchContacts = []
            self.tblAllContacts.reloadData()

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
            // tblMain.reloadData()
            searchContacts(searchText: searchText)
        }else{
            showAlert(strMsg: "Please enter search keyword")
        }
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent // .default
    }
    

}

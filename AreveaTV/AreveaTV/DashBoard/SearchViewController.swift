    //
    //  SearchViewController.swift
    //  AreveaTV
    //
    //  Created by apple on 6/5/20.
    //  Copyright © 2020 apple. All rights reserved.
    //
    
    import UIKit
    import Alamofire
    
    import MaterialComponents.MaterialCollections
    
    class SearchViewController: UIViewController , UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource{
        // MARK: - Variables Declaration
        
        var searchActive : Bool = false
        @IBOutlet weak var searchBar: UISearchBar!
        @IBOutlet weak var viewActivity: UIView!
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        var searchList = [Any]()
        @IBOutlet weak var lblNoData: UILabel!
        var aryFilterCategoriesData : Array<String> = Array()
        var aryFilterSubCategoriesData : Array<String> = Array()
        var aryFilterGenresData : Array<String> = Array()
        @IBOutlet weak var tblFilter: UITableView!
        @IBOutlet weak var mdChipCard:MDCCard!
        var sectionFilters = ["Categories","Sub Categories","Genres"]
        var selectedCells = NSMutableIndexSet()
        @IBOutlet var collectionView: UICollectionView!
        @IBOutlet weak var btnFilter: UIButton!
        var selectedSubCategories = [[String:Any]]();
        var selectedGenres = [[String:Any]]();
        @IBOutlet weak var heightTopView: NSLayoutConstraint?
        @IBOutlet weak var viewTop: UIView!
        
        // MARK: - View LifeCycle
        override func viewDidLoad() {
            super.viewDidLoad()
            
            // Do any additional setup after loading the view.
            viewActivity.isHidden = true
            // Do any additional setup after loading the view.
            self.navigationController?.isNavigationBarHidden = true
            self.searchBar.delegate = self
            tblFilter.register(UINib(nibName: "CheckMarkCell", bundle: nil), forCellReuseIdentifier: "CheckMarkCell")
            let nib = UINib(nibName: "DBSearchCVC", bundle: nil)
            collectionView?.register(nib, forCellWithReuseIdentifier:"DBSearchCVC")
            tblFilter.isHidden = true
            lblNoData.isHidden = false
            lblNoData.text = "Search with any keyword to get data"
            //let searchBar = UISearchBar(frame: CGRect(x: 0, y: 45, width: UIScreen.main.bounds.width, height: 44))
            searchBar.searchBarStyle = .default
            view.addSubview(searchBar)
            
            searchBar.placeholder = "Search with any keyword"
            searchBar.set(textColor: .white)
            searchBar.setTextField(color: UIColor.white.withAlphaComponent(0.3))
            searchBar.setPlaceholder(textColor: .white)
            searchBar.setSearchImage(color: .white)
            searchBar.setClearButton(color: .white)
            
            if(UIDevice.current.userInterfaceIdiom == .pad){
                let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 25.0), NSAttributedString.Key.foregroundColor: UIColor.white]
                UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = attributes
                
            }
            
            appDelegate.strCategory = ""
            btnFilter.isHidden = true;
            if(UIDevice.current.userInterfaceIdiom == .pad){
                heightTopView?.constant = 60;
                viewTop.layoutIfNeeded()
            }
        }
        
        func showAlert(strMsg: String){
            let alert = UIAlertController(title: "Alert", message: strMsg, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true)
        }
        override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
            super.viewWillTransition(to: size, with: coordinator)
            
            if UIDevice.current.orientation.isLandscape {
                print("Landscape")
            } else {
                print("Portrait")
            }
            collectionView.reloadData()
        }
        //MARK:Tableview Delegates and Datasource Methods
        
        func numberOfSections(in tableView: UITableView) ->  Int {
            return 2;
        }
        func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
            if (tableView == tblFilter){
                return 44;
            }
            return 0;
        }
        func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
            if (tableView == tblFilter){
                let view = UIView(frame: CGRect(x: 0, y: 0, width: Int(tableView.bounds.width), height: 44))
                //let darkGreen = UIColor(red: 5, green: 29, blue: 40);
                view.backgroundColor = .darkGray;
                let label = UILabel(frame: CGRect(x: 15, y: 0, width: tableView.bounds.width - 30, height: 44))
                if(UIDevice.current.userInterfaceIdiom == .pad){
                           label.font = UIFont.boldSystemFont(ofSize: 25)
                           }else{
                               label.font = UIFont.boldSystemFont(ofSize: 17)
                           }
                label.textColor = UIColor.orange
                if (section == 0){
                    label.text = "Sub Categories :"
                }else{
                    label.text = "Genre :"
                }
                view.addSubview(label)
                return view
            }
            let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 0))
            return view
        }
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            if (section == 0){
                return aryFilterSubCategoriesData.count;
            }else{
                return aryFilterGenresData.count;
            }
        }
        
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) ->  CGFloat {
            return 50;
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            // let cell = myTableView.dequeueReusableCell(withIdentifier: "DashBoardCell", for: indexPath) as! DashBoardCell
            let cell:CheckMarkCell = self.tblFilter.dequeueReusableCell(withIdentifier: "CheckMarkCell") as! CheckMarkCell
            if (indexPath.section == 0){
                let selectedItem = self.aryFilterSubCategoriesData[indexPath.row]
                cell.lblTitle.text = selectedItem
            }else{
                let selectedItem = self.aryFilterGenresData[indexPath.row]
                cell.lblTitle.text = selectedItem
            }
            cell.imgCheck.tag = (50 * indexPath.section) + (indexPath.row + 1)
            //cell.myImage?.image = UIImage(named:self.imageData[indexPath.row])
            return cell
            
        }
        
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            tableView.deselectRow(at: indexPath, animated: true)
            
            // If it is in the second section, indicate that no item is selected now
            let tag = (50 * indexPath.section) + (indexPath.row + 1)
            let checkImg = tblFilter.viewWithTag(tag) as? UIImageView
            //print("tag:",tag)
            if ((checkImg?.image?.isEqual(UIImage.init(named: "check-icon.png")))!)
            {
                checkImg?.image = UIImage.init(named: "uncheck-icon.png")
                if (indexPath.section == 0){
                    for (i,item) in self.selectedSubCategories.enumerated(){
                        if (item["index"] as! Int == indexPath.row){
                            self.selectedSubCategories.remove(at: i)
                            break
                        }
                    }
                }else if (indexPath.section == 1){
                    for (i,item) in self.selectedGenres.enumerated(){
                        if (item["index"] as! Int == indexPath.row){
                            self.selectedGenres.remove(at: i)
                            break
                        }
                    }
                }
            }
            else{
                checkImg?.image = UIImage.init(named: "check-icon.png")
                if (indexPath.section == 0){
                    let selectedItem = self.aryFilterSubCategoriesData[indexPath.row]
                    let subCategory = selectedItem
                    let strItem = ["index":indexPath.row,"sub_category":subCategory] as [String : Any]
                    selectedSubCategories.append(strItem)
                }else if (indexPath.section == 1){
                    let selectedItem = self.aryFilterGenresData[indexPath.row]
                    let subCategory = selectedItem
                    let strItem = ["index":indexPath.row,"genre":subCategory] as [String : Any]
                    selectedGenres.append(strItem)
                }
            }
            print("selectedSubCategories:",selectedSubCategories)
            print("selectedGenres:",selectedGenres)
            prepareQueryForCloudSearch()
            
        }
        func prepareQueryForCloudSearch() {
            var prepareORQuery = "";
            var query = "";
            var subCategories = ""
            var genres = ""
            
            for (_,item) in self.selectedSubCategories.enumerated(){
                let str = item["sub_category"] as! String
                subCategories += "'" + str + "'";
            }
            for (_,item) in self.selectedGenres.enumerated(){
                let str = item["genre"] as! String
                genres += "'" + str + "'";
            }
            //            subCategories =  subCategories.replacingOccurrences(of: " ", with: "")
            //            genres =  genres.replacingOccurrences(of: " ", with: "")
            if (subCategories == ""){
                subCategories = "''"
            }
            if (genres == ""){
                genres = "''"
            }
            let searchText = (searchBar.text!).lowercased().trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
            
            
            let fields = ["name", "searchkeywords", "streamvideodesc","performer","organizationname","subcategories","category","genres"];
            
            for i in 0...fields.count-1{
                prepareORQuery += "(prefix field=" + fields[i] + " " + "'" + searchText + "'" + ")";
                prepareORQuery += "(term field=" + fields[i] + " " + "'" + searchText + "'" + ")";
            }
            let  category_name = "''";
            query = "(and (and category:" + category_name + ")(and subcategories: " + subCategories + ") (and genres: " + genres + ") (and (or " + prepareORQuery + ")))";
            
            let encodedQuery = query.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed)
            query = encodedQuery!;
            
            query = query.replacingOccurrences(of: "'", with: "%27")
            query = query.replacingOccurrences(of: ":", with: "%3A")
            query = query.replacingOccurrences(of: "=", with: "%3D")
            query = query.replacingOccurrences(of: "/", with: "%252F")
            query = "?q=" + query
            query += "&q.parser=structured";
            query += "&size=500";
            
            print("query_category:",query);
            getSearchResults(searchString: query, isQuery: true)
        }
        // MARK: Handler for getCategoryOrganisations API
        func getSearchResults(searchString:String,isQuery:Bool){
            let baseURL = "https://3ptsrb2obj.execute-api.us-east-1.amazonaws.com/dev/"
            var url = ""
            if (isQuery){
                url = baseURL + searchString
            }else{
                //url = url.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed)!
                let customAllowedSet =  NSCharacterSet(charactersIn:"=\"#%/<>?@\\^`{|} ").inverted
                let encodedSearch = searchString.lowercased().addingPercentEncoding(withAllowedCharacters: customAllowedSet) ?? ""
                url = baseURL + "?q=" + encodedSearch + "*"
                url = url.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed)!
                
            }
            
            
            print("url:",url)
            viewActivity.isHidden = false
            //print("getCategoryOrganisations input:",inputData)
            let headers: HTTPHeaders
            headers = [appDelegate.securityKey: appDelegate.securityValue]
            AF.request(url, method: .get,encoding: JSONEncoding.default,headers:headers)
                .responseJSON { response in
                    self.viewActivity.isHidden = true
                    self.tblFilter.isHidden = true
                    self.btnFilter.isHidden = false;
                    if (!isQuery){
                        self.selectedSubCategories = [[String:Any]]();
                        self.selectedGenres = [[String:Any]]();
                    }
                    switch response.result {
                    case .success(let value):
                        if let json = value as? [String: Any] {
                            print("getSearchResults json:",json)
                            let resultObj = json["hits"] as? [String: Any]
                            let hitArray = resultObj?["hit"] as? [Any] ?? [Any]();
                            //print("--count:",self.searchList.count )
                            self.searchList = []
                            for (index,_) in hitArray.enumerated(){
                                let element = hitArray[index] as? [String: Any]
                                let fields = element?["fields"]
                                self.searchList.append(fields ?? [Any]())
                            }
                            if (!isQuery){
                                self.aryFilterCategoriesData = []
                                self.aryFilterSubCategoriesData = []
                                self.aryFilterGenresData = []
                                for (index,_) in self.searchList.enumerated(){
                                    let element = self.searchList[index] as? [String: Any]
                                    let category = element?["category"] as? [Any] ?? [Any]()
                                    let subCategory = element?["subcategories"]as? [Any] ?? [Any]()
                                    let genre = element?["genres"]as? [Any] ?? [Any]()
                                    for (i,_) in category.enumerated(){
                                        let categoryObj = category[i] as? String ?? ""
                                        self.aryFilterCategoriesData.append(categoryObj)
                                    }
                                    for (j,_) in subCategory.enumerated(){
                                        let subCategoryObj = subCategory[j] as? String ?? ""
                                        self.aryFilterSubCategoriesData.append(subCategoryObj)
                                    }
                                    for (k,_) in genre.enumerated(){
                                        let genreObj = genre[k] as? String ?? ""
                                        self.aryFilterGenresData.append(genreObj)
                                    }
                                }
                                //for get Unique values from Array
                                self.aryFilterCategoriesData = Array(Set(self.aryFilterCategoriesData))
                                self.aryFilterSubCategoriesData = Array(Set(self.aryFilterSubCategoriesData))
                                self.aryFilterGenresData = Array(Set(self.aryFilterGenresData))
                                self.lblNoData.text = "Your search did not match with any documents.\n\n1. Make sure that all words spelled correctly.\n2. Try with different key words."
                                self.lblNoData.textAlignment = .left
                                self.tblFilter.reloadData()
                            }else{
                                self.lblNoData.textAlignment = .center
                                self.lblNoData.text = "No results found with selected filter"
                            }
                            
                            if (self.searchList.count > 0){
                                self.lblNoData.isHidden = true;
                            }else{
                                self.lblNoData.isHidden = false;
                                if(!isQuery){
                                    self.btnFilter.isHidden = true;
                                }
                            }
                            self.collectionView.reloadData()
                        }
                    //searchList
                    case .failure(let error):
                        print(error.localizedDescription)
                        self.showAlert(strMsg: "Error occured. Please try again later")
                    }
            }
        }
        
        @IBAction func back(_ sender: Any) {
            self.navigationController?.popViewController(animated: true);
        }
        // MARK: Filter Events
        @IBAction func openFilter(_ sender: Any) {
            
            if(tblFilter.isHidden){
                tblFilter.isHidden = false;
            }else{
                tblFilter.isHidden = true;
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
        //MARK: UISearchbar delegate
       
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
            
            
            //self.tblMain.reloadData()
        }
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            if searchText.isEmpty {
                //when user press X icon
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    searchBar.resignFirstResponder()
                }
                searchActive = false;
                //self.tblMain.reloadData()
            }
        }
        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            searchBar.resignFirstResponder()
            let searchString = searchBar.text!.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
            if (searchString.count > 0){
                searchActive = true;
                getSearchResults(searchString: searchString, isQuery: false)
                //print("--count:",aryFilteredSubCategories.count)
                // tblMain.reloadData()
            }else{
                showAlert(strMsg: "Please enter search keyword")
            }
        }
        override var preferredStatusBarStyle: UIStatusBarStyle {
            return .lightContent // .default
        }
        
    }
    
    extension SearchViewController:UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout
    {
        //MARK: collectionView Data Source and Delegates
        
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            _ = collectionView.cellForItem(at: indexPath) as? DBCollectionViewCell
            let searchItem = searchList[indexPath.item] as! [String: Any]
            let type = searchItem["type"]as? String;
            print("searchItem:",searchItem)
            print("type:",type ?? "")
            switch type {
            case "stream":
                let storyboard = UIStoryboard(name: "Main", bundle: nil);
                let vc = storyboard.instantiateViewController(withIdentifier: "ChannelDetailVC") as! ChannelDetailVC
                let streamId = searchItem["id"] as? String ?? "0"
                vc.streamId = Int(streamId) ?? 0
                appDelegate.isLiveLoad = "1"
                appDelegate.detailToShow = "stream"
                let performerId = searchItem["performerid"] as? String ?? "0"
                vc.performerId = Int(performerId) ?? 0
                vc.strTitle = searchItem["performer"] as? String ?? "Channel Details"
                self.navigationController?.pushViewController(vc, animated: true)
            case "performer":
                let storyboard = UIStoryboard(name: "Main", bundle: nil);
                let vc = storyboard.instantiateViewController(withIdentifier: "ChannelDetailVC") as! ChannelDetailVC
                let streamId = searchItem["id"] as? String ?? "0"
                vc.streamId = Int(streamId) ?? 0
                appDelegate.isLiveLoad = "1"
                appDelegate.detailToShow = "performer"
                let performerId = searchItem["performerid"] as? String ?? "0"
                vc.performerId = Int(performerId) ?? 0
                vc.strTitle = searchItem["performer"] as? String ?? "Channel Details"
                self.navigationController?.pushViewController(vc, animated: true)
            case "video":
                let storyboard = UIStoryboard(name: "Main", bundle: nil);
                let vc = storyboard.instantiateViewController(withIdentifier: "ChannelDetailVC") as! ChannelDetailVC
                let streamId = searchItem["id"] as? String ?? "0"
                vc.streamId = Int(streamId) ?? 0
                appDelegate.isLiveLoad = "1"
                appDelegate.detailToShow = "video"
                let performerId = searchItem["performerid"] as? String ?? "0"
                vc.performerId = Int(performerId) ?? 0
                vc.strTitle = searchItem["performer"] as? String ?? "Channel Details"
                self.navigationController?.pushViewController(vc, animated: true)
            case "audio":
                let storyboard = UIStoryboard(name: "Main", bundle: nil);
                let vc = storyboard.instantiateViewController(withIdentifier: "ChannelDetailVC") as! ChannelDetailVC
                let streamId = searchItem["id"] as? String ?? "0"
                vc.streamId = Int(streamId) ?? 0
                appDelegate.isLiveLoad = "1"
                appDelegate.detailToShow = "audio"
                let performerId = searchItem["performerid"] as? String ?? "0"
                vc.performerId = Int(performerId) ?? 0
                vc.strTitle = searchItem["performer"] as? String ?? "Channel Details"
                self.navigationController?.pushViewController(vc, animated: true)
            case "organization":
                let storyboard = UIStoryboard(name: "Main", bundle: nil);
                let vc = storyboard.instantiateViewController(withIdentifier: "ChannelsVC") as! ChannelsVC
                let orgId = searchItem["id"] as? String ?? "0"
                vc.orgId = Int(orgId) ?? 0
                vc.organizationName = searchItem["organizationname"] as? String ?? ""
                self.navigationController?.pushViewController(vc, animated: true)
            case "category":
                appDelegate.strCategory = searchItem["name"] as? String ?? "0"
                for controller in self.navigationController!.viewControllers as Array {
                    if controller.isKind(of: DashBoardVC.self) {
                        self.navigationController!.popToViewController(controller, animated: true)
                        break
                    }
                }
            case "subCategory":
                appDelegate.strCategory = searchItem["name"] as? String ?? "0"
                for controller in self.navigationController!.viewControllers as Array {
                    if controller.isKind(of: DashBoardVC.self) {
                        self.navigationController!.popToViewController(controller, animated: true)
                        break
                    }
                }
            case "genre":
                let genreId = searchItem["id"] as? String ?? "0"
                appDelegate.genreId = Int(genreId) ?? 0
                let subcategories = searchItem["subcategories"] as? [Any] ?? [Any]()
                if (subcategories.count > 0){
                    appDelegate.strCategory = subcategories[0] as? String ?? ""
                }
                //print("genreId:",appDelegate.genreId)
                for controller in self.navigationController!.viewControllers as Array {
                    if controller.isKind(of: DashBoardVC.self) {
                        self.navigationController!.popToViewController(controller, animated: true)
                        break
                    }
                }
            default:
                break
            }
        }
        func numberOfSections(in collectionView: UICollectionView) -> Int {
            return 1
        }
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return self.searchList.count
        }
        
        // Set the data for each cell (color and color name)
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DBSearchCVC",for: indexPath) as? DBSearchCVC {
                let searchItem = searchList[indexPath.row] as! [String: Any]
                let thumbNail = UIImage.init(named: "default-img1.jpg")
                cell.imgCategory.image = thumbNail
                cell.imgCategory.contentMode = .scaleAspectFill
                cell.nameLabel.text = searchItem["name"]as? String;
                let type = searchItem["type"]as? String;
                //print("type:",type)
                switch type {
                case "stream":
                    cell.imgType.image = UIImage.init(named: "sr_stream.png")
                case "performer":
                    cell.imgType.image = UIImage.init(named: "sr_performer.png")
                case "video":
                    cell.imgType.image = UIImage.init(named: "sr_video.png")
                case "audio":
                    cell.imgType.image = UIImage.init(named: "sr_audio.png")
                case "organization":
                    cell.imgType.image = UIImage.init(named: "sr_organization.png")
                default:
                    cell.imgType.image = UIImage.init(named: "sr_category.png")
                    break
                }
                return cell
            }
            return UICollectionViewCell()
        }
        // Add spaces at the beginning and the end of the collection view
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
            return UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        }
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            let width = self.view.frame.size.width/2 - 10
            //print("width:",width)
            if(UIDevice.current.userInterfaceIdiom == .pad){
                return CGSize(width: width, height: 230.0)
            }else{
                return CGSize(width: width, height: 180.0)
            }
        }
        
    }
    

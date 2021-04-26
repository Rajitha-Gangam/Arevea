//
//  TicketTypesVC.swift
//  AreveaTV
//
//  Created by apple on 12/22/20.
//  Copyright © 2020 apple. All rights reserved.
//

import UIKit
import Alamofire

class TicketTypesVC: UIViewController,UITableViewDataSource,UITableViewDelegate,OpenChanannelChatDelegate,UIPickerViewDelegate, UIPickerViewDataSource{
    // MARK: - Variables Declaration
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var viewDropDown: UIView!
    
    @IBOutlet weak var tblTicketTypes: UITableView!
    var currency_type = ""
    var strTicketType = ""
    var strPrice = ""
    var strTicketIDs = ""

    var rowHeight = 160
    var isCameFromGetTickets = false

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var aryStreamInfo = [String: Any]()
    var aryTicketsData = [Any]()
    
    var pickerData =  ["0", "1"];
    var selectedTicketData = [Any]()
    @IBOutlet weak var tblheight: NSLayoutConstraint!
    @IBOutlet weak var heightTopView: NSLayoutConstraint?
    @IBOutlet weak var viewContentHeight: NSLayoutConstraint!

    @IBOutlet weak var viewTop: UIView!
    @IBOutlet weak var viewActivity: UIView!
    var aryUserSubscriptionInfo = [Any]()
    weak var chatDelegate: OpenChanannelChatDelegate?
    var currencySymbol = ""
    var jsonCurrencyList = [String:Any]()
    @IBOutlet weak var btnCancel: UIButton!
    var number_of_creators = 1
    var isUserSubscribe = false
    
    var aryCurrencyKeys = [String]()
    var aryCurrencyValues = [Any]()
    var aryDisplayCurrencies = [Any]()
    var doubleDisplayCurrencies = [Double]()
    @IBOutlet weak var txtFirstName: UITextField!
    @IBOutlet weak var txtLastName: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var viewGuest: UIView!
    @IBOutlet weak var viewGuestheight: NSLayoutConstraint!
    @IBOutlet weak var btnProceed: UIButton!
    @IBOutlet weak var btnRegister: UIButton!
    @IBOutlet weak var viewContent: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollViewHeight: NSLayoutConstraint!
    var event_id = 0
    var access_token = ""
    var strSlug = "";
    var selectedTicketIndex = -1
    var isSelectedTicket = false
    var selectedTicketValue = "0"
    var aryQuestions = [Any]()
    var dicSold = [String:Any]()
    
    // MARK: - View Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        txtFirstName.backgroundColor = .clear;
        txtLastName.backgroundColor = .clear;
        txtEmail.backgroundColor = .clear;
        lblTitle.text = "   " + appDelegate.strTitle
        // Do any additional setup after loading the view.
        tblTicketTypes.register(UINib(nibName: "TicketTypesCell", bundle: nil), forCellReuseIdentifier: "TicketTypesCell")
        
        print("aryTicketsData:",aryTicketsData)
        for(index,_)in self.aryTicketsData.enumerated(){
            var ticketInfo = self.aryTicketsData[index] as? [String : Any] ?? [String:Any]()
            let event_id1 = ticketInfo["event_id"]as? Int ?? 0
            let sessions = ticketInfo["sessions"] as? [Any] ?? [Any]()
            
            if(sessions.count > 0){
            for(jIndex,_)in sessions.enumerated(){
                let sessionId = sessions[jIndex] as? Int ?? 0
                if(event_id1 == sessionId){
                    ticketInfo["allSessions"] = true
                }
                if (self.aryUserSubscriptionInfo.count > 0){
                    let userSubscription = self.aryUserSubscriptionInfo[0] as? [String : Any] ?? [:];
                    let aryTicketIds = userSubscription["ticket_ids"] as? [Any] ?? [Any]()
                    for(kIndex,_)in aryTicketIds.enumerated(){
                        let ticketId = aryTicketIds[kIndex] as? Int ?? 0
                        if(sessionId == ticketId){
                            ticketInfo["disableTickets"] = true
                        }
                    }
                }
                self.aryTicketsData[index] = ticketInfo
            }
            }else{
                ticketInfo["allSessions"] = true
                if (self.aryUserSubscriptionInfo.count > 0){
                    let userSubscription = self.aryUserSubscriptionInfo[0] as? [String : Any] ?? [:];
                    let aryTicketIds = userSubscription["ticket_ids"] as? [Any] ?? [Any]()
                    for(kIndex,_)in aryTicketIds.enumerated(){
                        let ticketId = aryTicketIds[kIndex] as? Int ?? 0
                        if(event_id1 == ticketId){
                            ticketInfo["disableTicket"] = true
                        }
                    }
                }
            }
        }
        if let path = Bundle.main.path(forResource: "currencies", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResult = jsonResult as? Dictionary<String, AnyObject>
                {
                    // do stuff
                    jsonCurrencyList = jsonResult
                }
            } catch {
                // handle error
            }
        }
        btnCancel.layer.borderColor = UIColor.white.cgColor
        addDoneButton()
        //Free event and guest
        if (appDelegate.streamPaymentMode.lowercased() == "free" && appDelegate.isGuest){
            let  amountWithCurrencyType = self.currencySymbol + "0.00"
            //lblPrice.text = amountWithCurrencyType
        }else{
            //paid event
            //for guest
            if(appDelegate.isGuest){
                viewGuest.isHidden = true
                viewGuestheight.constant = 220
                viewGuest.layoutIfNeeded()
            }
            //paid but not guest
            else{
                viewGuest.isHidden = true
                viewGuestheight.constant = 0
                viewGuest.layoutIfNeeded()
                
            }
            
        }
        btnRegister.isHidden = true
        self.selectedTicketData = []
        // print("==aryTicketsData:",self.aryTicketsData)
        for(j,_)in self.aryTicketsData.enumerated(){
            self.selectedTicketData.append(["index":"0"])
        }
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true);
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name:UIApplication.didBecomeActiveNotification , object: nil)
        NotificationCenter.default.removeObserver(self)
    }
    @IBAction func cancelTapped(_ sender: Any) {
        viewDropDown.isHidden = true
    }
    @IBAction func doneTapped(_ sender: Any) {
        viewDropDown.isHidden = true
        if(isSelectedTicket){
            selectedTicketData[selectedTicketIndex] = ["index":selectedTicketValue]
            if (selectedTicketValue == "1"){
                let ticketInfo = self.aryTicketsData[selectedTicketIndex] as? [String : Any] ?? [String:Any]()
                let ticket_type_name = ticketInfo["title"]as? String ?? ""
                strTicketType = ticket_type_name
                self.event_id = ticketInfo["event_id"]as? Int ?? 0
                let ticketId = ticketInfo["id"]as? Int ?? 0
                strTicketIDs = "&ticket_ids=" + String(ticketId)
                print("->event_id:",event_id)
                print("->ticketId:",ticketId)

                let aryAmounts = ticketInfo["amounts"] as? [Any] ?? [Any]()
                // print("stream_amounts:",stream_amounts)
                //print("isUserSubscribe:",isUserSubscribe)
                    // print("==dicAmounts1:",aryAmounts)
                    var aryCurrencies = [String]()
                    
                    for(j,_)in aryAmounts.enumerated(){
                        let amountObject = aryAmounts[j] as? [String : Any] ?? [String:Any]()
                        if(isUserSubscribe && !appDelegate.isGuest){
                            var strAmount = "0.00"
                            if (amountObject["subscriber"] as? Double) != nil {
                                strAmount = String(amountObject["subscriber"] as? Double ?? 0.00)
                            }else if (amountObject["subscriber"] as? String) != nil {
                                strAmount = String(amountObject["subscriber"] as? String ?? "0.00")
                            }
                            let doubleAmount = Double(strAmount)
                            let amount = String(format: "%.02f", doubleAmount!)
                            
                            aryCurrencies.append(amount)
                            // print("==amounts1:",amount)
                        }else{
                            var strAmount = "0.00"
                            if (amountObject["non_subscriber"] as? Double) != nil {
                                strAmount = String(amountObject["non_subscriber"] as? Double ?? 0.00)
                            }else if (amountObject["non_subscriber"] as? String) != nil {
                                strAmount = String(amountObject["non_subscriber"] as? String ?? "0.00")
                            }
                            let doubleAmount = Double(strAmount)
                            let amount = String(format: "%.02f", doubleAmount!)
                            
                            aryCurrencies.append(amount)
                            // print("==amounts1:",amount)
                        }
                    }
                    var doubleDisplayCurrencies = [Double]()
                    doubleDisplayCurrencies = aryCurrencies.compactMap(Double.init)//["5.00","100.00"] to [5,1000]
                    doubleDisplayCurrencies.sort(by: <)//sort ascending
                    if(doubleDisplayCurrencies.count > 0){
                        let firstValue = String(format: "%.02f",doubleDisplayCurrencies[0])
                        let lastValue = String(format: "%.02f",doubleDisplayCurrencies[doubleDisplayCurrencies.count - 1]);
                        let amountDisplay = self.currencySymbol + firstValue + " - " + self.currencySymbol + lastValue;
                        // ////print("====amount in Dollars:",amountDisplay)
                        var amountWithCurrencyType = ""
                        if(firstValue == lastValue){
                            amountWithCurrencyType = self.currencySymbol + firstValue
                        }else{
                            amountWithCurrencyType = amountDisplay
                        }
                        strPrice = amountWithCurrencyType
                    }
            }else{
                strTicketType = ""
            }
            tblTicketTypes.reloadData()
        }
    }
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    func showAlert(strMsg: String){
        let alert = UIAlertController(title: "Alert", message: strMsg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
    // continue button pressed action
    @IBAction func proceedPressed(_ sender: UIButton){
        resignKB(sender)
        let netAvailable = appDelegate.isConnectedToInternet()
        if(!netAvailable){
            showAlert(strMsg: "Please check your internet connection!")
            return
        }
        var ticketSelected = false
        for(j,_)in self.selectedTicketData.enumerated(){
            var selectedObj = selectedTicketData[j] as? [String:Any] ?? [String:Any]()
            var ticketValue = selectedObj["index"] as! String
            if(ticketValue == "1")
            {
                ticketSelected = true
                break
            }
        }
        if(appDelegate.isGuest){
            if (appDelegate.streamPaymentMode.lowercased() != "free"){
                if(ticketSelected){
                    getUserByEmail()
                }else{
                    showAlert(strMsg: "Please select atleast one ticket")
                }
            }else{
                getUserByEmail()
            }
        }else{
            if(ticketSelected){
                getQuestionsByEventId()
            }else{
                showAlert(strMsg: "Please select atleast one ticket")
            }
        }
        
    }
    // register button pressed action
    @IBAction func register(_ sender: UIButton){
        resignKB(sender)
        let netAvailable = appDelegate.isConnectedToInternet()
        if(!netAvailable){
            showAlert(strMsg: "Please check your internet connection!")
            return
        }
       /* if(appDelegate.isGuest && appDelegate.streamPaymentMode == "Free"){
            registerEvent()
        }else if(appDelegate.isGuest && appDelegate.streamPaymentMode != "Free"){
            self.getQuestionsByEventId()
        }*/
        self.getQuestionsByEventId()
        
    }
    func getQuestionsByEventId(){
        let netAvailable = appDelegate.isConnectedToInternet()
        if(!netAvailable){
            showAlert(strMsg: "Please check your internet connection!")
            return
        }
        viewActivity.isHidden = false
        let url: String = appDelegate.baseURL +  "/getQuestionsByEventId/" + String(appDelegate.streamId)
        
        print("getQuestionsByEventId url:",url)
        let headers: HTTPHeaders
        headers = [appDelegate.x_api_key: appDelegate.x_api_value]
        AF.request(url, method: .get, encoding: JSONEncoding.default,headers:headers)
            .responseJSON { response in
                self.viewActivity.isHidden = true
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any] {
                        print("getQuestionsByEventId JSON:",json)
                        if (json["statusCode"]as? String == "200" ){
                            self.aryQuestions = json["Data"] as? [Any] ?? [Any]()
                            if(self.aryQuestions.count > 0){
                                self.gotoQuestions()
                            }else{
                                if(self.appDelegate.streamPaymentMode.lowercased() == "free"){
                                    self.registerEvent()
                                }else{
                                    self.gotoOrderSummary()
                                }
                            }
                        }else{
                            let strMsg = json["message"] as? String ?? ""
                            self.showAlert(strMsg: strMsg)
                        }
                    }
                case .failure(let error):
                    let errorDesc = error.localizedDescription.replacingOccurrences(of: "URLSessionTask failed with error:", with: "")
                    self.showAlert(strMsg: errorDesc)
                    self.viewActivity.isHidden = true
                    
                }
            }
    }
    func gotoQuestions(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil);
        let streamInfo = self.aryStreamInfo
        
        let stream_video_title = streamInfo["stream_video_title"] as? String ?? "Channel Details"
        appDelegate.isLiveLoad = "1"
        let vc = storyboard.instantiateViewController(withIdentifier: "QuestionsVC") as! QuestionsVC
        vc.chatDelegate = self
        appDelegate.strTitle = stream_video_title
        //vc.isCameFromGetTickets = true
        vc.aryQuestions = aryQuestions
        vc.strTicketName = strTicketType
        vc.strPrice = strPrice
        vc.strTicketIDs = strTicketIDs
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func gotoOrderSummary(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil);
        let streamInfo = self.aryStreamInfo
        
        let stream_video_title = streamInfo["stream_video_title"] as? String ?? "Channel Details"
        appDelegate.isLiveLoad = "1"
        let vc = storyboard.instantiateViewController(withIdentifier: "OrderSummaryVC") as! OrderSummaryVC
        vc.chatDelegate = self
        appDelegate.strTitle = stream_video_title
        //vc.isCameFromGetTickets = true
        vc.strTicketName = strTicketType
        vc.strPrice = strPrice
        vc.strTicketIDs = strTicketIDs
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func proceedToPayment(){
        //let url: String = appDelegate.baseURL +  "/proceedToPayment"
        //var user_id
        
        
        let user_id = UserDefaults.standard.string(forKey: "user_id");
        let strUserId = user_id ?? "1"
        var encoded_ticket_type_name = strTicketType
        
        encoded_ticket_type_name = encoded_ticket_type_name.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed) ?? ""
        encoded_ticket_type_name = encoded_ticket_type_name.replacingOccurrences(of: "'", with: "%27")
        encoded_ticket_type_name = encoded_ticket_type_name.replacingOccurrences(of: ":", with: "%3A")
        encoded_ticket_type_name = encoded_ticket_type_name.replacingOccurrences(of: "=", with: "%3D")
        encoded_ticket_type_name = encoded_ticket_type_name.replacingOccurrences(of: "/", with: "%252F")
        
        var queryString = "stream_id=" + String(appDelegate.streamId) + "&user_id=" + strUserId + "&ticket_type_name=" + encoded_ticket_type_name//ppv
        if(appDelegate.isGuest){
            queryString = queryString + "&is_guest=1&" + "token=" + access_token
        }
        // print("queryString:",queryString)
        
        let urlOpen = appDelegate.paymentRedirectionURL + "/" + "pay_per_view" + "?" + queryString
        guard let url = URL(string: urlOpen) else { return }
        // print("url to open:",url)
        UIApplication.shared.open(url)
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent // .default
    }
    func addDoneButton() {
        let toolbar =  UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 35))
        
        let flexButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action:#selector(resignKB(_:)))
        toolbar.setItems([flexButton, doneButton], animated: true)
        toolbar.sizeToFit()
        txtFirstName.inputAccessoryView = toolbar;
        txtLastName.inputAccessoryView = toolbar;
        txtEmail.inputAccessoryView = toolbar;
    }
    @IBAction func resignKB(_ sender: Any) {
        txtFirstName.resignFirstResponder();
        txtLastName.resignFirstResponder();
        txtEmail.resignFirstResponder();
    }
    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: txtEmail.text)
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    func convertToArray(text: String) -> [Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [Any]
            } catch {
                //////print(error.localizedDescription)
            }
        }
        return nil
    }
    var disableTickets = false;
    @objc func selectTicket(_ sender: UIButton) {
        
        /*selectedTicketIndex = sender.tag
        for(index,_)in self.aryTicketsData.enumerated(){
            let ticketsObj = aryTicketsData[index] as? [String:Any] ?? [String:Any]()
            var selectedTicketsObj = aryTicketsData[selectedTicketIndex] as? [String:Any] ?? [String:Any]()
            let id = ticketsObj["id"] as? Int
            let selectedObjId = selectedTicketsObj["id"] as? Int
            if(id == selectedObjId && selectedTicketValue == "1"){
                selectedTicketsObj["isTicketSelected"] = true
                disableTickets = true
            }else if(id == selectedObjId && selectedTicketValue == "0"){
                disableTickets = false
            }
            let ticketsSelected = ticketsObj["isTicketSelected"] as? Bool ?? false
            if (id == selectedObjId && selectedTicketValue == "1"){
            selectedTicketsObj["isTicketSelected"] = true;
            }else if (id == selectedObjId && selectedTicketValue == "0" &&  ticketsSelected){
                selectedTicketsObj["isTicketSelected"] = false;
            }
            

        }
            let ticketsObj = aryTicketsData[selectedTicketIndex] as? [String:Any] ?? [String:Any]()
            let ticketsSelected = ticketsObj["isTicketSelected"] as? Bool ?? false
            let limitedTickets = ticketsObj["limited_tickets"] as? Int ?? 0
            let ticketStatus = ticketsObj["status"]as? Int ?? 0
            let ticketInventory = ticketsObj["inventory"]as? Int ?? 0


            
            if((!ticketsSelected) || (limitedTickets == 1 && ticketInventory == 0 && ticketStatus == 0)){
                print("disable")
            }else{
            print("enable")
            }*/
        let ticketInfo = aryTicketsData[sender.tag] as? [String:Any] ?? [String:Any]()

        let allSessions = ticketInfo["allSessions"] as? Bool ?? false
        let disableTickets = ticketInfo["disableTickets"] as? Bool ?? false

       let stringSold = dicSold[String(sender.tag)]
        let sold = stringSold as? String ?? ""
        if((disableTickets && !allSessions) || sold == "sold"){
            return
        }
        
        /*for(index,_)in self.selectedTicketData.enumerated(){
            let selectedObj = selectedTicketData[index] as? [String:Any] ?? [String:Any]()
            let value = selectedObj["index"] as! String
            if(value == "1"){
                return
            }
            
        }*/
        print("ticketSelect:",sender.tag)
        viewDropDown.isHidden = false
        selectedTicketIndex = sender.tag
        isSelectedTicket = false
        
        var selectedObj = selectedTicketData[selectedTicketIndex] as? [String:Any] ?? [String:Any]()
        
        var btnTitle = selectedObj["index"] as! String
        print("btnTitle:",btnTitle)
        if(btnTitle == "1"){
            pickerView.selectRow(1, inComponent: 0, animated: true)
        }else{
            pickerView.selectRow(0, inComponent: 0, animated: true)
        }
        viewDropDown.isHidden = false

        
    }
    //MARK:Tableview Delegates and Datasource Methods
    
    func numberOfSections(in tableView: UITableView) ->  Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(appDelegate.isGuest){
            viewGuest.isHidden = false
            viewGuestheight.constant = 220
            viewGuest.layoutIfNeeded()
        }
//        viewContentHeight.constant = CGFloat((rowHeight * aryTicketsData.count) + 330)
//        scrollViewHeight.constant = CGFloat((rowHeight * aryTicketsData.count) + 330)
//
//        viewContent.layoutIfNeeded()
//        scrollView.layoutIfNeeded()
        if(appDelegate.streamPaymentMode.lowercased() == "free"){
            tblheight.constant = 0
            self.tblTicketTypes.layoutIfNeeded()
            return 0
        }else{
            tblheight.constant = CGFloat(rowHeight * aryTicketsData.count)
            self.tblTicketTypes.layoutIfNeeded()
            return aryTicketsData.count
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) ->  CGFloat {
        return CGFloat(rowHeight);
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TicketTypesCell") as! TicketTypesCell
        cell.backgroundColor = UIColor.clear
        let ticketInfo = self.aryTicketsData[indexPath.row] as? [String : Any] ?? [String:Any]()
        let ticket_type_name = ticketInfo["title"]as? String ?? ""
        
        cell.btnSelect.addTarget(self, action: #selector(selectTicket(_:)), for: .touchUpInside)
        cell.btnSelect1.addTarget(self, action: #selector(selectTicket(_:)), for: .touchUpInside)

        cell.btnSelect.tag = indexPath.row
        cell.btnSelect1.tag = indexPath.row

        let selectedObj = selectedTicketData[indexPath.row] as? [String:Any] ?? [String:Any]()
        print("selectedObj:",selectedObj)
        var btnTitle = selectedObj["index"] as! String
        btnTitle = "   " + btnTitle
        cell.btnSelect.setTitle(btnTitle, for:.normal)
        
        cell.lblTitle.text = ticket_type_name
        let allSessions = ticketInfo["allSessions"] as? Bool ?? false

        if(allSessions){
            cell.lblTitle.text = ticket_type_name + "  (all days)"
        }
        cell.imgCheck.image = UIImage.init(named: "check")
//        if(indexSelectedTicketType == indexPath.row){
//            cell.imgCheck.image = UIImage.init(named: "checked-green")
//        }
        let start_date = ticketInfo["start_date"] as? String ?? "";
        let end_date = ticketInfo["end_date"] as? String ?? "";
        
        let formatter = DateFormatter()
        formatter.timeZone = NSTimeZone(abbreviation: "UTC") as TimeZone?
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if let startDate = formatter.date(from: start_date){
            // print("startDate:",startDate)
            if let endDate = formatter.date(from: end_date){
                formatter.dateFormat =  "dd MMM yyyy"
                let strStartDate = formatter.string(from: startDate)
                let strEndDate = formatter.string(from: endDate)
                //  print("endDate:",endDate)
                if (startDate == endDate){
                    cell.lblDate.text = strStartDate
                }else{
                    cell.lblDate.text = strStartDate + " - " + strEndDate
                }
            }
        }
        let limitedTickets = ticketInfo["limited_tickets"] as? Int ?? 0
        let ticketStatus = ticketInfo["status"]as? Int ?? 0
        let ticketInventory = ticketInfo["inventory"]as? Int ?? 0

        if((limitedTickets == 0 &&  ticketStatus == 1) || (limitedTickets == 1 && ticketStatus == 1 && ticketInventory > 0)){
            cell.lblSaleEnds.text = ticketInfo["message"] as? String ?? ""
        }else if(limitedTickets == 1 && ticketInventory == 0 && ticketStatus == 0){
            cell.lblSaleEnds.text = "Sold out"
            dicSold[String(indexPath.row)] = "sold"
            
        }
        cell.txtDesc.text = ticketInfo["description"] as? String ?? ""
        let aryAmounts = ticketInfo["amounts"] as? [Any] ?? [Any]()
        // print("stream_amounts:",stream_amounts)
        //print("isUserSubscribe:",isUserSubscribe)
            // print("==dicAmounts1:",aryAmounts)
            var aryCurrencies = [String]()
            
            for(j,_)in aryAmounts.enumerated(){
                let amountObject = aryAmounts[j] as? [String : Any] ?? [String:Any]()
                if(isUserSubscribe && !appDelegate.isGuest){
                    var strAmount = "0.00"
                    if (amountObject["subscriber"] as? Double) != nil {
                        strAmount = String(amountObject["subscriber"] as? Double ?? 0.00)
                    }else if (amountObject["subscriber"] as? String) != nil {
                        strAmount = String(amountObject["subscriber"] as? String ?? "0.00")
                    }
                    let doubleAmount = Double(strAmount)
                    let amount = String(format: "%.02f", doubleAmount!)
                    
                    aryCurrencies.append(amount)
                    // print("==amounts1:",amount)
                }else{
                    var strAmount = "0.00"
                    if (amountObject["non_subscriber"] as? Double) != nil {
                        strAmount = String(amountObject["non_subscriber"] as? Double ?? 0.00)
                    }else if (amountObject["non_subscriber"] as? String) != nil {
                        strAmount = String(amountObject["non_subscriber"] as? String ?? "0.00")
                    }
                    let doubleAmount = Double(strAmount)
                    let amount = String(format: "%.02f", doubleAmount!)
                    
                    aryCurrencies.append(amount)
                    // print("==amounts1:",amount)
                }
            }
            var doubleDisplayCurrencies = [Double]()
            doubleDisplayCurrencies = aryCurrencies.compactMap(Double.init)//["5.00","100.00"] to [5,1000]
            doubleDisplayCurrencies.sort(by: <)//sort ascending
            if(doubleDisplayCurrencies.count > 0){
                let firstValue = String(format: "%.02f",doubleDisplayCurrencies[0])
                let lastValue = String(format: "%.02f",doubleDisplayCurrencies[doubleDisplayCurrencies.count - 1]);
                let amountDisplay = self.currencySymbol + firstValue + " - " + self.currencySymbol + lastValue;
                // ////print("====amount in Dollars:",amountDisplay)
                var amountWithCurrencyType = ""
                if(firstValue == lastValue){
                    amountWithCurrencyType = self.currencySymbol + firstValue
                }else{
                    amountWithCurrencyType = amountDisplay
                }
                cell.lblAmount.text = amountWithCurrencyType
                
            }
        
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    func gotoStreamDetails(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil);
        appDelegate.isLiveLoad = "1"
        let vc = storyboard.instantiateViewController(withIdentifier: "StreamDetailVC") as! StreamDetailVC
        vc.chatDelegate = self
        vc.isCameFromGetTickets = true
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    @objc func applicationDidBecomeActive(notification: NSNotification) {
        // Application is back in the foreground
        print("====applicationDidBecomeActive TT")
        //if user comes from payment redirection, need to refresh stream/vod
        getEventBySlug()
    }
    func LiveEventById() {
        viewActivity.isHidden = false
        let netAvailable = appDelegate.isConnectedToInternet()
        if(!netAvailable){
            showAlert(strMsg: "Please check your internet connection!")
            return
        }
        let url: String = appDelegate.baseURL +  "/LiveEventById"
        let user_id = UserDefaults.standard.string(forKey: "user_id");
        var streamIdLocal = "0"
        if (appDelegate.streamId != 0){
            streamIdLocal = String(appDelegate.streamId)
        }
        let headers: HTTPHeaders
        headers = [appDelegate.x_api_key: appDelegate.x_api_value]
        
        let params: [String: Any] = ["userid":user_id ?? "","performer_id":appDelegate.performerId,"stream_id": streamIdLocal]
        // print("liveEvents params:",params)
        // let params: [String: Any] = ["userid":user_id ?? "","performer_id":"101","stream_id": "0"]
        AF.request(url, method: .post,parameters: params, encoding: JSONEncoding.default,headers:headers)
            .responseJSON { [self] response in
                self.viewActivity.isHidden = true
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any] {
                        //print("myList JSON:",json)
                        if (json["statusCode"]as? String == "200" ){
                            let data = json["Data"] as? [String:Any]
                            self.aryStreamInfo = data?["stream_info"] as? [String:Any] ?? [:]
                            
                            let user_subscription_info = data?["user_subscription_info"] != nil
                            if(user_subscription_info){
                                self.aryUserSubscriptionInfo = data?["user_subscription_info"] as? [Any] ?? [Any]()
                            }
                            if (self.aryUserSubscriptionInfo.count > 0){
                                gotoSchedule()
                            }
                        }else{
                            let strMsg = json["message"] as? String ?? ""
                            self.showAlert(strMsg: strMsg)
                        }
                    }
                case .failure(let error):
                    let errorDesc = error.localizedDescription.replacingOccurrences(of: "URLSessionTask failed with error:", with: "")
                    self.showAlert(strMsg: errorDesc)
                    self.viewActivity.isHidden = true
                    
                }
            }
    }
    func getEventBySlug() {
        let netAvailable = appDelegate.isConnectedToInternet()
        if(!netAvailable){
            showAlert(strMsg: "Please check your internet connection!")
            return
        }
        viewActivity.isHidden = false
        let url: String = appDelegate.baseURL +  "/getEventBySlug"
        let user_id = UserDefaults.standard.string(forKey: "user_id");
        var params: [String: Any] = ["slug":strSlug]
        if(!appDelegate.isGuest){
            // params["userid"] = user_id ?? ""
        }
        params["userid"] = user_id ?? ""
        
        //print("getEventBySlug params:",params)
        let headers: HTTPHeaders
        headers = [appDelegate.x_api_key: appDelegate.x_api_value]
        AF.request(url, method: .post,parameters: params, encoding: JSONEncoding.default,headers:headers)
            .responseJSON { response in
                self.viewActivity.isHidden = true
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any] {
                        //print("getEventBySlug JSON:",json)
                        if (json["statusCode"]as? String == "200" ){
                            let data = json["Data"] as? [String:Any]
                            self.aryStreamInfo = data?["stream_info"] as? [String:Any] ?? [:]
                            
                            let user_subscription_info = data?["user_subscription_info"] != nil
                            if(user_subscription_info){
                                self.aryUserSubscriptionInfo = data?["user_subscription_info"] as? [Any] ?? [Any]()
                            }
                            if (self.aryUserSubscriptionInfo.count > 0){
                                self.gotoSchedule()
                            }
                        }else{
                            let strMsg = json["message"] as? String ?? ""
                            self.showAlert(strMsg: strMsg)
                        }
                    }
                case .failure(let error):
                    let errorDesc = error.localizedDescription.replacingOccurrences(of: "URLSessionTask failed with error:", with: "")
                    self.showAlert(strMsg: errorDesc)
                    self.viewActivity.isHidden = true
                    
                }
            }
    }
    
    func gotoLogin(){
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
    func showConfirmation(strMsg:String,isNewAccount:Bool){
        let alert = UIAlertController(title: "Alert", message: strMsg, preferredStyle: .alert)
        if(isNewAccount){
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { [self] action in
                //sendpwd need to call
                sendPassword()
            }))
        }else{
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { [self] action in
                gotoLogin()
            }))
        }
        if(isNewAccount){
            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { [self] action in
                btnRegister.isHidden = false
                btnProceed.isHidden = true
            }))
        }
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
    func sendPassword(){
        viewActivity.isHidden = false
        let netAvailable = appDelegate.isConnectedToInternet()
        if(!netAvailable){
            showAlert(strMsg: "Please check your internet connection!")
            return
        }
        let url: String = appDelegate.profileURL +  "/sendPassword"
        
        let headers: HTTPHeaders
        headers = [appDelegate.x_api_key: appDelegate.x_api_value]
        let user_id = UserDefaults.standard.string(forKey: "user_id");
        
        let params: [String: Any] = ["user_id":user_id ?? ""]
        //print("sendPassword params:",params)
        // let params: [String: Any] = ["userid":user_id ?? "","performer_id":"101","stream_id": "0"]
        AF.request(url, method: .post,parameters: params, encoding: JSONEncoding.default,headers:headers)
            .responseJSON { [self] response in
                self.viewActivity.isHidden = true
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any] {
                        //print("sendPassword JSON:",json)
                        if (json["status"]as? Int == 0 ){
                            let email = txtEmail.text!.lowercased().trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
                            let msg = "Password sent to " + email
                            showAlert(strMsg: msg)
                            btnRegister.isHidden = false
                            btnProceed.isHidden = true
                        }else{
                            let strMsg = json["message"] as? String ?? ""
                            self.showAlert(strMsg: strMsg)
                        }
                    }
                case .failure(let error):
                    let errorDesc = error.localizedDescription.replacingOccurrences(of: "URLSessionTask failed with error:", with: "")
                    self.showAlert(strMsg: errorDesc)
                    self.viewActivity.isHidden = true
                    
                }
            }
        
    }
    
    func getUserByEmail() {
        let firstName = txtFirstName.text!.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        let lastName = txtLastName.text!.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        let email = txtEmail.text!.lowercased().trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        
        if (firstName.count == 0){
            showAlert(strMsg: "Please enter first name");
        }else if (lastName.count == 0){
            showAlert(strMsg: "Please enter last name");
        }else if (email.count == 0){
            showAlert(strMsg: "Please enter email");
        }else if (!isValidEmail()){
            showAlert(strMsg: "Please enter valid email");
        }else{
            //print("else")
            viewActivity.isHidden = false
            let netAvailable = appDelegate.isConnectedToInternet()
            if(!netAvailable){
                showAlert(strMsg: "Please check your internet connection!")
                return
            }
            let url: String = appDelegate.profileURL +  "/getUserByEmail"
            
            let headers: HTTPHeaders
            headers = [appDelegate.x_api_key: appDelegate.x_api_value]
            
            let params: [String: Any] = ["firstname":firstName,"lastname":lastName,"email":email,"stream_id":appDelegate.streamId]
            // print("getUserByEmail params:",params)
            // let params: [String: Any] = ["userid":user_id ?? "","performer_id":"101","stream_id": "0"]
            AF.request(url, method: .post,parameters: params, encoding: JSONEncoding.default,headers:headers)
                .responseJSON { [self] response in
                    self.viewActivity.isHidden = true
                    switch response.result {
                    case .success(let value):
                        if let json = value as? [String: Any] {
                            //   print("getUserByEmail JSON:",json)
                            if (json["status"]as? Int == 0 ){
                                let tickets = json["tickets"]as? Int ?? 0
                                let user = json["user"] as? [String:Any] ?? [:]
                                let is_guest = user["is_guest"]as? Bool ?? false
                                //                                print("tkts:",tickets)
                                //                                print("is_guest:",is_guest)
                                access_token = user["access_token"] as? String ?? ""
                                UserDefaults.standard.set(user["id"], forKey: "user_id")
                                UserDefaults.standard.set(user["access_token"], forKey: "session_token")
                                let fn = user["first_name"] as? String ?? ""
                                let ln = user["last_name"]as? String ?? ""
                                let displayName = user["display_name"]as? String ?? ""
                                
                                let strName = String((fn.first ?? "A")) + String((ln.first ?? "B"))
                                self.appDelegate.USER_NAME = strName;
                                self.appDelegate.USER_NAME_FULL = displayName
                                self.appDelegate.USER_DISPLAY_NAME = displayName
                                UserDefaults.standard.set(self.appDelegate.USER_NAME, forKey: "USER_NAME")
                                UserDefaults.standard.set(self.appDelegate.USER_NAME_FULL, forKey: "USER_NAME_FULL")
                                UserDefaults.standard.set(displayName, forKey: "user_display_name")
                                
                                // print("access_token:",access_token)
                                if(tickets == 1){
                                    //email id already registered with event
                                    let emailAlert = email + " already registered for this stream"
                                    showAlert(strMsg: emailAlert)
                                    self.gotoSchedule()
                                }else if(tickets == 0){
                                    txtEmail.isEnabled = false
                                    txtFirstName.isEnabled = false
                                    txtLastName.isEnabled = false
                                    txtEmail.textColor = UIColor.lightGray
                                    txtFirstName.textColor = UIColor.lightGray
                                    txtLastName.textColor = UIColor.lightGray
                                    //email id not registered with event
                                    UserDefaults.standard.set("guest-user", forKey: "user")
                                    if(is_guest){
                                        showConfirmation(strMsg: "Do you want to create an account?",isNewAccount:true)
                                    }else {
                                        showConfirmation(strMsg: "An account with this email address already exists, Please sign in.",isNewAccount:false)
                                    }
                                }
                                
                            }else{
                                let strMsg = json["message"] as? String ?? ""
                                //print("422 strMsg:",strMsg)
                                if(strMsg.lowercased().contains("email must be unique")){
                                    showConfirmation(strMsg: "An account with this email address already exists, Please sign in.",isNewAccount:false)
                                }else{
                                    self.showAlert(strMsg: strMsg)
                                }
                            }
                        }
                    case .failure(let error):
                        let errorDesc = error.localizedDescription.replacingOccurrences(of: "URLSessionTask failed with error:", with: "")
                        self.showAlert(strMsg: errorDesc)
                        self.viewActivity.isHidden = true
                        
                    }
                }
        }
    }
    
    // MARK: Handler for getCategoryOrganisations API
    func registerEvent(){
        //print("registerEvent")
        let netAvailable = appDelegate.isConnectedToInternet()
        if(!netAvailable){
            showAlert(strMsg: "Please check your internet connection!")
            return
        }
        viewActivity.isHidden = false
        let url: String = appDelegate.paymentBaseURL +  "/registerEvent"
        
        let session_token = UserDefaults.standard.string(forKey: "session_token") ?? ""
        let headers : HTTPHeaders = [
            "Content-Type": "application/json",
            appDelegate.x_api_key:appDelegate.x_api_value,
            "Authorization": "Bearer " + access_token
        ]
        AF.request(url, method: .post,parameters: appDelegate.paramsForFreeRegistration, encoding: JSONEncoding.default,headers:headers)
            .responseJSON { response in
                self.viewActivity.isHidden = true
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any] {
                        //print("registerEvent JSON:",json)
                        if (json["status"]as? Int == 0){
                            self.gotoSchedule()
                        }else{
                            let strError = json["message"] as? String
                            //////print("strError1:",strError ?? "")
                            self.showAlert(strMsg: strError ?? "")
                        }
                    }
                case .failure(let error):
                    let errorDesc = error.localizedDescription.replacingOccurrences(of: "URLSessionTask failed with error:", with: "")
                    self.showAlert(strMsg: errorDesc)
                    self.viewActivity.isHidden = true
                    
                }
            }
    }
    // MARK: Picker DataSource & Delegate Methods
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedItem = pickerData[row]
        isSelectedTicket = true
        //selectedTicketIndex
        if selectedItem.contains("0") {
            selectedTicketValue = "0"
        }else{
            selectedTicketValue = "1"
        }
        
    }
    func gotoSchedule(){
        if(appDelegate.selected_type == "single_session_event"){
            let vc = storyboard!.instantiateViewController(withIdentifier: "ScheduleVC") as! ScheduleVC
            self.navigationController?.pushViewController(vc, animated: true)
        }else{
            let vc = storyboard!.instantiateViewController(withIdentifier: "ScheduleVC") as! ScheduleVC
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}



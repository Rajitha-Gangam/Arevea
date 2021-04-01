//
//  QuestionsVC.swift
//  AreveaTV
//
//  Created by apple on 3/17/21.
//  Copyright © 2021 apple. All rights reserved.
//

import UIKit
import Alamofire

class QuestionsVC: UIViewController,OpenChanannelChatDelegate,UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate, UITextViewDelegate {
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var heightTopView: NSLayoutConstraint?
    @IBOutlet weak var viewTop: UIView!
    @IBOutlet weak var viewActivity: UIView!
    @IBOutlet weak var tblQuestions: UITableView!
    var selectedRadioIndex = -1
    var selectedRadioSection = -1
    weak var chatDelegate: OpenChanannelChatDelegate?
    var strTicketName = ""
    var aryQuestions = [Any]()
    var aryAnswers = [Any]()
    var radioControllerChoice : SSRadioButtonsController = SSRadioButtonsController()
    var radioControllerDip : SSRadioButtonsController = SSRadioButtonsController()
    var strPrice = ""
    var strTicketIDs = ""
    var aryAnswersIds = [Any]()
    var streamPaymentMode = ""
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var aryStreamInfo = [String: Any]()
    var questionsObj = [Int:Any]()
    @IBOutlet weak var tblheight: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        print("aryQuestions:",aryQuestions)
        for(j,_)in self.aryQuestions.enumerated(){
            self.aryAnswers.insert("", at: j)
            self.aryAnswersIds.insert(0, at: j)
        }
        lblTitle.text = "   " + appDelegate.strTitle
        tblQuestions.register(UINib(nibName: "RadioCell", bundle: nil), forCellReuseIdentifier: "RadioCell")
        tblQuestions.register(UINib(nibName: "CheckMarkCell", bundle: nil), forCellReuseIdentifier: "CheckMarkCell")
        tblQuestions.register(UINib(nibName: "TextFieldCell", bundle: nil), forCellReuseIdentifier: "TextFieldCell")
        tblQuestions.register(UINib(nibName: "TextAreaCell", bundle: nil), forCellReuseIdentifier: "TextAreaCell")
        
        
        
    }
    
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
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
                return try JSONSerialization.jsonObject(with: data, options: []) as? [Any] ?? []
            } catch {
                ////print(error.localizedDescription)
            }
        }
        return nil
    }
    
    //MARK:Tableview Delegates and Datasource Methods
    
    func numberOfSections(in tableView: UITableView) ->  Int {
        return aryQuestions.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView() // The width will be the same as the cell, and the height should be set in tableView:heightForRowAtIndexPath:
        view.backgroundColor = UIColor.init(red: 34, green: 44, blue: 54)
        let label = UILabel()
        let questionInfo = aryQuestions[section] as? [String:Any] ?? [:]
        let question = questionInfo["question"] as? String ?? ""
        let is_mandatory = questionInfo["is_mandatory"] as? Bool ?? false

        let title =  "Q" + String(section + 1) + ": " + question
        label.text = title
        if(is_mandatory){
            label.text = title + "  *"
        }
        label.textColor = .white
        // button.addTarget(self, action: Selector("visibleRow:"), forControlEvents:.TouchUpInside)
        
        view.addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let views = ["label": label,"view": view]
        
        let horizontallayoutContraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[label]-10-|", options: .alignAllCenterY, metrics: nil, views: views)
        view.addConstraints(horizontallayoutContraints)
        
        let verticalLayoutContraint = NSLayoutConstraint(item: label, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0)
        view.addConstraint(verticalLayoutContraint)
        
        return view
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let questionInfo = aryQuestions[section] as? [String:Any] ?? [:]
        let options = questionInfo["options"] as? String ?? ""
        let aryTierAmounts = self.convertToArray(text: options)
        print("==setion:",section)
        print("==count:",aryTierAmounts?.count)
        if(aryTierAmounts?.count == 0){
            return 1
        }else{
            return aryTierAmounts?.count ?? 1
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) ->  CGFloat {
        let questionInfo = aryQuestions[indexPath.section] as? [String:Any] ?? [:]
        let option_type = questionInfo["option_type"] as? String ?? ""
        if(option_type == "textbox"){
            return 50;
        }else if(option_type == "textarea"){
            return 100;
        }
        return 44;
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let questionInfo = aryQuestions[indexPath.section] as? [String:Any] ?? [:]
        let option_type = questionInfo["option_type"] as? String ?? ""
        if(option_type == "textbox"){
            let cell = tableView.dequeueReusableCell(withIdentifier: "TextFieldCell") as! TextFieldCell
            cell.txtAnswer.delegate = self
            let section1 = indexPath.section + 1
            cell.txtAnswer.tag = (5 * section1) + indexPath.row
            return cell
        }else if(option_type == "textarea"){
            let cell = tableView.dequeueReusableCell(withIdentifier: "TextAreaCell") as! TextAreaCell
            cell.txtAnswer.delegate = self
            let section1 = indexPath.section + 1
            cell.txtAnswer.tag = (10 * section1) + indexPath.row
            return cell
        }
        else if(option_type == "checkbox"){
            let cell = tableView.dequeueReusableCell(withIdentifier: "RadioCell") as! RadioCell
            let options = questionInfo["options"] as? String ?? ""
            let aryTierAmounts = self.convertToArray(text: options)
            let option = aryTierAmounts?[indexPath.row] as? [String:Any] ?? [:]
            cell.lblTitle.text = option["option"] as? String ?? ""
            let section1 = indexPath.section + 1
            cell.imgCheck.tag = (15 * section1) + (indexPath.row)
            
            return cell
            
        }
        else if(option_type == "radio" || option_type == "select"){
            let cell = tableView.dequeueReusableCell(withIdentifier: "RadioCell") as! RadioCell
            
            if(selectedRadioSection == indexPath.section){
                if(selectedRadioIndex == indexPath.row){
                    if(option_type == "radio"){
                        cell.imgCheck.image = UIImage.init(named: "radio_checked")
                    }else{
                        cell.imgCheck.image = UIImage.init(named: "checked-green")
                    }
                }else{
                    if(option_type == "radio"){
                        cell.imgCheck.image = UIImage.init(named: "radio_uncheck")
                    }else{
                        cell.imgCheck.image = UIImage.init(named: "check")
                        
                    }
                }
            }else{
                if(option_type == "radio"){
                    cell.imgCheck.image = UIImage.init(named: "radio_uncheck")
                }else{
                    cell.imgCheck.image = UIImage.init(named: "check")
                }
            }
            let options = questionInfo["options"] as? String ?? ""
            let aryTierAmounts = self.convertToArray(text: options)
            let option = aryTierAmounts?[indexPath.row] as? [String:Any] ?? [:]
            cell.lblTitle.text = option["option"] as? String ?? ""
            let section1 = indexPath.section + 1
            if(option_type == "radio")
            {
                cell.imgCheck.tag = (20 * section1) + (indexPath.row)
            }else{
                cell.imgCheck.tag = (25 * section1) + (indexPath.row)
            }
            return cell
            
        }
        else{
            let cell: UITableViewCell = UITableViewCell()
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let questionInfo = aryQuestions[indexPath.section] as? [String:Any] ?? [:]
        let option_type = questionInfo["option_type"] as? String ?? ""

        var tag = 0
        if(option_type == "radio" || option_type == "checkbox" || option_type == "select"){
            let options = questionInfo["options"] as? String ?? ""

            let aryTierAmounts = self.convertToArray(text: options)
            let option = aryTierAmounts?[indexPath.row] as? [String:Any] ?? [:]
            
            if(option_type == "radio" ||  option_type == "select"){
                selectedRadioIndex = indexPath.row
                selectedRadioSection = indexPath.section
                self.tblQuestions.reloadSections([selectedRadioSection], with: .none)
                aryAnswers[indexPath.section] = [option["option"] as? String ?? ""]
                aryAnswersIds[indexPath.section] = questionInfo["id"] as? Int ?? 0
            }else{
                let section1 = indexPath.section + 1
                tag = (15 * section1) + (indexPath.row)
                let checkImg = tblQuestions.viewWithTag(tag) as? UIImageView
                if ((checkImg?.image?.isEqual(UIImage.init(named: "checked-green")))!)
                {
                    checkImg?.image = UIImage.init(named: "check")
                    aryAnswers[indexPath.section] = []
                    aryAnswersIds[indexPath.section] = 0

                }
                else{
                    checkImg?.image = UIImage.init(named: "checked-green")
                    aryAnswers[indexPath.section] = [option["option"] as? String ?? ""]
                    aryAnswersIds[indexPath.section] = questionInfo["id"] as? Int ?? 0

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
    @IBAction func next(_ sender: Any) {
        var params = [Any]()
        var param1 = [String:Any]()
        for(index,_)in aryQuestions.enumerated(){
            let questionInfo = aryQuestions[index] as? [String : Any] ?? [String:Any]()
            let option_type = questionInfo["option_type"] as? String ?? ""
            let questionId = questionInfo["id"] as? Int ?? 0
            if(option_type == "textbox"){
                let section1 = index + 1
               let tag = (5 * section1)
                let txtAnswer = tblQuestions.viewWithTag(tag) as? UITextField
                let answer = txtAnswer?.text ?? ""
                aryAnswers[index] = answer
                aryAnswersIds[index] = questionId
            }else if(option_type == "textarea"){
                let section1 = index + 1
               let tag = (10 * section1)
                let txtAnswer = tblQuestions.viewWithTag(tag) as? UITextView
                let answer = txtAnswer?.text ?? ""
                aryAnswers[index] = answer
                aryAnswersIds[index] = questionId
            }
        }
        
        var inc = 0
        for(index,element)in aryAnswers.enumerated(){
            let questionInfo = aryQuestions[index] as? [String : Any] ?? [String:Any]()
            let is_mandatory = questionInfo["is_mandatory"] as? Bool ?? false
            if((element as? String) != nil){
                let obj = element as? String ?? ""
                if(is_mandatory){
                    if(obj != ""){
                        inc = inc + 1
                    }
                }else{
                    inc = inc + 1
                }
            }else if((element as? [Any]) != nil){
                let obj = element as? [Any] ?? [Any]()
                if(is_mandatory){
                if(obj.count != 0){
                    inc = inc + 1
                }
                }else{
                    inc = inc + 1
                }
            }
        }
        if(aryAnswers.count != inc){
            showAlert(strMsg: "Please answer all mandatory questions")
            return
        }
        questionsObj = [Int:Any]()
        for(index,element)in aryAnswers.enumerated(){
            if((element as? String) != nil){
                let obj = element as? String ?? ""
                if(obj != ""){
                    let id = aryAnswersIds[index] as? Int ?? 0
                    questionsObj[id] = aryAnswers[index]
                }
            }else if((element as? [Any]) != nil){
                let obj = element as? [Any] ?? [Any]()
                if(obj.count != 0){
                    let id = aryAnswersIds[index] as? Int ?? 0
                    questionsObj[id] = aryAnswers[index]
                }
            }
        }
        print("questionsObj:",questionsObj)
        if(appDelegate.streamPaymentMode.lowercased() == "free"){
            registerEvent()
        }else{
            gotoOrderSummary()
        }
        
    }
    func registerEvent(){
        //print("registerEvent")
        let netAvailable = appDelegate.isConnectedToInternet()
        if(!netAvailable){
            showAlert(strMsg: "Please check your internet connection!")
            return
        }
        viewActivity.isHidden = false
        let url: String = appDelegate.paymentBaseURL +  "/registerEvent"
        _ = UserDefaults.standard.string(forKey: "user_id");
        let streamObj = self.aryStreamInfo
        let currency_type = streamObj["currency_type"] as? String ?? ""
        let stream_video_title = streamObj["stream_video_title"] as? String ?? ""
        var strAmount = "0.0"
        
        if (streamObj["stream_payment_amount"] as? Double) != nil {
            strAmount = String(streamObj["stream_payment_amount"] as? Double ?? 0.0)
        }else if (streamObj["stream_payment_amount"] as? String) != nil {
            strAmount = String(streamObj["stream_payment_amount"] as? String ?? "0.0")
        }
        let doubleAmount = Double(strAmount)
        let amount = String(format: "%.02f", doubleAmount!)
        let stream_amounts = streamObj["stream_amounts"] as? String ?? "";
        let publish_date_time = streamObj["publish_date_time"] as? String ?? "";
        let video_thumbnail_image = streamObj["video_thumbnail_image"] as? String ?? "";
        let user_first_name = streamObj["user_first_name"] as? String ?? "";
        let user_last_name = streamObj["user_last_name"] as? String ?? "";
        let user_display_name = streamObj["user_display_name"] as? String ?? "";
        let channel_name = streamObj["channel_name"] as? String ?? "";
        let stream_status = streamObj["stream_status"] as? String ?? "";
        let expected_end_date_time = streamObj["expected_end_date_time"] as? String ?? "";
        
        
        let params: [String: Any] = ["paymentInfo": ["paymentType": "pay_per_view","payment_type": "pay_per_view","organization_id": appDelegate.orgId,"currency": currency_type,"amount": 0,"stream_id": appDelegate.streamId,"streamInfo": ["id": appDelegate.streamId,"stream_video_title": stream_video_title,"organization_id": appDelegate.orgId,"amount":amount,"currency": currency_type,"stream_amounts":stream_amounts,"publish_date_time": publish_date_time,"video_thumbnail_image": video_thumbnail_image,"performer_id": appDelegate.performerId,"user_first_name": user_first_name,"user_last_name": user_last_name,"user_display_name": user_display_name,"channel_name": channel_name,"number_of_creators": 1,"stream_status": stream_status,"currency_type": currency_type,"expected_end_date_time": expected_end_date_time],"questions":"\(questionsObj)"]]
        
        ////print("params:",params)
        
        let session_token = UserDefaults.standard.string(forKey: "session_token") ?? ""
        let headers : HTTPHeaders = [
            "Content-Type": "application/json",
            appDelegate.x_api_key:appDelegate.x_api_value,
            "Authorization": "Bearer " + session_token
        ]
        AF.request(url, method: .post,parameters: params, encoding: JSONEncoding.default,headers:headers)
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
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //currentResponder = textField
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("textFieldDidEndEditing")
        textField.resignFirstResponder();
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("textFieldShouldReturn")
        print("textField tag:",textField.tag)
        textField.resignFirstResponder();
        return true;
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let textFieldText: NSString = (textField.text ?? "") as NSString
        let txtAfterUpdate = textFieldText.replacingCharacters(in: range, with: string)
        print("txtAfterUpdate:",txtAfterUpdate)
        print("tag:",textField.tag)

        return true
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        print("print1")
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        print("print2")
    }
    func textViewShouldReturn(textView: UITextView!) -> Bool {
        
        self.view.endEditing(true);
        return true;
    }
    // Use this if you have a UITextView
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        print("tag:",textView.tag)
        // get the current text, or use an empty string if that failed
        let currentText = textView.text ?? ""
        
        // attempt to read the range they are trying to change, or exit if we can't
        guard let stringRange = Range(range, in: currentText) else { return false }
        
        // add their new text to the existing text
        let updatedText = currentText.replacingCharacters(in: stringRange, with: text)
        print("updatedText:",updatedText)
        // make sure the result is under 16 characters
        return updatedText.count <= 100
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent // .default
    }
    func gotoOrderSummary(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil);
         let vc = storyboard.instantiateViewController(withIdentifier: "OrderSummaryVC") as! OrderSummaryVC
         vc.chatDelegate = self
        vc.strTicketName = strTicketName
        vc.strPrice = strPrice
        vc.strTicketIDs = strTicketIDs
        vc.questionsObj = questionsObj
         self.navigationController?.pushViewController(vc, animated: true)
    }
    func gotoStreamDetails(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil);
        appDelegate.isLiveLoad = "1"
        let vc = storyboard.instantiateViewController(withIdentifier: "StreamDetailVC") as! StreamDetailVC
        vc.chatDelegate = self
        vc.isCameFromGetTickets = true
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    func gotoSchedule(){
        let vc = storyboard!.instantiateViewController(withIdentifier: "ScheduleVC") as! ScheduleVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

//
//  Q_And_A_Final_Cell.swift
//  PopOverSample
//
//  Created by apple on 1/7/21.
//

import UIKit
import SendBirdSDK

class Q_And_A_Final_Cell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextFieldDelegate {
    var txtTopOfToolBarQAndA : UITextField!
    var currentResponder : UITextField!

    //weak var cellDelegate: CollectionViewCellDelegate?
    var aryAnswers = [Any]()
    var aryQuestions: [SBDBaseMessage] = []

    var strController = "";
    //weak var cellDelegate: CollectionViewCellDelegate?
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet weak var lbl1: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.collectionView.showsHorizontalScrollIndicator = false
        //for disable scroll
        self.collectionView.isScrollEnabled = true
        // Comment if you set Datasource and delegate in .xib
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
        
        // Register the xib for collection view cell
        let cellNib = UINib(nibName: "Q_And_A_CVC", bundle: nil)
        self.collectionView.register(cellNib, forCellWithReuseIdentifier: "Q_And_A_CVC")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    func updateCellWith(questions:[SBDBaseMessage],answers:[Any]){
        self.aryQuestions = questions
        self.aryAnswers = answers
        self.collectionView.reloadData()

        if let layout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .vertical  // .horizontal
        }
    }
   
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? Q_And_A_CVC
        ////print("I'm tapping the \(indexPath.item)")
        
        //self.cellDelegate?.collectionView(collectionviewcell: cell, index: indexPath.item,title: strController,  didTappedInTableViewCell: self)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.aryQuestions.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    // Set the data for each cell (color and color name)
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Q_And_A_CVC", for: indexPath) as? Q_And_A_CVC {
            // cell.colorView.backgroundColor = self.rowWithItems?[indexPath.item].color ?? UIColor.black
            
            let question = aryQuestions[indexPath.row]
            
            //print("messageId:",question.messageId)
            //print("messages_q_and_a_answers_main:",messages_q_and_a_answers_main)
            let messageId = String(question.messageId)
            let searchPredicate = NSPredicate(format: "data = %@", messageId)
            let filteredArray = (aryAnswers as NSArray).filtered(using: searchPredicate)
            //let filteredArray = messages_q_and_a_answers_main.filter { $0["data"] == "1210730782" }
            //print("filteredArray count:",filteredArray)
            
            cell.btnSend.tag = indexPath.row
            cell.txtMsg.delegate = self
            cell.txtMsg.tag = 10 + indexPath.row
            cell.btnSend.addTarget(self, action: #selector(sendReply(_:)), for: .touchUpInside)
            addDoneButton_Q_And_A(textField:cell.txtMsg)
            return cell
        }
        return UICollectionViewCell()
    }
    func addDoneButton_Q_And_A(textField: UITextField) {
        let screenRect = UIScreen.main.bounds
        let screenWidth = screenRect.size.width
        var screenHeight = screenRect.size.height/2 - 90

        let toolbar =  UIToolbar(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 35))
        toolbar.backgroundColor = .white
        if(txtTopOfToolBarQAndA == nil){
        txtTopOfToolBarQAndA =  UITextField(frame: CGRect(x: 50, y: 0, width: screenWidth-150, height: 35))
        // let textfield =  UITextField()
        txtTopOfToolBarQAndA.placeholder = "Send a reply"
        txtTopOfToolBarQAndA.delegate = self
        txtTopOfToolBarQAndA.backgroundColor = .clear
        //txtTopOfToolBarChat.isUserInteractionEnabled = false
        txtTopOfToolBarQAndA.borderStyle = UITextField.BorderStyle.none
        }
        let textfieldBarButton = UIBarButtonItem.init(customView: txtTopOfToolBarQAndA)
        
        // UIToolbar expects an array of UIBarButtonItems:
        
        let flexButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        
        let cancel = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action:#selector(resignKB(_:)))
        
        let button = UIButton.init(type: .custom)
        //set image for button
        button.setImage(UIImage(named: "blue-send"), for: UIControl.State.normal)
        
        //add function for button
        button.tag = 10 - textField.tag
        
        button.addTarget(self, action: #selector(sendReply(_:)), for: UIControl.Event.touchUpInside)
        //set frame
        button.frame = CGRect(x: screenWidth - 180, y: 0, width: 20, height: 20)
        
        let sendBtn = UIBarButtonItem(customView: button)
        toolbar.setItems([cancel,textfieldBarButton,flexButton,sendBtn], animated: true)
        toolbar.sizeToFit()
        txtTopOfToolBarQAndA.inputAccessoryView = toolbar;
        textField.inputAccessoryView = toolbar;
        
    }
    @objc func resignKB(_ sender: Any) {
        currentResponder.resignFirstResponder()
    }
    func showAlert(strMsg: String){
        let alert = UIAlertController(title: "Alert", message: strMsg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        let activeVc = UIApplication.shared.keyWindow?.rootViewController
        DispatchQueue.main.async {
            activeVc?.present(alert, animated: true, completion: nil)
        }
    }
    @objc func sendReply(_ sender: UIButton) {
       // self.view.endEditing(true)
        currentResponder.resignFirstResponder()
        print("tag:",sender.tag)
        let txtField = collectionView.viewWithTag(10 + sender.tag) as? UITextField
        print("txt1:",txtField?.text)
        let messageText = txtField?.text?.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        if (messageText?.count == 0){
            showAlert(strMsg: "Please enter your reply")
            return
        }
    }
    
    // Add spaces at the beginning and the end of the collection view
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    // Add spaces at the beginning and the end of the collection view
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        ////print("width:",width)
        let screenRect = UIScreen.main.bounds
        let screenWidth = collectionView.frame.size.width
        var screenHeight = screenRect.size.height/2 - 90
        
        return CGSize(width: screenWidth, height: 184)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        currentResponder = textField
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
      print("textFieldDidEndEditing")
        //textField.resignFirstResponder();
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
        txtTopOfToolBarQAndA.text = txtAfterUpdate
        return true
    }
    
    
}

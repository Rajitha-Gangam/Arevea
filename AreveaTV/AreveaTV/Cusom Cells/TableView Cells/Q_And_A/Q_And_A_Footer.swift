//
//  Q_And_A_Section.swift
//  AreveaTV
//
//  Created by apple on 12/15/20.
//  Copyright © 2020 apple. All rights reserved.
//

import UIKit

class Q_And_A_Footer: UITableViewCell,UITextFieldDelegate {
    @IBOutlet weak var btnSend: UIButton!
    @IBOutlet weak var btnInput: UIButton!

    @IBOutlet weak var txtMsg: UITextField!
    var txtTopOfToolBarQAndA : UITextField!
    @IBOutlet weak var viewSendReply: UIView!

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    func updateCellWith(index:Int){
        txtMsg.delegate = self
        txtMsg.tag = 10 + index
        addDoneButton_Q_And_Answer(textField: txtMsg)
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
       // currentResponder = textField
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
      print("w==textFieldDidEndEditing")
        //textField.resignFirstResponder();
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder();
        let messageText = textField.text?.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        textField.text = ""
        txtTopOfToolBarQAndA.text = ""
        if (messageText?.count == 0){
            showAlert(strMsg: "Please enter your reply")
        }else{
            sendAnswer(index: textField.tag - 10, msg: messageText ?? "")
        }
        return true;
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let textFieldText: NSString = (textField.text ?? "") as NSString
        let txtAfterUpdate = textFieldText.replacingCharacters(in: range, with: string)
        txtTopOfToolBarQAndA.text = txtAfterUpdate
        return true
    }
    func addDoneButton_Q_And_Answer(textField: UITextField) {
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
        button.tag = textField.tag - 10
        
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
        txtMsg.resignFirstResponder()
    }
    func sendAnswer(index:Int,msg:String){
        print("index:",index)
        print("msg:",msg)
        let msgInfo = ["index":index,"msg": msg] as [String : Any]
        NotificationCenter.default.post(name: .Notification_Q_And_A_Reply, object: self, userInfo: msgInfo)
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
       // currentResponder.resignFirstResponder()
       // print("w==tag1:",sender.tag)
        let txtField = self.viewWithTag(10 + sender.tag) as? UITextField
        txtField?.resignFirstResponder()
      //  print("w==txt2:",txtField?.text)
        let messageText = txtField?.text?.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        txtField?.text = ""
        txtTopOfToolBarQAndA.text = ""
        if (messageText?.count == 0){
            showAlert(strMsg: "Please enter your reply")
            return
        }
        sendAnswer(index: sender.tag, msg: messageText ?? "")
    }
}

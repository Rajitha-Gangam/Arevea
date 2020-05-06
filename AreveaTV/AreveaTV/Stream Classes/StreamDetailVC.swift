//
//  DetailViewController.swift
//  R5ProTestbed
//
//  Created by Andy Zupko on 12/16/15.
//  Copyright © 2015 Infrared5, Inc. All rights reserved.
//
//  The accompanying code comprising examples for use solely in conjunction with Red5 Pro (the "Example Code")
//  is  licensed  to  you  by  Infrared5  Inc.  in  consideration  of  your  agreement  to  the  following
//  license terms  and  conditions.  Access,  use,  modification,  or  redistribution  of  the  accompanying
//  code  constitutes your acceptance of the following license terms and conditions.
//
//  Permission is hereby granted, free of charge, to you to use the Example Code and associated documentation
//  files (collectively, the "Software") without restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit
//  persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The Software shall be used solely in conjunction with Red5 Pro. Red5 Pro is licensed under a separate end
//  user  license  agreement  (the  "EULA"),  which  must  be  executed  with  Infrared5,  Inc.
//  An  example  of  the EULA can be found on our website at: https://account.red5pro.com/assets/LICENSE.txt.
//
//  The above copyright notice and this license shall be included in all copies or portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,  INCLUDING  BUT
//  NOT  LIMITED  TO  THE  WARRANTIES  OF  MERCHANTABILITY, FITNESS  FOR  A  PARTICULAR  PURPOSE  AND
//  NONINFRINGEMENT.   IN  NO  EVENT  SHALL INFRARED5, INC. BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN  AN  ACTION  OF  CONTRACT,  TORT  OR  OTHERWISE,  ARISING  FROM,  OUT  OF  OR  IN CONNECTION
//  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

import UIKit
import R5Streaming
import AVKit

class StreamDetailVC: UIViewController, UITextFieldDelegate {
    
    var r5ViewController : BaseTest? = nil
    @IBOutlet weak var viewVOD: UIView!
    
    var detailItem: NSDictionary? {
        didSet {
            // Update the view.
            // self.configureView()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        Testbed.setLicenseKey(value:"YI8J-RDXS-DMLH-H5DZ")
        Testbed.setStream1Name(name: "stream1")
        Testbed.setStream2Name(name: "stream2")
        Testbed.setHost(ip: "vimal.cloudext.co");
        Testbed.setServerPort(port: "8,554")
        Testbed.setDebug(on: true)
        Testbed.setVideo(on: true)
        Testbed.setAudio(on: true)
        Testbed.setHWAccel(on: true)
        Testbed.setRecord(on: true)
        Testbed.setRecordAppend(on: true)
        
        self.configureView()
        
    }
    
    func configureView() {
        // Update the user interface for the detail item.
        // Access the static shared interface to ensure it's loaded
        _ = Testbed.sharedInstance
        
        if(self.detailItem != nil){
            Testbed.setLocalOverrides(params: self.detailItem!["LocalProperties"] as? NSMutableDictionary)
            let className = self.detailItem!["class"] as! String
            let mClass = NSClassFromString(className) as! BaseTest.Type;
            //only add this view if it isn't HOME
            r5ViewController  = mClass.init()
            r5ViewController?.view.frame = self.viewVOD.bounds
            self.viewVOD.addSubview(r5ViewController!.view)
           
            self.addChild(r5ViewController!)
            
            //r5ViewController!.view.autoresizesSubviews = false
            //r5ViewController!.view.autoresizingMask = [UIViewAutoresizing.FlexibleHeight, UIViewAutoresizing.FlexibleWidth];
        }
    }
    @objc func showInfo(){
        let alert = UIAlertView()
        alert.title = "Info"
        alert.message = self.detailItem!["description"] as? String
        alert.addButton(withTitle: "OK")
        alert.show()
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    override func viewWillDisappear(_ animated: Bool) {
        closeCurrentTest()
        self.navigationController?.isNavigationBarHidden = true
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        self.navigationController?.isNavigationBarHidden = false
    }
    func closeCurrentTest(){
        if( r5ViewController != nil ){
            r5ViewController!.closeTest()
            r5ViewController = nil
        }
    }
    var shouldClose:Bool{
        get{
            if(r5ViewController != nil){
                return (r5ViewController?.shouldClose)!
            }
            else{
                return true
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    open override var shouldAutorotate:Bool {
        get {
            return true
        }
    }
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        get {
            return [UIInterfaceOrientationMask.all]
        }
    }
    func navigationControllerSupportedInterfaceOrientations(_ navigationController: UINavigationController) -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.all
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent // .default
    }
}

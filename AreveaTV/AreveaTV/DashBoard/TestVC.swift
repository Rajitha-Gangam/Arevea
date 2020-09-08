//
//  TestVC.swift
//  AreveaTV
//
//  Created by apple on 8/25/20.
//  Copyright © 2020 apple. All rights reserved.
//

import UIKit
import WebKit
class TestVC: UIViewController, UIWebViewDelegate {
    @IBOutlet weak var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.webView.backgroundColor = .clear
        self.webView.isOpaque = false
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let htmlString = "<html>\n" + "<body style='margin:0;padding:0;background:transparent;'>\n" +
                            "<iframe width=\"100%\" height=\"100%\" src=\"https://app.singular.live/appinstances/419608/outputs/Output/onair\" frameborder=\"0\" allow=\"accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture\" allowfullscreen>\n" + "</iframe>\n" + "</body>\n" + "</html>";
                            print("htmlString:",htmlString)
                            self.webView.loadHTMLString(htmlString, baseURL: nil)
                            //self.webView.delegate = self
                            //self.webView.isHidden = false
        
        let url = URL(string: "https://www.hackingwithswift.com")!
        let requestObj = URLRequest(url: url as URL)
        //webView.load(requestObj)
        //webView.loadRequest()
        //webView.allowsBackForwardNavigationGestures = true
                            
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

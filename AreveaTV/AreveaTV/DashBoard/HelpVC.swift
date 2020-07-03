//
//  HelpVC.swift
//  AreveaTV
//
//  Created by apple on 6/1/20.
//  Copyright © 2020 apple. All rights reserved.
//

import UIKit

class HelpVC: UIViewController,UIWebViewDelegate{
    // MARK: - Variables Declaration
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var viewActivity: UIView!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    @IBOutlet weak var heightTopView: NSLayoutConstraint?
    @IBOutlet weak var viewTop: UIView!
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        viewActivity.isHidden = true
        // Do any additional setup after loading the view.
        let netAvailable = appDelegate.isConnectedToInternet()
        if(!netAvailable){
            showAlert(strMsg: "Please check your internet connection!")
        }else{
            let strURL = "https://app.koopid.ai/kpd-client/index.html?send=%7B%22text%22%3A%22Arevea+Concierge%22%2C%22type%22%3A%22hidden%22%7D&provider=478851&autoconfig=true&login-providerId=478851&resize=scale&localstore=customer&home=chatwith%2F478853&target=chatwith%2F478853&username=guest#chat/3079456024273702113"
            //if let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)   {

            if let url = URL(string: strURL){
                let request = URLRequest(url: url as URL)
                webView.delegate = self
                webView.loadRequest(request)
                viewActivity.isHidden = false
            }else{
                showAlert(strMsg: "Invalid URL")
            }
        }
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
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true);
    }
    // MARK: - Webview Delegates
    func webViewDidStartLoad(_ webView: UIWebView) {
        viewActivity.isHidden = false
    }
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error)
    {
        viewActivity.isHidden = true
        self.showAlert(strMsg:error.localizedDescription)
    }
    func webViewDidFinishLoad(_ webView: UIWebView) {
        viewActivity.isHidden = true
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent // .default
    }
}

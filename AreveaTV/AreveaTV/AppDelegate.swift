//
//  AppDelegate.swift
//  AreveaTV
//
//  Created by apple on 4/18/20.
//  Copyright © 2020 apple. All rights reserved.
//

import UIKit
//import Firebase
import SendBirdSDK
import CoreLocation
import AWSAppSync
import UIKit
import  AVKit
import FirebaseCore


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,CLLocationManagerDelegate {
    // MARK: - Variables Declaration
    var window: UIWindow? // <-- Here
    
    var USER_EMAIL = "";
    var plan = "";
    var USER_NAME = "";
    var USER_NAME_FULL = "";
    var isLiveLoad = "0";
    var locationManager:CLLocationManager!
    
    // MARK: - Dev Environmet Variables Declaration
    /* var baseURL = "https://r5ibd3yzp7.execute-api.us-west-2.amazonaws.com/devel";
     var termsURL = "https://dev.arevea.tv"
     var sendBirdAppId = "AE94EB49-0A01-43BF-96B4-8297EBB47F12";
     var profileURL = "https://dev.arevea.tv/api/user/v1";
     var uploadURL = "https://dev-uploads.arevea.tv/dev"//need to test in dev
     var shareURL = "https://dev.arevea.tv/channel";
     var paymentBaseURL = "https://dev.arevea.tv/api/payment/v1";
     var paymentRedirectionURL = "https://dev.arevea.tv/payment";
     var cloudSearchURL = "https://r5ibd3yzp7.execute-api.us-west-2.amazonaws.com/devel/search";
     var x_api_key = "x-api-key"
     var x_api_value = "ORnphwUvEBoqHaoIDBIA2GOhYF0HHQ53JPkLwFM5";
     var AWSCognitoIdentityPoolId = "us-west-2:2f173740-e6a4-4fc5-a37a-3064ac25e1bc"
     var red5_pro_host = "livestream.arevea.tv";
     var red5_acc_token = "YEOkGmERp08V"*/
    
    //Dev Variables END
    
    // MARK: - QA Environmet Variables Declaration
    var baseURL = "https://eku2g4rzxl.execute-api.us-west-2.amazonaws.com/dev"
    var termsURL = "https://qa.arevea.tv"
    var sendBirdAppId = "7AF38850-F099-4C47-BD19-F7F84DAFECF8";
    var profileURL = "https://qa.arevea.tv/api/user/v1"
    var uploadURL = "https://qa-uploads.arevea.tv"
    var shareURL = "https://qa.arevea.tv/channel"
    var paymentBaseURL = "https://qa.arevea.tv/api/payment/v1";
    var paymentRedirectionURL = "https://qa.arevea.tv/payment";
    var cloudSearchURL = "https://3ptsrb2obj.execute-api.us-east-1.amazonaws.com/dev";
    var x_api_key = "x-api-key"
    var x_api_value = "gq78SwjuLY539BLW5G3dN88IXjVtWPLB1YHL1omd"
    var AWSCognitoIdentityPoolId = "us-west-2:00b71663-b151-44a1-9164-246be7970493"
    var red5_pro_host = "livestream.arevea.tv";
    var red5_acc_token = "YEOkGmERp08V"
    //QA Variables END
    
    // MARK: - Pre-prod Environmet Variables Declaration
    /*var baseURL = "https://preprod-apis.arevea.tv"
     var termsURL = "https://preprod.arevea.tv"
     var sendBirdAppId = "2115A8A2-36D7-4ABC-A8CE-758500A54DFD";
     var profileURL = "https://preprod.arevea.tv/api/user/v1"
     var uploadURL = "https://preprod-uploads.arevea.tv"
     var shareURL = "https://preprod.arevea.tv/channel"
     var paymentBaseURL = "https://preprod.arevea.tv/api/payment/v1";
     var paymentRedirectionURL = "https://preprod.arevea.tv/payment";
     var cloudSearchURL = "https://preprod-apis.arevea.tv";
     var x_api_key = "x-api-key"
     var x_api_value = "xeer4W0Zt47sQ09C9OYBz3AfoYMiCaQe7gu5mEeZ"
     var AWSCognitoIdentityPoolId = "us-west-2:e1389653-813a-4f76-8af3-b15157a6ffd8"
     var red5_pro_host = "livestream1.arevea.tv";
     var red5_acc_token = "Ck2jUK49JIEp"*/
    
    //Pre-prod Variables END
    
    // MARK: - prod Environmet Variables Declaration
    /* var baseURL = "https://apis.arevea.tv"
     var termsURL = "https://www.arevea.tv"
     var sendBirdAppId = "ED4D2A9B-A140-40FD-83BF-6D240903C5BF";
     var profileURL = "https://www.arevea.tv/api/user/v1"
     var uploadURL = "https://prod-uploads.arevea.tv"
     var shareURL = "https://www.arevea.tv/c"
     var paymentBaseURL = "https://www.arevea.tv/api/payment/v1";
     var paymentRedirectionURL = "https://www.arevea.tv/payment";
     var cloudSearchURL = "https://apis.arevea.tv";
     var x_api_key = "x-api-key"
     var x_api_value = "42aCyQg9Cj7yWDuXTCwEL7Ll3j2YojHrablYoCYs"
     var AWSCognitoIdentityPoolId = "us-west-2:c239b0d1-5cd5-4fcf-86a1-e812eb6d4777"
     var red5_pro_host = "livestream2.arevea.tv";
     var red5_acc_token = "Ck2jUK49JIEp"*/
    //prod Variables END
    
    
    var emailPopulate = ""
    var strCategory = "";
    var genreId = 0;
    var aryCountries = [["region_code":"blr1","countries":["india","sri lanka","bangaldesh","pakistan","china"]],["region_code":"tor1","countries":["canada"]],["region_code":"fra1","countries":["germany"]],["region_code":"lon1","countries":["england"]],["region_code":"sgp1","countries":["singapore"]],["region_code":"sfo1","countries":["United States"]],["region_code":"sfo2","countries":["United States"]],["region_code":"ams2","countries":["netherlands"]],["region_code":"ams3","countries":["netherlands"]],["region_code":"nyc1","countries":["United States"]],["region_code":"nyc2","countries":["United States"]],["region_code":"nyc3","countries":["United States"]]]
    var strCountry = "United States"//United States
    var strRegionCode = "sfo1"//sfo1
    var detailToShow = "Stream" //for details screen to show stream/audio/video,,,etc based on serach selected item
    enum UIUserInterfaceIdiom : Int {
        case unspecified
        case phone // iPhone and iPod touch style UI
        case pad   // iPad style UI (also includes macOS Catalyst)
    }
    var appSyncClient: AWSAppSyncClient?
    
    var orientationLock = UIInterfaceOrientationMask.all
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return self.orientationLock
    }
    
    // MARK: - Application Life cycle
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        if let USER_NAME  = UserDefaults.standard.string(forKey: "USER_NAME")  {
            self.USER_NAME = USER_NAME
        }
        if let USER_NAME_FULL  = UserDefaults.standard.string(forKey: "USER_NAME_FULL")  {
            self.USER_NAME_FULL = USER_NAME_FULL
        }
        self.window?.makeKeyAndVisible()
        // Use Firebase library to configure APIs
        FirebaseApp.configure()
        //SBDMain.initWithApplicationId("9308C3B1-A36D-47E2-BA3C-8F6F362C35AF")
        SBDMain.initWithApplicationId(sendBirdAppId)
        /*locationManager = CLLocationManager()
         locationManager.delegate = self
         locationManager.desiredAccuracy = kCLLocationAccuracyBest
         locationManager.requestAlwaysAuthorization()
         
         if CLLocationManager.locationServicesEnabled(){
         locationManager.startUpdatingLocation()
         }*/
        do {
            // initialize the AppSync client configuration configuration
            let cacheConfiguration = try AWSAppSyncCacheConfiguration()
            let appSyncConfig = try AWSAppSyncClientConfiguration(appSyncServiceConfig: AWSAppSyncServiceConfig(),
                                                                  cacheConfiguration: cacheConfiguration)
            // initialize app sync client
            appSyncClient = try AWSAppSyncClient(appSyncConfig: appSyncConfig)
            
            // set id as the cache key for objects
            appSyncClient?.apolloClient?.cacheKeyForObject = { $0["id"] }
            
            print("AppSyncClient initialized with cacheConfiguration: \(cacheConfiguration)")
        } catch {
            print("Error initializing AppSync client. \(error)")
        }
        
        return true
    }
    
    func isConnectedToInternet() -> Bool {
        let hostname = "google.com"
        let hostinfo = gethostbyname(hostname)
        //let hostinfo = gethostbyname2(hostname, AF_INET6)//AF_INET6
        if hostinfo != nil {
            return true // internet available
        }
        return false // no internet
    }
    
    // MARK: UISceneSession Lifecycle
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
    
    
    
    //MARK: - location delegate methods
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let netAvailable = self.isConnectedToInternet()
        if(!netAvailable){
            return
        }
        let userLocation :CLLocation = locations[0] as CLLocation
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(userLocation) { (placemarks, error) in
            if (error != nil){
                //print("error in reverseGeocode")
            }
            let placemark = placemarks! as [CLPlacemark]
            if placemark.count>0{
                let placemark = placemarks![0]
                //print("country:",placemark.country!)
                self.strCountry = placemark.country!
                self.getRegion()
            }
        }
        
    }
    func getRegion(){
        for (i,_) in aryCountries.enumerated(){
            let element = aryCountries[i]
            let countryNames = element["countries"] as! [Any];
            for (j,_) in countryNames.enumerated() {
                let country = countryNames[j] as! String
                if(country.lowercased() == strCountry.lowercased()){
                    //print("equal:",country)
                    strRegionCode = element["region_code"]as! String
                    return
                }
            }
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        //print("Error \(error)")
    }
    func application(_ application: UIApplication, shouldSaveApplicationState coder: NSCoder) -> Bool {
        return true
    }
    
    func application(_ application: UIApplication, shouldRestoreApplicationState coder: NSCoder) -> Bool {
        return true
    }
    struct AppUtility {
        
        static func lockOrientation(_ orientation: UIInterfaceOrientationMask) {
            
            if let delegate = UIApplication.shared.delegate as? AppDelegate {
                delegate.orientationLock = orientation
            }
        }
        
        /// OPTIONAL Added method to adjust lock and rotate to the desired orientation
        static func lockOrientation(_ orientation: UIInterfaceOrientationMask, andRotateTo rotateOrientation:UIInterfaceOrientation) {
            
            self.lockOrientation(orientation)
            
            UIDevice.current.setValue(rotateOrientation.rawValue, forKey: "orientation")
            UINavigationController.attemptRotationToDeviceOrientation()
        }
        
    }
}
// MARK: - Extensions

extension UISearchBar {
    
    func getTextField() -> UITextField? { return value(forKey: "searchField") as? UITextField }
    func set(textColor: UIColor) { if let textField = getTextField() { textField.textColor = textColor } }
    func setPlaceholder(textColor: UIColor) { getTextField()?.setPlaceholder(textColor: textColor) }
    func setClearButton(color: UIColor) { getTextField()?.setClearButton(color: color) }
    
    func setTextField(color: UIColor) {
        guard let textField = getTextField() else { return }
        switch searchBarStyle {
        case .minimal:
            textField.layer.backgroundColor = color.cgColor
            textField.layer.cornerRadius = 6
        case .prominent, .default: textField.backgroundColor = color
        @unknown default: break
        }
    }
    
    func setSearchImage(color: UIColor) {
        guard let imageView = getTextField()?.leftView as? UIImageView else { return }
        imageView.tintColor = color
        imageView.image = imageView.image?.withRenderingMode(.alwaysTemplate)
    }
}

private extension UITextField {
    
    private class Label: UILabel {
        private var _textColor = UIColor.lightGray
        override var textColor: UIColor! {
            set { super.textColor = _textColor }
            get { return _textColor }
        }
        
        init(label: UILabel, textColor: UIColor = .lightGray) {
            _textColor = textColor
            super.init(frame: label.frame)
            self.text = label.text
            self.font = label.font
        }
        
        required init?(coder: NSCoder) { super.init(coder: coder) }
    }
    
    
    private class ClearButtonImage {
        static private var _image: UIImage?
        static private var semaphore = DispatchSemaphore(value: 1)
        static func getImage(closure: @escaping (UIImage?)->()) {
            DispatchQueue.global(qos: .userInteractive).async {
                semaphore.wait()
                DispatchQueue.main.async {
                    if let image = _image { closure(image); semaphore.signal(); return }
                    guard let window = UIApplication.shared.windows.first else { semaphore.signal(); return }
                    let searchBar = UISearchBar(frame: CGRect(x: 0, y: -200, width: UIScreen.main.bounds.width, height: 44))
                    window.rootViewController?.view.addSubview(searchBar)
                    searchBar.text = "txt"
                    searchBar.layoutIfNeeded()
                    _image = searchBar.getTextField()?.getClearButton()?.image(for: .normal)
                    closure(_image)
                    searchBar.removeFromSuperview()
                    semaphore.signal()
                }
            }
        }
    }
    
    func setClearButton(color: UIColor) {
        ClearButtonImage.getImage { [weak self] image in
            guard   let image = image,
                let button = self?.getClearButton() else { return }
            button.imageView?.tintColor = color
            button.setImage(image.withRenderingMode(.alwaysTemplate), for: .normal)
        }
    }
    
    var placeholderLabel: UILabel? { return value(forKey: "placeholderLabel") as? UILabel }
    
    func setPlaceholder(textColor: UIColor) {
        guard let placeholderLabel = placeholderLabel else { return }
        let label = Label(label: placeholderLabel, textColor: textColor)
        setValue(label, forKey: "placeholderLabel")
    }
    
    func getClearButton() -> UIButton? { return value(forKey: "clearButton") as? UIButton }
    
}

extension UIImage {
    func isEqual(to image: UIImage) -> Bool {
        guard let data1: Data = self.pngData(),
            let data2: Data = image.pngData() else {
                return false
        }
        return data1.elementsEqual(data2)
    }
}
extension UIImageView {
    func downloaded(from url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFit) {  // for swift 4.2 syntax just use ===> mode: UIView.ContentMode
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() { [weak self] in
                self?.image = image
            }
        }.resume()
    }
    
}
extension UINavigationController {
    
    override open var shouldAutorotate: Bool {
        get {
            if let visibleVC = visibleViewController {
                return visibleVC.shouldAutorotate
            }
            return super.shouldAutorotate
        }
    }
    
    override open var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation{
        get {
            if let visibleVC = visibleViewController {
                return visibleVC.preferredInterfaceOrientationForPresentation
            }
            return super.preferredInterfaceOrientationForPresentation
        }
    }
    
    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        get {
            if let visibleVC = visibleViewController {
                return visibleVC.supportedInterfaceOrientations
            }
            return super.supportedInterfaceOrientations
        }
    }
    
}
extension NSLayoutConstraint {
    
    static func setMultiplier(_ multiplier: CGFloat, of constraint: inout NSLayoutConstraint) {
        NSLayoutConstraint.deactivate([constraint])
        
        let newConstraint = NSLayoutConstraint(item: constraint.firstItem, attribute: constraint.firstAttribute, relatedBy: constraint.relation, toItem: constraint.secondItem, attribute: constraint.secondAttribute, multiplier: multiplier, constant: constraint.constant)
        
        newConstraint.priority = constraint.priority
        newConstraint.shouldBeArchived = constraint.shouldBeArchived
        newConstraint.identifier = constraint.identifier
        
        NSLayoutConstraint.activate([newConstraint])
        constraint = newConstraint
    }
    
}
extension Dictionary {
    var queryString: String {
        var output: String = ""
        forEach({ output += "\($0.key)=\($0.value)&" })
        output = String(output.dropLast())
        return output
    }
}
extension AVPlayerViewController {
    override open var supportedInterfaceOrientations : UIInterfaceOrientationMask     {
        return .all
    }
}
extension UIColor {
    public convenience init?(hex: String) {
        let r, g, b, a: CGFloat
        
        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])
            
            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0
                
                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255
                    
                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }
        
        return nil
    }
}

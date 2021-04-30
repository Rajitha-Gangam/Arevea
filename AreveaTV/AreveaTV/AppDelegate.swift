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
import AWSAppSync
import UIKit
import AVKit
import FirebaseCore
import Alamofire
import FirebaseMessaging
import UserNotifications
import Firebase
import PhenixSdk

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate , OpenChanannelChatDelegate{
    // MARK: - Variables Declaration
    var window: UIWindow? // <-- Here
    
    var USER_EMAIL = "";
    var plan = "";
    var USER_NAME = "";
    var USER_NAME_FULL = "";
    var USER_DISPLAY_NAME = "";
    var isLiveLoad = "0";
    var appLoaded = false
    let gcmMessageIDKey = "com.prod.arevea"
    let deviceToken = ""
    var strFCMToken = ""
    var sharedScreenBy = ""
    var ipGeoLocationURL = "https://api.ipgeolocation.io/ipgeo?apiKey=3af47278566b46e58bb63b70fb6df99d"
    var userCurrencyCode = ""
    var userCurrencySymbol = ""
    var userTimezoneOffset = 0.0
    var urlCloudFront = "https://d3vv6h15bemsva.cloudfront.net/live/"
    var isGuest = false

    var orgId = 0
    var streamId = 0
    var performerId = 0
    var strTitle = ""
    var channel_name_subscription = ""
    var isVOD = false
    var isUpcoming = false
    var isAudio = false
    var isStream = false
    var strSlug = ""
    var streamPaymentMode = ""
    var paramsForFreeRegistration = [String : Any]()
    var strTicketKey = ""
    var isPvtChatFromLeftMenu = false
    
    
    // MARK: - Dev Environmet Variables Declaration
    /*var baseURL = "https://dev1-apis.arevea.com";
     var websiteURL = "https://dev1.arevea.com"
     var sendBirdAppId = "AE94EB49-0A01-43BF-96B4-8297EBB47F12";
     var profileURL = "https://dev1.arevea.com/api/user/v1";
     var uploadURL = "https://dev1-uploads.arevea.com/dev"//need to test in dev
     var shareURL = "https://dev1.arevea.com/channel";
     var paymentBaseURL = "https://dev1.arevea.com/api/payment/v1";
     var paymentRedirectionURL = "https://dev1.arevea.com/payment";
     var cloudSearchURL = "https://r5ibd3yzp7.execute-api.us-west-2.amazonaws.com/devel/search";
     var x_api_key = "x-api-key"
     var x_api_value = "ORnphwUvEBoqHaoIDBIA2GOhYF0HHQ53JPkLwFM5";
     var AWSCognitoIdentityPoolId = "us-west-2:2f173740-e6a4-4fc5-a37a-3064ac25e1bc"
     var red5_pro_host = "livestream.arevea.com";
     var red5_acc_token = "YEOkGmERp08V"
     var ol_base_url = "https://api.us.onelogin.com";
     var ol_sub_domain = "areveatv-sandbox"
     var ol_client_id = "4e42c39db6ada915afaf60448254cd10033604c982128c55d1548e218b983279"
     var ol_client_secret = "67795bdcf01b42caeb145988f7e64bd71d00191e2abab99dc7e43bf86da3e50c"
     var ol_access_token = ""
     var FCMBaseURL = "https://r5ibd3yzp7.execute-api.us-west-2.amazonaws.com/devel"
     var socialLoginURL = "https://areveatv-sandbox.onelogin.com/access/initiate"
    
    //Dev Variables END
    */
    // MARK: - QA Environmet Variables Declaration
   /* var baseURL = "https://qa1-apis.arevea.com"
    var websiteURL = "https://qa1.arevea.com"
    var sendBirdAppId = "7AF38850-F099-4C47-BD19-F7F84DAFECF8";
    var profileURL = "https://qa1.arevea.com/api/user/v1"
    var uploadURL = "https://qa1-uploads.arevea.com"
    var shareURL = "https://qa1.arevea.com/channel"
    var paymentBaseURL = "https://qa1.arevea.com/api/payment/v1";
    var paymentRedirectionURL = "https://qa1.arevea.com/payment";
    var cloudSearchURL = "https://3ptsrb2obj.execute-api.us-east-1.amazonaws.com/dev";
    var x_api_key = "x-api-key"
    var x_api_value = "gq78SwjuLY539BLW5G3dN88IXjVtWPLB1YHL1omd"
    var AWSCognitoIdentityPoolId = "us-west-2:00b71663-b151-44a1-9164-246be7970493"
    var red5_pro_host = "livestream.arevea.com";
    var red5_acc_token = "YEOkGmERp08V"
    var ol_base_url = "https://api.us.onelogin.com";
    var ol_sub_domain = "areveatv-sandbox"
    var ol_client_id = "4e42c39db6ada915afaf60448254cd10033604c982128c55d1548e218b983279"
    var ol_client_secret = "67795bdcf01b42caeb145988f7e64bd71d00191e2abab99dc7e43bf86da3e50c"
    var ol_access_token = ""
    var FCMBaseURL = "https://eku2g4rzxl.execute-api.us-west-2.amazonaws.com/dev"
    var socialLoginURL = "https://areveatv-sandbox.onelogin.com/access/initiate"
    //QA Variables END
    */
    // MARK: - Pre-prod Environmet Variables Declaration
     var baseURL = "https://preprod-apis.arevea.tv"
     var websiteURL = "https://preprod.arevea.tv"
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
     var red5_pro_host = "livestream1.arevea.com";
     var red5_acc_token = "Ck2jUK49JIEp"
     var ol_base_url = "https://api.us.onelogin.com";
     var ol_sub_domain = "areveatv-sandbox"
     var ol_client_id = "4e42c39db6ada915afaf60448254cd10033604c982128c55d1548e218b983279"
     var ol_client_secret = "67795bdcf01b42caeb145988f7e64bd71d00191e2abab99dc7e43bf86da3e50c"
     var ol_access_token = ""
     var FCMBaseURL = "https://preprod-apis.arevea.tv"
     var socialLoginURL = "https://areveatv-sandbox.onelogin.com/access/initiate"
    
    //Pre-prod Variables END
    
    // MARK: - prod Environmet Variables Declaration
    /*var baseURL = "https://prod-apis.arevea.com"
     var websiteURL = "https://www.arevea.com"
     var sendBirdAppId = "ED4D2A9B-A140-40FD-83BF-6D240903C5BF";
     var profileURL = "https://www.arevea.com/api/user/v1"
     var uploadURL = "https://prod-uploads.arevea.com"
     var shareURL = "https://www.arevea.com/c"
     var paymentBaseURL = "https://www.arevea.com/api/payment/v1";
     var paymentRedirectionURL = "https://www.arevea.com/payment";
     var cloudSearchURL = "https://prod-apis.arevea.com";
     var x_api_key = "x-api-key"
     var x_api_value = "wehytUonSt5gtoW2IW1o03soWGcgREO87srybAKl"
     var AWSCognitoIdentityPoolId = "us-west-2:c239b0d1-5cd5-4fcf-86a1-e812eb6d4777"
     var red5_pro_host = "livestream1.arevea.com";
     var red5_acc_token = "Ck2jUK49JIEp"
     var ol_base_url = "https://api.us.onelogin.com";
     var ol_sub_domain = "areveatv-dev"
     var ol_client_id = "4f4a70d46e9cb24ce5f723837402343a1b622bca17dc041df218991c1f5eb247"
     var ol_client_secret = "d5c29333a8e9e5164d203cd7540b17e4c1d7bf2c2f52d15a01460c506a60dbca"
     var ol_access_token = ""
     var FCMBaseURL = "https://prod-apis.arevea.com"
     var socialLoginURL = "https://areveatv-dev.onelogin.com/access/initiate"
     */
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
    var selected_type = ""
    /*Phenix Variables Start*/
    public static let channelExpress: PhenixChannelExpress = { createChannelExpress() }()

    var phenixChannelAlias = "352_1619179577237_single_day_event_with_multistages"
    private static let phenixBackendEndpoint = "https://pcast.phenixrts.com/pcast"
    
    public static var phenixAccessToken = "DIGEST:eyJhcHBsaWNhdGlvbklkIjoiYXJldmVhLmNvbSIsImRpZ2VzdCI6IldsT2FlQkgwalh6YjhCUDlLU1ZUWnRYZE5YQkVRWlJqUjNIRzA2UVZaNTZIdkV4Tm5FZWxadUtnTEtHb2pFK0FQOW92OFh1aXdxMWc3bWJIUEdNd21BPT0iLCJ0b2tlbiI6IntcImV4cGlyZXNcIjoxNjE5MTg2NzMyMjQzLFwicmVxdWlyZWRUYWdcIjpcImNoYW5uZWxJZDp1cy13ZXN0I2FyZXZlYS5jb20jMzUyMTYxOTE3OTU3NzIzN1NpbmdsZURheUV2ZW50V2l0aE11bHRpc3RhZ2VzLmVnTUxiV0QzQlFERFwifSJ9"
    var phenixAccessToken1 = "DIGEST:eyJhcHBsaWNhdGlvbklkIjoiYXJldmVhLmNvbSIsImRpZ2VzdCI6IldsT2FlQkgwalh6YjhCUDlLU1ZUWnRYZE5YQkVRWlJqUjNIRzA2UVZaNTZIdkV4Tm5FZWxadUtnTEtHb2pFK0FQOW92OFh1aXdxMWc3bWJIUEdNd21BPT0iLCJ0b2tlbiI6IntcImV4cGlyZXNcIjoxNjE5MTg2NzMyMjQzLFwicmVxdWlyZWRUYWdcIjpcImNoYW5uZWxJZDp1cy13ZXN0I2FyZXZlYS5jb20jMzUyMTYxOTE3OTU3NzIzN1NpbmdsZURheUV2ZW50V2l0aE11bHRpc3RhZ2VzLmVnTUxiV0QzQlFERFwifSJ9"
    var phenixChannelId = "us-west#arevea.com#3521619179577237SingleDayEventWithMultistages.egMLbWD3BQDD"
    
    private static func createChannelExpress() -> PhenixChannelExpress {
        let pcastExpressOptions = PhenixPCastExpressFactory.createPCastExpressOptionsBuilder()
            .withBackendUri(phenixBackendEndpoint)?.withAuthenticationToken(phenixAccessToken)
            .buildPCastExpressOptions()

        let pCastExpress = PhenixPCastExpressFactory.createPCastExpress(pcastExpressOptions);

        let roomExpressOptions = PhenixRoomExpressFactory.createRoomExpressOptionsBuilder()
            .withPCastExpressOptions(pcastExpressOptions)
            .buildRoomExpressOptions()

        let channelExpressOptions = PhenixChannelExpressFactory.createChannelExpressOptionsBuilder()
            .withRoomExpressOptions(roomExpressOptions)
            .buildChannelExpressOptions()

        return PhenixChannelExpressFactory.createChannelExpress(channelExpressOptions)
    }
    /*Phenix Variables End*/

    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return self.orientationLock
    }
    public func removeTimeStamp(fromDate: Date) -> Date {
        guard let date = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day], from: fromDate)) else {
            fatalError("Failed to strip time from Date object")
        }
        return date
    }
    // MARK: - Application Life cycle
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        if let USER_NAME  = UserDefaults.standard.string(forKey: "USER_NAME")  {
            self.USER_NAME = USER_NAME
        }
        if let USER_NAME_FULL  = UserDefaults.standard.string(forKey: "USER_NAME_FULL")  {
            self.USER_NAME_FULL = USER_NAME_FULL
        }
        if let USER_DISPLAY_NAME  = UserDefaults.standard.string(forKey: "USER_DISPLAY_NAME")  {
            self.USER_DISPLAY_NAME = USER_DISPLAY_NAME
        }
        self.window?.makeKeyAndVisible()
        // Use Firebase library to configure APIs
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        
        //SBDMain.initWithApplicationId("9308C3B1-A36D-47E2-BA3C-8F6F362C35AF")
        SBDMain.initWithApplicationId(sendBirdAppId)
        
        do {
            // initialize the AppSync client configuration configuration
            let cacheConfiguration = try AWSAppSyncCacheConfiguration()
            let appSyncConfig = try AWSAppSyncClientConfiguration(appSyncServiceConfig: AWSAppSyncServiceConfig(),
                                                                  cacheConfiguration: cacheConfiguration)
            // initialize app sync client
            appSyncClient = try AWSAppSyncClient(appSyncConfig: appSyncConfig)
            
            // set id as the cache key for objects
            appSyncClient?.apolloClient?.cacheKeyForObject = { $0["id"] }
            
            //print("AppSyncClient initialized with cacheConfiguration: \(cacheConfiguration)")
        } catch {
            //print("Error initializing AppSync client. \(error)")
        }
        /*ol_access_token = UserDefaults.standard.string(forKey: "ol_access_token") ?? "";
         if (ol_access_token == ""){
         getToken()
         }*/
        appLoaded = true
        /*if #available(iOS 10.0, *) {
         // For iOS 10 display notification (sent via APNS)
         UNUserNotificationCenter.current().delegate = self
         
         let authOptions: UNAuthorizationOptions = []
         UNUserNotificationCenter.current().requestAuthorization(
         options: authOptions,
         completionHandler: {_, _ in })
         } else {
         let settings: UIUserNotificationSettings =
         UIUserNotificationSettings(types: [], categories: nil)
         application.registerUserNotificationSettings(settings)
         }
         
         application.registerForRemoteNotifications()*/
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: []) { granted, error in
            
            if let error = error {
                // Handle the error here.
            }
            
            // Enable or disable features based on the authorization.
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
    // [START receive_message]
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        showAlert(userInfo: userInfo)
        
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
    }
    func showAlert(userInfo: [AnyHashable: Any])
    {
        print("===showAlert")
        let str = "\(userInfo)"
        let alert = UIAlertController(title: "Alert", message:str , preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Click", style: UIAlertAction.Style.default, handler: nil))
        //self.window?.rootViewController?.present(alert, animated: true, completion: nil)
        let activeVc = UIApplication.shared.keyWindow?.rootViewController
        activeVc?.present(alert, animated: true, completion: nil)
        
    }
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        print("didReceiveRemoteNotification: \(userInfo)")
        //showAlert(userInfo: userInfo)
        
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print ful l message.
        print(userInfo)
        
        NotificationCenter.default.post(name: Notification.Name("PushNotification"), object: nil, userInfo: userInfo)
        completionHandler(UIBackgroundFetchResult.newData)
    }
    // [END receive_message]
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unable to register for remote notifications: \(error.localizedDescription)")
    }
    
    // This function is added here only for debugging purposes, and can be removed if swizzling is enabled.
    // If swizzling is disabled then this function must be implemented so that the APNs token can be paired to
    // the FCM registration token.
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        //showAlert(userInfo: ["deviceToken":deviceToken])
        let strToken = String(decoding: deviceToken, as: UTF8.self)
        
        print("APNs token retrieved: \(deviceToken)")
        // With swizzling disabled you must set the APNs token here.
        // Messaging.messaging().apnsToken = deviceToken
    }
    // MARK: Send Bird Methods
    func sendBirdConnect(streamInfo:[String:Any]) {
        
        // self.view.endEditing(true)
        if SBDMain.getConnectState() == .open {
            SBDMain.disconnect {
                //                    DispatchQueue.main.async {
                //                        //self.setUIsForDefault()
                //                    }
                self.sendBirdConnect(streamInfo: streamInfo)
            }
            ////print("sendBirdConnect disconnect")
        }
        else {
            let userId = UserDefaults.standard.string(forKey: "user_id");
            let nickname = self.USER_NAME_FULL
            let userDefault = UserDefaults.standard
            userDefault.setValue(userId, forKey: "sendbird_user_id")
            userDefault.setValue(nickname, forKey: "sendbird_user_nickname")
            
            //self.setUIsWhileConnecting()
            
            ConnectionManager.login(userId: userId ?? "1", nickname: nickname) { user, error in
                guard error == nil else {
                    DispatchQueue.main.async {
                        // self.setUIsForDefault()
                    }
                    // self.showAlert(strMsg:error?.localizedDescription ?? "" )
                    return
                }
                
                DispatchQueue.main.async {
                    self.gotoSchedule(streamInfo: streamInfo)
                }
            }
        }
    }
    func getTicketDetails(){
        print("==getTicketDetails")
        // let params: [String: Any] = ["userid":user_id ?? "","performer_id":"101","stream_id": "0"]
        let url: String = self.baseURL +  "/getTicketDetails"
        let headers: HTTPHeaders
        headers = [self.x_api_key: self.x_api_value]
        let params: [String: Any] = ["ticket_key": strTicketKey]
         print("getTicketDetails params:",params)
        
        AF.request(url, method: .post,parameters: params, encoding: JSONEncoding.default,headers:headers)
            .responseJSON { [self] response in
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any] {
                        print("getTicketDetails JSON:",json)
                        if (json["statusCode"]as? String == "200" ){
                            let data = json["Data"] as? [String: Any] ?? [:]
                            let userInfo = data["UserInfo"] as? [String: Any] ?? [:]
                            let streamInfo1 = data["stream_info"] as? [String: Any] ?? [:]
                            let streamInfo = streamInfo1["stream_info"] as? [String: Any] ?? [:]
                            let strSlug = streamInfo1["slug"] as? String ?? ""
                            let userID = userInfo["id"]as? String ?? ""
                            print("streamInfo:",streamInfo)
                            UserDefaults.standard.set(userID, forKey: "user_id")
                            UserDefaults.standard.set(userInfo["access_token"], forKey: "session_token")
                            UserDefaults.standard.set("guest-user", forKey: "user")

                            let fn = userInfo["user_first_name"] as? String ?? ""
                            let ln = userInfo["user_last_name"]as? String ?? ""
                            let displayName = userInfo["user_display_name"]as? String ?? ""
                            let strName = String((fn.first ?? "A")) + String((ln.first ?? "B"))
                            self.USER_NAME = strName;
                            self.USER_NAME_FULL = (fn ) + " " + (ln )
                            self.USER_DISPLAY_NAME = displayName
                            self.isLiveLoad = "1"
                            self.gotoSchedule(streamInfo: streamInfo)
                        }else{
                            let strMsg = json["message"] as? String ?? ""
                            //self.showAlert(strMsg: strMsg)
                        }
                        
                    }
                case .failure(let error):
                    let errorDesc = error.localizedDescription.replacingOccurrences(of: "URLSessionTask failed with error:", with: "")
                    //self.showAlert(strMsg: errorDesc)
                    
                }
            }
    }
//when user click (watch) Button on Mail, Navigation Hadle
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        print("Continue User Activity called: ")
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
            let url = userActivity.webpageURL!
            print("open url in app del:",url.absoluteString)
            // alternative: not case sensitive
            //https://qa1.arevea.com/schedule/1898-101059776-d85HRNgYlGhi
            let url1 = url.absoluteString
            //handle url and open whatever page you want to open.
            if(url1 == self.websiteURL){
                gotoDB()
            }
            else if url1.range(of:"/schedule/") != nil {
                let link = url1.components(separatedBy: "/schedule/")//https://preprod.arevea.tv/schedule/1844-120076432-aw0T2PqSZg3C
                if(link.count > 1){
                    let ticketKey: String = link[1]
                    print("ticketKey:",ticketKey)
                    isVOD = false
                    self.strTicketKey = ticketKey
                    getTicketDetails()
                }
            }else if url1.range(of:"/stream/") != nil {
                let link = url1.components(separatedBy: "/stream/")//https://preprod.arevea.tv/stream/7246-101059655-4JADmNVFYiBb/stage=7247
                if(link.count > 1){
                    let ticketKey: String = link[1]//
                    let ticketKey1 = ticketKey.components(separatedBy: "/")//7246-101059655-4JADmNVFYiBb/stage=7247
                    print("ticketKey:",ticketKey)
                    print("ticketKey1:",ticketKey1)
                    print("ticketKey2:",ticketKey1[0])
                    isVOD = false
                    self.strTicketKey = ticketKey1[0]
                    getTicketDetails()
                }
            }else if url1.range(of:"/watch/") != nil {
                let link = url1.components(separatedBy: "/watch/")
                if(link.count > 1){
                    let ticketKey: String = link[1]
                    print("ticketKey:",ticketKey)
                    isVOD = true
                    self.strTicketKey = ticketKey
                    getTicketDetails()
                }
            }else if(url1.range(of:"/payment/") != nil || url1.range(of:"/place-order") != nil){
                //to resolve below issue
               // In ios application>>After payment completed when we click on open button near Arevea App in header again redirecting to payment page.
            }else{
                print("url to open:",url)
                UIApplication.shared.open(url)
            }
        }
        return true
    }
    func gotoDB(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil);
        let vc = storyboard.instantiateViewController(withIdentifier: "DashBoardVC") as! DashBoardVC
        let rootViewController = self.window!.rootViewController as! UINavigationController
        print("Nav from mail")
        rootViewController.pushViewController(vc, animated: true)
    }
    func gotoSchedule(streamInfo:[String:Any]){
        print("gotoSchedule")
        let storyboard = UIStoryboard(name: "Main", bundle: nil);
         let stream_video_title = streamInfo["stream_video_title"] as? String ?? "Channel Details"

        let vc = storyboard.instantiateViewController(withIdentifier: "ScheduleVC") as! ScheduleVC
       let orgId = streamInfo["organization_id"] as? Int ?? 0
       let streamId = streamInfo["id"] as? Int ?? 0
       let performerId = streamInfo["performer_id"] as? Int ?? 0
       let channelName = streamInfo["channel_name"] as? String ?? ""
       self.strSlug = streamInfo["slug"] as? String ?? "";

        self.orgId = orgId
        self.streamId = streamId
        vc.chatDelegate = self
        self.performerId = performerId
        self.strTitle = stream_video_title
        //vc.isCameFromGetTickets = true
        self.channel_name_subscription = channelName
       self.isGuest = true
        if(!isVOD){
            self.isUpcoming = true
        }
       let rootViewController = self.window!.rootViewController as! UINavigationController
       print("Nav from mail")
       rootViewController.pushViewController(vc, animated: true)
        
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
        // //print("===applicationDidBecomeActive:",appLoaded)
        if(appLoaded){
            
        }
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
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
// [START ios_10_message_handling]
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print("---ui:",userInfo)
        // NotificationCenter.default.post(name: Notification.Name("PushNotification"), object: nil, userInfo: userInfo)
        
        // Change this to your preferred presentation option
        completionHandler([[.alert, .sound]])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Print full message.
        print(userInfo)
        
        completionHandler()
    }
}
// [END ios_10_message_handling]


extension AppDelegate : MessagingDelegate {
    // [START refresh_token]
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(String(describing: fcmToken))")
        strFCMToken = fcmToken ?? ""
        
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }
    // [END refresh_token]
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
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
    convenience init(hexString: String) {
            let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
            var int = UInt64()
            Scanner(string: hex).scanHexInt64(&int)
            let a, r, g, b: UInt64
            switch hex.count {
            case 3: // RGB (12-bit)
                (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
            case 6: // RGB (24-bit)
                (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
            case 8: // ARGB (32-bit)
                (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
            default:
                (a, r, g, b) = (255, 0, 0, 0)
            }
            self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
        }
    
}
extension Date {
    
    func isEqualTo(_ date: Date) -> Bool {
        return self == date
    }
    
    func isGreaterThan(_ date: Date) -> Bool {
        return self > date
    }
    
    func isSmallerThan(_ date: Date) -> Bool {
        return self < date
    }
    
    // Convert local time to UTC (or GMT)
    func toGlobalTime() -> Date {
        let timezone = TimeZone.current
        let seconds = -TimeInterval(timezone.secondsFromGMT(for: self))
        return Date(timeInterval: seconds, since: self)
    }
    
    // Convert UTC (or GMT) to local time
    func toLocalTime() -> Date {
        let timezone = TimeZone.current
        let seconds = TimeInterval(timezone.secondsFromGMT(for: self))
        return Date(timeInterval: seconds, since: self)
    }
    static func getFormattedDate(strDate: String , formatter:String) -> String{
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = formatter
        
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "MMM dd,yyyy"
        
        let date: Date? = dateFormatterGet.date(from: strDate)
        return dateFormatterPrint.string(from: date!);
    }
    
}
extension String {
    func convertDateString() -> String? {
        return convert(dateString: self, fromDateFormat: "yyyy-MM-dd HH:mm:ss", toDateFormat: "yyyy-MM-dd")
    }
    
    func convert(dateString: String, fromDateFormat: String, toDateFormat: String) -> String? {
        let fromDateFormatter = DateFormatter()
        fromDateFormatter.dateFormat = fromDateFormat
        if let fromDateObject = fromDateFormatter.date(from: dateString) {
            let toDateFormatter = DateFormatter()
            toDateFormatter.dateFormat = toDateFormat
            let newDateString = toDateFormatter.string(from: fromDateObject)
            return newDateString
        }
        return nil
    }
    static func getFormattedDate(strDate: String , formatter:String) -> Date{
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = formatter
        dateFormatterGet.timeZone = NSTimeZone(abbreviation: "UTC") as TimeZone?
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "MMM dd, yyyy"
        
        let date: Date? = dateFormatterGet.date(from: formatter)
        return date ?? Date()
    }
    static func getFormattedDate1(strDate: String , formatter:String) -> Date{
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = formatter
        dateFormatterGet.timeZone = NSTimeZone(abbreviation: "UTC") as TimeZone?
        dateFormatterGet.locale = Locale(identifier: "en_US_POSIX")
        
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "dd-MMM-yyyy HH:mm"
        
        let date: Date? = dateFormatterGet.date(from: formatter)
        return date ?? Date()
    }
    
    func image() -> UIImage? {
        let size = CGSize(width: 45, height: 45)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        UIColor.clear.set()
        let rect = CGRect(origin: .zero, size: size)
        UIRectFill(CGRect(origin: .zero, size: size))
        (self as AnyObject).draw(in: rect, withAttributes: [.font: UIFont.systemFont(ofSize: 40)])
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return NSAttributedString() }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return NSAttributedString()
        }
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
    var length: Int {
        return count
    }

    subscript (i: Int) -> String {
        return self[i ..< i + 1]
    }

    func substring(fromIndex: Int) -> String {
        return self[min(fromIndex, length) ..< length]
    }

    func substring(toIndex: Int) -> String {
        return self[0 ..< max(0, toIndex)]
    }

    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                            upper: min(length, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[start ..< end])
    }
    
}
extension Array where Element : Equatable  {
    public mutating func removeObject(_ item: Element) {
        if let index = self.firstIndex(of: item) {
            self.remove(at: index)
        }
    }
}


extension Sequence where Iterator.Element: Hashable {
    func unique() -> [Iterator.Element] {
        var seen: [Iterator.Element: Bool] = [:]
        return self.filter { seen.updateValue(true, forKey: $0) == nil }
    }
}
extension Notification.Name {
    static let didReceiveStreamData = Notification.Name("didReceiveStreamData")
    static let didReceiveScreenShareData = Notification.Name("didReceiveScreenShareData")
    static let StreamOrienationChange = Notification.Name("StreamOrienationChange")
    static let Notification_Q_And_A_Reply = Notification.Name("Notification_Q_And_A_Reply")
}

//
//  AppDelegate.swift
//  AreveaTV
//
//  Created by apple on 4/18/20.
//  Copyright © 2020 apple. All rights reserved.
//

import UIKit
import Firebase
import SendBirdSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow? // <-- Here
    
    var USER_EMAIL = "";
    var plan = "";
    var qaURL = "https://qa.arevea.tv/api/user/v1"
    var USER_NAME = "";
    var USER_NAME_FULL = "";

    //var baseURL = "http://52.25.98.205/api/user/v1";
    //var baseURL = "https://private-anon-c5fd1ec25e-viv3consumer.apiary-mock.com/dev";
    var baseURL = "https://eku2g4rzxl.execute-api.us-west-2.amazonaws.com/dev"
    //var baseURL = "https://eku2g4rzxl.execute-api.us-west-2.amazonaws.com/dev";
    
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
        SBDMain.initWithApplicationId("9308C3B1-A36D-47E2-BA3C-8F6F362C35AF")

        return true
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
    
    
    
    
    
    
    
    
}


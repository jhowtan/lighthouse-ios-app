//
//  AppDelegate.swift
//  Lighthouse
//
//  Created by Roland on 9/6/15.
//  Copyright (c) 2015 Digital Arts Network. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate:
    UIResponder, UIApplicationDelegate, ESTBeaconManagerDelegate,
    CLLocationManagerDelegate{

    var window: UIWindow?

    // ---------- APPLICATION SETUP ------------------------
    // AppDelegate.application : handles notification and beacon settings
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Setup notifications
        let notificationType = UIUserNotificationType.Alert | UIUserNotificationType.Badge | UIUserNotificationType.Sound
        let settings = UIUserNotificationSettings(forTypes: notificationType, categories: nil)
        application.registerUserNotificationSettings(settings)
        
        return true
    }
    
    // AppDelegate.application : Handle redirects from Google to application
    func application(application: UIApplication, openURL url: NSURL,
        sourceApplication: String?, annotation: AnyObject?) -> Bool {
            return GPPURLHandler.handleURL(url,
                sourceApplication:sourceApplication,
                annotation:annotation)
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        // println("in background and starting monitoring")
        
        // Start monitoring the reception region
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

}


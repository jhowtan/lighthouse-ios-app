//
//  AppDelegate.swift
//  Lighthouse
//
//  Created by Roland on 9/6/15.
//  Copyright (c) 2015 Digital Arts Network. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, ESTBeaconManagerDelegate, CLLocationManagerDelegate, GPPSignInDelegate {

    var window: UIWindow?
    
    // Beacon variables
    // Should shift beaconManager to AppDelegate
    let beaconManager = ESTBeaconManager()
    var beaconRegion:CLBeaconRegion?
    var beacons = [Beacon]()
    
    // Firebase reference
    let fbRootRef = Firebase(url:"https://beacon-dan.firebaseio.com/")
    let beaconsRef = Firebase(url:"https://beacon-dan.firebaseio.com/beacons/")
    let locationRef = Firebase(url:"https://beacon-dan.firebaseio.com/location/")
    let messagesRef = Firebase(url:"https://beacon-dan.firebaseio.com/messages/")
    
    // Other global variables
    var myMessages = [Message]()
    var activeMenu = 0
    var currentView = "mainmenu"
    
    // Google auth variables
    let googleClientID = "186193271444-835107nm0lkjlepsmv66fkl4rp6eoir7.apps.googleusercontent.com"
    // Temp user ID
    var currentUser = "google:118075399016047699152"

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?, openURL url: NSURL, sourceApplication: String, annotation: AnyObject?) -> Bool {
        
        // Setup notifications
        let notificationType = UIUserNotificationType.Alert | UIUserNotificationType.Badge | UIUserNotificationType.Sound
        let settings = UIUserNotificationSettings(forTypes: notificationType, categories: nil)
        application.registerUserNotificationSettings(settings)
        
        // Add the beacon manager delegate
        beaconManager.delegate = self
        
        // return true
        return GPPURLHandler.handleURL(url,
                sourceApplication:sourceApplication,
                annotation:annotation)
    }
    
    // BeaconManager Class for listening to events:
    // enterRegion, exitRegion, etc.
    func beaconManager(manager: AnyObject!,
        didRangeBeacons beacons: [AnyObject]!,
        inRegion region: CLBeaconRegion!) {
            
            // To do:
            // Check if nearestBeacon minor values match any of those in self.myMessages.
            // If true: Push notification to phone.
            if let nearestBeacon = beacons.first as? CLBeacon {
                // stop polling for beacons
                beaconManager.stopRangingBeaconsInRegion(region)
                println(nearestBeacon)
            }
    }
    
    func startRanging(uuid:NSUUID){
        beaconRegion = CLBeaconRegion(
            proximityUUID: uuid,
            identifier: "Lighthouse")
        
        println("ranging")
        
        beaconManager.requestWhenInUseAuthorization()
        beaconManager.startRangingBeaconsInRegion(beaconRegion)
    }
    
    func getFirebaseData() {
        // Get reception beacon label
        locationRef.childByAppendingPath("reception").childByAppendingPath("beacon")
        .observeEventType(.Value, withBlock: { recep in
            // recepKey is the name of the reception beacon
            let recepKey = recep.value as? String
                
            println(recepKey!)
        })
        
        // Get and save the constant beacon object
        beaconsRef.observeSingleEventOfType(.Value, withBlock: { beacon in
            let child = beacon.children
            
            while let b = child.nextObject() as? FDataSnapshot {
                // Create new beacon object
                var nBeacon = Beacon()
                
                // Assign the attribute name
                nBeacon.name = b.key as String
                
                for rest in b.children.allObjects as! [FDataSnapshot] {
                    // Assign inner attributes
                    if(rest.key == "minor") {
                        nBeacon.minor = rest.value as? String
                    }
                    if(rest.key == "major") {
                        nBeacon.major = rest.value as? String
                    }
                    if(rest.key == "uuid") {
                        nBeacon.uuid = rest.value as? String
                    }
                }
                
                // Push beacon to global beacon variable
                self.beacons.append(nBeacon)
            }
        })

    }
    
    func addMessageSnapshot(messages:FDataSnapshot){
        let children = messages.children
        var newMessage = Message()
        
        while let message = children.nextObject() as? FDataSnapshot {
            switch message.key {
            case "date":
                var dateFormatter = NSDateFormatter()
                dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
                dateFormatter.timeStyle = .ShortStyle
                
                if let t = message.value as? NSTimeInterval {
                    // Cast the value to an NSTimeInterval
                    // and divide by 1000 to get seconds.
                    let date = NSDate(timeIntervalSince1970: t/1000)
                    
                    newMessage.date = dateFormatter.stringFromDate(date)
                }
                
            case "location":
                newMessage.location = message.value as? String
            case "message":
                newMessage.message = message.value as? String
            case "status":
                newMessage.status = message.value as? String
            case "title":
                newMessage.title = message.value as? String
            case "type":
                newMessage.type = message.value as? String
            default:
                println("Nothing to see here...")
            }
        }
        
        myMessages.insert(newMessage, atIndex: 0)
    }
        
    func authenticateWithGoogle() {
        // use the Google+ SDK to get an OAuth token
        var signIn = GPPSignIn.sharedInstance()
        signIn.shouldFetchGooglePlusUser = true
        signIn.clientID = googleClientID
        signIn.scopes = ["email"]
        signIn.delegate = self
        signIn.authenticate()
    }
    
    func finishedWithAuth(auth: GTMOAuth2Authentication!, error: NSError!) {
        if error != nil {
            // There was an error obtaining the Google+ OAuth Token
            println("Error! \(error)")
        } else {
            // We successfully obtained an OAuth token, authenticate on Firebase with it
            let ref = Firebase(url: "https://beacon-dan.firebaseio.com")
            ref.authWithOAuthProvider("google", token: auth.accessToken,
                withCompletionBlock: { error, authData in
                    if error != nil {
                        // Error authenticating with Firebase with OAuth token
                    } else {
                        // User is now logged in!
                        println("Successfully logged in! \(authData)")
                    }
            })
        }
    }

    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
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


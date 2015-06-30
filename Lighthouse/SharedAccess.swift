//
//  KeepAlive.swift
//  Lighthouse
//
//  Created by Roland on 30/6/15.
//  Copyright (c) 2015 Digital Arts Network. All rights reserved.
//

import UIKit

class SharedAccess: UIView, ESTBeaconManagerDelegate, CLLocationManagerDelegate {
    // Firebase reference
    let fbRootRef = Firebase(url:"https://beacon-dan.firebaseio.com/")
    let beaconsRef = Firebase(url:"https://beacon-dan.firebaseio.com/beacons/")
    let locationRef = Firebase(url:"https://beacon-dan.firebaseio.com/location/")
    let messagesRef = Firebase(url:"https://beacon-dan.firebaseio.com/messages/")
    let roomsRef = Firebase(url:"https://beacon-dan.firebaseio.com/rooms/")
    
    // Beacon variables
    let beaconManager = ESTBeaconManager()
    var beaconRegion:CLBeaconRegion?
    var beacons = [Beacon]() // local store from Firebase
    var detectedBeacons = [] // use with beaconManager
    
    // Other global variables
    var myMessages = [Message]()
    var activeView = 0
    var currentView = "mainmenu"
    var currentUser = ""
    var auth : NSObject?
    
    // Google auth variables
    let googleClientID = "186193271444-835107nm0lkjlepsmv66fkl4rp6eoir7.apps.googleusercontent.com"
    
    // Reference to current TableViewController
    var currentTableView: ItemsTableViewController?
    
    // Instantiate the Singleton
    class var sharedInstance : SharedAccess {
        struct Static {
            static let instance : SharedAccess = SharedAccess()
        }
        return Static.instance
    }
    
    // View Methods
    func setCurView(view:String){
        currentView = view
    }
    
    // -------- FIREBASE METHODS --------------------------
    // Add reference to initial firebase data
    func cacheFirebaseData() {
        // Get and save the static beacon object from firebase
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
        
        
        
        // --------- OBTAIN KEY FOR CURRENT LOCATION ---------------
        // USE BEACON TO DETECT NEAREST BEACON THEN USE THAT TO MATCH AGAINST LOCATIONS
        
        //        // Get reception key to retrieve reception messages from Reception
        //        locationRef.childByAppendingPath("reception").childByAppendingPath("beacon")
        //            .observeEventType(.Value, withBlock: { recep in
        //                // recepKey is the name of the reception beacon
        //                let recepKey = recep.value as? String
        //                println("RecepKey: \(recepKey!)")
        //            })
        
        
        
    }
    
    // ------ Blast(Messaging) Methods -------
        // Get all of the current user's messages
        // This is just used to list the messages the current user has
    
    func getUserMessages(){
        // .Value will always be triggered last so the ordering does not matter
        // We just need to cache the messages on load to pass to the Messages View
        
        messagesRef.childByAppendingPath(currentUser).observeEventType(.ChildAdded, withBlock: { messages in
            // Use the appdelegate add message method
            self.addMessageSnapshot(messages)
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
        
        if(currentTableView != nil){
            currentTableView!.insertNewObject()
        }
    }
    
    
    // --------- BEACON MANAGEMENT METHODS ------------------
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
                println("BeaconManager fired, nearest: \(nearestBeacon)")
                // nearestBeacon is a CLBeacon object
                // use nearestBeacon.minor to match with list of beacons in AppDelegate
                // to find location to filter by
            }
    }
    
    func startRanging(){
        beaconRegion = CLBeaconRegion(
            proximityUUID: NSUUID(UUIDString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D"),
            identifier: "Lighthouse")
        
        println("BeaconManager has begun ranging...")
        
        beaconManager.requestWhenInUseAuthorization()
        beaconManager.startRangingBeaconsInRegion(beaconRegion)
    }

}

let sharedAccess = SharedAccess()
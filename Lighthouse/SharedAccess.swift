//
//  KeepAlive.swift
//  Lighthouse
//
//  Created by Roland on 30/6/15.
//  Copyright (c) 2015 Digital Arts Network. All rights reserved.
//

import UIKit
import SwiftyJSON

class SharedAccess: UIView, ESTBeaconManagerDelegate {
    // Firebase reference
    let fbRootRef = Firebase(url:"https://beacon-dan.firebaseio.com/")
    let beaconsRef = Firebase(url:"https://beacon-dan.firebaseio.com/beacons/")
    let locationRef = Firebase(url:"https://beacon-dan.firebaseio.com/location/")
    let messagesRef = Firebase(url:"https://beacon-dan.firebaseio.com/messages/")
    
    // Beacon variables
    let beaconManager = ESTBeaconManager()
    let beaconRegion = CLBeaconRegion(
        proximityUUID: NSUUID(UUIDString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D"),
        identifier: "Lighthouse")
    
    var beaconList = [Beacon]() // local store from Firebase
    var locationList = [Location]()
    var receptionBeacon:Beacon?
    
    // Other global variables
    var myMessages = [Message]()
    var activeView = 0
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
    
    
    // -------- FIREBASE METHODS --------------------------
    func cacheFirebaseData() {
        // Get and save the static beacon object from firebase
        // Add reference to reception label
        
        locationRef.observeSingleEventOfType(.Value, withBlock: { beacon in
            let child = beacon.children
            var receptionLabel = ""
            
            while let l = child.nextObject() as? FDataSnapshot {
                // Create new beacon object
                var nLocation = Location()
                
                // Assign the attribute name
                nLocation.key = l.key as String
                
                for loc in l.children.allObjects as! [FDataSnapshot] {
                    // Assign inner attributes
                    if(loc.key == "name") {
                        nLocation.name = loc.value as? String
                    }
                    if(loc.key == "beacon") {
                        nLocation.beacon = loc.value as? String
                    }
                    
                    // catch the beacon name for reception
                    if(nLocation.name == "Reception") {
                        receptionLabel = nLocation.beacon!
                        println("receptionLabel is \(receptionLabel)")
                    }

                }
                
                // Push beacon to global beacon variable
                self.locationList.append(nLocation)
            }
            
            self.beaconsRef.observeSingleEventOfType(.Value, withBlock: { beacon in
                let child = beacon.children
                
                while let b = child.nextObject() as? FDataSnapshot {
                    // Create new beacon object
                    var nBeacon = Beacon()
                    
                    // Assign the attribute name
                    nBeacon.name = b.key as String
                    
                    for rest in b.children.allObjects as! [FDataSnapshot] {
                        // Assign inner attributes
                        if(rest.key == "minor") {
                            nBeacon.minor = rest.value as? Int
                        }
                        if(rest.key == "major") {
                            nBeacon.major = rest.value as? Int
                        }
                        if(rest.key == "uuid") {
                            nBeacon.uuid = rest.value as? String
                        }
                    }
                    
                    if(nBeacon.name == receptionLabel) {
                        self.receptionBeacon = nBeacon
                        // println("Found the receptionBeacon! ------ \(self.receptionBeacon?.minor)")
                    }
                    
                    // Push beacon to global beacon variable
                    self.beaconList.append(nBeacon)
                }
            })
        })
        
        
        // Add the beacon manager delegate
        beaconManager.delegate = self
        
        // Start Ranging for beacons
        sharedAccess.startRanging()
    }
    
    
    // ------ Blast(Messaging) Methods -------
    func getUserMessages(){
        // .Value will always be triggered last so the ordering does not matter
        // We just need to cache the messages on load to pass to the Messages View
        
        // This is just used to list the messages the current user has
        messagesRef.childByAppendingPath(currentUser).observeEventType(.ChildAdded, withBlock: { messages in
            let json = JSON(messages.value)
            var newMessage = Message(json: json)
            
            // Use the appdelegate add message method
            self.addMessageSnapshot(newMessage)
        })
    }
    
    func addMessageSnapshot(newMessage: Message) {
        myMessages.insert(newMessage, atIndex: 0)
        
        if(currentTableView != nil){
            currentTableView!.insertNewObject()
        }
    }
    
    // --------- BEACON MANAGEMENT METHODS ------------------
    func beaconManager(manager: AnyObject!, didRangeBeacons beacons: [AnyObject]!, inRegion region: CLBeaconRegion!) {
            // To do:
            // Push notification for messages.
        
        if let nearestBeacon = beacons.first as? CLBeacon {
            // beaconManager.stopRangingBeaconsInRegion(region)
            // nearestBeacon is a CLBeacon object
            // use nearestBeacon.minor to match with list of beacons in AppDelegate
            
            // if nearest beacon is the reception beacon, alert the user
            if(receptionBeacon != nil && nearestBeacon.minor.integerValue == receptionBeacon!.minor){
                println("Neareset beacon check \(nearestBeacon.minor.integerValue == receptionBeacon!.minor)")
                Notifications.display("You have some parcel for pickup.")
            }
        }
    }
    
    func beaconManager(manager: AnyObject!, didStartMonitoringForRegion region: CLBeaconRegion!) {
        
    }
    
    func startRanging(){
//        beaconManager.requestWhenInUseAuthorization()
        beaconManager.requestAlwaysAuthorization()
        beaconManager.startRangingBeaconsInRegion(beaconRegion)
        println("BeaconManager has begun ranging...")
    }

}

let sharedAccess = SharedAccess()
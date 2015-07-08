//
//  SharedAccess.swift
//  Lighthouse
//
//  For beacon methods management and global variables:
//  Beacons, Locations, Auth variables
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
    
    // Beacon variables
    let beaconManager = ESTBeaconManager()
    let meetingRoomRegion = CLBeaconRegion(
        proximityUUID: NSUUID(UUIDString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D"),
        identifier: "LighthouseRooms")
    
    var beaconList = [Beacon]() // local store from Firebase
    var locationList = [Location]()
    var receptionBeacon:Beacon?
    
    var receptionRegion:CLBeaconRegion?
    
    // Other global variables
    var activeView = 0
    // Variable to check if app is on background or foreground
    var inForeground = true
    
    // Login Auth variables
    // var auth : FAuthData?
    var currentUser = ""
    var currentUserName = ""
    var currentUserEmail = ""
    var accessToken = ""
    
    // Messages array should be in SharedAccess so we can initialise it from init 
    // and query the length of the array
    var myMessages = [Message]()
    var pingedForeground = false
    var pingedBackground = false
    
    // Declare the Singleton
    class var sharedInstance : SharedAccess {
        struct Static {
            static let instance : SharedAccess = SharedAccess()
        }
        return Static.instance
    }
    
    // Google auth variables
    let googleClientID = "186193271444-835107nm0lkjlepsmv66fkl4rp6eoir7.apps.googleusercontent.com"
    
    // Reference to current TableViewController
    var currentTableView: UITableViewController?
    
    // View Methods

    // -------- FIREBASE METHODS --------------------------
    func cacheFirebaseData() {
        // Add the beacon manager delegate
        beaconManager.delegate = self
        
        // Start Ranging for beacons
        SharedAccess.sharedInstance.startRanging()
        
        // Get and save the static beacon object from firebase
        // Add reference to reception label
        locationRef.observeSingleEventOfType(.Value, withBlock: { locations in
            var receptionLabel = ""
            
            let json = JSON(locations.value)
            for (key: String, subJson: JSON) in json {
                var nLocation = Location(json: subJson)
                nLocation.key = key
                self.locationList.append(nLocation)
                
                // catch the beacon name for reception
                if(nLocation.name == "Reception") {
                    receptionLabel = nLocation.beacon!
                }
            }
            
            self.beaconsRef.observeSingleEventOfType(.Value, withBlock: { beacons in
                let json = JSON(beacons.value)
                for (key: String, subJson: JSON) in json {
                    var nBeacon = Beacon(json: subJson)
                    nBeacon.name = key
                    // catch the beacon name for reception
                    if (nBeacon.name == receptionLabel) {
                        self.receptionBeacon = nBeacon
                        println("Retrieved the receptionBeacon! ------ \(self.receptionBeacon!.name)")
                        
                        let bcnMinor = nBeacon.minor as CLBeaconMinorValue
                        let bcnMajor = nBeacon.major as CLBeaconMajorValue
                        
                        // Declare reception region after getting the minor and major values of the reception beacon from firebase
                        self.receptionRegion = CLBeaconRegion(proximityUUID: NSUUID(UUIDString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D"), major: nBeacon.major, minor: nBeacon.minor, identifier: "LighthouseReception")
                        
                    }
                    
                    // Push beacon to global beacon variable
                    self.beaconList.append(nBeacon)
                }
            })
        })
    }
    
    // --------- BEACON MANAGEMENT METHODS ------------------
    func isBeacon(beacon: CLBeacon, withUUID UUIDString: String, major: CLBeaconMajorValue, minor: CLBeaconMinorValue) -> Bool {
        return beacon.proximityUUID.UUIDString == UUIDString && beacon.major.unsignedShortValue == major && beacon.minor.unsignedShortValue == minor
    }
    
    func beaconManager(manager: AnyObject!, didRangeBeacons beacons: [AnyObject]!, inRegion region: CLBeaconRegion!) {
            // To do:
            // Push notification for messages.
        
        if let nearestBeacon = beacons.first as? CLBeacon {
            // beaconManager.stopRangingBeaconsInRegion(region)
            // nearestBeacon is a CLBeacon object
            // use nearestBeacon.minor to match with list of beacons in AppDelegate
            
            // if nearest beacon is the reception beacon, alert the user
            
            if(receptionBeacon != nil && currentTableView != nil && myMessages.count > 0){
                println("we are ranging and we have view and beacon identified...")
                // Check if nearest beacon is
                if isBeacon(nearestBeacon, withUUID: receptionBeacon!.uuid!, major: receptionBeacon!.major!, minor: receptionBeacon!.minor!) {
                    
                    // Loop through the messages arrray and check if any message came from reception
                    for msg in myMessages {
                        // If message is found, notify the user
                        if(msg.type == "Beacon" && msg.location == "reception" && !pingedForeground) {
                            Notifications.alert("You have a parcel", message: "Please pickup your parcel since your near reception.", view: self.currentTableView!)
                            pingedForeground = true
                        }
                        
                    }
                    
                }
            }
        }
    }
    
    func beaconManager(manager: AnyObject!, didStartMonitoringForRegion region: CLBeaconRegion!) {
        println("we are now monitoring")

    }
    
    func beaconManager(manager: AnyObject!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .Denied || status == .Restricted {
            NSLog("Location Services authorization denied, can't range")
        }
    }
    
    func beaconManager(manager: AnyObject!, rangingBeaconsDidFailForRegion region: CLBeaconRegion!, withError error: NSError!) {
        NSLog("Ranging beacons failed for region '%@'\n\nMake sure that Bluetooth and Location Services are on, and that Location Services are allowed for this app. Also note that iOS simulator doesn't support Bluetooth.\n\nThe error was: %@", region.identifier, error);
    }
    
    func beaconManager(manager: AnyObject!, didEnterRegion region: CLBeaconRegion!) {
        println("You have entered a region \(pingedForeground) \(pingedBackground)")
        
        // Check the messages array if you have any message from reception
        for msg in myMessages {
            if(msg.type == "Beacon" && msg.location == "reception" && !pingedBackground) {
                Notifications.display("Please pickup your parcel.")
                pingedBackground = true
            }
        }
    }
    
    func beaconManager(manager: AnyObject!, didExitRegion region: CLBeaconRegion!) {
        println("You are out of the region.")
    }
    
    func startRanging(){
        println("Start ranging...")
        beaconManager.requestAlwaysAuthorization()
        beaconManager.startRangingBeaconsInRegion(meetingRoomRegion)
    }
    
    func startMonitoring(){
        println("Start monitoring...")
        if(receptionRegion != nil) {
            // Start monitoring the reception region
            beaconManager.startMonitoringForRegion(receptionRegion)
        }
    }
    
}

// Initialize singleton even before initialising any view
let sharedAccess = SharedAccess()
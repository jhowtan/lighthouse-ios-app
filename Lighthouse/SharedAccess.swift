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
    let beaconRegion = CLBeaconRegion(
        proximityUUID: NSUUID(UUIDString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D"),
        identifier: "Lighthouse")
    
    var beaconList = [Beacon]() // local store from Firebase
    var locationList = [Location]()
    var receptionBeacon:Beacon?
    
    // Other global variables
    var activeView = 0
    // Login Auth variables
    var auth : FAuthData? // user .uid for currentUser id; .token for accessToken
    var currentUser = ""
    var accessToken = ""
    
    // Instantiate the Singleton
    class var sharedInstance : SharedAccess {
        struct Singleton {
            static let instance = SharedAccess()
        }
        return Singleton.instance
    }
    
    // Google auth variables
    let googleClientID = "186193271444-835107nm0lkjlepsmv66fkl4rp6eoir7.apps.googleusercontent.com"
    
    // Reference to current TableViewController
    var currentTableView: ItemsTableViewController?
    
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
                    println("SharedAccess.swift - cacheFirebaseData(): receptionLabel is \(receptionLabel)")
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
//                        println("Found the receptionBeacon! ------ \(self.receptionBeacon?.minor)")
                    }
                    
                    // Push beacon to global beacon variable
                    self.beaconList.append(nBeacon)
                }
            })
        })
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
        // For when the app goes into background
    }
    
    func startRanging(){
//        beaconManager.requestWhenInUseAuthorization()
        beaconManager.requestAlwaysAuthorization()
        beaconManager.startRangingBeaconsInRegion(beaconRegion)
        println("BeaconManager has begun ranging...")
    }

}
//
//  MasterViewController.swift
//  Lighthouse
//
//  Created by Roland on 9/6/15.
//  Copyright (c) 2015 Digital Arts Network. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController, ESTBeaconManagerDelegate, CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate {

    var objects = [AnyObject]()
    
    // Beacon variables
    // Should shift beaconManager to AppDelegate
    let beaconManager = ESTBeaconManager()
    var beaconRegion:CLBeaconRegion?
    
    // Firebase reference
    let fbRootRef = Firebase(url:"https://beacon-dan.firebaseio.com/")
    let beaconsRef = Firebase(url:"https://beacon-dan.firebaseio.com/beacons/")
    let locationRef = Firebase(url:"https://beacon-dan.firebaseio.com/location/")
    let messagesRef = Firebase(url:"https://beacon-dan.firebaseio.com/messages/")
    
    // Public variables
    var recepBeacon:[String:String] = ["uuid":""] // Instantiate null object
    var myMessage = [0:["beacon":""]]
    

    override func awakeFromNib() {
        super.awakeFromNib()
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            self.clearsSelectionOnViewWillAppear = false
            self.preferredContentSize = CGSize(width: 320.0, height: 600.0)
        }
    }

    // Initialization method called automatically when App is launched.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set main navigation logo
        let image = UIImage(named: "nav-logo")
        self.navigationItem.titleView = UIImageView(image: image)
        
        // Do any additional setup after loading the view, typically from a nib.
        // self.navigationItem.leftBarButtonItem = self.editButtonItem()
        
        // Add the beacon manager delegate
        beaconManager.delegate = self
        
        // Retrieve firebase data
        setUpFirebaseData()
    }
    
    // Called on app initialization
    func setUpFirebaseData() {
        
        // Setup Reception Messages Data
        locationRef.childByAppendingPath("reception").childByAppendingPath("beacon")
        .observeEventType(.Value, withBlock: { recep in
            
            // recepKey is the name of the reception beacon
            let recepKey = recep.value as? String
            
            // Check beacon list for the key of the reception beacon
            // Begins ranging for the Reception Beacon using the UUID
            self.beaconsRef.childByAppendingPath(recepKey)
            .observeEventType(.ChildAdded, withBlock: { beacon in
                let rkey = beacon.key as String
                let val = beacon.value as! String
                
                // recepBeacon holds the beacon object retrieved from Firebase
                self.recepBeacon[rkey] = val
//                println(self.recepBeacon["beacon"])
                
//                if(self.recepBeacon == )
//                self.sendLocalNotificationWithMessage("Please pickup item in reception!")
            })
        })
        
        self.getReceptionMessages()

    }

    func getReceptionMessages() {
        // Get messages from Firebase:
        // Messages from Reception,
        // Ordered by User
        let fQueryReception = messagesRef.childByAppendingPath("reception").queryOrderedByChild("to_user")
        
        var details = ["beacon" : "","date" : "","message" : "","status" : "","to_user" : "","type":"","title": ""]

        // Use .ChildAdded to monitor new messages
//        fQueryReception.observeEventType(.ChildAdded, withBlock: {
//            message in
//            let child = message.children
//
//            for rest in child.allObjects as! [FDataSnapshot] {
//                details[rest.key] = rest.value as? String
//            }
//            
//            self.insertNewObject(0)
//            // self.sendLocalNotificationWithMessage("You have a new message!")
//        })
        
        // Todo: Use observeSingleEventType for initial load of existing messages.
        
        fQueryReception.observeEventType(.Value, withBlock: { message in
            let child = message.children
            var c = 0
            // Fix message loop for display of messages on the Table View:
            // Messages don't delete correctly.
            while let msg = child.nextObject() as? FDataSnapshot {
//                println(msg)
                
                for rest in msg.children.allObjects as! [FDataSnapshot] {
                    // println(rest.value)
                    details[rest.key] = rest.value as? String
                }
                
                self.myMessage[c] = details
                
                // Adds to the view. See insertNewObject(Object)
                self.insertNewObject(c)
                c++
            }
            
            // Call notification outside of loop
            self.sendLocalNotificationWithMessage("You have a new message!")
        })
    }
    
    // Local Notification method call
    // Todo: allow passing message object into parameter,
    // call notification with message body and date/time
    func sendLocalNotificationWithMessage(message: String!) {
        let notification:UILocalNotification = UILocalNotification()
        notification.alertBody = message
        notification.soundName = UILocalNotificationDefaultSoundName
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
        
        let remindAction = UIMutableUserNotificationAction()
        remindAction.identifier = "Snooze"
        remindAction.title = "Remind in 30 minutes"
        remindAction.activationMode = .Background
        remindAction.destructive = false
        
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
                
                // 1. Check if nearestBeacon object == reception beacon object
                
                
                // 2. Check proximity of reception beacon object
                switch nearestBeacon.proximity {
                case CLProximity.Far:
                    // Continue ranging for closer beacons
                    beaconManager.startRangingBeaconsInRegion(region)
                    sendLocalNotificationWithMessage("Device is Far from beacon.")
                case CLProximity.Near:
                    // Trigger notifications for messages
                    sendLocalNotificationWithMessage("Device is near to a beacon.")
                case CLProximity.Immediate:
                    // Trigger notifications for messages
                    sendLocalNotificationWithMessage("You are in the immediate proximity of the beacon")
                case CLProximity.Unknown:
                    // Do nothing
                    return
                }
                
                println(nearestBeacon.minor.integerValue)
            }
    }
    
    func startRanging(uuid:NSUUID){
        beaconRegion = CLBeaconRegion(
            proximityUUID: uuid,
            identifier: "Lighthouse")

        beaconManager.requestWhenInUseAuthorization()
        beaconManager.startRangingBeaconsInRegion(beaconRegion)
    }
    
    // Message population onto Table View
    func insertNewObject(sender: AnyObject!) {
        let msgInd = sender as! Int
        let message = self.myMessage[msgInd]!
        
        objects.insert(message["title"]!, atIndex: msgInd)
        let indexPath = NSIndexPath(forRow: msgInd, inSection: 0)
        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        //  authenticateWithGoogle()
        //  -- 15/6/2015: confirmed that Google OAuth works --
        // Create view for logging user into application
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Segues


    // MARK: - Table View
    // Needs to refactor for more complete loading of message objects into the Table View
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell

        let object = objects[indexPath.row] as! String
        cell.textLabel!.text = object
        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            objects.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }


}


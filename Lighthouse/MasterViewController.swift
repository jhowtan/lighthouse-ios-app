//
//  MasterViewController.swift
//  Lighthouse
//
//  Created by Roland on 9/6/15.
//  Copyright (c) 2015 Digital Arts Network. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController, ESTBeaconManagerDelegate, UITableViewDataSource, UITableViewDelegate {

    var detailViewController: DetailViewController? = nil
    var objects = [AnyObject]()
    
    // Beacon variables
    let beaconManager = ESTBeaconManager()
    var beaconRegion:CLBeaconRegion?
    
    // Firebase reference
    let fbRootRef = Firebase(url:"https://beacon-dan.firebaseio.com/")
    let beaconsRef = Firebase(url:"https://beacon-dan.firebaseio.com/beacons/")
    let locationRef = Firebase(url:"https://beacon-dan.firebaseio.com/location/")
    let usersRef = Firebase(url:"https://beacon-dan.firebaseio.com/users/")
    let messagesRef = Firebase(url:"https://beacon-dan.firebaseio.com/messages/")
    
    // Public variables
    var recepBeacon:[String:String] = ["uuid":""]
    var user = "google:118075399016047699152"
    var myMessage = [0:["beacon":""]]
    
    var tableNumber = 0

    override func awakeFromNib() {
        super.awakeFromNib()
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            self.clearsSelectionOnViewWillAppear = false
            self.preferredContentSize = CGSize(width: 320.0, height: 600.0)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let image = UIImage(named: "Icon-Small")
        
        self.navigationItem.titleView = UIImageView(image: image)
        
        // Do any additional setup after loading the view, typically from a nib.
        // self.navigationItem.leftBarButtonItem = self.editButtonItem()
        
        // Add the plus button
        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "insertNewObject:")
        self.navigationItem.rightBarButtonItem = addButton
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = controllers[controllers.count-1].topViewController as? DetailViewController
        }
        
        // Add the beacon manager delegate
        beaconManager.delegate = self
        
        setUpFirebaseData()
    }
    
    func setUpFirebaseData() {
        // Setup Reception Data
        locationRef.childByAppendingPath("reception").childByAppendingPath("beacon")
        .observeEventType(.Value, withBlock: { recep in
            
            let recepKey = recep.value as? String
            
            self.beaconsRef.childByAppendingPath(recepKey)
            .observeEventType(.ChildAdded, withBlock: { snapshot in
                    
                    let rkey = snapshot.key as String
                    let val = snapshot.value as! String
                    self.recepBeacon[rkey] = val
                    
                    if(rkey == "uuid") {
                        self.startRanging(NSUUID(UUIDString: val)!)
                    }
            })
            
        })
        
        // Setup reception messages data
//        messagesRef.childByAppendingPath("reception").queryOrderedByChild("to_user").queryEqualToValue(user)
//        .observeEventType(.ChildAdded, withBlock: { snapshot in
//            println(snapshot.key)
//        })
        
        messagesRef.childByAppendingPath("reception").queryOrderedByChild("to_user")
        .observeEventType(.Value, withBlock: { message in
            
            let child = message.children
            var c = 0
            while let msg = child.nextObject() as? FDataSnapshot {
                var details = ["beacon" : "","date" : "","message" : "","status" : "","to_user" : "","type":"", "title": ""]
                for rest in msg.children.allObjects as! [FDataSnapshot] {
                    // println(rest.value)
                    details[rest.key] = rest.value as? String
                }
                self.myMessage[c] = details
                self.insertNewObject(c)
                c++
            }
            
            // let child: FDataSnapshot = message.children.nextObject() as! FDataSnapshot
            // println("Test: \(child.key)");
//            let queryRef = ref.queryOrderedByChild("height").queryEndingAtValue(favoriteDinoHeight).queryLimitedToLast(2)
//            queryRef.observeSingleEventOfType(.Value, withBlock: { querySnapshot in
//                if querySnapshot.childrenCount == 2 {
//                    let child: FDataSnapshot = querySnapshot.children.nextObject() as FDataSnapshot
//                    println("The dinosaur just shorter than the stegasaurus is \(child.key)");
//                } else {
//                    println("The stegosaurus is the shortest dino");
//                }
//            })
        })
    }
    
    func beaconManager(manager: AnyObject!,
        didRangeBeacons beacons: [AnyObject]!,
        inRegion region: CLBeaconRegion!) {
            
//            for (key,val) in self.recepBeacon {
//                println("\(key) : \(val)")
//            }
            
            if let nearestBeacon = beacons.first as? CLBeacon {
                beaconManager.stopRangingBeaconsInRegion(region)
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
        
    func insertNewObject(sender: AnyObject!) {
        let msgInd = sender as! Int
        let message = self.myMessage[msgInd]!
        
        objects.insert(message["title"]!, atIndex: msgInd)
        let indexPath = NSIndexPath(forRow: msgInd, inSection: 0)
        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow() {
                let object = objects[indexPath.row] as! String
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = object
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

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


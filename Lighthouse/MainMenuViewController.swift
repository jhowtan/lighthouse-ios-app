//
//  MainViewTableViewController.swift
//  Lighthouse
//
//  Created by Roland on 17/6/15.
//  Copyright (c) 2015 Digital Arts Network. All rights reserved.
//

import UIKit

class MainMenuViewController: UITableViewController, UITableViewDataSource, UITableViewDelegate {
    
    // Global variable
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        // Add login button
        var b : UIBarButtonItem = UIBarButtonItem(title: "Login", style: UIBarButtonItemStyle.Plain, target: self, action: "startAuth")
        self.navigationItem.rightBarButtonItem = b
        
        // Start getting firebase info
        appDelegate.getFirebaseData()
        
        // Set main navigation logo
        let image = UIImage(named: "nav-logo")
        self.navigationItem.titleView = UIImageView(image: image)
    }
        // Get the users messages
    func getUserMessages(){
        // .Value will always be triggered last so the ordering does not matter
        // We just need to cache the messages on load to pass to the Messages View
        appDelegate.messagesRef.childByAppendingPath(appDelegate.currentUser).observeEventType(.ChildAdded, withBlock: { messages in
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
            
            self.appDelegate.myMessages.insert(newMessage, atIndex: 0)
            self.proceedToListView()
        })
    }
    
    // Authentication Method
    func startAuth (){
        appDelegate.authenticateWithGoogle()
    }
    
    // Manual Segue Transition
    func proceedToListView() {
        dismissViewControllerAnimated(true, completion: nil)
        performSegueWithIdentifier("List View", sender: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return 3
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Nav Item", forIndexPath: indexPath) as! MenuItemCell
        
        // Configure the cell...
            // Set the img variable as nil
        var img:String?
        switch indexPath.row {
        case 0:
            cell.btnTitle.text = "Blast"
            cell.btnSubTitle.text = "Administrative tool"
            img = "blast-icon"
        
        case 1:
            cell.btnTitle.text = "Ticker"
            cell.btnSubTitle.text = "Timesheet Tracker Tool"
            img = "ticker-icon"
        case 2:
            cell.btnTitle.text = "Broker"
            cell.btnSubTitle.text = "Facilities Reservation Tool"
            img = "broker-icon"
        default:
            println("Nothing to see here...")
        }
        
        // Apply the bg image
        // cell.btnBgImage.image = UIImage(named: img!)
        
        return cell
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Check if index path has value
        if let indexPath = self.tableView.indexPathForSelectedRow() {
            
            // Save reference of selected main navi item
            appDelegate.activeMenu = indexPath.row
            
            // If first row, check if messages array has value
            switch indexPath.row {
            case 0:
                // Check if myMessages have values values
                // If not, call the start firebase call
                if(appDelegate.myMessages.count > 0) {
                    proceedToListView()
                }else {
                    let vc = storyboard!.instantiateViewControllerWithIdentifier("Preloader") as! UIViewController
                    vc.modalPresentationStyle = .OverFullScreen
                    vc.modalTransitionStyle = .CrossDissolve
                    presentViewController(vc, animated: true) {
                        self.getUserMessages()
                    }
                }
                
            case 1:
                println("Will show Ticker list")
            case 2:
                println("Will show Broker list")
            default:
                println("Nothing to see here...")
            }
        }
        
        tableView.reloadData()
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation
    
    /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        var nextScene = segue.destinationViewController as! ItemsTableViewController
        // Pass the selected object to the new view controller.
        if let indexPath = self.tableView.indexPathForSelectedRow() {
            println(indexPath.row)
        }
    }
    */


}
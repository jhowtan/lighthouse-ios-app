//
//  ItemsTableViewController.swift
//  Lighthouse
//
//  Created by Roland on 18/6/15.
//  Copyright (c) 2015 Digital Arts Network. All rights reserved.
//

import UIKit

class ItemsTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        SharedAccess.sharedInstance.currentTableView = self
        
        var viewTitle:String?
        
        switch SharedAccess.sharedInstance.activeView {
        case 0:
            // self.title = "Blast"
            viewTitle = "Tina"
        case 1:
            // self.title = "Broker"
            viewTitle = "Sylvia"
        case 2:
            // self.title = "Ticker"
            viewTitle = "James"
        default:
            println("Lighthouse")
            viewTitle = "Lighthouse"
        }
        
        self.title = viewTitle
        
        MessageManager.sharedInstance.messagesRef.removeAllObservers()
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
        switch SharedAccess.sharedInstance.activeView {
        case 0:
            return MessageManager.sharedInstance.myMessages.count
        case 1:
            return CalendarEventsManager.sharedInstance.roomList.count
        case 2:
            return 1
        default:
            return 1
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("List Item", forIndexPath: indexPath) as! ListItemCell
        
        switch SharedAccess.sharedInstance.activeView {
        case 0: // Messaging section
            let message = MessageManager.sharedInstance.myMessages[indexPath.row]
            cell.msgIndex = indexPath.row
            cell.msgTitle!.text = message.title
            cell.msgDate!.text = message.date
            
            if SharedAccess.sharedInstance.activeView != 1 {
                cell.roomAvailability.hidden = true
            }

            return cell
        case 1: // Calendar section
            let room = CalendarEventsManager.sharedInstance.roomList[indexPath.row]
            cell.msgIndex = indexPath.row
            cell.msgTitle!.text = room.name
            cell.msgDate!.text = room.location
            cell.roomAvailability!.text = room.status
            return cell
        case 2: // Timer section
            return cell
        default:
            return cell
        }
        
            }
    
    func insertNewObject() {
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
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
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch SharedAccess.sharedInstance.activeView {
        // Messaging section
        case 0:
            // Get the new view controller using [segue destinationViewController]
            var nextView = segue.destinationViewController as! DetailViewController
            // Pass the selected object to the new view controller.
            if let indexPath = self.tableView.indexPathForSelectedRow() {
                let msg = MessageManager.sharedInstance.myMessages[indexPath.row]
                nextView.currentMsg = msg
            }
        // Calendar section
        case 1:
            // Get the new view controller using [segue destinationViewController]
            var nextView = segue.destinationViewController as! DetailViewController
            // Pass the selected object to the new view controller.
            if let indexPath = self.tableView.indexPathForSelectedRow() {
                let room = CalendarEventsManager.sharedInstance.roomList[indexPath.row]
                nextView.currentRoom = room
            }

        // Timer section
        case 2:
            return
        default:
            return
        }
    }


}

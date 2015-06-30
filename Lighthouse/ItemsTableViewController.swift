//
//  ItemsTableViewController.swift
//  Lighthouse
//
//  Created by Roland on 18/6/15.
//  Copyright (c) 2015 Digital Arts Network. All rights reserved.
//

import UIKit

class ItemsTableViewController: UITableViewController {
    // get global variable
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        var viewTitle:String?
        switch sharedAccess.activeView {
        case 0:
            // self.title = "Blast"
            viewTitle = "Sylvia"
        case 1:
            // self.title = "Ticker"
            viewTitle = "James"
        case 2:
            // self.title = "Broker"
            viewTitle = "Tina"
        default:
            println("default title")
        }
        
        self.title = viewTitle
        
        println(sharedAccess.currentView)
        
        sharedAccess.messagesRef.removeAllObservers()
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
        return sharedAccess.myMessages.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("List Item", forIndexPath: indexPath) as! ListItemCell
        
        let message = sharedAccess.myMessages[indexPath.row]
        cell.msgIndex = indexPath.row
        cell.msgTitle!.text = message.title
        cell.msgDate!.text = message.date
        
        return cell
    }
    
    func insertNewObject(rowIndex: Int) {
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }
    
    func getNewlyAddedMessages(){
        sharedAccess.messagesRef.childByAppendingPath(sharedAccess.currentUser).observeEventType(.ChildAdded, withBlock: { messages in
            // Use the appdelegate add message method
            sharedAccess.addMessageSnapshot(messages)
            
            // Trigger the next view
            self.insertNewObject(0)
        })
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
        // Get the new view controller using [segue destinationViewController]
        var nextView = segue.destinationViewController as! DetailViewController
        // Pass the selected object to the new view controller.
        if let indexPath = self.tableView.indexPathForSelectedRow() {
            let msg = sharedAccess.myMessages[indexPath.row]
            nextView.currentMsg = msg
        }
    }


}

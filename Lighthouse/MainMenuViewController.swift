//
//  MainViewTableViewController.swift
//  Lighthouse
//
//  Created by Roland on 17/6/15.
//  Copyright (c) 2015 Digital Arts Network. All rights reserved.
//

import UIKit

class MainMenuViewController: UITableViewController, UITableViewDataSource, UITableViewDelegate, GPPSignInDelegate {
    
    // Global variable
    //    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        // Start getting firebase info
        sharedAccess.cacheFirebaseData()
        MessageManager.sharedInstance.getUsersList()
        
        // Add auth listeners
        sharedAccess.fbRootRef.observeAuthEventWithBlock({ authData in
            if authData != nil {
                // user authenticated with Firebase
                sharedAccess.accessToken = (authData.providerData["accessToken"] as? String)!
                sharedAccess.currentUserName = (authData.providerData["displayName"] as? String)!
                sharedAccess.currentUserEmail = (authData.providerData["email"] as? String)!
                sharedAccess.currentUser = authData.uid
                
                var b : UIBarButtonItem = UIBarButtonItem(title: "Logout",
                    style: UIBarButtonItemStyle.Plain, target: self, action: "logOut")
                self.navigationItem.rightBarButtonItem = b
            } else {
                // No user is logged in
                println("Successfully Unauthenticated. Ready for login")
                
                // Add login button
                var b : UIBarButtonItem = UIBarButtonItem(title: "Login",
                    style: UIBarButtonItemStyle.Plain, target: self, action: "startAuth")
                self.navigationItem.rightBarButtonItem = b
            }
        })
        
        // Set main navigation logo
        let image = UIImage(named: "nav-logo")
        self.navigationItem.titleView = UIImageView(image: image)
        
        // Start ranging here
        sharedAccess.startRanging()
    }
    
    // Authentication method called by Login button
    // Move this function along with the login button when View for Login Page is done
    func startAuth (){
        let pointer = moveToView
        self.authenticateWithGoogle()
    }
    
    func logOut(){
        sharedAccess.fbRootRef.unauth()
        signOutOfGoogle()
    }
    
    // Manual Segue Transition
    func proceedToListView() {
        dismissViewControllerAnimated(true, completion: nil)
        performSegueWithIdentifier("List View", sender: self)
    }
    
    // Menu Interaction handlers
    func moveToView() {
        // If first row, check if messages array has value
        switch sharedAccess.activeView {
        case 0:
            // Check if myMessages has values
            // If not, call the start firebase call
            if(sharedAccess.myMessages.count > 0) {
                proceedToListView()
            } else {
                let vc = storyboard!.instantiateViewControllerWithIdentifier("Preloader") as! UIViewController
                vc.modalPresentationStyle = .OverFullScreen
                vc.modalTransitionStyle = .CrossDissolve
                presentViewController(vc, animated: true) {
                    MessageManager.sharedInstance.getUserMessages()
                    
                    // Delay 2 seconds
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(2.0 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
                        self.proceedToListView()
                    }
                }
                
            }
            
        case 1:
            // Check if roomList has values
            // If not, call the start firebase call
            if (CalendarEventsManager.sharedInstance.roomList.count > 0) {
                CalendarEventsManager.sharedInstance.getFreeBusy()
                proceedToListView()
            } else {
                let vc = storyboard!.instantiateViewControllerWithIdentifier("Preloader") as! UIViewController
                vc.modalPresentationStyle = .OverFullScreen
                vc.modalTransitionStyle = .CrossDissolve
                presentViewController(vc, animated: true) {
                    CalendarEventsManager.sharedInstance.getCalendars()
                    
                    // Delay 2 seconds
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(2.0 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
                        self.proceedToListView()
                    }
                }
            }
        case 2:
            println("Will show Broker list")
        default:
            println("Nothing to see here...")
        }
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
    
    // Initialize the main navigation rows
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Nav Item", forIndexPath: indexPath) as! MenuItemCell
        
        // Configure the cell...
        // Set the img variable as nil
        var img:String?
        switch indexPath.row {
        case 0:
            cell.btnTitle.text = "Blast"
            // cell.btnTitle.text = "Tina"
            cell.btnSubTitle.text = "Administrative"
            cell.backgroundColor = UIColor.lightGrayColor()
            
            img = "blast-icon"
        case 1:
            cell.btnTitle.text = "Broker"
            // cell.btnTitle.text = "Sylvia"
            cell.btnSubTitle.text = "Facilities Reservation"
            cell.backgroundColor = UIColor.grayColor()
            
            img = "ticker-icon"
        case 2:
            cell.btnTitle.text = "Ticker"
            // cell.btnTitle.text = "James"
            cell.btnSubTitle.text = "Timesheet Tracker"
            cell.backgroundColor = UIColor.darkGrayColor()
            
            img = "broker-icon"
        default:
            println("Nothing to see here...")
        }
        
        // Apply the bg image
        cell.btnBgImage.image = UIImage(named: img!)
        
        return cell
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Check if index path has value
        if let indexPath = self.tableView.indexPathForSelectedRow() {
            
            // Save reference of selected main navi item
            sharedAccess.activeView = indexPath.row
            
            // Check if logged in before going through with the funtions
            if(sharedAccess.currentUser.isEmpty) {
                startAuth()
            }else {
                moveToView()
            }
            
        }
        
        tableView.reloadData()
    }
    
    // ------- GOOGLE AUTHENTICATION METHODS ----------------
    func authenticateWithGoogle() {
        // use the Google+ SDK to get an OAuth token
        var signIn = GPPSignIn.sharedInstance()
        signIn.shouldFetchGooglePlusUser = true
        signIn.clientID = sharedAccess.googleClientID
        signIn.scopes = ["email", "https://www.googleapis.com/auth/calendar"]
        signIn.delegate = self
        signIn.authenticate()
    }
    
    func signOutOfGoogle() {
        var signIn = GPPSignIn.sharedInstance()
        signIn.signOut()
    }
    
    func finishedWithAuth(auth: GTMOAuth2Authentication!, error: NSError!) {
        if error != nil {
            // There was an error obtaining the Google+ OAuth Token
            println("Error! \(error)")
        } else {
            // We successfully obtained an OAuth token, authenticate on Firebase with it
            sharedAccess.fbRootRef.authWithOAuthProvider("google", token: auth.accessToken,
                withCompletionBlock: { error, authData in
                    if error != nil {
                        // Error authenticating with Firebase with OAuth token
                        println("Error! \(error)")
                        println("User may have cancelled the Authentication Process")
                    } else {
                        // User is now logged in, set currentUser to the obtained uid
                        sharedAccess.currentUser = authData.uid
                        sharedAccess.currentUserName = authData.providerData["displayName"] as! String
                        sharedAccess.currentUserEmail = authData.providerData["email"] as! String
                        sharedAccess.accessToken = authData.providerData["accessToken"] as! String
                        // sharedAccess.auth = authData
                    }
            })
        }
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

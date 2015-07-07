//
//  DetailViewController.swift
//  Lighthouse
//
//  Created by Roland on 18/6/15.
//  Copyright (c) 2015 Digital Arts Network. All rights reserved.
//

import UIKit
import SwiftyJSON

class DetailViewController: UIViewController {

    // Set Blast UI elements
    @IBOutlet weak var msgTitle: UILabel!
    @IBOutlet weak var msgDate: UILabel!
    @IBOutlet weak var msgLocation: UILabel!
    @IBOutlet weak var msgContent: UITextView!
    @IBOutlet weak var bookBtn: UIButton!
    @IBOutlet weak var pingBtn: UIButton!
    
    // Need to manage if detail is a message or a calendar room
    var currentMsg:Message?
    var currentRoom:Room?

    override func viewDidLoad() {
        super.viewDidLoad()
        switch sharedAccess.activeView {

        case 0: // Messaging section
            // Do any additional setup after loading the view.
            if let pageTitle = currentMsg!.title {
                self.title = pageTitle
            }
            
            msgTitle.text = currentMsg!.title
            msgDate.text = currentMsg!.date
            msgContent.text = currentMsg!.message
            msgLocation.text = currentMsg!.location?.uppercaseString

        case 1: // Calendar section
            if let pageTitle = currentRoom!.name {
                self.title = pageTitle
            }
            msgTitle.text = currentRoom!.location?.uppercaseString
            msgDate.text = currentRoom!.calendarId
            msgContent.text = "Placeholder for Event Details"
            msgLocation.text = currentRoom!.status
        case 2: // Timer section
            return
        default:
            return
        }
        
    }
    
    // Book button handler
    @IBAction func bookRoom(sender: AnyObject) {
        
    }
    
    // Ping button handler
    @IBAction func pingAttendees(sender: AnyObject) {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

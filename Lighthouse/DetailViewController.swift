//
//  DetailViewController.swift
//  Lighthouse
//
//  Created by Roland on 18/6/15.
//  Copyright (c) 2015 Digital Arts Network. All rights reserved.
//

import UIKit
import SwiftyJSON
import SwiftDate

class DetailViewController: UIViewController {

    // Set Blast UI elements
    @IBOutlet weak var msgTitle: UILabel!
    @IBOutlet weak var msgDate: UILabel!
    @IBOutlet weak var msgLocation: UILabel!
    @IBOutlet weak var msgContent: UITextView!
    
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
            if (currentRoom!.event != nil) {
                let visibility = currentRoom!.event["visibility"].string
                let attendees = currentRoom!.event["attendees"]
                let startTime = currentRoom!.event["start"]["dateTime"].string
                let endTime = currentRoom!.event["end"]["dateTime"].string
                let summary = currentRoom!.event["summary"].string
                let description = currentRoom!.event["description"].string
                var attendeeString = ""
                
                if visibility != "private" {
                    for attendee in attendees.arrayValue {
                        if let displayName = attendee["displayName"].string {
                            if displayName.rangeOfString("SG - ") == nil {
                                attendeeString = attendeeString + "\(displayName) \n"
                            }
                        }
                    }
                } else {
                    attendeeString = "There is a private event ongoing."
                }

//                msgTitle.text = currentRoom!.location?.uppercaseString
                msgTitle.text = summary?.uppercaseString
                msgDate.text = "\(startTime!) to \(endTime!)"
                msgContent.text = "\(attendeeString)"
                msgLocation.text = currentRoom!.status
            } else {
                // If currentRoom is an available room:
                msgTitle.text = "Room is available".uppercaseString
                msgDate.text = "Available for booking"
                msgContent.text = "There are currently no occupants of the room."
                msgLocation.text = currentRoom!.status
            }
        case 2: // Timer section
            return
        default:
            return
        }
        
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

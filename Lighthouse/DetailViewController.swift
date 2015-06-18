//
//  DetailViewController.swift
//  Lighthouse
//
//  Created by Roland on 18/6/15.
//  Copyright (c) 2015 Digital Arts Network. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    // Set Blast UI elements
    @IBOutlet weak var msgTitle: UILabel!
    @IBOutlet weak var msgDate: UILabel!
    @IBOutlet weak var msgLocation: UILabel!
    @IBOutlet weak var msgContent: UITextView!
    
    var currentMsg:Message?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if let pageTitle = currentMsg!.title {
            self.title = pageTitle
        }
        
        msgTitle.text = currentMsg!.title
        msgDate.text = currentMsg!.date
        msgContent.text = currentMsg!.message
        msgLocation.text = currentMsg!.location?.uppercaseString
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

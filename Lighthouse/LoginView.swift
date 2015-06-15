//
//  loginView.swift
//  Lighthouse
//
//  Created by Roland on 16/6/15.
//  Copyright (c) 2015 Digital Arts Network. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, GPPSignInDelegate {
    
    var tableNumber: Int!
    var user = "google:118075399016047699152" // Hardcoded user data, changes with Firebase login.
    let usersRef = Firebase(url:"https://beacon-dan.firebaseio.com/users/")
    
    @IBOutlet weak var tableNumberLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        authenticateWithGoogle()
    }

    
    func authenticateWithGoogle() {
        // use the Google+ SDK to get an OAuth token
        var signIn = GPPSignIn.sharedInstance()
        signIn.shouldFetchGooglePlusUser = true
        signIn.clientID = "186193271444-835107nm0lkjlepsmv66fkl4rp6eoir7.apps.googleusercontent.com"
        signIn.scopes = []
        signIn.delegate = self
        signIn.authenticate()
    }
    
    func finishedWithAuth(auth: GTMOAuth2Authentication!, error: NSError!) {
        if error != nil {
            // There was an error obtaining the Google+ OAuth Token
        } else {
            // We successfully obtained an OAuth token, authenticate on Firebase with it
            let ref = Firebase(url: "https://beacon-dan.firebaseio.com")
            ref.authWithOAuthProvider("google", token: auth.accessToken,
                withCompletionBlock: { error, authData in
                    if error != nil {
                        // Error authenticating with Firebase with OAuth token
                    } else {
                        // User is now logged in!
                        println("Successfully logged in! \(authData)")
                        self.dismissViewControllerAnimated(true, completion: {});
                    }
            })
        }
    }
}


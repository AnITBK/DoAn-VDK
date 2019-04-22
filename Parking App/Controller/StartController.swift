//
//  ViewController.swift
//  Parking App
//
//  Created by An Nguyễn on 4/8/19.
//  Copyright © 2019 An Nguyễn. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import FBSDKLoginKit
import GoogleSignIn


class StartController: UIViewController, GIDSignInUIDelegate, GIDSignInDelegate {

    @IBOutlet weak var imageProfile: UIImageView!
    @IBAction func googleLoginButton(_ sender: Any) {
        GIDSignIn.sharedInstance().signIn()
    }
    
    @IBAction func loginFacebookButton(_ sender: Any) {
        let LoginManager = FBSDKLoginManager()
        LoginManager.logIn(withReadPermissions: ["public_profile", "email"], from: self) { (result, error) in
            if let error = error {
                print("Failed to login: \(error.localizedDescription)")
                return
            }
            self.pushTabVC()
            print("LOGIN BY FACEBOOK")
        }
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true
        if let _ = FBSDKAccessToken.current() {
            view.backgroundColor = .red
            self.pushTabVC()
            print("LOGIN BY FACEBOOK")
        }
        
        if let _ = Auth.auth().currentUser {
            self.pushTabVC()
            print("LOGIN BY GOOGLE")
        }
        GIDSignIn.sharedInstance()?.uiDelegate = self
        GIDSignIn.sharedInstance()?.delegate = self
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.isNavigationBarHidden = true
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        if let error = error {
            print("ERROR LOGIN GOOGLE")
            print("\(error.localizedDescription)")
        } else {
            print("LOGIN GOOGLE")
            self.pushTabVC()
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        print("DisconnectWith LOGIN GOOGLE")
    }
    
    func pushTabVC() {
        let tabBarVC = storyboard?.instantiateViewController(withIdentifier: "tabbarVC")
        present(tabBarVC!, animated: true, completion: nil)
    }

}


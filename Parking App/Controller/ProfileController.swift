//
//  ProfileViewController.swift
//  Parking App
//
//  Created by An Nguyễn on 4/8/19.
//  Copyright © 2019 An Nguyễn. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FirebaseAuth
import FBSDKLoginKit
import GoogleSignIn

class ProfileController: UIViewController {

    @IBOutlet weak var profileImage: UIButton!
    @IBOutlet weak var boundsInforView: UIView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var memberOrGuestLabel: UILabel!
    @IBOutlet weak var emailUserLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    
    @IBAction func profileImage(_ sender: Any) {
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.title = "Profile"
        navigationController?.isNavigationBarHidden = false
        profileImage.cornerImage(profileImage.bounds.width/2)
        getInformation()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.isNavigationBarHidden = false
    }
    
    @IBAction func logoutButton(_ sender: Any) {
        let alert = UIAlertController(title: "LOGOUT", message: "You will logout!", preferredStyle: .actionSheet)
        let OkButton = UIAlertAction(title: "OK", style: .default) { (_) in
            let firebaseAuth = Auth.auth()
            do {
                try firebaseAuth.signOut()
                print("LOGOUT")
            } catch let signOutError as NSError {
                print ("Error signing out: ", signOutError)
            }
            let loginManager = FBSDKLoginManager()
            loginManager.logOut()
            let startVC = self.storyboard?.instantiateViewController(withIdentifier: "startVC")
            startVC?.modalTransitionStyle = .crossDissolve
            startVC?.modalPresentationStyle = .custom
            self.dismiss(animated: true, completion: nil)
            print("LOGTOUT!!!")
        }
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
            print("Cancel!")
        }
        alert.addAction(OkButton)
        alert.addAction(cancelButton)
        present(alert, animated: true, completion: nil)
    }
    
    func getInformation(){
        if let _ = FBSDKAccessToken.current() {
            FBSDKGraphRequest(graphPath: "/me", parameters: ["fields": "id, name, email, gender"])?.start(completionHandler: { (connection, result, error) in
                if error != nil {
                    print("Failed to start graph request!", error as Any)
                    return
                }
                if let results = result as? [String: Any] {
                    let email = results["email"] as? String
                    let name = results["name"] as? String
                    let gender = results["gender"] as? String
                    let FBid = results["id"] as? String
                    let urlStr = "https://graph.facebook.com/\(FBid!)/picture?type=large&return_ssl_resources=1"
                    let imageURL = URL(string: urlStr)
                    let imageData:Data? = try? Data(contentsOf: imageURL!)
                    
                    self.profileImage.setImage(UIImage(data: imageData!), for: .normal)
                    self.genderLabel.text = gender?.localizedCapitalized ?? "nil"
                    self.emailUserLabel.text = email ?? "nil"
                    self.usernameLabel.text = name ?? "nil"
                }
                
                
            })
        }
                
        if let user = GIDSignIn.sharedInstance()?.currentUser {
            let email = user.profile.email
            let name = user.profile.name
            let gender = user.profile.debugDescription
            if user.profile.hasImage {
                let photoURL = user.profile.imageURL(withDimension: 100)
                let imageData:Data? = try? Data(contentsOf: photoURL!)
                self.profileImage.setImage(UIImage(data: imageData!), for: .normal)
            }
            self.emailUserLabel.text = email ?? "nil"
            self.usernameLabel.text = name ?? "nil"
            self.genderLabel.text = gender
            print("data \(gender)")
        }
        
        if let user = Auth.auth().currentUser {
            let email = user.email
            let name = user.displayName
            let gender = "Male"
            if let photoURL = user.photoURL {
                let imageData:Data? = try? Data(contentsOf: photoURL)
                self.profileImage.setImage(UIImage(data: imageData!), for: .normal)
            }
            self.emailUserLabel.text = email ?? "nil"
            self.usernameLabel.text = name ?? "nil"
            self.genderLabel.text = gender
            print("data \(gender)")
        }
    }
}

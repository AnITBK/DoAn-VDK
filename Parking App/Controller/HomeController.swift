//
//  HomeViewController.swift
//  Parking App
//
//  Created by An Nguyễn on 4/8/19.
//  Copyright © 2019 An Nguyễn. All rights reserved.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit
import GoogleSignIn
import FirebaseFirestore
import FirebaseCore

class HomeController: UIViewController {

    var imageView: UIImageView!
    @IBOutlet weak var viewAboutUs: UIView!
    @IBOutlet weak var qrButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        navigationController?.isNavigationBarHidden = false
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Home"
        imageView = UIImageView()
        imageView.frame = CGRect(x: view.bounds.width/2 - 100, y: 350, width: 200, height: 200)
        view.addSubview(imageView)
        imageView.isHidden = true
        viewAboutUs.borderView(5, UIColor.black)
        qrButton.borderView(8, UIColor.white)
        qrButton.setTitleColor(UIColor.white, for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.isNavigationBarHidden = false
        
    }
    
    @IBAction func qrButton(_ sender: Any) {
        var idOp: String?
        var emailOp: String?
        if let user = Auth.auth().currentUser {
            idOp = user.email! + user.providerID
            emailOp = user.email
        }
        if let user = GIDSignIn.sharedInstance()?.currentUser {
            idOp = user.userID
            emailOp = user.profile.email
        }
        if let user = FBSDKAccessToken.current() {
            idOp = user.userID
            FBSDKGraphRequest(graphPath: "/me", parameters: ["fields": "id, name, email, gender"])?.start(completionHandler: { (connection, result, error) in
                if error != nil {
                    print("Failed to start graph request!", error as Any)
                    return
                }
                if let results = result as? [String: Any] {
                    let em = results["email"] as? String
                    emailOp = em
                }
                if let id = idOp, let email = emailOp {
                    let image = self.generateQRCode(from: id)
                    self.imageView.image = image
                    self.imageView.isHidden = !self.imageView.isHidden
                    if !self.imageView.isHidden {
                        let db = Firestore.firestore()
                        let settings = db.settings
                        settings.areTimestampsInSnapshotsEnabled = true
                        db.settings = settings
                        db.collection("tickets").document("\(email)").setData([
                            "id": "\(id)"
                        ]) { (error) in
                            if let err = error {
                                print("Error adding document: \(err)")
                                return
                            }
                            print("Document added with email: \(email)")
                            self.createAlert(title: "Success", message: "Welcome to your parking!")
                        }
                    }
                }
            })
        }
        if let id = idOp, let email = emailOp {
            let image = generateQRCode(from: id)
            imageView.image = image
            imageView.isHidden = !imageView.isHidden
            if !self.imageView.isHidden {
                let db = Firestore.firestore()
                let settings = db.settings
                settings.areTimestampsInSnapshotsEnabled = true
                db.settings = settings
                db.collection("tickets").document("\(email)").setData([
                    "id": "\(id)"
                ]) { (error) in
                    if let err = error {
                        print("Error adding document: \(err)")
                        return
                    }
                    print("Document added with email: \(email)")
                    self.createAlert(title: "Success", message: "Welcome to your parking!")
                }
            }
        }
    }
    
    internal func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)
            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }
        return nil
    }
    
    fileprivate func createAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(alertAction)
        present(alert, animated: true, completion: nil)
    }
    
}

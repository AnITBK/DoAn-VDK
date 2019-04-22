//
//  LoginViewController.swift
//  Parking App
//
//  Created by An Nguyễn on 4/10/19.
//  Copyright © 2019 An Nguyễn. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginController: UIViewController {

    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    
    @IBAction func backButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func loginButton(_ sender: Any) {
        if let email = emailTxt.text, let password = passwordTxt.text {
            Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
                if let error = error {
                    print("LOGIN FAILED!!", error)
                    return
                }
                print("LOGIN SUCESS!!")
                if let result = result {
//                    print(result.user.displayName)
//                    print(result.user.email)
//                    print(result.user.photoURL)
//                    print(result.user.phoneNumber)
                }
                let tabBarVC = self.storyboard?.instantiateViewController(withIdentifier: "tabbarVC")
                self.present(tabBarVC!, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func forgotPasswordButton(_ sender: Any) {
        if let email = emailTxt.text {
            Auth.auth().sendPasswordReset(withEmail: email) { (error) in
                if let error = error {
                    print("send password reset failed!!, \(error)")
                    return
                }
                print("Sent password to email \(email).")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = false
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Login"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.isNavigationBarHidden = false

    }
}

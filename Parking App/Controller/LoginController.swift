//
//  LoginViewController.swift
//  Parking App
//
//  Created by An Nguyễn on 4/10/19.
//  Copyright © 2019 An Nguyễn. All rights reserved.
//

import UIKit
import FirebaseFirestore

class LoginController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    @IBOutlet weak var loginButton: CustomButton!
    
    @IBAction func loginButton(_ sender: Any) {
        if let email = emailTxt.text, let password = passwordTxt.text {
            handleLogin(email: email, password: password)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true
        setTextField()
        if let email = UserDefaults.standard.object(forKey: "email")  as? String, let password = UserDefaults.standard.object(forKey: "password") as? String{
            emailTxt.text = email
            passwordTxt.text = password
            handleLogin(email: email, password: password)
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        scrollView.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard(){
        view.endEditing(true)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.isNavigationBarHidden = true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if emailTxt.becomeFirstResponder() {
            passwordTxt.becomeFirstResponder()
        }
        if let email = emailTxt.text, let password = passwordTxt.text {
            if passwordTxt.becomeFirstResponder() && email.count >= 9 && password.count >= 6{
                passwordTxt.resignFirstResponder()
                handleLogin(email: email, password: password)
            }else {
                
            }
        }
        return true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //emailTxt.becomeFirstResponder()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        passwordTxt.text = ""
    }
    
    fileprivate func setTextField(){
        emailTxt.delegate = self
        passwordTxt.delegate = self
        emailTxt.tintColor = .white
        emailTxt.textAlignment = .left
        passwordTxt.textAlignment = .left
        emailTxt.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 45))
        emailTxt.leftViewMode = .always
        passwordTxt.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 45))
        passwordTxt.leftViewMode = .always
        emailTxt.attributedPlaceholder = NSAttributedString(string: "MSSV", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white.withAlphaComponent(0.6), NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.bold)])
        passwordTxt.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white.withAlphaComponent(0.6), NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.bold)])
        emailTxt.keyboardType = .emailAddress
        emailTxt.returnKeyType = .next
        passwordTxt.returnKeyType = .go
        emailTxt.font = UIFont.systemFont(ofSize: 19)
        passwordTxt.tintColor = .white
        passwordTxt.font = UIFont.systemFont(ofSize: 19)
        loginButton.isEnabled = false
        loginButton.alpha = 0.7
        passwordTxt.isSecureTextEntry = true
        passwordTxt.keyboardType = .emailAddress
        passwordTxt.delegate = self
        passwordTxt.clearButtonMode = .whileEditing
        emailTxt.clearButtonMode = .whileEditing
        passwordTxt.addTarget(self, action: #selector(handleShowButtonLogin), for: .editingChanged)
        emailTxt.addTarget(self, action: #selector(handleShowButtonLogin), for: .editingChanged)
    }
    
    @objc func handleShowButtonLogin(){
        guard let email = emailTxt.text, let password = passwordTxt.text else { return }
        let condition = email.count == 9 && password.count >= 6 && Int(email) != nil
        if condition {
            self.loginButton.isEnabled = true
            loginButton.alpha = 1
        }else {
            if Int(email) == nil && email.count > 8 {
                createAlert(title: "Re-type your account!", message: "MSSV is numbers .")
            }
            self.loginButton.isEnabled = false
            loginButton.alpha = 0.7
        }
    }
    
    fileprivate func createAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(alertAction)
        present(alert, animated: true, completion: nil)
    }
    
    fileprivate func handleLogin(email: String, password: String){
        var success: Bool = false
        let db = Firestore.firestore()
        let settings = db.settings
        db.settings = settings
        db.collection("members").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                return
            }
            for document in querySnapshot!.documents {
                let data = document.data()
                let mssv = data["MSSV"] as? String ?? ""
                let password = data["password"] as? String ?? ""
                if mssv == email && password == password {
                    print("LOGIN MEMBER!")
                    success = true
                    UserDefaults.standard.set(email, forKey: "email")
                    UserDefaults.standard.set(password, forKey: "password")
                    UserDefaults.standard.set(document.documentID, forKey: "documentID")
                    let tabBarVC = self.storyboard?.instantiateViewController(withIdentifier: "tabbarVC")
                    self.present(tabBarVC!, animated: true, completion: nil)
                    //self.navigationController?.pushViewController(tabBarVC!, animated: true)
                }
            }
            if !success {
                self.createAlert(title: "LOGIN FAILED!", message: "Please check your account or password.")
            }
        }
    }
    
}

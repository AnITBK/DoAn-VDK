//
//  RegisterController.swift
//  Parking App
//
//  Created by An Nguyễn on 4/27/19.
//  Copyright © 2019 An Nguyễn. All rights reserved.
//

import UIKit
import FirebaseFirestore

class RegisterController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var usernameTextField: CustomTextField!
    @IBOutlet weak var classTextField: CustomTextField!
    @IBOutlet weak var plateTextField: CustomTextField!
    @IBOutlet weak var mssvTextField: CustomTextField!
    @IBOutlet weak var passwordTextField: CustomTextField!
    @IBOutlet weak var re_typePasswordTextField: CustomTextField!
    @IBOutlet weak var registerButton: CustomButton!
    
    private var mssvData:[String] = []
    private var plateData:[String] = []
    var textFieldActive: UITextField?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = false
        navigationController?.navigationBar.barTintColor = UIColor(red: 36/255, green: 36/255, blue: 36/255, alpha: 0.8)
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 25, weight: .bold), NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationController?.navigationBar.tintColor = UIColor.white
        setupUI()
        let db = Firestore.firestore()
        let settings = db.settings
        db.settings = settings
        db.collection("members").addSnapshotListener({ documentSnapshot, error in
            guard let documents = documentSnapshot?.documents else {
                print("Error fetching document: \(error!)")
                return
            }
            documents.forEach{ (document) in
                let data = document.data()
                let mssvStr = data["MSSV"] as? String ?? ""
                let plateStr = data["plate"] as? String ?? ""
                self.mssvData.append(mssvStr)
                self.plateData.append(plateStr)
            }
        })
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: self)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: self)
    }
    
    @objc func keyboardWillShow(notification: Notification){
        guard let keyboardInfor = notification.userInfo else { return }
        if let keyboardSize = (keyboardInfor[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size {
            let keyboardHeight = keyboardSize.height + 10
            let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
            self.scrollView.contentInset = contentInsets
            var viewRect = self.view.frame
            viewRect.size.height -= keyboardHeight
            guard let activeField = textFieldActive else { return }
            if viewRect.contains(activeField.frame.origin) {
                let scrollPoint = CGPoint(x: 0, y: activeField.frame.origin.y - keyboardHeight)
                self.scrollView.setContentOffset(scrollPoint, animated: true)
            }
        }
    }
    
    @objc func keyboardWillHide(notification: Notification){
        let contentInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInsets
    }
    
    fileprivate func setupUI(){
        textFieldActive = UITextField()
        usernameTextField.delegate = self
        classTextField.delegate = self
        plateTextField.delegate = self
        mssvTextField.delegate = self
        passwordTextField.delegate = self
        mssvTextField.keyboardType = .emailAddress
        mssvTextField.returnKeyType = .next
        re_typePasswordTextField.delegate = self
        registerButton.isEnabled = false
        registerButton.alpha = 0.7
        usernameTextField.addTarget(self, action: #selector(handleRegisterButtonEnable), for: .editingChanged)
        classTextField.addTarget(self, action: #selector(handleRegisterButtonEnable), for: .editingChanged)
        plateTextField.addTarget(self, action: #selector(hadleCheckPlate), for: .editingChanged)
        mssvTextField.addTarget(self, action: #selector(handleCheckMSSV), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(handleRegisterButtonEnable), for: .editingChanged)
        re_typePasswordTextField.addTarget(self, action: #selector(handleRegisterButtonEnable), for: .editingChanged)

    }
    
    @objc func hadleCheckPlate(sender: UITextField){
        handleRegisterButton()
        if let plateStr = sender.text {
            let isMSSVAlready1 = checkIsMSSVAlreadyExist(arrData: plateData, str: plateStr)
            print(plateData)
            print(isMSSVAlready1)
            if isMSSVAlready1 {
                registerButton.isEnabled = false
                registerButton.alpha = 0.7
                if plateStr.count > 2 {
                    let index1 = plateStr.index(before: plateStr.endIndex)
                    plateTextField.text = String(plateStr[..<index1])
                }
                let alert = UIAlertController(title: "\(plateStr) already exists", message: "Re-type Plate", preferredStyle: .alert)
                let alertAction = UIAlertAction(title: "OK", style: .default, handler: { (_) in
                    self.mssvTextField.becomeFirstResponder()
                    return
                })
                alert.addAction(alertAction)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    @objc func handleCheckMSSV(sender: UITextField){
        handleRegisterButton()
        if let mssvStr = sender.text {
            let isMSSVAlready1 = checkIsMSSVAlreadyExist(arrData: mssvData, str: mssvStr)
            print(mssvData)
            if isMSSVAlready1 {
                registerButton.isEnabled = false
                registerButton.alpha = 0.7
                if mssvStr.count > 2 {
                    let index1 = mssvStr.index(before: mssvStr.endIndex)
                    mssvTextField.text = String(mssvStr[..<index1])
                }
                let alert = UIAlertController(title: "\(mssvStr) already exists", message: "Re-type MSSV", preferredStyle: .alert)
                let alertAction = UIAlertAction(title: "OK", style: .default, handler: { (_) in
                    self.mssvTextField.becomeFirstResponder()
                    return
                })
                alert.addAction(alertAction)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    @objc func handleRegisterButtonEnable(){
        handleRegisterButton()
    }
    
    fileprivate func handleRegisterButton(){
        guard let name = usernameTextField.text, let className = classTextField.text, let plate = plateTextField.text, let mssv = mssvTextField.text, let password = passwordTextField.text, let re_typePassword = re_typePasswordTextField.text else { return }
        let condition = name.count > 0 && className.count > 0 && plate.count > 0 && mssv.count == 9 && password.count > 5 && re_typePassword.count > 5 && re_typePassword == password && Int(mssv) != nil
        if condition {
            registerButton.isEnabled = true
            registerButton.alpha = 1
            mssvTextField.textColor = .black
        }else{
            registerButton.isEnabled = false
            registerButton.alpha = 0.7
            mssvTextField.textColor = .red
            if mssv.count > 9 {
                let index1 = mssv.index(before: mssv.endIndex)
                mssvTextField.text = String(mssv[..<index1])
            }
            if (Int(mssv) == nil || mssv.count > 9) && mssv.count > 0 {
                createAlert(title: "Re-type your account!", message: "MSSV are 9 numbers .")
            }
            if re_typePassword != password && name.count > 0 && className.count > 0 && plate.count > 0 && mssv.count == 9 && password.count > 5 && re_typePassword.count > 5 {
                createAlert(title: "Re-type your account!", message: "Re-type your password.")
                re_typePasswordTextField.text = ""
            }
        }
    }
    
    fileprivate func checkIsMSSVAlreadyExist(arrData: [String], str: String) -> Bool{
        for str1 in arrData {
            if str == str1 {
                return true
            }
        }
        return false
    }
    
    fileprivate func createAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(alertAction)
        present(alert, animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.textFieldActive = nil
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        usernameTextField.becomeFirstResponder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        usernameTextField.becomeFirstResponder()
    }
    
    @IBAction func backButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func registerButton(_ sender: Any) {
        guard let name = usernameTextField.text, let className = classTextField.text, let plate = plateTextField.text, let mssv = mssvTextField.text, let password = re_typePasswordTextField.text else { return }
        let db = Firestore.firestore()
        let settings = db.settings
        db.settings = settings
        print("Registering ....")
        db.collection("members").addDocument(data: [
            "MSSV": "\(mssv)",
            "RFID": 0,
            "class": "\(className)",
            "history": [String](),
            "isCurrentlyIn": false,
            "name": "\(name)",
            "password": "\(password)",
            "plate": "\(plate)",
            "subscribeUntil": Timestamp(date: Date())
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added.")
                self.createAlert(title: "Register succeed!", message: "Created account successfuly Back to login.")
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    

}

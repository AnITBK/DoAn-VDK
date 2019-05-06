//
//  EditProfileController.swift
//  Parking App
//
//  Created by An Nguyễn on 4/27/19.
//  Copyright © 2019 An Nguyễn. All rights reserved.
//

import UIKit
import FirebaseFirestore

class EditProfileController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var contraintBottom: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var changeButton: CustomButton!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var saveButton: CustomButton!
    @IBOutlet weak var usernameLabel: UITextField!
    @IBOutlet weak var classMemberLabel: UITextField!
    @IBOutlet weak var plate: UITextField!
    @IBOutlet weak var mssvLabel: UITextField!
    @IBOutlet weak var passwordTextfield: CustomTextField!
    @IBOutlet weak var re_typePasswordTextField: CustomTextField!
    var textFieldActive: UITextField?

    
    private var mssvData:[String] = [String]()
    private var plateData:[String] = [String]()
    private var member: Member?
    
    @IBAction func backButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func changePasswordButton(_ sender: Any) {
        guard let _ = passwordTextfield.text, let re_typePassword = re_typePasswordTextField.text else { return }
        guard var member = member else { return }
        member.password = re_typePassword
        let db = Firestore.firestore()
        let settings = db.settings
        db.settings = settings
        if let documentID = UserDefaults.standard.value(forKey: "documentID") as? String {
            db.collection("members").document(documentID).setData([
                "MSSV": member.mssv,
                "RFID": member.RFID,
                "class": member.cClass,
                "history": member.history,
                "isCurrentlyIn": member.isCurrentlyIn,
                "lastActivity": member.lastActivity,
                "name": member.name,
                "password": member.password,
                "plate": member.plate,
                "subscribeUntil": member.subscribeUntil,
                ]) { err in
                    if let err = err {
                        print("Error writing document: \(err)")
                    } else {
                        print("Document successfully written!")
                        self.createAlert(title: "Saved!", message: "Password was changed.")
                    }
            }
        }
    }
    @IBAction func saveButton(_ sender: Any) {
        guard let name = usernameLabel.text, let classMember = classMemberLabel.text, let plate = plate.text, let mssv = mssvLabel.text else {
            createAlert(title: "Somethings wrong!", message: "Please check your information.")
            return
        }
        guard var member = member else { return }
        member.name = name
        member.cClass = classMember
        member.plate = plate
        member.mssv = mssv
        let db = Firestore.firestore()
        let settings = db.settings
        db.settings = settings
        if let documentID = UserDefaults.standard.value(forKey: "documentID") as? String {
            db.collection("members").document(documentID).setData([
                "MSSV": member.mssv,
                "RFID": member.RFID,
                "class": member.cClass,
                "history": member.history,
                "isCurrentlyIn": member.isCurrentlyIn,
                "lastActivity": member.lastActivity,
                "name": member.name,
                "password": member.password,
                "plate": member.plate,
                "subscribeUntil": member.subscribeUntil,
            ]) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    print("Document successfully written!")
                    self.createAlert(title: "Saved!", message: "Informations was changed.")
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Edit profile"
        navigationController?.navigationBar.barTintColor = UIColor.white
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 25, weight: .bold)]
        navigationController?.navigationBar.tintColor = UIColor.black
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
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: self)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: self)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc func handleTap(){
        view.endEditing(true)
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
            if viewRect.contains(activeField.frame.origin) && activeField.frame.maxY > (view.bounds.height - keyboardHeight + 20) {
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
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        scrollView.addGestureRecognizer(tap)
        saveButton.isEnabled = false
        saveButton.alpha = 0.6
        changeButton.isEnabled = false
        changeButton.alpha = 0.6
        passwordTextfield.isSecureTextEntry = true
        re_typePasswordTextField.isSecureTextEntry = true
        passwordTextfield.delegate = self
        re_typePasswordTextField.delegate = self
        usernameLabel.delegate = self
        classMemberLabel.delegate = self
        mssvLabel.keyboardType = .numberPad
        plate.delegate = self
        mssvLabel.delegate = self
        usernameLabel.addTarget(self, action: #selector(handleSaveButton), for: .editingChanged)
        classMemberLabel.addTarget(self, action: #selector(handleSaveButton), for: .editingChanged)
        plate.addTarget(self, action: #selector(hadleCheckPlate), for: .editingChanged)
        mssvLabel.addTarget(self, action: #selector(handleCheckMSSV(sender:)), for: .editingChanged)
        passwordTextfield.addTarget(self, action: #selector(handleChangePassword), for: .editingChanged)
        re_typePasswordTextField.addTarget(self, action: #selector(handleChangePassword), for: .editingChanged)
        
        if let documentID = UserDefaults.standard.value(forKey: "documentID") as? String {
            let db = Firestore.firestore()
            let settings = db.settings
            db.settings = settings
            db.collection("members").document(documentID)
                .addSnapshotListener { documentSnapshot, error in
                    guard let document = documentSnapshot else {
                        print("Error fetching document: \(error!)")
                        return
                    }
                    guard let data = document.data() else {
                        print("Document data was empty.")
                        return
                    }
                    let mssv = data["MSSV"] as? String ?? ""
                    let name = data["name"] as? String ?? ""
                    let plate = data["plate"] as? String ?? ""
                    let class1 = data["class"] as? String ?? ""
                    let isCurrentlyIn = data["isCurrentlyIn"] as? Bool ?? false
                    let lastActivity = data["lastActivity"] as? Timestamp ?? Timestamp(date: Date())
                    let rfid = data["RFID"] as? Int ?? 0
                    let history = data["history"] as? [String] ?? [String]()
                    let password = data["password"] as? String ?? ""
                    let subscribeUntil = data["subscribeUntil"] as? Timestamp ?? Timestamp(date: Date())
                    self.member =  Member(subscribeUntil: subscribeUntil, mssv: mssv, password: password, history: history, RFID: rfid, lastActivity: lastActivity, name: name, isCurrentlyIn: isCurrentlyIn, plate: plate, cClass: class1)
                    guard let member = self.member else { return }
                    self.usernameLabel.placeholder = "Name: " + member.name
                    self.mssvLabel.placeholder = "MSSV: " + member.mssv
                    self.plate.placeholder = "Plate: " + member.plate
                    self.classMemberLabel.placeholder = "Class: " + member.cClass
            }
        }
    }
    
    @objc func handleChangePassword(){
        guard let password = passwordTextfield.text, let re_typePassword = re_typePasswordTextField.text else { return }
        if password.count < 6 || re_typePassword.count < 6 || password != re_typePassword {
            changeButton.isEnabled = false
            changeButton.alpha = 0.6
        }else {
            changeButton.isEnabled = true
            changeButton.alpha = 1
        }
    }
    
    @objc func hadleCheckPlate(sender: UITextField){
        handleSaveButton()
        if let plateStr = sender.text, let member = member {
            let isPlateAlready1 = checkIsMSSVAlreadyExist(arrData: plateData, str: plateStr)
            print(plateData)
            print(isPlateAlready1)
            if isPlateAlready1 && plateStr != member.plate  {
                saveButton.isEnabled = false
                saveButton.alpha = 0.7
                if plateStr.count > 2 {
                    let index1 = plateStr.index(before: plateStr.endIndex)
                    plate.text = String(plateStr[..<index1])
                }
                let alert = UIAlertController(title: "\(plateStr) already exists", message: "Re-type Plate", preferredStyle: .alert)
                let alertAction = UIAlertAction(title: "OK", style: .default, handler: { (_) in
                    self.plate.becomeFirstResponder()
                    return
                })
                alert.addAction(alertAction)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    @objc func handleCheckMSSV(sender: UITextField){
        handleSaveButton()
        if let mssvStr = sender.text, let member = member {
            let isMSSVAlready1 = checkIsMSSVAlreadyExist(arrData: mssvData, str: mssvStr)
            print(mssvData)
            if isMSSVAlready1 && mssvStr != member.mssv {
                saveButton.isEnabled = false
                saveButton.alpha = 0.7
                if mssvStr.count > 2 {
                    let index1 = mssvStr.index(before: mssvStr.endIndex)
                    mssvLabel.text = String(mssvStr[..<index1])
                }
                let alert = UIAlertController(title: "\(mssvStr) already exists", message: "Re-type MSSV", preferredStyle: .alert)
                let alertAction = UIAlertAction(title: "OK", style: .default, handler: { (_) in
                    self.mssvLabel.becomeFirstResponder()
                    return
                })
                alert.addAction(alertAction)
                self.present(alert, animated: true, completion: nil)
            }
            
            if !isMSSVAlready1 && mssvStr.count == 9 {
                sender.textColor = .black
            }
        }
    }
    
    @objc func handleSaveButton(){
        guard let name = usernameLabel.text, let classMember = classMemberLabel.text, let plate = plate.text, let mssv = mssvLabel.text else {
            createAlert(title: "Somethings wrong!", message: "Please check your information.")
            return
        }
        if name.count > 0 && classMember.count > 0 && plate.count > 0 && mssv.count > 0 {
            saveButton.isEnabled = true
            saveButton.alpha = 1
        }else {
            saveButton.isEnabled = false
            saveButton.alpha = 0.6
        }
    }
    
    fileprivate func createAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default) { (_) in
            self.navigationController?.popViewController(animated: true)
        }
        alert.addAction(alertAction)
        present(alert, animated: true, completion: nil)
    }
    
    fileprivate func checkIsMSSVAlreadyExist(arrData: [String], str: String) -> Bool{
        for str1 in arrData {
            if str == str1 {
                return true
            }
        }
        return false
    }
    
}

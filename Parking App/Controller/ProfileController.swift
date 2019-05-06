//
//  ProfileViewController.swift
//  Parking App
//
//  Created by An Nguyễn on 4/8/19.
//  Copyright © 2019 An Nguyễn. All rights reserved.
//

import UIKit
import FirebaseFirestore

class ProfileController: UIViewController {

    @IBOutlet weak var profileImage: UIButton!
    @IBOutlet weak var boundsInforView: UIView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var memberOrGuestLabel: UILabel!
    @IBOutlet weak var isCurrentlyIn: UIImageView!
    @IBOutlet weak var rfidLabel: UILabel!
    @IBOutlet weak var classAndMssv: UILabel!
    @IBOutlet weak var plateLabel: UILabel!
    @IBOutlet weak var lastActivityLabel: UILabel!
    
    @IBAction func profileImage(_ sender: Any) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Profile"
        navigationController?.navigationBar.barTintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 25, weight: .bold)]
        navigationItem.rightBarButtonItem?.tintColor = .black
        navigationController?.navigationBar.tintColor = UIColor.black
        profileImage.cornerImage(profileImage.bounds.width/2)
        setInformation()
    }
    
    @IBAction func logoutButton(_ sender: Any) {
        let alert = UIAlertController(title: "LOGOUT", message: "You will logout!", preferredStyle: .actionSheet)
        let OkButton = UIAlertAction(title: "OK", style: .default) { (_) in
            UserDefaults.standard.set(nil, forKey: "email")
            UserDefaults.standard.set(nil, forKey: "password")
            let startVC = self.storyboard?.instantiateViewController(withIdentifier: "loginVC")
            startVC?.modalTransitionStyle = .crossDissolve
            startVC?.modalPresentationStyle = .custom
            self.dismiss(animated: true, completion: nil)
            //self.navigationController?.popToViewController(startVC!, animated: true)
            print("LOGTOUT!!!")
        }
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
            print("Cancel!")
        }
        alert.addAction(OkButton)
        alert.addAction(cancelButton)
        present(alert, animated: true, completion: nil)
    }
    
    func setInformation(){
        let db = Firestore.firestore()
        let settings = db.settings
        db.settings = settings
        var documentID: String? {
            didSet{
                guard let documentID = documentID  else { return }
                UserDefaults.standard.set(documentID, forKey: "documentID")
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
                        let rfid = data["RFID"] as? Int ?? 0
                        let class1 = data["class"] as? String ?? ""
                        let isCurrentlyIn = data["isCurrentlyIn"] as? Bool ?? false
                        let lastActivity = data["lastActivity"] as? Timestamp ?? Timestamp(date: Date())
                        let name = data["name"] as? String ?? ""
                        let plate = data["plate"] as? String ?? ""
                        self.usernameLabel.text = name
                        self.isCurrentlyIn.backgroundColor = !isCurrentlyIn ? .gray: .green
                        self.classAndMssv.text = "\(mssv) - \(class1)"
                        if rfid == 0 {
                            self.lastActivityLabel.text = "Register: \(self.convertDateTime(date: lastActivity.dateValue()))"
                            self.memberOrGuestLabel.text = "Guest"
                        }else {
                            self.lastActivityLabel.text = "Last activity: \(self.convertDateTime(date: lastActivity.dateValue()))"
                        }
                        self.rfidLabel.text = "RFID: \(rfid)"
                        self.plateLabel.text = "Plate: \(plate)"
                }
            }
        }
        if let documentIDUserDefaults = UserDefaults.standard.value(forKey: "documentID") as? String {
            documentID = documentIDUserDefaults
        }
        
    }
    
    fileprivate func convertDateTime(date: Date) -> String{
        let dateCurrent = Date()
        let calendar:Calendar = Calendar.current
        
        let day = calendar.component(Calendar.Component.day, from: date)
        let month = calendar.component(Calendar.Component.month, from: date)
        let year = calendar.component(Calendar.Component.year, from: date)
        let second = calendar.component(Calendar.Component.second, from: date)
        let minute = calendar.component(Calendar.Component.minute, from: date)
        let hour = calendar.component(Calendar.Component.hour, from: date)
        
        let dayCurrent = calendar.component(Calendar.Component.day, from: dateCurrent)
        let monthCurrent = calendar.component(Calendar.Component.month, from: dateCurrent)
        let yearCurrent = calendar.component(Calendar.Component.year, from: dateCurrent)
        let secondCurrent = calendar.component(Calendar.Component.second, from: dateCurrent)
        let minuteCurrent = calendar.component(Calendar.Component.minute, from: dateCurrent)
        let hourCurrent = calendar.component(Calendar.Component.hour, from: dateCurrent)
        
        //TODO: -Caculator day
        let yearResult = yearCurrent - year
        let monthResult = (yearCurrent == year) ? (monthCurrent - month): ( yearResult * 12 - month + monthCurrent)
        var dayResult = 0
        if(year == yearCurrent){
            if(month == monthCurrent){
                dayResult += dayCurrent - day;
            }else{
                dayResult += dayOfMonth(month: month, year: year) - day + dayCurrent;
                for  i in month + 1 ..< monthCurrent{
                    dayResult += dayOfMonth(month: i, year: year);
                }
            }
        }
        if year != yearCurrent {
            if day == dayCurrent && month == monthCurrent {
                for j in year ..< yearCurrent {
                    dayResult += dayOfYear(year: j)
                }
            }
            else{
                dayResult += dayOfMonth(month: month, year: year) - day + dayCurrent
                for i in month ... 12 {
                    dayResult += dayOfMonth(month: i, year: year)
                }
                for i in 1..<monthCurrent {
                    dayResult += dayOfMonth(month: i, year: year);
                    for j in year+1 ..< yearCurrent{
                        dayResult += dayOfYear(year: j)
                    }
                }
            }
        }
        
        let hourResult = (dayCurrent == day) ? (hourCurrent - hour): (dayResult * 24 - hour + hourCurrent)
        let minuteResult = (hourCurrent == hour) ? (minuteCurrent - minute): (hourResult * 60 - minute + minuteCurrent)
        let secondResult = (minuteCurrent == minute) ? (secondCurrent - second): (minuteResult * 60 - second + secondCurrent)

        if yearResult > 0 && monthResult > 12 {
            if yearResult == 1 {
                return "An year ago"
            }
            return "\(yearResult) years ago"
        }
        if monthResult > 0 && dayResult > 30{
            if monthResult == 1 {
                return "An month ago"
            }
            return "\(monthResult) months ago"
        }
        if dayResult > 0 && hourResult > 24{
            if dayResult == 1 {
                return "An day ago"
            }
            return "\(dayResult) days ago"
        }
        if hourResult > 0 && minuteResult > 60 {
            if hourResult == 1 {
                return "An hour ago"
            }
            return "\(hourResult) hours ago"
        }
        if minuteResult > 0 && secondResult > 60 {
            if minuteResult == 1 {
                return "An minute ago"
            }
            return "\(minuteResult) minutes ago"
        }
        if secondResult > 0 {
            if secondResult == 1 {
                return "An second ago"
            }
            return "\(secondResult) seconds ago"
        }
        return "Now"
    }
    
    fileprivate func dayOfMonth(month: Int, year: Int) -> Int{
        switch month {
        case 1,3,5,7,8,10,12:
            return 31
        case 4,6,9,11:
            return 30
        case 2:
            return ((year % 4 == 0 && year % 100 != 0 ) || (year % 400 == 0)) ? 29: 28
        default:
            return 0
        }
        
    }
    
    fileprivate func dayOfYear(year: Int) -> Int {
        if ((year % 4 == 0) && (year % 100 != 0 )) || (year % 400 == 0) {
            return 366
        }
        return 365
    }
}

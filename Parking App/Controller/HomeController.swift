//
//  HomeViewController.swift
//  Parking App
//
//  Created by An Nguyễn on 4/8/19.
//  Copyright © 2019 An Nguyễn. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseCore

class HomeController: UIViewController {

    var imageView: UIImageView!
    @IBOutlet weak var viewAboutUs: UIView!
    @IBOutlet weak var numberOfDaysLeft: UILabel!
    @IBOutlet var inforLabel: [UILabel]!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = "Home"
        navigationController?.navigationBar.barTintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 25, weight: .bold)]
        navigationController?.navigationBar.tintColor = UIColor.black
        imageView = UIImageView()
        imageView.frame = CGRect(x: view.bounds.width/2 - 100, y: 350, width: 200, height: 200)
        view.addSubview(imageView)
        imageView.isHidden = true
        viewAboutUs.borderView(5, UIColor.white)
        inforLabel.forEach { (label) in
            label.textColor = UIColor.white
        }
        numberOfDaysLeft.textColor = .white
        
        let db = Firestore.firestore()
        let settings = db.settings
        db.settings = settings
        if let documentID = UserDefaults.standard.value(forKey: "documentID") as? String {
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
                    let subscribeUntil = data["subscribeUntil"] as? Timestamp ?? Timestamp(date: Date())
                    let rfid = data["RFID"] as? Int ?? 0
                    let dateSubscribeUntil = subscribeUntil.dateValue()
                    let daysLeft = self.numberOfDaysLeft(dateUntil: dateSubscribeUntil)
                    let dateFormater = DateFormatter()
                    dateFormater.dateFormat = "hh:mm:ss  dd-MM-yyyy"
                    let dateStr = dateFormater.string(from: dateSubscribeUntil)
                    if rfid == 0 {
                        self.numberOfDaysLeft.text = "You were register but receive card not yet, please go to our counter pay fee and get your card. Thank you!"
                    }else {
                        if daysLeft == 0 {
                            self.numberOfDaysLeft.text = "Please charge more at our counter. Your card has expired form \(dateStr) !"
                        }else{
                            self.numberOfDaysLeft.text = "Your account has \(daysLeft) days left !"
                        }
                    }
                    
                    
            }
        }
        
    }
    
    fileprivate func createAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(alertAction)
        present(alert, animated: true, completion: nil)
    }
    
    fileprivate func numberOfDaysLeft(dateUntil: Date) -> Int{
        let dateCurrent = Date()
        let calendar = Calendar.current
        let dayUntil = calendar.component(Calendar.Component.day, from: dateUntil)
        let monthUntil = calendar.component(Calendar.Component.month, from: dateUntil)
        //let yearUntil = calendar.component(Calendar.Component.year, from: dateUntil)
        let dayCurrent = calendar.component(Calendar.Component.day, from: dateCurrent)
        let monthCurrent = calendar.component(Calendar.Component.month, from: dateCurrent)
        let yearCurrent = calendar.component(Calendar.Component.year, from: dateCurrent)
        let dayOfMonthCurrent = dayOfMonth(month: monthCurrent, year: yearCurrent)
        
        if monthCurrent == monthUntil {
            return dayUntil - dayCurrent
        }else if monthUntil > monthCurrent {
            return dayOfMonthCurrent - dayCurrent + dayUntil
        }else {
            return 0
        }
        
    }
    
    fileprivate func dayOfMonth(month: Int, year: Int) -> Int{
        switch month {
        case 1,3,5,7,8,10,12:
            return 31
        case 4,6,9,11:
            return 30
        case 2:
            return (((year % 4 == 0) && (year % 100 != 0 )) || (year % 400 == 0)) ? 29: 28
        default:
            return 0
        }
        
    }
}

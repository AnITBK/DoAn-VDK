//
//  MoreViewController.swift
//  Parking App
//
//  Created by An Nguyễn on 4/8/19.
//  Copyright © 2019 An Nguyễn. All rights reserved.
//

import UIKit
import FirebaseFirestore
import Firebase


class MoreController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var members_guestsSegue: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    private var members = [Member]()
    private var guests = [Guest]()
    @IBAction func backHome(_ sender: Any) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Detail"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.isNavigationBarHidden = false
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleLoadData), for: .valueChanged)
        refreshControl.tintColor = .red
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        }else {
            tableView.addSubview(refreshControl)
        }
        tableView.delegate = self
        tableView.dataSource = self
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.isNavigationBarHidden = false
    }
    
    @objc func handleLoadData(){
        fetchData()
    }
    
    func fetchData(){
        let db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        members = []
        guests = []
        if members_guestsSegue.selectedSegmentIndex == 0{
            db.collection("members").getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                    return
                }
                for document in querySnapshot!.documents {
                    let data = document.data()
                    let rfid = data["RFID"] as? Int ?? 0
                    let lastActivity = data["lastActivity"] as? Date ?? Date()
                    let name = data["name"] as? String ?? ""
                    let isCurrentlyIn = data["isCurrentlyIn"] as? Bool ?? false
                    let plate = data["plate"] as? String ?? ""
                    let cClass = data["class"] as? String ?? ""
                    let member = Member(RFID: rfid, lastActivity: lastActivity, name: name, isCurrentlyIn: isCurrentlyIn, plate: plate, cClass: cClass)
                    self.members.append(member)
                }
                self.tableView.reloadData()
                self.tableView.refreshControl?.endRefreshing()
            }
        }else {
//           Guests
            self.tableView.refreshControl?.endRefreshing()
        }
        
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if members_guestsSegue.selectedSegmentIndex == 0{
            return self.members.count
        }else {
            return self.guests.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        if members_guestsSegue.selectedSegmentIndex == 0{
            let member = members[indexPath.row]
            cell.textLabel?.text = "\(member.name)"
            cell.accessoryType = member.isCurrentlyIn ? .checkmark: .none
        }else {
            let guest = guests[indexPath.row]
            cell.textLabel?.text = "\(guest.name)"
            cell.accessoryType = guest.isCurrentlyIn ? .checkmark: .none
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if members_guestsSegue.selectedSegmentIndex == 0{
            print(self.members[indexPath.row])
        }else {
            print(self.guests[indexPath.row])
        }
    }
    
    @IBAction func members_guestsSegue(_ sender: UISegmentedControl) {
        tableView.reloadData()
    }


}

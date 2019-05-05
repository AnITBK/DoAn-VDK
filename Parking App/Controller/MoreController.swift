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
    
    @IBOutlet weak var totalTime: UILabel!
    @IBOutlet weak var tableView: UITableView!
    var histories: [String]?
    var headersDays: [String]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "History"
        navigationController?.navigationBar.barTintColor = UIColor(red: 36/255, green: 36/255, blue: 36/255, alpha: 0.8)
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 25, weight: .bold), NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationController?.navigationBar.tintColor = UIColor.white
        tableView.delegate = self
        tableView.dataSource = self
        fetchData()
    }
    
    fileprivate func fetchData(){
        let db = Firestore.firestore()
        let settings = db.settings
        db.settings = settings
        var documentID: String? {
            didSet{
                guard let documentID = documentID  else { return }
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
                        self.histories = data["history"] as? [String] ?? [String]()
                        guard var histories = self.histories else { return }
                        self.reverseHistories(histories: &histories)
                        self.histories = histories
                        self.handleHistories(histories: self.histories ?? [String]())
                        self.totalTime.text = "Total: \(self.histories?.count ?? 0) times"
                        self.tableView.reloadData()
                }
            }
        }
        if let documentIDUserDefaults = UserDefaults.standard.value(forKey: "documentID") as? String {
            documentID = documentIDUserDefaults
        }
    }
    
    fileprivate func handleHistories(histories: [String]) {
        headersDays = [String]()
        for history in histories {
            //Request: Open --- Time: Sat Apr 27 2019 17:19:33 GMT+0700 (Indochina Time) --- Failed
            let indexFrom = history.index(history.firstIndex(of: "-")!, offsetBy: 10)
            let indexTo = history.index(history.firstIndex(of: "-")!, offsetBy: 25)
            let time = String(history[indexFrom...indexTo])
            if time != (headersDays?.last ?? "") {
                headersDays?.append(time)
            }
        }
    }
    
    fileprivate func reverseHistories(histories: inout [String]){
        if histories.count > 0 {
            var j = histories.count - 1
            for i in 0..<histories.count/2 {
                let history = histories[i]
                histories[i] = histories[j]
                histories[j] = history
                j -= 1
            }
        }
        print("aaa",histories)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return headersDays?[section] ?? ""
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return headersDays?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return histories?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "historyCell") as! HistoryCell
        let history = histories?[indexPath.row] ?? ""
        cell.setupCell(history: history)
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layer.transform = CATransform3DMakeScale(0.1,0.1,1)
        UIView.animate(withDuration: 0.5, animations: {
            cell.layer.transform = CATransform3DMakeScale(1,1,1)
        })
        UIView.animate(withDuration: 0.5, animations: {
            cell.layer.transform = CATransform3DMakeScale(2,2,2)
        })
        UIView.animate(withDuration: 0.5, animations: {
            cell.layer.transform = CATransform3DMakeScale(1,1,1)
        })
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }


}

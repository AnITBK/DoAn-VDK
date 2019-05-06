//
//  HistoryCell.swift
//  Parking App
//
//  Created by An Nguyễn on 4/27/19.
//  Copyright © 2019 An Nguyễn. All rights reserved.
//

import UIKit

class HistoryCell: UITableViewCell {
    @IBOutlet weak var viewBoundContent: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var imageFailedOrSucess: UIImageView!
    
    func setupCell(history: String){
        var request = "Request"
//Request: Exit --- Time: Sun May 05 2019 19:38:29 GMT+0700 (SE Asia Standard Time) --- Succceed
        if history.contains("Open") {
            request += ": Open"
        }else{
            request += ": Exit"
        }
        let indexFrom = history.index(history.firstIndex(of: "-")!, offsetBy: 26)
        let indexTo = history.index(history.firstIndex(of: "-")!, offsetBy: 43)
        let time = history[indexFrom...indexTo]
        timeLabel.text = request + " - Time: " + time
        timeLabel.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.thin)
        timeLabel.textColor = UIColor.white
        viewBoundContent.layer.shadowColor = UIColor.gray.cgColor
        viewBoundContent.layer.shadowOffset = CGSize(width: 1, height: 1)
        if history.contains("Exit") && history.contains("Succceed") {
            imageFailedOrSucess.image = #imageLiteral(resourceName: "out_Success")
        }
        if history.contains("Exit") && history.contains("Failed") {
            imageFailedOrSucess.image = #imageLiteral(resourceName: "out_Failed")
        }
        if history.contains("Open") && history.contains("Succeed") {
            imageFailedOrSucess.image = #imageLiteral(resourceName: "in_success")
        }
        if history.contains("Open") && history.contains("Failed") {
            imageFailedOrSucess.image = #imageLiteral(resourceName: "in_failed")
        }
    }
}

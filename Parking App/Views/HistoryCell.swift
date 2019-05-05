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
        if history.contains("Open") {
            request += ": Open"
        }else{
            request += ": Exit"
        }
        let indexFrom = history.index(history.firstIndex(of: "-")!, offsetBy: 4)
        let indexTo = history.index(history.firstIndex(of: "+")!, offsetBy: 4)
        let time = history[indexFrom...indexTo]
        timeLabel.text = request + " - " + time
        viewBoundContent.layer.shadowColor = UIColor.gray.cgColor
        viewBoundContent.layer.shadowOffset = CGSize(width: 1, height: 1)
        if history.contains("Exit") && history.contains("Succeed") {
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

//
//  CustomView.swift
//  Parking App
//
//  Created by An Nguyễn on 4/9/19.
//  Copyright © 2019 An Nguyễn. All rights reserved.
//

import UIKit

extension UIColor {
    static let tealColor = UIColor(red: 48/255, green: 164/255, blue: 182/255, alpha: 1)
    
    static let tableViewBgColor = UIColor(red: 9/255, green: 45/255, blue: 64/255, alpha: 1)
    
    static let lightRed = UIColor(red: 247/255, green: 66/255, blue: 82/255, alpha: 1)
    
    static let lightBlue = UIColor(red: 218/255, green: 235/255, blue: 243/255, alpha: 1)
}

extension UIView {
    func cornerImage(_ cornerRadius: CGFloat){
        layer.borderWidth = 4
        layer.borderColor = UIColor.white.cgColor
        layer.masksToBounds = true
        clipsToBounds = true
        layer.cornerRadius = cornerRadius
    }
    func borderView(_ cornerRadius: CGFloat,_ color: UIColor){
        layer.borderWidth = 2
        layer.borderColor = color.cgColor
        layer.masksToBounds = true
        clipsToBounds = true
        layer.cornerRadius = cornerRadius
        
    }
}

//
//  CustomView.swift
//  Parking App
//
//  Created by An Nguyễn on 4/9/19.
//  Copyright © 2019 An Nguyễn. All rights reserved.
//

import UIKit

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

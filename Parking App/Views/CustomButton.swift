//
//  CustomButton.swift
//  Parking App
//
//  Created by An Nguyễn on 4/23/19.
//  Copyright © 2019 An Nguyễn. All rights reserved.
//

import UIKit

@IBDesignable
class CustomButton: UIButton {
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    @IBInspectable var borderColor: UIColor? {
        didSet {
            layer.borderColor = borderColor?.cgColor
        }
    }
    @IBInspectable var height: CGFloat = 45 {
        didSet {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
}

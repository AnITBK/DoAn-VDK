//
//  Guest.swift
//  Parking App
//
//  Created by An Nguyễn on 4/9/19.
//  Copyright © 2019 An Nguyễn. All rights reserved.
//

import Foundation

struct Guest: Person {
    var RFID: Int
    
    var lastActivity: Date
    
    var name: String
    
    var isCurrentlyIn: Bool
    
    var plate: String
    
    var cClass: String
    
    
}

//
//  Member.swift
//  Parking App
//
//  Created by An Nguyễn on 4/9/19.
//  Copyright © 2019 An Nguyễn. All rights reserved.
//

import Foundation

protocol Person {
    var RFID: Int {get}
    var lastActivity: Date {set get}
    var name: String {set get}
    var isCurrentlyIn: Bool {get}
    var plate: String {set get}
    var cClass: String {set get}
}

struct Member: Person {
    var RFID: Int
    
    var lastActivity: Date
    
    var name: String
    
    var isCurrentlyIn: Bool
    
    var plate: String
    
    var cClass: String
}

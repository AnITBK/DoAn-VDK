//
//  Member.swift
//  Parking App
//
//  Created by An Nguyễn on 4/9/19.
//  Copyright © 2019 An Nguyễn. All rights reserved.
//

import Foundation
import FirebaseFirestore

protocol Person {
    var mssv: String {set get}
    var password: String {set get}
    var RFID: Int {set get}
    var lastActivity: Timestamp {set get}
    var name: String {set get}
    var isCurrentlyIn: Bool {get}
    var plate: String {set get}
    var cClass: String {set get}
    var subscribeUntil: Timestamp {set get}
    var history: [String] {get set}
}

struct Member: Person {
    
    var subscribeUntil: Timestamp
    
    var mssv: String
    
    var password: String
    
    var history: [String]
    
    var RFID: Int
    
    var lastActivity: Timestamp
    
    var name: String
    
    var isCurrentlyIn: Bool
    
    var plate: String
    
    var cClass: String
}

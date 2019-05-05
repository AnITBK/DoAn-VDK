//
//  Member.swift
//  Parking App
//
//  Created by An Nguyễn on 4/9/19.
//  Copyright © 2019 An Nguyễn. All rights reserved.
//

import Foundation
import FirebaseFirestore

struct Member {
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

//
//  User.swift
//  Flash Chat iOS13
//
//  Created by Yu Lin on 2020/6/18.
//  Copyright © 2020 Angela Yu. All rights reserved.
//

import Foundation

struct User {
    let id: String
    let email: String
    let userName: String
    var friendList: [Friend]
}

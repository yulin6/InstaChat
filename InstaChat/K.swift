//
//  Constants.swift
//  Flash Chat iOS13
//
//  Created by Yu Lin on 2020/6/2.
//  Copyright © 2020 Angela Yu. All rights reserved.
//

import Foundation

struct K {
    static let appName = "    InstaChat"
    static let cellIdentifier = "ReusableCell"
    static let cellNibName = "MessageCell"
    static let registerSegue = "RegisterToChat"
    static let loginSegue = "LoginToChat"
    static let chatSegue = "ListToChat"
    static let welcomeSegue = "WelcomeToFriendList"
    
    struct BrandColors {
        static let green0 = "green0"
        static let green1 = "green1"
        static let green2 = "green2"
        static let green3 = "green3"
    }
    
    struct FStore {
        static let id = "id"
        static let users = "users"
        static let friends = "friends"
        static let friendList = "friendList"
        static let email = "email"
        static let userName = "userName"
        static let messagesCollection = "messages"
        static let senderField = "sender"
        static let receiverField = "receiver"
        static let bodyField = "body"
        static let dateField = "date"
    }
}



import Foundation
import RealmSwift

class User: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var email: String = ""
    @objc dynamic var userName: String = ""
    var friendList = List<Friend>()
    
    init(id: String, email: String, userName: String, friendList: List<Friend>) {
        self.id = id
        self.email = email
        self.userName = userName
        self.friendList = friendList
    }
    
    override required init() {
//        fatalError("init() has not been implemented")
    }
    
    
}

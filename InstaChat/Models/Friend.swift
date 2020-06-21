

import Foundation
import RealmSwift

class Friend: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var email: String = ""
    @objc dynamic var userName: String = ""
    
    
    init(id: String, email: String, userName: String) {
        self.id = id
        self.email = email
        self.userName = userName
    }
    
    override required init() {
//        fatalError("init() has not been implemented")
    }
    

    
    
    
//    var parent = LinkingObjects(fromType: User.self, property: "friendList")
}



import UIKit
import Firebase
import RealmSwift

class FriendsListViewController: UIViewController {
    
    @IBOutlet weak var friendListTable: UITableView!
    let defaults = UserDefaults.standard
    let realm = try! Realm()
    let db = Firestore.firestore()
    
    var currentUserResults: Results<User>? {
        didSet {
            reloadTable()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        friendListTable.rowHeight = 85.0
        friendListTable.dataSource = self
        friendListTable.delegate = self
        
        setCurrentUserResults()
    }
    
    func reloadTable() {
        DispatchQueue.main.async {
            self.title = self.currentUserResults?[0].userName
            self.friendListTable.reloadData()
        }
    }
    
    func setCurrentUserResults() {
        
        //if local has logedin user, retrieve its data from realm and set it to a variable
        if let userId = defaults.string(forKey: "LocalUserId")  {
            currentUserResults = realm.objects(User.self).filter("id = '\(userId)'")
        }
        
        //retrieving data from firestore
        if let userEmail = Auth.auth().currentUser?.email, let userId = Auth.auth().currentUser?.uid{
            
            let docRef = db.collection(K.FStore.users).document(userEmail)
            docRef.addSnapshotListener { (querySnapshot, error) in
                if let e = error{
                    print("There was an issue retrieving data from Firestore. \(e)")
                } else {
                    if let data = querySnapshot?.data(){
                        if let userName = data[K.FStore.userName] as? String{
                            
                            self.defaults.set(userId, forKey: "LocalUserId")
                            self.defaults.set(userEmail, forKey: "LocalUserEmail")
                            self.defaults.set(userName, forKey: "LocalUserName")
                            
                            
                            self.currentUserResults = self.realm.objects(User.self).filter("id = '\(userId)'")
                            self.setFriendListToCurrentUser(data: data)
                            
                            
                        }
                    }
                }
            }
        }
    }
    
    func setFriendListToCurrentUser(data : Dictionary<String, Any>) {
        if let fList = data[K.FStore.friendList] as? [[String: String]] {
            
            if let currentUser = self.currentUserResults?[0] {
                do{
                    try self.realm.write {
                        for friend in currentUser.friendList {
                            realm.delete(friend)
                        }
                        print("cleared all friends")
                    }
                }catch{
                    print("Error clearing all friends, \(error)")
                }
            }
            
            for friend in fList {
                if let friendId = friend[K.FStore.id],let friendEmail = friend[K.FStore.email], let friendUsername = friend[K.FStore.userName]{
                    let newFriend = Friend(id: friendId, email: friendEmail, userName: friendUsername)
                    
                    writeNewFriendToRealm(friend: newFriend)
                    
                }
            }
        }
    }
    
    func writeNewFriendToRealm(friend: Friend) {
        if let currentUser = self.currentUserResults?[0] {
            do{
                try self.realm.write {
                    currentUser.friendList.append(friend)
                }
            }catch{
                print("Error appending new friend, \(error)")
            }
        }
    }
    
    
    
    
    @IBAction func addFriend(_ sender: Any) {
        let alert = UIAlertController(title: "Add a New Friend", message: "", preferredStyle: .alert)
        var textField = UITextField()
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Enter Email"
            textField = alertTextField
        }
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            if let receiverEmail = textField.text, let senderEmail = self.currentUserResults?[0].email, let senderUsername = self.currentUserResults?[0].userName, let senderId = self.currentUserResults?[0].id {
                let docRef = self.db.collection(K.FStore.users).document(receiverEmail)
                docRef.getDocument{ (document, error) in
                    if let e = error{
                        print("There was an issue retrieving data from Firestore. \(e)")
                        
                    } else if let document = document, document.exists {
                        if let data = document.data(){
                            
                            if let receiverId = data[K.FStore.id] as? String, let receiverUsername = data[K.FStore.userName] as? String {
                                
                                let newFriend = Friend(id: receiverId, email: receiverEmail, userName: receiverUsername)
                                self.writeNewFriendToRealm(friend: newFriend)
                                
                                self.db.collection(K.FStore.users).document(self.currentUserResults![0].email).updateData([K.FStore.friendList : FieldValue.arrayUnion(
                                    [[K.FStore.id : receiverId,
                                      K.FStore.email : receiverEmail,
                                      K.FStore.userName : receiverUsername]])])
                                self.db.collection(K.FStore.users).document(receiverEmail).updateData([K.FStore.friendList : FieldValue.arrayUnion(
                                    [[K.FStore.id : senderId,
                                      K.FStore.email : senderEmail,
                                      K.FStore.userName : senderUsername]])])
                                
                                //add empty message list
                                self.db.collection(K.FStore.messagesCollection).document(self.currentUserResults![0].email).setData([receiverId : []], merge: true)
                                self.db.collection(K.FStore.messagesCollection).document(receiverEmail).setData([self.currentUserResults![0].id : []], merge: true)
                                
                            }
                        }
                        
                        
                    } else {
                        let notExistAlert = UIAlertController(title: "User Not Exist", message: "", preferredStyle: .alert)
                        let notExistAction = UIAlertAction(title: "Done", style: .default, handler: nil)
                        notExistAlert.addAction(notExistAction)
                        self.present(notExistAlert, animated: true, completion: nil)
                    }
                }
            }
            
            
            print("searched")
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func logOutPressed(_ sender: UIBarButtonItem) {
        do {
            try Auth.auth().signOut()
            self.defaults.removeObject(forKey: "LocalUserId")
            self.defaults.removeObject(forKey: "LocalUserEmail")
            self.defaults.removeObject(forKey: "LocalUserName")
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
}

extension FriendsListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentUserResults?[0].friendList.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell", for: indexPath)
        cell.textLabel?.text = currentUserResults?[0].friendList[indexPath.row].userName
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print(currentUserResults?[0].friendList[indexPath.row])
        
        performSegue(withIdentifier: K.chatSegue, sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ChatViewController
        
        if let indexPath = friendListTable.indexPathForSelectedRow {
            destinationVC.receiver = currentUserResults?[0].friendList[indexPath.row]
            destinationVC.sender = self.currentUserResults?[0]
            
        }
    }
    
    
}

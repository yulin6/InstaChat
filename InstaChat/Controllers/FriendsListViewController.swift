//
//  FriendsListViewController.swift
//  Flash Chat iOS13
//
//  Created by Yu Lin on 2020/6/17.
//  Copyright © 2020 Angela Yu. All rights reserved.
//

import UIKit
import Firebase

class FriendsListViewController: UIViewController {
    
    @IBOutlet weak var friendListTable: UITableView!
    
    let db = Firestore.firestore()
    var currentUser: User? {
        didSet {
            reloadTable()
        }
    }
    var friendList: [Friend] = []
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        friendListTable.rowHeight = 85.0
        friendListTable.dataSource = self
        friendListTable.delegate = self
        setCurrentUser()
        
    }
    
    func reloadTable() {
        DispatchQueue.main.async {
            self.title = self.currentUser?.userName
            self.friendListTable.reloadData()
        }
    }
    
    func setCurrentUser() {
        if let userEmail = Auth.auth().currentUser?.email, let userId = Auth.auth().currentUser?.uid{
            let docRef = db.collection(K.FStore.users).document(userEmail)
            docRef.addSnapshotListener { (querySnapshot, error) in
                self.friendList = []
                if let e = error{
                    print("There was an issue retrieving data from Firestore. \(e)")
                } else {
                    if let data = querySnapshot?.data(){
                        self.setFriendList(data: data)
                        if let userName = data[K.FStore.userName] as? String{
                            self.currentUser = User(id: userId, email: userEmail, userName: userName, friendList: self.friendList)
                            
                        }
                    }
                }
            }
        }
    }
    
    func setFriendList(data : Dictionary<String, Any>) {
        if let fList = data[K.FStore.friendList] as? [[String: String]] {
            for friend in fList {
                if let friendId = friend[K.FStore.id],let friendEmail = friend[K.FStore.email], let friendUsername = friend[K.FStore.userName]{
                    let newFriend = Friend(id: friendId, email: friendEmail, userName: friendUsername)
                    friendList.append(newFriend)
                    
                }
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
            if let receiverEmail = textField.text, let senderEmail = self.currentUser?.email, let senderUsername = self.currentUser?.userName, let senderId = self.currentUser?.id {
                let docRef = self.db.collection(K.FStore.users).document(receiverEmail)
                 docRef.getDocument{ (document, error) in
                 if let e = error{
                     print("There was an issue retrieving data from Firestore. \(e)")
                    
                 } else if let document = document, document.exists {
                    if let data = document.data(){
                        
                        if let receiverId = data[K.FStore.id] as? String, let receiverUsername = data[K.FStore.userName] as? String {

                            let newFriend = Friend(id: receiverId, email: receiverEmail, userName: receiverUsername)
                            self.friendList.append(newFriend)
                            self.currentUser?.friendList = self.friendList
                            
                            self.db.collection(K.FStore.users).document(self.currentUser!.email).updateData([K.FStore.friendList : FieldValue.arrayUnion(
                                [[K.FStore.id : receiverId,
                                  K.FStore.email : receiverEmail,
                                  K.FStore.userName : receiverUsername]])])
                            self.db.collection(K.FStore.users).document(receiverEmail).updateData([K.FStore.friendList : FieldValue.arrayUnion(
                                [[K.FStore.id : senderId,
                                  K.FStore.email : senderEmail,
                                  K.FStore.userName : senderUsername]])])
                            
                            //add empty message list
                            self.db.collection(K.FStore.messagesCollection).document(self.currentUser!.email).setData([receiverId : []], merge: true)
                            self.db.collection(K.FStore.messagesCollection).document(receiverEmail).setData([self.currentUser!.id : []], merge: true)
                            
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
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
}

extension FriendsListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell", for: indexPath)
        cell.textLabel?.text = friendList[indexPath.row].userName
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(friendList[indexPath.row])
        
        performSegue(withIdentifier: K.chatSegue, sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ChatViewController
        
        if let indexPath = friendListTable.indexPathForSelectedRow {
            destinationVC.receiver = friendList[indexPath.row]
            destinationVC.sender = self.currentUser
            
        }
    }
    
    
}

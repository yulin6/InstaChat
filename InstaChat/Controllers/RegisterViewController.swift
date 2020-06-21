

import UIKit
import Firebase
import RealmSwift

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var userNameTextfield: UITextField!
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    
    let db = Firestore.firestore()
    let realm = try! Realm()
    
    @IBAction func registerPressed(_ sender: UIButton) {
        if let userName = userNameTextfield.text, let email = emailTextfield.text, let password = passwordTextfield.text {
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let e = error {
                    print(e.localizedDescription)
                    let alert = UIAlertController(title: "Registration Failed", message: e.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Try Again", style: .default))
                    self.present(alert, animated: true, completion: nil)
                } else {
                    // Navigate to the ChatViewController
                    if let id = Auth.auth().currentUser?.uid {
                        self.db.collection(K.FStore.users).document(email).setData(["id": id, "userName" : userName, "friendList" : []])
                        
                        self.saveUserToRealm(user: User(id: id, email: email, userName: userName, friendList: List<Friend>()))
                        self.saveFriendToRealm(friend: Friend(id: id, email: email, userName: userName))
                        
                        self.performSegue(withIdentifier: K.registerSegue, sender: self)
                    }
                }
            }
        }
    }
    
    func saveUserToRealm(user: User) {
        do{
            try realm.write {
                realm.add(user)
            }
        } catch {
            print("Error saving user in RegisterViewController, \(error)")
        }
    }
    
        func saveFriendToRealm(friend: Friend) {
            do{
                try realm.write {
                    realm.add(friend)
                }
            } catch {
                print("Error saving friend in RegisterViewController, \(error)")
            }
            
        }
    
    
}

//
//  RegisterViewController.swift
//  Flash Chat iOS13
//
//  Created by Angela Yu on 21/10/2019.
//  Copyright © 2019 Angela Yu. All rights reserved.
//

import UIKit
import Firebase

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var userNameTextfield: UITextField!
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    
    let db = Firestore.firestore()
    
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
                        self.performSegue(withIdentifier: K.registerSegue, sender: self)
                    }
                }
            }
        }
    }
    
}

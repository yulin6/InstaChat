
import UIKit
import Firebase
import RealmSwift

class ChatViewController: UIViewController {
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextfield: UITextField!
    
    let realm = try! Realm()
    
    let db = Firestore.firestore()
    
    var receiver: Friend?
    var sender: User?
    
    var messages: [Message] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        tableView.delegate = self
        tableView.dataSource = self
        title = receiver?.userName ?? K.appName
        //        navigationItem.hidesBackButton = true
        
        tableView.register(UINib(nibName: K.cellNibName, bundle: nil), forCellReuseIdentifier: K.cellIdentifier)
        loadMessages()
    }
    
    func loadMessages() {
        if let receiver = receiver, let sender = sender {
            
            db.collection(K.FStore.messagesCollection).document(sender.email)//.collection(receiver.id)
//                            .order(by: K.FStore.dateField)
                .addSnapshotListener { (querySnapshot, error) in
                    
                    self.messages = []
                    if let e = error{
                        print("There was an issue retrieving data from Firestore. \(e)")
                    } else {
                        if let data = querySnapshot?.data() {
//                            print(data[receiver.id] as? [[String:Any]])
                            if let messageCollection = data[receiver.id] as? [[String:Any]] {
                                
                                for message in messageCollection {
                                if let messageSender = message[K.FStore.senderField] as? String, let messageReceiver = message[K.FStore.receiverField] as? String, let messageBody = message[K.FStore.bodyField] as? String {
                                    
                                    let newMessage = Message(sender: messageSender, receiver: messageReceiver, body: messageBody)
                                    self.messages.append(newMessage)
                                    
                                    DispatchQueue.main.async {
                                        
                                        //todo review course
                                        self.tableView.reloadData()
                                        let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                                        self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                                    }
                                }
                            }
                        }
                    }
                    }
            }
        }
    }
    
    @IBAction func sendPressed(_ sender: UIButton) {
        
        let date = Date().timeIntervalSince1970
        if let messageBody = messageTextfield.text, let sender = self.sender, let receiver = self.receiver{
            
            db.collection(K.FStore.messagesCollection).document(sender.email).updateData([receiver.id : FieldValue.arrayUnion(
                [[K.FStore.senderField : sender.email,
                  K.FStore.receiverField : receiver.email,
                  K.FStore.bodyField : messageBody,
                  K.FStore.dateField: date]])]){ (error) in
                    if let e = error{
                        print("There was an issue saving sender's message to firestore, \(e)")
                    } else {
                        self.db.collection(K.FStore.messagesCollection).document(receiver.email).updateData([sender.id : FieldValue.arrayUnion(
                            [[K.FStore.senderField : sender.email,
                              K.FStore.receiverField : receiver.email,
                              K.FStore.bodyField : messageBody,
                              K.FStore.dateField: date]])]){ (error) in
                                if let e = error{
                                    print("There was an issue saving receiver's message to firestore, \(e)")
                                } else {
                                    DispatchQueue.main.async {
                                        self.messageTextfield.text = ""
                                        self.tableView.reloadData()
                                    }
                                }
                                print("Successfully saved data.")
                        }
                    }
            }
        }
        
    }
}

extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath) as! MessageCell
        cell.label.text = message.body
        
        
        //message from the current user
        if message.sender == Auth.auth().currentUser?.email {
            cell.leftImageView.isHidden = true
            cell.rightImageView.isHidden = false
            cell.messageBubble.backgroundColor = UIColor(named: K.BrandColors.green1)
            cell.label.textColor = UIColor(named: K.BrandColors.green3)
        } else {
            cell.leftImageView.isHidden = false
            cell.rightImageView.isHidden = true
            cell.messageBubble.backgroundColor = UIColor(named: K.BrandColors.green2)
            cell.label.textColor = UIColor(named: K.BrandColors.green0)
        }
        
        
        return cell
    }
    
    
}

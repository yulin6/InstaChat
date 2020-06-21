

import UIKit
import CLTypingLabel
import RealmSwift

class WelcomeViewController: UIViewController {

    let defaults = UserDefaults.standard
    
    @IBOutlet weak var titleLabel: CLTypingLabel!
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        if defaults.string(forKey: "LocalUserId") != nil  {
            self.performSegue(withIdentifier: K.welcomeSegue, sender: self)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
         navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = K.appName

    }
    

}

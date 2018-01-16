//
//  MypageViewController.swift
//  chat-tutorial
//
//  Created by 加納駿 on 2018/01/08.
//  Copyright © 2018年 arupaka. All rights reserved.
//

import UIKit
import Firebase

class MypageViewController: UIViewController {

    @IBOutlet weak var ScreeName: UILabel!
    @IBOutlet weak var ScreenNameTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    var ref: DatabaseReference!
    var screenname: String = ""
    var uid: String = ""
    var email: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        errorLabel.isHidden = true
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        screenname = ScreenNameTextField.text!
        self.view.endEditing(true)
    }
    
    @IBAction func updateButton(_ sender: Any) {
        screenname = ScreenNameTextField.text!
        if screenname == "" {
            errorLabel.isHidden = false
            return
        } else {
            self.ref = Database.database().reference()
            let User = Auth.auth().currentUser
            if let user = User {
                self.uid = user.uid
                self.email = user.email!
            }
            self.ref.child("Users/\(self.uid)/").setValue(["screen_name": screenname])
            
            let alert = UIAlertController(title: screenname, message: "Name changed!", preferredStyle: UIAlertControllerStyle.alert)
            let action1 = UIAlertAction(title: "close", style: UIAlertActionStyle.default, handler: {
                (action: UIAlertAction!) in
            })
            alert.addAction(action1)
            self.present(alert, animated: true, completion: nil)
        }
    }

}

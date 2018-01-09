//
//  SignupViewController.swift
//  chat-tutorial
//
//  Created by 加納駿 on 2018/01/08.
//  Copyright © 2018年 arupaka. All rights reserved.
//

import UIKit
import Firebase

class SignupViewController: UIViewController {

    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    var ref: DatabaseReference!
    var Email: String = ""
    var Password: String = ""
    var handle: AuthStateDidChangeListenerHandle?
    var uid: String = ""
    var get_email: String = ""
    
    @IBOutlet weak var sign_up: UIButton!
    @IBOutlet weak var sign_in: UIButton!
    @IBOutlet weak var back: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sign_in.isExclusiveTouch = true
        sign_up.isExclusiveTouch = true
        back.isExclusiveTouch = true
    }
    override func viewWillAppear(_ animated: Bool) {
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        Auth.auth().removeStateDidChangeListener(handle!)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        Email = email.text!
        Password = password.text!
        self.view.endEditing(true)
    }
    
    @IBAction func Signup(_ sender: Any) {
        Email = email.text!
        Password = password.text!
        print(Email)
        print(Password)
        Auth.auth().createUser(withEmail: Email, password: Password) { (user, error) in
            if let error = error {
                print(error)
                return
            } else {
                print("登録できたよ")
                self.ref = Database.database().reference()
                let User = Auth.auth().currentUser
                if let user = User {
                    self.uid = user.uid
                    self.get_email = user.email!
                }
                self.ref.child("Users/\(self.uid)/").setValue(["screen_name": "noname", "email": self.get_email])
                let nextView = self.storyboard?.instantiateViewController(withIdentifier: "Tabbar")
                self.present(nextView!,animated: true, completion: nil)
            }
            
        }
        
        
    }
    @IBAction func Signin(_ sender: Any) {
        Email = email.text!
        Password = password.text!
        print(Email)
        print(Password)
        Auth.auth().signIn(withEmail: Email, password: Password) { (user, error) in
            if let error = error {
                print(error)
                return
            } else {
                print("ログイン成功")
                let nextView = self.storyboard?.instantiateViewController(withIdentifier: "Tabbar")
                self.present(nextView!,animated: true, completion: nil)
            }
            
        }
    }
    
}

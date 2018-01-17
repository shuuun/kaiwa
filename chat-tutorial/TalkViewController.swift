//
//  TalkViewController.swift
//  chat-tutorial
//
//  Created by 加納駿 on 2018/01/16.
//  Copyright © 2018年 arupaka. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class TalkViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var TextView: UITextView!
    @IBOutlet weak var TypeMessage: UITextField!

    let ScreenSize = UIScreen.main.bounds.size
    let app:AppDelegate =
        (UIApplication.shared.delegate as! AppDelegate)
    var ref: DatabaseReference!
    var uid: String = ""
    let owner: String = "owner"
    var screen_name: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        
        TypeMessage.delegate = self
        navigationController?.setNavigationBarHidden(false, animated: false)
        SVProgressHUD.setDefaultStyle(SVProgressHUDStyle.dark)
        SVProgressHUD.show(withStatus: "チャット相手をさがしています")
        
        getRoom()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let roomRef = ref.child("Rooms")
        TextView.isEditable = false
        roomRef.child(self.app.roomId!).removeValue()
        self.uid = (Auth.auth().currentUser?.uid)!
        let getPlace = ref.child("Users/\(self.uid)/screen_name")
        getPlace.observe(.value, with: {(DataSnapshot) in
            self.screen_name = (DataSnapshot.value! as AnyObject).description
        })
    }
    
    @IBAction func TapClose(_ sender: Any) {
        self.view.endEditing(true)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        TypeMessage.resignFirstResponder()
        return true
    }
    
    @IBAction func SendMessage(_ sender: Any) {
        let userRef = ref.child("Users")
        let roomRef = ref.child("Rooms")
        let getPlace = userRef.child("\(self.uid)/screen_name")
        getPlace.observe(.value, with: {(DataSnapshot) in
            self.screen_name = (DataSnapshot.value! as AnyObject).description
        })
        let messageData = ["from": self.screen_name, "text": TypeMessage.text!] as [String : Any]
        print(self.screen_name)
        print(messageData)
        roomRef.child(self.app.roomId!).child("message").childByAutoId().setValue(messageData)
        TypeMessage.text = ""
        self.view.endEditing(true)
    }
    
    func getRoom() {
        let userRef = ref.child("Users")
        let user = [
            "inRoom": "0",
            "waitingFlg": "0"
        ]
        userRef.child("\(self.uid)/").updateChildValues(user)
        userRef.queryOrdered(byChild: "waitingFlg").queryEqual(toValue: "1").observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            
            if value != nil {
                if value!.count >= 1 {
                    print(value!.count);
                    print("value \(value!)")
                    print("↑初回ボタン押下時に、waitingFlgが１のユーザ")
                    self.createRoom(value: value as! Dictionary<AnyHashable, Any>)
                }
            } else {
                userRef.child(self.uid).updateChildValues(["waitingFlg": "1"])
                self.checkMyWaitingFlg();
            }
        })
        
    }
    
    func checkMyWaitingFlg() {
        let userRef = ref.child("Users")
        userRef.child(self.uid).observe(DataEventType.childChanged, with: { (snapshot) in
            print(snapshot)
            let snapshotValue = snapshot.value as! String
            let snapshotKey = snapshot.key
            
            if snapshotValue == "0" && snapshotKey == "waitingFlg" {
                self.getJoinRoom()
            }
        })
    }
    
    func getJoinRoom() {
        let userRef = ref.child("Users")
//        let roomRef = ref.child("Rooms")
        userRef.child(self.uid).child("inRoom").observeSingleEvent(of: .value, with: { (snapshot) in
            let snapshotValue = snapshot.value as! String
            self.app.roomId = snapshotValue
            if self.app.roomId != "0" {
                print("roomId→ \(self.app.roomId!)")
                self.getMessages()
            }
        })
    }
    
    func getMessages() {
        let roomRef = ref.child("Rooms")
        SVProgressHUD.dismiss()
        SVProgressHUD.showSuccess(withStatus: "マッチングしました！")
        self.app.chatStartFlg = true
        print("チャットを開始します")
       
        roomRef.child(self.app.roomId!).child("message").observe(.childAdded, with: { (snapshot) -> Void in
            let from = String(describing: snapshot.childSnapshot(forPath: "from").value!)
            let text = String(describing: snapshot.childSnapshot(forPath: "text").value!)
            print(from)
            print(text)
            let result = "\(self.TextView.text!)\n\(from): \(text)"
            print(result)
            self.TextView.text = result
        })
        //                let snapshotValue = snapshot.value as! [String: AnyObject]
        //                print(snapshotValue)
        //                let from = snapshotValue["from"] as! String
        //                let text = snapshotValue["text"] as! String
        //                self.TextView.text = "\(self.TextView.text)\n \(from): \(text)"

    }
    
    func createRoom(value: Dictionary<AnyHashable, Any>) {
        for (key,val) in value {
            if key as! String != self.uid {
                print("待機中のユーザーId(key)")
                self.app.targetId = key as? String
            }
        }
        
        print("チャット開始するユーザId\(self.app.targetId!)")
        getNewRoomId()
    }
    
    var count: Int = 1
    
    func getNewRoomId() {
        Database.database().reference().child("roomKeyNum").observeSingleEvent(of: .value, with: { (snapshot) in
            if !(snapshot.value is NSNull) {
                self.count = (snapshot.value as! Int) + 1
            }
            
            Database.database().reference()
                .child("roomKeyNem")
                .child("\(self.count)")
            self.app.newRoomId = String(self.count)
            self.updateEachUserInfo()
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func updateEachUserInfo() {
        let userRef = ref.child("Users")
        self.app.roomId = self.app.newRoomId
        print (self.app.roomId!)
        print (self.app.newRoomId!)
        userRef.child(self.app.targetId!).updateChildValues(["inRoom": self.app.roomId!])
        userRef.child(self.app.targetId!).updateChildValues(["waitingFlg":"0"])
        userRef.child(self.uid).updateChildValues(["inRoom":self.app.roomId!])
        userRef.child(self.uid).updateChildValues(["waitingFlg":"0"])
        
        getMessages()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let roomRef = ref.child("Rooms")
        roomRef.child(self.app.roomId!).removeValue()
        print("ViewController/viewWillDisappear/別の画面に遷移する直前")
        
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        let userRef = ref.child("Users")
        let roomRef = ref.child("Rooms")
        super.viewDidDisappear(animated)
        print("ViewController/viewDidDisappear/別の画面に遷移した直後")
        
        userRef.child(self.uid).updateChildValues(["waitingFlg":"0"])
        //Indicatorを止める
        SVProgressHUD.dismiss()
        if(self.app.roomId != "0"){
            let endMsg = "~相手が退出したよ!!~"
            roomRef.child(self.app.roomId!).child("message").updateChildValues(["from": self.owner,
                                                                                 "text": endMsg
                ])
            self.app.roomId = "0"
        }
    }
    
}

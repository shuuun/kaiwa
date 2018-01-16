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

class TalkViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let app:AppDelegate =
        (UIApplication.shared.delegate as! AppDelegate)
    var userRef = Database.database().reference().child("Users")
    var roomRef = Database.database().reference().child("Rooms")
    var uid: String = (Auth.auth().currentUser?.uid)!

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(false, animated: false)
        SVProgressHUD.setDefaultStyle(SVProgressHUDStyle.dark)
        SVProgressHUD.show(withStatus: "チャット相手をさがしています")
        
        getRoom()
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getRoom() {
        let user = [
            "inRoom": "0",
            "waitingFlg": "0"
        ]
        
        userRef.child("\(self.uid)/").setValue(user)
        
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
                self.userRef.child(self.uid).updateChildValues(["waitingFlg": "1"])
                self.checkMyWaitingFlg();
            }
        })
        
    }
    
    func checkMyWaitingFlg() {
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
        userRef.child(self.uid).child("inRoom").observeSingleEvent(of: .value, with: { (snapshot) in
            let snapshotValue = snapshot.value as! String
            self.app.roomId = snapshotValue
            
            if self.app.roomId != "0" {
                print("roomId→ \(self.app.roomId!)")
                print("チャットを開始します")
                self.getMessages()
            }
        })
    }
    
    func getMessages() {
        var screen_name: String = ""
        SVProgressHUD.dismiss()
        SVProgressHUD.showSuccess(withStatus: "マッチングしました！")
        self.app.chatStartFlg = true
        roomRef.child(self.app.roomId!).queryLimited(toLast: 100).observe(DataEventType.childAdded, with: { (snapshot) in
            let getName = self.userRef.child("Users/\(self.uid)/screen_name")
            getName.observe(.value, with: {(DataSnapshot) in
                screen_name = (DataSnapshot.value! as AnyObject).description
            })
            let snapshotValue = snapshot.value as! NSDictionary
            let text = snapshotValue["message"] as! String
            let message = [
                "from": screen_name,
                "text": text
            ]
            self.roomRef.child(self.app.roomId!).setValue(message)
            
        })
    }
    
    func createRoom(value: Dictionary<AnyHashable, Any>) {
        for (key,value) in value {
            if key as! String != self.uid {
                print("待機中のユーザーId(key)")
                self.app.targetId = key as? String
            }
        }
        
        print("チャット開始するユーザId\(self.app.targetId!)")
//        getNewRoomId()
    }
    
    var count: Int = 1
    
    func getNewroomId() {
        Database.database().reference().child("roomKeyNum").observeSingleEvent(of: .value, with: { (snapshot) in
            if !(snapshot.value is NSNull) {
                self.count = (snapshot.value as! Int) + 1
            }
            
            Database.database().reference()
                .child("roomKeyNem")
                .child("self.count")
            self.app.newRoomId = String(self.count)
            self.updateEachUserInfo()
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func updateEachUserInfo() {
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
        print("ViewController/viewWillDisappear/別の画面に遷移する直前")
        
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("ViewController/viewDidDisappear/別の画面に遷移した直後")
        
        userRef.child(self.uid).updateChildValues(["waitingFlg":"0"])
        //Indicatorを止める
        SVProgressHUD.dismiss()
        if(self.app.roomId != "0"){
            let endMsg = "~相手が退出したよ!!~"
            self.app.roomId = "0"
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        return UITableViewCell()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

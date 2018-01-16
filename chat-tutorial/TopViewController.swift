//
//  TopViewController.swift
//  chat-tutorial
//
//  Created by 加納駿 on 2018/01/08.
//  Copyright © 2018年 arupaka. All rights reserved.
//

import UIKit
import Firebase

class TopViewController: UIViewController {
    
    @IBOutlet weak var screen_name: UILabel!
    var screenname: String = ""
    var uid: String = ""
    var ref: DatabaseReference!

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: false)
        self.uid = (Auth.auth().currentUser?.uid)!
        self.ref = Database.database().reference()
        let getPlace = ref.child("Users/\(self.uid)/screen_name")
        getPlace.observe(.value, with: {(DataSnapshot) in
            self.screen_name.text = (DataSnapshot.value! as AnyObject).description
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: false)
        self.uid = (Auth.auth().currentUser?.uid)!
        self.ref = Database.database().reference()
        let getPlace = ref.child("Users/\(self.uid)/screen_name")
        getPlace.observe(.value, with: {(DataSnapshot) in
            self.screen_name.text = (DataSnapshot.value! as AnyObject).description
        })
    }
    
    
    
    @IBAction func StartTalk(_ sender: Any) {
        let nextView = storyboard?.instantiateViewController(withIdentifier: "Talk")
        self.navigationController?.pushViewController(nextView!, animated: true)
    }


}

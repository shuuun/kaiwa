//
//  TalkViewController.swift
//  chat-tutorial
//
//  Created by 加納駿 on 2018/01/09.
//  Copyright © 2018年 arupaka. All rights reserved.
//

import UIKit
import Firebase
import JSQMessagesViewController

class TalkViewController: JSQMessagesViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    


}

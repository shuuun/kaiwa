//
//  HomeViewController.swift
//  chat-tutorial
//
//  Created by 加納駿 on 2018/01/08.
//  Copyright © 2018年 arupaka. All rights reserved.
//

import UIKit
import Firebase

class HomeViewController: UIViewController {

    @IBAction func goHome(segue: UIStoryboardSegue) {}
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func LoginButton(_ sender: Any) {
            let nextView = self.storyboard?.instantiateViewController(withIdentifier: "Signup")
            self.present(nextView!,animated: true, completion: nil)
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

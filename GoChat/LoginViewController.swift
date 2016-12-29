//
//  LoginViewController.swift
//  GoChat
//
//  Created by 鄭薇 on 2016/12/4.
//  Copyright © 2016年 LilyCheng. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class LoginViewController: UIViewController {
    
    @IBOutlet weak var Name: UITextField!
    @IBOutlet weak var InputEmail: UITextField!
    @IBOutlet weak var Password: UITextField!
    @IBOutlet weak var Enterbutton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // Set border color and width
        Enterbutton.layer.borderColor = UIColor.gray.cgColor
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        print(FIRAuth.auth()?.currentUser)
//        FIRAuth.auth()?.addStateDidChangeListener({(auth:FIRAuth, user:FIRUser?)in
//            if user !=nil{
//                print(user)
//                Helper.helper.switchToNavigationViewController()
//            }else{
//                print("Unauthorized")
//            }
//        })
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func CreateAccount(_ sender: Any) {
        let Name = self.Name.text
        let InputEmail = self.InputEmail.text
        let Password = self.Password.text
        Helper.helper.CreateAccountByEmail(NickName: Name!, Email: InputEmail!, Password: Password!)
    }
    @IBAction func NickNameButton(_ sender: Any) {
        if Name?.text != "" {
            FIRAuth.auth()?.signInAnonymously(completion: { (user, error) in
                if let err:Error = error {
                    print(err.localizedDescription)
                    return
                }
                print("Your NickName is " + self.Name.text!)
                print(FIRAuth.auth()?.currentUser?.uid)
                self.performSegue(withIdentifier: "LoginToApp", sender: nil)
            })
        }
    }
    @IBAction func EnterChatRoom(_ sender: Any) {
        let Name = self.Name.text
        let InputEmail = self.InputEmail.text
        let Password = self.Password.text
        Helper.helper.EnterChatRoomByEmail(NickName: Name!, Email: InputEmail!, Password: Password!)
        self.dismiss(animated: true, completion:nil)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        let navVc = segue.destination as! UINavigationController // 1
        let roomVc = navVc.viewControllers.first as! RoomsViewController // 2
        
        roomVc.senderDisplayName = Name?.text // 3
    }
}

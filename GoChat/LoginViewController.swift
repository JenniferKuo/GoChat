
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
import FirebaseDatabase

class LoginViewController: UIViewController {
    
    @IBOutlet weak var Name: UITextField!
    @IBOutlet weak var InputEmail: UITextField!
    @IBOutlet weak var Password: UITextField!
    @IBOutlet weak var Enterbutton: UIButton!
    
    let uuid: String =  UIDevice.current.identifierForVendor!.uuidString
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // Set border color and width
        //Enterbutton.layer.borderColor = UIColor.gray.cgColor
        print("my uuid is:\(uuid)")
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
        print("現在是誰\(FIRAuth.auth()?.currentUser?.uid)")
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func NickNameButton(_ sender: Any) {
        if Name?.text != "" {
            FIRAuth.auth()?.signInAnonymously(completion: { (user, error) in
                if let err:Error = error {
                    print(err.localizedDescription)
                    return
                }
                print("Your NickName is " + self.Name.text!)
                print((FIRAuth.auth()?.currentUser?.uid)!)
                let userName: String = self.Name.text!
                let userId:String = (FIRAuth.auth()?.currentUser?.uid)!
                
                let userRef = FIRDatabase.database().reference().child("users")

                //新增User到資料庫
                let newUser = userRef.child(self.uuid)
                let newUserData = ["NickName":userName, "id":userId]
                newUser.setValue(newUserData)
                
                self.performSegue(withIdentifier: "LoginToApp", sender: nil)
            })
        }
    }
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        let navVc = segue.destination as! UINavigationController // 1
        let roomVc = navVc.viewControllers.first as! RoomsViewController // 2
        roomVc.senderDisplayName = (Name?.text)! // 3
    }
}

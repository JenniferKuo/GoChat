//
//  RoomsViewController.swift
//  GoChat
//
//  Created by 鄭薇 on 2016/12/19.
//  Copyright © 2016年 LilyCheng. All rights reserved.
//
import Foundation
import UIKit
import Firebase

enum Section: Int {
    case createNewChannelSection = 0
    case currentChannelsSection
}


class RoomsViewController: UIViewController {
    
    // MARK: Properties
    var senderDisplayName: String?
    var newRoomTextField: UITextField?

    private var roomRefHandle: FIRDatabaseHandle?
    private var rooms: [Room] = []  //本意是在tableview上列出所有已存在房間
    
    private lazy var roomRef: FIRDatabaseReference = FIRDatabase.database().reference().child("rooms")
    
    // MARK: TextField
    @IBOutlet weak var InputRoomName: UITextField!    
    @IBOutlet weak var InputRoomNum: UITextField!
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = senderDisplayName
        observeRooms()
    }
    deinit {
        if let refHandle = roomRefHandle {
            roomRef.removeObserver(withHandle: refHandle)
        }
    }
    
    // MARK :Actions
    @IBAction func Logout(_ sender: Any) {
        print("User logged out")
        do{
            try FIRAuth.auth()?.signOut()
        }catch let error{
            print(error)
        }
        print(FIRAuth.auth()?.currentUser)
        //Create a main storyboard instance
        let storyboard = UIStoryboard(name : "Main", bundle: nil)
        
        //From main storyboard instantiate a View controller
        let LoginVC = storyboard.instantiateViewController(withIdentifier:"LoginVC")as!LoginViewController
        //Get the app delegate
        let appDelegate = UIApplication.shared.delegate as!AppDelegate
        //Set Login Conteoller as root view controller
        appDelegate.window?.rootViewController = LoginVC
    }
    
    @IBAction func NewRoom(_ sender: Any) {
        let randomRoomNum:UInt32 = arc4random_uniform(9999)         //亂數產生四位數房號
        let newRoomRef = roomRef.child(String(randomRoomNum))       //定義firebase裡的reference
        //原：let newChannelRef = channelRef.childByAutoId()
        let roomName = self.InputRoomName.text
        let roomItem = ["RoomName":roomName!, "RoomNum": randomRoomNum, "Members":senderDisplayName!] as [String : Any]
        newRoomRef.setValue(roomItem)
        
        print("room ref is: " + String(describing: newRoomRef))
        print("room name is: " + roomName!)
        print("room num is: " + String(describing: randomRoomNum))
    }

    @IBAction func EnterRoom(_ sender: Any) {
        let inputRoomNum = self.InputRoomNum.text
        
        roomRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.value is NSNull{
                print("this room doesn't exist")
            }else{
                for child in snapshot.children{
                    //let targetRoomRef = self.roomRef.child(inputRoomNum!)
                    let existRoom = (child as AnyObject).key as String
                    print(existRoom)
                    print("enter Room " + inputRoomNum!)
                    self.performSegue(withIdentifier: "ShowRoom", sender: existRoom)
                }
            }
        })
    }
    
    // MARK: Firebase related methods
    private func observeRooms() {

    }
    private func findMyRoomRef(InputRoomNum:String){
        
    }

    
    // MARK: Navigation
    override func prepare(for segue:UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let room = sender as? Room {
            let chatVc = segue.destination as! ChatViewController
            chatVc.senderDisplayName = senderDisplayName
            chatVc.room = room
            chatVc.roomRef = roomRef.child(room.roomNum)
            print(chatVc.roomRef)
        }
    }
    
}

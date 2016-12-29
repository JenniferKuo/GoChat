//
//  ChatViewController.swift
//  GoChat
//
//  Created by 鄭薇 on 2016/12/4.
//  Copyright © 2016年 LilyCheng. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import MobileCoreServices
import AVKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth
import GoogleMaps

class ChatViewController: JSQMessagesViewController {
    var messages = [JSQMessage]()
//    var roomRef: FIRDatabaseReference?
    var roomRef = FIRDatabase.database().reference().child("rooms").child("2244")

    private lazy var messageRef: FIRDatabaseReference = FIRDatabase.database().reference().child("rooms").child("2244").child("message")
//    private lazy var messageRef: FIRDatabaseReference = self.roomRef!.child("薇的訊息")
    
    var room: Room? {
        didSet {
            title = room?.roomName
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // No avatars
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        
        if let currentUser = FIRAuth.auth()?.currentUser{
            self.senderId = currentUser.uid
            if currentUser.isAnonymous == true
            {
                self.senderDisplayName = "anonymous"
            }else{
                //self.senderId = FIRAuth.auth()?.currentUser?.uid
                //self.senderDisplayName = currentUser.senderDiaplayName
            }
        }
        observeMessages()
    }
    func observeUsers(id: String){
        FIRDatabase.database().reference().child("users").child(id).observe(.value, with:{
            snapshot in
            if let dict = snapshot.value as? [String:AnyObject]
            {
                
                print(dict)
                //let NickName = dict["NickName"]as! String
                self.setUpNickName()
            }
        }
        )
    }
    func setUpNickName(){
        
    }
    func observeMessages() {
        messageRef.observe(FIRDataEventType.childAdded){(snapshot: FIRDataSnapshot) in
            if let dict = snapshot.value as?[String: AnyObject]{
                let mediaType = dict["MediaType"] as!String
                let senderId = dict["senderId"] as!String
                let senderName = dict["senderName"] as!String

                self.observeUsers(id: senderId)
                
                switch mediaType{
                case "TEXT":
                    let text = dict["text"]as!String
                    self.messages.append(JSQMessage(senderId: senderId, displayName: senderName, text: text))
                case "PHOTO":
                    let fileUrl = dict["fileURL"]as!String
                    let url = NSURL(string:fileUrl)
                    let data = NSData(contentsOf:url! as URL)
                    let picture = UIImage(data:data! as Data)
                    let photo = JSQPhotoMediaItem(image:picture)
                    self.messages.append(JSQMessage(senderId: senderId, displayName: senderName, media: photo))
                    if self.senderId == senderId{
                        photo?.appliesMediaViewMaskAsOutgoing = true
                    }else{
                        photo?.appliesMediaViewMaskAsOutgoing = false
                    }
                case "VIDEO":
                    let fileUrl = dict["fileURL"]as!String
                    let video = NSURL(string: fileUrl)
                    let videoItem = JSQVideoMediaItem(fileURL: video as URL!, isReadyToPlay: true)
                    self.messages.append(JSQMessage(senderId: senderId, displayName: senderName, media: videoItem ))
                    if self.senderId == senderId{
                        videoItem?.appliesMediaViewMaskAsOutgoing = true
                    }else{
                        videoItem?.appliesMediaViewMaskAsOutgoing = false
                    }
                default:
                    print("unknown data type")
                }
                self.collectionView.reloadData()
                self.scrollToBottom(animated: true)
            }
        }
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        print("已點傳送按鈕")
        //print("\(text)")
        //print(senderId)
        //print(senderDisplayName)
        
        //messages.append(JSQMessage(senderId: senderId, displayName: senderDisplayName, text: text))
        //collectionView.reloadData()
        //print(messages)
        
        let newMessage = messageRef.childByAutoId()
        let messageData = ["text":text, "senderId":senderId, "senderName":senderDisplayName, "MediaType":"TEXT"]
        newMessage.setValue(messageData)
        self.finishSendingMessage()
        //isTyping = false
    }
    
    override func didPressAccessoryButton(_ sender: UIButton!) {
        print("已點附件按鈕")
        //pick a photo
        //let imagePicker = UIImagePickerController()
        //imagePicker.delegate = self
        //self.present(imagePicker, animated: true, completion: nil)
        
        //pick a photo or video
        let sheet = UIAlertController(title:"媒體訊息", message:"請選擇一個媒體", preferredStyle: UIAlertControllerStyle.actionSheet)
        let cancel = UIAlertAction(title:"Cancel", style:UIAlertActionStyle.cancel){(alert:UIAlertAction)in
        }
        let photoLibrary = UIAlertAction(title:"照片相簿", style:UIAlertActionStyle.default){(alert:UIAlertAction)in
            self.getMediaFrom(type: kUTTypeImage)
        }
        let videoLibrary = UIAlertAction(title:"影片相簿", style:UIAlertActionStyle.default){(alert:UIAlertAction)in
            self.getMediaFrom(type: kUTTypeMovie)
        }
        sheet.addAction(photoLibrary)
        sheet.addAction(videoLibrary)
        sheet.addAction(cancel)
        self.present(sheet, animated:true, completion:nil)
    }
    
    func getMediaFrom(type: CFString){
        print(type)
        let mediaPicker = UIImagePickerController()
        mediaPicker.delegate = self
        mediaPicker.mediaTypes = [type as String]
        self.present(mediaPicker, animated:true, completion:nil)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item]
        let bubbleFactory = JSQMessagesBubbleImageFactory()
        if message.senderId == self.senderId{
            return bubbleFactory?.outgoingMessagesBubbleImage(with: UIColor(red:0.72, green:0.71, blue:0.71, alpha:1.0))
        }else{
            return bubbleFactory?.incomingMessagesBubbleImage(with: UIColor(red:0.72, green:0.71, blue:0.71, alpha:1.0))
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
  
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print ("訊息有幾則:\(messages.count)")
        return messages.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath)as! JSQMessagesCollectionViewCell
        return cell
    }

    //video message的對話泡泡
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAt indexPath: IndexPath!) {
        print("didTapMessageBubbleAt indexPath:\(indexPath.item)")
        let message = messages[indexPath.item]
        if message.isMediaMessage{
            if let mediaItem = message.media as? JSQVideoMediaItem{
                let player = AVPlayer(url: mediaItem.fileURL)
                let playerViewController = AVPlayerViewController()
                playerViewController.player = player
                self.present(playerViewController, animated: true, completion: nil)
            }
        }
    }
    override func collectionView(_ collectionView: JSQMessagesCollectionView?, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString? {
        let message = messages[indexPath.item]
        switch message.senderId {
        case senderId:
            return nil
        default:
            guard let senderDisplayName = message.senderDisplayName else {
                assertionFailure()
                return nil
            }
            return NSAttributedString(string: senderDisplayName)
        }
    }
        override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logoutDidTapped(_ sender: Any) {
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
    /*
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func sendMedia(picture:UIImage?, video:NSURL?){
        print (picture!)
        print(FIRStorage.storage().reference())
        if let picture = picture{
            let filePath = "\(FIRAuth.auth()!.currentUser!.uid)/\(NSDate.timeIntervalSinceReferenceDate)"
            print(filePath)
            let data = UIImageJPEGRepresentation(picture, 1)//1,0是否壓縮
            let metadata = FIRStorageMetadata()
            metadata.contentType = "image/jpg"
            FIRStorage.storage().reference().child(filePath).put(data!, metadata: metadata){(metadata, error)
                in
                if error != nil{
                    print("there's an error")
                    //print(error.localizedDescription)
                    return
                }
                print(metadata!)
                let fileURL = metadata!.downloadURLs![0].absoluteString
                
                let newMessage = self.messageRef.childByAutoId()
                let messageData = ["fileURL":fileURL, "senderId":self.senderId, "senderName":self.senderDisplayName, "MediaType":"PHOTO"]
                newMessage.setValue(messageData)
            }
        }else if let video = video{
            let filePath = "\(FIRAuth.auth()!.currentUser!.uid)/\(NSDate.timeIntervalSinceReferenceDate)"
            print(filePath)
            let data = NSData(contentsOf:video as URL)
            let metadata = FIRStorageMetadata()
            metadata.contentType = "video/mp4"
            FIRStorage.storage().reference().child(filePath).put(data! as Data, metadata: metadata){(metadata, error)
                in
                if error != nil{
                    print("there's an error")
                    //print(error.localizedDescription)
                    return
                }
                let fileURL = metadata!.downloadURLs![0].absoluteString
                
                let newMessage = self.messageRef.childByAutoId()
                let messageData = ["fileURL":fileURL, "senderId":self.senderId, "senderName":self.senderDisplayName, "MediaType":"VIDEO"]
                newMessage.setValue(messageData)
            }
        }
        
    }
    //indicate an user is typing
//    override func textViewDidChange(_ textView: UITextView) {
//        super.textViewDidChange(textView)
//        // If the text is not empty, the user is typing
//        isTyping = textView.text != ""
//    }
//    private lazy var userIsTypingRef: FIRDatabaseReference =
//        self.channelRef!.child("typingIndicator").child(self.senderId) // 1
//    private var localTyping = false // 2
//    var isTyping: Bool {
//        get {
//            return localTyping
//        }
//        set {
//            // 3
//            localTyping = newValue
//            userIsTypingRef.setValue(newValue)
//        }
//    }
//    private func observeTyping() {
//        let typingIndicatorRef = channelRef!.child("typingIndicator")
//        userIsTypingRef = typingIndicatorRef.child(senderId)
//        userIsTypingRef.onDisconnectRemoveValue()
//        // 1
//        usersTypingQuery.observe(.value) { (data: FIRDataSnapshot) in
//            // 2 You're the only one typing, don't show the indicator
//            if data.childrenCount == 1 && self.isTyping {
//                return
//            }
//            
//            // 3 Are there others typing?
//            self.showTypingIndicator = data.childrenCount > 0
//            self.scrollToBottom(animated: true)
//        }
//    }
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        observeTyping()
//    }
//    private lazy var usersTypingQuery: FIRDatabaseQuery =
//        self.channelRef!.child("typingIndicator").queryOrderedByValue().queryEqual(toValue: true)
}


extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    private func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        print("完成選擇媒體")
        //get the image info 可能之後有GPS資訊
        print(info)
        if let picture = info[UIImagePickerControllerOriginalImage] as? UIImage{
//            let photo = JSQPhotoMediaItem(image: picture)
//            messages.append(JSQMessage(senderId: senderId, displayName: senderDisplayName, media: photo))
            sendMedia(picture:picture, video:nil)
        }
        if let video = info[UIImagePickerControllerMediaURL]as? NSURL{
//            let videoItem = JSQVideoMediaItem(fileURL: video as URL!, isReadyToPlay: true)
//            messages.append(JSQMessage(senderId:senderId, displayName: senderDisplayName, media:videoItem))
            sendMedia(picture: nil, video:video)
        }
        self.dismiss(animated: true, completion: nil)
        collectionView.reloadData()
    }
}

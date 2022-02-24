//
//  ChatViewController.swift
//  ChatAppPractice
//
//  Created by Apple New on 2022-02-11.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import SDWebImage
import AVKit
import AVFoundation
import CoreLocation

class ChatViewController: MessagesViewController {

    private var senderPhotoURL: URL?
    private var otherUserPhotoURL: URL?
    
    //========= Elements ===============
    public static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .long
        formatter.locale = .current
        return formatter
    }()
    
    public var isNewConversation = false
    public let otherUserEmail: String
    private var conversationID : String?
    
    private var messages = [Message]()
//    var data = MessageDataProvider.dataProvider() //will be deleted later
    private var selfSender : Sender? {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            print("Email Error")
            return nil
        }
        
        let safeEmail = DatabaseManager.safeEmail(email: email)
        return Sender(photpURL: "", senderId: safeEmail, displayName: "")
    }
    
    
    init(with email: String, id: String?){
        self.conversationID = id
        self.otherUserEmail  = email
        super.init(nibName: nil, bundle: nil)
       
    }
    
    required init(coder: NSCoder){
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //=============== Views =================
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        messageInputBar.delegate = self
        
        setupInputButton()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messageInputBar.inputTextView.becomeFirstResponder()
        if let conversationID = conversationID {
            listenForMessages(id: conversationID, shouldScrollToButtom: true)
        }
    }
    // ================= Functions =============
    private func listenForMessages(id: String, shouldScrollToButtom: Bool){
        DatabaseManager.shared.getAllMessagesForConversation(with: id) { [weak self] result in
            switch result {
            case .success(let messages):
                guard !messages.isEmpty else { return }
                self?.messages = messages
                DispatchQueue.main.async {
                    self?.messagesCollectionView.reloadDataAndKeepOffset()
                    if shouldScrollToButtom{
                        self?.messagesCollectionView.reloadData()
                    }else{
                        self?.messagesCollectionView.scrollToBottom()
                    }
                    
                }
                
            case .failure(let error):
                print("failed to get messages: \(error)")
            }
        }
    }
    
    private func setupInputButton(){
        let button = InputBarButtonItem()
        button.setSize(CGSize(width:35, height: 35), animated: false)
        button.setImage(UIImage(systemName: "paperclip"), for: .normal)
        button.onTouchUpInside { [weak self] _  in
            self?.presentInputActionSheet()
        }
            messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
            messageInputBar.setStackViewItems([button], forStack: .left, animated: false)
        
    }
    
    
    
    
    private func presentInputActionSheet(){
        let actionSheet = UIAlertController(title: "Attach Media", message: "What would you to attach?", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Photo", style: .default, handler: { [weak self] _ in
            self?.presentPhotoInputActionSheet()
        }))
        actionSheet.addAction(UIAlertAction(title: "Video", style: .default, handler: { [weak self]  _ in
            self?.presentVideoInputActionSheet()
        }))
        actionSheet.addAction(UIAlertAction(title: "Audio", style: .default, handler: { _ in
            
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Location", style: .default, handler: {[weak self] _ in
            self?.presentLocationPicker()
        }))
//
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(actionSheet, animated: true)
    }
    


    
    
    private func presentLocationPicker(){
        let vc = LocationPickerViewController(coordinates: nil)
        vc.title = "Pick Location "
        vc.navigationItem.largeTitleDisplayMode = .never
        vc .completion = { [weak self] selectedCoordinates in
            guard let strongSelf = self else{ return }
            guard
                let messageID = strongSelf.createMessageId(),
                let conversationID = strongSelf.conversationID,
                let name = strongSelf.title,
                let selfSnder = strongSelf.selfSender
            else{ return }

            
            let longtitude: Double = selectedCoordinates.longitude
            let latitude: Double = selectedCoordinates.latitude
            print("Long: \(longtitude),   Lat: \(latitude)")
            
            let location = Location(location: CLLocation(latitude: latitude, longitude: longtitude), size: .zero)
            let message = Message(sender: selfSnder, messageId: messageID, sentDate: Date(), kind: .location(location))
//
        DatabaseManager.shared.sendMessage(to: conversationID, otherUserEmail: conversationID, name: name, newMessage: message) { success in
                if success {
                    print("sent location message")
                }else{
                    print("failed to sand a location messge")
                }
            }
    
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func presentPhotoInputActionSheet(){
        let actionSheet = UIAlertController(title: "Attach Photo", message: "Where would you to attach a photo from?", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { [weak self] _ in
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.delegate = self
            picker.allowsEditing = true
            self?.present(picker, animated: true)
        }))
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { [weak self] _ in
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            picker.allowsEditing = true
            self?.present(picker, animated: true)
        }))
  
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(actionSheet, animated: true)
    }
    
    private func presentVideoInputActionSheet(){
        let actionSheet = UIAlertController(title: "Attach Photo", message: "Where would you to attach a photo from?", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { [weak self] _ in
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.delegate = self
            picker.mediaTypes = ["public.movie"]
            picker.videoQuality = .typeMedium
            picker.allowsEditing = true
            self?.present(picker, animated: true)
        }))
        actionSheet.addAction(UIAlertAction(title: "Library", style: .default, handler: { [weak self] _ in
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            picker.mediaTypes = ["public.movie"]
            picker.videoQuality = .typeMedium
            picker.allowsEditing = true
            self?.present(picker, animated: true)
        }))
  
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(actionSheet, animated: true)
    }
    
}

extension  ChatViewController : InputBarAccessoryViewDelegate{
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty,
            let selfSender = self.selfSender,
                let messageId = createMessageId() else
        {
            print("====error: textField is empty====")
            return
        }
        
        print("Sending: \(text)")
        let message = Message(sender: selfSender, messageId: messageId, sentDate: Date(), kind: .text(text))
        print("isNewConversation==============")
        if isNewConversation{
            print("\(isNewConversation): isNewConversation")
            DatabaseManager.shared.createNewConversation(with: otherUserEmail, name: self.title ?? "User", firstMessage: message) { [weak self] success in
               print("isNewConversation")
                if success {
                    print("New Conversation:  message is sent successfully")
                    self?.isNewConversation = false
                    
                    let newConverationId = "conversation_\(message.messageId)"
                    self?.conversationID = newConverationId
                    self?.listenForMessages(id: newConverationId, shouldScrollToButtom: true)
                    self?.messageInputBar.inputTextView.text = nil
                } else{
                    print("New Conversation: failed to send a message")
                }
            }
        }else{
            guard let conversationID = conversationID,
                    let name = self.title else { return }
            DatabaseManager.shared.sendMessage(to: conversationID,otherUserEmail: otherUserEmail, name: name ,newMessage: message) { [weak self] success in

                print("!isNewConversation")
                if success {
                    self?.messageInputBar.inputTextView.text = nil
                    print("Conversation continued fro the latest message:    message sent")
                } else{
                    print("Conversation continued fro the latest message:    failed to send")
                }
            }
        }
        print("print1")
    }
    
    private func createMessageId() -> String? {
        
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            print("let dateString = Self.dateFormatter.string(from: Date()) is nil")
            return "emai is nil"
            
        }
        print("GOOD")
        let safeCurrenEmail = DatabaseManager.safeEmail(email: currentUserEmail)
        let dateString = DateFormatters.dateFormattersChatView(date: Date())
        let newIdentifier = "\(otherUserEmail)_\(safeCurrenEmail)_\(dateString)"
        print("created message id: \(newIdentifier)")
        return newIdentifier
    }
}

extension ChatViewController : MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate{
    func currentSender() -> SenderType {
        
        if let sender = selfSender {
            return sender
        }
        fatalError("SelfSender is nil, email should be cashed")
//        return Sender(photpURL: "", senderId: "-1", displayName: "")
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
//        return data[indexPath.section]
        return messages[indexPath.section]// will be replaced with data[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
       // return message.count
        return messages.count // will be replaced with message.count
    }
    
    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        guard let message = message as? Message else { return }
        
        switch message.kind {
        case .photo(let media):
            guard let imageUrl = media.url else { return }
            imageView.sd_setImage(with: imageUrl, completed: nil)
        default:
            break
        }
    }
    
//     func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let message = messages[indexPath.section]
//
//        switch message.kind {
//        case .photo(let media):
//            guard let imageUrl = media.url else { return }
//            let vc = PhotoViewrViewController(with: imageUrl)
//            self.navigationController?.pushViewController(vc, animated: true)
//        default:
//            break
//        }
//
    
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        let sender = message.sender
        if sender.senderId == selfSender?.senderId{
            return . link
        }
        return .secondarySystemBackground
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        
        let sender = message.sender
        if sender.senderId == selfSender?.senderId{
            if let currentUserImageURL = senderPhotoURL{
                avatarView.sd_setImage(with: currentUserImageURL, completed: nil)
            }else{
                guard let email = UserDefaults.standard.value(forKey: "email") as? String else { return }
                let safeEmail = DatabaseManager.safeEmail(email: email)
                let path = "images/\(safeEmail)_profile_picture.png"
                StorageManager.shared.downloadURL(for: path) {[weak self] result in
                    switch result{
                        case .success(let url):
                        self?.senderPhotoURL = url
                        DispatchQueue.main.async {
                            avatarView.sd_setImage(with: url, completed: nil)
                        }
                        case .failure(let error):
                            print("error: \(error)")
                    }
                }
            }
        }else{
            if sender.senderId == selfSender?.senderId{
                if let currentUserImageURL = self.senderPhotoURL{
                            avatarView.sd_setImage(with: currentUserImageURL, completed: nil)
                }
                else{
                    let email = self.otherUserEmail
                    let safeEmail = DatabaseManager.safeEmail(email: email)
                    let path = "images/\(safeEmail)_profile_picture.png"
                    StorageManager.shared.downloadURL(for: path) {[weak self] result in
                        switch result{
                            case .success(let url):
                            self?.otherUserPhotoURL = url
                            DispatchQueue.main.async {
                                avatarView.sd_setImage(with: url, completed: nil)
                            }
                            case .failure(let error):
                                print("error: \(error)")
                        }
                    }
                }
            }
        }
    }
}


extension ChatViewController: MessageCellDelegate {
    func didTapImage(in cell: MessageCollectionViewCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else { return }
            
        let message = messages[indexPath.section]

        switch message.kind {
//        case .photo(let media):
//            guard let imageUrl = media.url else { return }
//            let vc = PhotoViewrViewController(with: imageUrl)
//            self.navigationController?.pushViewController(vc, animated: true)
        case .location(let locationData):
            let coordinates = locationData.location.coordinate
            let vc = LocationPickerViewController(coordinates: coordinates)
            vc.title = "Location''"
            self.navigationController?.pushViewController(vc, animated: true)
//        case .video(let media):
//        case .video(let media):
//            guard let videoUrl = media.url else { return }
//            let vc = AVPlayerViewController()
//            vc.player = AVPlayer(url: videoUrl)
//            present(vc, animated: true)
        default:
            break
        }
        
        
    }
}

extension ChatViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard
            let messageID = createMessageId(),
            let conversationID = conversationID,
            let name = self.title,
            let selfSnder = selfSender
        else{
            return
        }
        
        if let image = info[.editedImage] as? UIImage,
           let imageData = image.pngData(){
                let fileName = "photo_message_" + messageID.replacingOccurrences(of: " ", with: "-") + ".png"
                StorageManager.shared.uploadMessagePhoto(with: imageData, fileName: fileName) { [weak self] result  in
                    guard let strongSelf = self else { return }
                    switch result {
                        case .success(let urlString):
                            print("UPload Message Photo: \(urlString)")
                            guard let url = URL(string: urlString),
                                  let placeholder = UIImage(systemName: "plus") else{ return }
                            let media = Media(url: url, image: nil, placeholderImage: placeholder, size: .zero)
                            let message = Message(sender: selfSnder, messageId: messageID, sentDate: Date(), kind: .photo(media))
        //
                        DatabaseManager.shared.sendMessage(to: conversationID, otherUserEmail: conversationID, name: name, newMessage: message) { success in
                            if success {
                                print("sent photo message")
                            }else{
                                print("failed to sand a photo messge")
                            }
                        }
        //
                        case .failure(let error):
                            print("message photo upload error: \(error)")
                    }
                }
        }else if let videoUrl = info[.mediaURL] as? URL{
            let fileName = "photo_message_" + messageID.replacingOccurrences(of: " ", with: "-") + ".mov"
          
            StorageManager.shared.uploadMessageVideo(with: videoUrl, fileName: fileName) { [weak self] result  in
                guard let strongSelf = self else { return }
                switch result {
                    case .success(let urlString):
                        print("UPload Message Video: \(urlString)")
                        guard let url = URL(string: urlString),
                              let placeholder = UIImage(systemName: "plus") else{ return }
                        let media = Media(url: url, image: nil, placeholderImage: placeholder, size: .zero)
                        let message = Message(sender: selfSnder, messageId: messageID, sentDate: Date(), kind: .video(media))
    //
                        DatabaseManager.shared.sendMessage(to: conversationID, otherUserEmail: conversationID, name: name, newMessage: message) { success in
                            if success {
                                print("sent video message")
                            }else{
                                print("failed to sand a video messge")
                            }
                        }
                    case .failure(let error):
                        print("message photo upload error: \(error)")
                }
            }

        }
    }
}

//extension ChatViewController : UINavigationControllerDelegate{
//
//}

//will be deleted later
//class MessageDataProvider{
//    static func dataProvider() -> [Message]{
//        var array = [Message]()
//        array.append(Message(sender: ChatViewController.selfSender, messageId: "1", sentDate: Date(), kind: .text("Hello")))
//        array.append(Message(sender: ChatViewController.selfSender, messageId: "1", sentDate: Date(), kind: .text("hey")))
//        return array
//    }
//}


struct Media : MediaItem {
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
}

struct Location: LocationItem {
    var location: CLLocation
    var size: CGSize
}

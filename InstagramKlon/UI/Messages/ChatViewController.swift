//
//  ChatViewController.swift
//  InstagramKlon
//
//  Created by Bertan Taşman on 30.05.2025.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import SDWebImage

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var chatNickname: UILabel!
    @IBOutlet weak var chatProfilePhoto: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!

    var messages: [Message] = []
    var chatID: String = ""
    var receiverID: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        guard !chatID.isEmpty, !receiverID.isEmpty else {
            print("[HATA] chatID veya receiverID eksik.")
            return
        }

        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none

        messageTextField.delegate = self

        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)

        loadReceiverInfo()
        listenForMessages()
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func loadReceiverInfo() {
        let db = Firestore.firestore()
        db.collection("users").document(receiverID).getDocument { snapshot, error in
            guard let data = snapshot?.data(), error == nil else {
                print("Kullanıcı bilgileri alınamadı: \(error?.localizedDescription ?? "Bilinmeyen hata")")
                return
            }

            let nickname = data["nickname"] as? String ?? "Bilinmeyen"
            let profileURL = data["profileImageURL"] as? String ?? ""

            DispatchQueue.main.async {
                self.chatNickname.text = nickname
                if let url = URL(string: profileURL) {
                    self.chatProfilePhoto.sd_setImage(with: url, placeholderImage: UIImage(systemName: "person.circle"))
                } else {
                    self.chatProfilePhoto.image = UIImage(systemName: "person.circle")
                }
                self.chatProfilePhoto.layer.cornerRadius = self.chatProfilePhoto.frame.size.width / 2
                self.chatProfilePhoto.clipsToBounds = true
            }
        }
    }

    func listenForMessages() {
        let db = Firestore.firestore()
        db.collection("chats").document(chatID).collection("messages")
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Mesajlar alınamadı: \(error.localizedDescription)")
                    return
                }

                guard let documents = snapshot?.documents else { return }
                self.messages = documents.compactMap { Message(document: $0.data()) }

                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.scrollToBottom()
                }
            }
    }

    func scrollToBottom() {
        guard messages.count > 0 else { return }
        let indexPath = IndexPath(row: messages.count - 1, section: 0)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }

    @IBAction func sendButtonTapped(_ sender: UIButton) {
        guard let text = messageTextField.text, !text.isEmpty,
              let senderID = Auth.auth().currentUser?.uid else {
            print("[HATA] Metin boş veya kullanıcı oturum açmamış")
            return
        }

        print("[DEBUG] Gönderilecek mesaj: \(text)")

        let db = Firestore.firestore()

        let messageData: [String: Any] = [
            "senderID": senderID,
            "receiverID": receiverID,
            "text": text,
            "timestamp": Timestamp()
        ]
        
        db.collection("chats").document(chatID).collection("messages").addDocument(data: messageData) { error in
            if let error = error {
                print("[HATA] Mesaj gönderilemedi: \(error.localizedDescription)")
            } else {
                print("[DEBUG] Mesaj başarıyla gönderildi.")
            }
        }
        
        db.collection("chats").document(chatID).setData([
            "lastMessage": text,
            "timestamp": Timestamp(),
            "participants": [senderID, receiverID]
        ], merge: true)

        messageTextField.text = ""
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        let currentUserID = Auth.auth().currentUser?.uid

        if message.senderID == currentUserID {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RightBubbleCell", for: indexPath)
            cell.textLabel?.text = message.text
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "LeftBubbleCell", for: indexPath)
            cell.textLabel?.text = message.text
            return cell
        }
    }
}

//
//  messagesList.swift
//  InstagramKlon
//
//  Created by Bertan Taşman on 28.05.2025.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import SDWebImage

class messagesList: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var newChatButton: UIButton!

    var chats: [Chat] = []
    var selectedChatID: String?
    var selectedReceiverID: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        fetchChats()
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
    }

    private func fetchChats() {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }

        Firestore.firestore().collection("chats")
            .whereField("participants", arrayContains: currentUserID)
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                if let error = error {
                    print("Chatler alınamadı: \(error.localizedDescription)")
                    return
                }

                guard let documents = snapshot?.documents else {
                    print("Boş geldi")
                    return
                }

                self.chats.removeAll()

                for doc in documents {
                    let data = doc.data()
                    let id = doc.documentID

                    if let chat = Chat(document: data, id: id) {
                        self.chats.append(chat)
                    }
                }

                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
    }

    @IBAction func newChatButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let newChatVC = storyboard.instantiateViewController(withIdentifier: "newChatViewController")
        self.navigationController?.pushViewController(newChatVC, animated: true)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chats.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let chat = chats[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "messageListCell", for: indexPath) as! messageListCell

        cell.listLastMessage.text = chat.lastMessage
        cell.listNickname.text = "Yükleniyor..."
        cell.listPhoto.image = UIImage(named: "defaultProfile")

        guard let currentUserID = Auth.auth().currentUser?.uid else { return cell }

        if let otherUserID = chat.participants.first(where: { $0 != currentUserID }) {
            Firestore.firestore().collection("users").document(otherUserID).getDocument { snapshot, error in
                if let data = snapshot?.data() {
                    let nickname = data["nickname"] as? String ?? "Bilinmeyen"
                    let profileURL = data["profileImageURL"] as? String ?? ""

                    DispatchQueue.main.async {
                        cell.listNickname.text = nickname
                        if let url = URL(string: profileURL) {
                            cell.listPhoto.sd_setImage(with: url, placeholderImage: UIImage(named: "defaultProfile"))
                        }
                    }
                }
            }
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let chat = chats[indexPath.row]
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }

        if let otherUserID = chat.participants.first(where: { $0 != currentUserID }) {
            selectedChatID = chat.id
            selectedReceiverID = otherUserID
            performSegue(withIdentifier: "goToChatVC", sender: nil)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToChatVC",
           let destination = segue.destination as? ChatViewController {
            destination.chatID = selectedChatID ?? ""
            destination.receiverID = selectedReceiverID ?? ""
        }
    }
}

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
    var chats: [Chat] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        fetchChats()
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
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
                
                guard let documents = snapshot?.documents else { return }
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

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chats.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let chat = chats[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "messageListCell", for: indexPath) as! messageListCell
        
        cell.listLastMessage.text = chat.lastMessage
        
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            cell.listNickname.text = "Bilinmeyen"
            cell.listPhoto.image = UIImage(named: "defaultProfile")
            return cell
        }
        
        // Diğer katılımcı UID'sini bul
        if let otherUserID = chat.participants.first(where: { $0 != currentUserID }) {
            Firestore.firestore().collection("users").document(otherUserID).getDocument { snapshot, error in
                if let data = snapshot?.data() {
                    let nickname = data["nickname"] as? String ?? "Bilinmeyen"
                    let profileURL = data["profileImageURL"] as? String ?? ""

                    DispatchQueue.main.async {
                        cell.listNickname.text = nickname
                        if let url = URL(string: profileURL) {
                            cell.listPhoto.sd_setImage(with: url, placeholderImage: UIImage(named: "defaultProfile"))
                        } else {
                            cell.listPhoto.image = UIImage(named: "defaultProfile")
                        }
                    }
                }
            }
        }
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Burada chat detay ekranına geçiş yapılabilir
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

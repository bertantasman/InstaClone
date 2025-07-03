//
//  newChat.swift
//  InstagramKlon
//
//  Created by Bertan Taşman on 29.05.2025.
//

import UIKit
import FirebaseFirestore
import SDWebImage
import FirebaseAuth

class newChat: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    var allUsers: [[String: Any]] = []
    var filteredUsers: [[String: Any]] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self

        searchBar.placeholder = "Kullanıcı ara"
        fetchUsers()
    }

    func fetchUsers() {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }

        let db = Firestore.firestore()
        db.collection("users").getDocuments { snapshot, error in
            if let error = error {
                print("Kullanıcılar alınamadı: \(error.localizedDescription)")
                return
            }

            guard let documents = snapshot?.documents else { return }
            self.allUsers.removeAll()

            for doc in documents {
                var data = doc.data()
                data["uid"] = doc.documentID
                if doc.documentID != currentUserID, let _ = data["nickname"] as? String {
                    self.allUsers.append(data)
                }
            }

            DispatchQueue.main.async {
                self.filteredUsers = self.allUsers
                self.tableView.reloadData()
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredUsers.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let user = filteredUsers[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "userListCell", for: indexPath) as! userListCell
        cell.nickname.text = user["nickname"] as? String ?? "Bilinmeyen"
        if let profileURLString = user["profileImageURL"] as? String, let url = URL(string: profileURLString) {
            cell.profilePhoto.sd_setImage(with: url, placeholderImage: UIImage(named: "defaultProfile"))
        } else {
            cell.profilePhoto.image = UIImage(named: "defaultProfile")
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedUser = filteredUsers[indexPath.row]
        performSegue(withIdentifier: "goToChat", sender: selectedUser)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToChat",
           let destinationVC = segue.destination as? ChatViewController,
           let selectedUser = sender as? [String: Any],
           let receiverID = selectedUser["uid"] as? String {

            guard let currentUserID = Auth.auth().currentUser?.uid else { return }
            let chatID = [currentUserID, receiverID].sorted().joined(separator: "_")

            destinationVC.chatID = chatID
            destinationVC.receiverID = receiverID
        }
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredUsers = allUsers
        } else {
            filteredUsers = allUsers.filter { user in
                if let nickname = user["nickname"] as? String {
                    return nickname.lowercased().contains(searchText.lowercased())
                }
                return false
            }
        }
        tableView.reloadData()
    }
}

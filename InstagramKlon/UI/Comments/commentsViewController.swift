//
//  commentsViewController.swift
//  InstagramKlon
//
//  Created by Bertan Taşman on 13.05.2025.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import SDWebImage

class commentsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!

    var comments: [Comment] = []
    var postID: String?
    var listener: ListenerRegistration?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
        setupKeyboardDismiss()
        fetchComments()
        
        view.addSubview(emptyLabel)
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            emptyLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "Henüz yorum yok..."
        label.textColor = .lightGray
        label.font = UIFont.italicSystemFont(ofSize: 15)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()
    
    

    deinit {
        listener?.remove()
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
    }

    private func setupKeyboardDismiss() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tableView.addGestureRecognizer(tapGesture)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    private func fetchComments() {
        guard let postID = postID else { return }

        listener = Firestore.firestore()
            .collection("comments")
            .whereField("postID", isEqualTo: postID)
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }

                if let error = error {
                    print("Yorumlar alınamadı: \(error.localizedDescription)")
                    return
                }

                guard let snapshot = snapshot else { return }
                print("Firestore snapshot change detected with \(snapshot.documentChanges.count) changes.")

                var updatedComments: [Comment] = []

                for document in snapshot.documents {
                    if let comment = Comment(document: document.data()) {
                        updatedComments.append(comment)
                    }
                }

                DispatchQueue.main.async {
                    print("Loaded \(updatedComments.count) comments.")
                    self.comments = updatedComments
                    self.emptyLabel.isHidden = !self.comments.isEmpty
                    self.tableView.reloadData()
                }
            }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let comment = comments[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "commentCellID", for: indexPath) as! commentCell

        cell.usernameLabel.text = "\(comment.username):"
        cell.commentTextLabel.text = comment.commentText
        cell.timestampLabel.text = comment.timestampString
        cell.profileImageView.sd_setImage(with: URL(string: comment.profileImageURL), placeholderImage: UIImage(named: "defaultProfile"))

        return cell
    }

    @IBAction func sendButtonTapped(_ sender: UIButton) {
        guard let commentText = commentTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !commentText.isEmpty,
              let uid = Auth.auth().currentUser?.uid,
              let postID = postID else {
            showAlert(message: "Yorum boş olamaz.")
            return
        }

        let db = Firestore.firestore()
        let commentID = UUID().uuidString

        db.collection("users").document(uid).getDocument { [weak self] snapshot, error in
            guard let self = self else { return }

            if let data = snapshot?.data() {
                let username = data["nickname"] as? String ?? "Kullanıcı"
                let profileImageURL = data["profileImageURL"] as? String ?? ""

                let newComment: [String: Any] = [
                    "id": commentID,
                    "userID": uid,
                    "postID": postID,
                    "username": username,
                    "commentText": commentText,
                    "timestamp": Timestamp(date: Date()),
                    "profileImageURL": profileImageURL
                ]

                db.collection("comments").document(commentID).setData(newComment) { error in
                    if let error = error {
                        print("Yorum eklenemedi: \(error.localizedDescription)")
                    } else {
                        self.commentTextField.text = ""
                    }
                }
            }
        }
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Uyarı", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default))
        present(alert, animated: true)
    }
}

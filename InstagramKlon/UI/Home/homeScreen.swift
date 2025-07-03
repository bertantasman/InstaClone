//
//  ViewController.swift
//  InstagramKlon
//
//  Created by Bertan Taşman on 28.03.2025.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage
import SDWebImage
import FirebaseAuth

class homeScreen: UIViewController {
    
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    @IBOutlet weak var quitButton: UIBarButtonItem!
    @IBOutlet weak var postCheckLabel: UILabel!
    @IBOutlet weak var homeTable: UITableView!

    var contents = [data]()

    override func viewDidLoad() {
        super.viewDidLoad()
        homeTable.delegate = self
        homeTable.dataSource = self
        homeTable.separatorColor = .clear

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        homeTable.refreshControl = refreshControl

        Firestore.firestore().collection("posts").order(by: "timestamp", descending: true).addSnapshotListener { snapshot, error in
            guard let documents = snapshot?.documents else { return }

            self.contents.removeAll()

            for doc in documents {
                let dataMap = doc.data()
                let content = data(
                    id: 0,
                    photo: dataMap["imageURL"] as? String,
                    nickname: dataMap["nickname"] as? String,
                    content: dataMap["description"] as? String,
                    profileImageURL: dataMap["profileImageURL"] as? String,
                    documentID: doc.documentID,
                    likes: dataMap["likes"] as? [String] ?? []
                )
                self.contents.append(content)
            }

            self.homeTable.reloadData()
            self.postCheckLabel.isHidden = !self.contents.isEmpty
        }
    }
    
    func didTapComment(cell: cellContent) {
        guard let indexPath = homeTable.indexPath(for: cell) else { return }
        let selectedPost = contents[indexPath.row]

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let commentsVC = storyboard.instantiateViewController(withIdentifier: "commentsViewControllerID") as? commentsViewController {
            commentsVC.postID = selectedPost.documentID
            commentsVC.modalPresentationStyle = .pageSheet
            if let sheet = commentsVC.sheetPresentationController {
                sheet.detents = [.medium(), .large()]
                sheet.prefersGrabberVisible = true
            }
            present(commentsVC, animated: true)
        }
    }

    @IBAction func logoutTapped(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            redirectToLogin()
        } catch let error {
            print("Çıkış hatası: \(error.localizedDescription)")
        }
    }

    @IBAction func deleteAccountTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Hesabı Sil", message: "Bu işlem geri alınamaz. Hesabınızı silmek istediğinize emin misiniz?", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "İptal", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Sil", style: .destructive, handler: { _ in
            self.deleteUserAccount()
        }))

        present(alert, animated: true, completion: nil)
    }

    func deleteUserAccount() {
        guard let user = Auth.auth().currentUser else { return }
        let uid = user.uid

        Firestore.firestore().collection("users").document(uid).delete { error in
            if let error = error {
                self.showAlert(title: "Hata", message: "Kullanıcı verisi silinemedi: \(error.localizedDescription)")
            }
        }
        
        user.delete { error in
            if let error = error {
                print("Hesap silinemedi: \(error.localizedDescription)")
                self.showAlert(title: "Hata", message: "Hesap silinirken bir sorun oluştu.")
            } else {
                self.redirectToLogin()
            }
        }
    }

    func redirectToLogin() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginVC = storyboard.instantiateViewController(withIdentifier: "loginScreen") as! loginScreen
        let navController = UINavigationController(rootViewController: loginVC)

        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            sceneDelegate.window?.rootViewController = navController
            sceneDelegate.window?.makeKeyAndVisible()
        }
    }

    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default))
        present(alert, animated: true)
    }

    func deletePost(at indexPath: IndexPath) {
        let selectedPost = contents[indexPath.row]
        guard let imageURL = selectedPost.photo else { return }

        Firestore.firestore().collection("posts").whereField("imageURL", isEqualTo: imageURL).getDocuments { snapshot, error in
            if let document = snapshot?.documents.first {
                document.reference.delete()
                let storageRef = Storage.storage().reference(forURL: imageURL)
                storageRef.delete(completion: nil)

                self.contents.remove(at: indexPath.row)
                self.homeTable.deleteRows(at: [indexPath], with: .automatic)
            }
        }
    }
}

extension homeScreen: UITableViewDelegate, UITableViewDataSource, cellContentDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contents.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let content = contents[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "IDcellContent", for: indexPath) as! cellContent
        cell.likesCountLabel.text = "\(content.likes.count)"
        
        let postID = content.documentID
        Firestore.firestore().collection("comments").whereField("postID", isEqualTo: postID).getDocuments { snapshot, error in
            if let error = error {
                print("Yorum sayısı alınamadı: \(error.localizedDescription)")
                cell.commentCount.text = "0"
            } else {
                let count = snapshot?.documents.count ?? 0
                DispatchQueue.main.async {
                    cell.commentCount.text = "\(count)"
                }
            }
        }

        if let urlString = content.photo, let url = URL(string: urlString) {
            cell.photo.sd_setImage(with: url)
        }

        if let profileURLString = content.profileImageURL, let profileURL = URL(string: profileURLString) {
            cell.profilePhoto.sd_setImage(with: profileURL)
        } else {
            cell.profilePhoto.image = UIImage(named: "defaultProfile")
        }

        cell.nickname.text = content.nickname
        cell.content.text = content.content
        cell.selectionStyle = .none
        cell.delegate = self

        let currentUID = Auth.auth().currentUser?.uid ?? ""
        if content.likes.contains(currentUID) {
            cell.likeButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            cell.likeButton.tintColor = .systemRed
        } else {
            cell.likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
            cell.likeButton.tintColor = .gray
        }

        return cell
    }

    func didTapOptionsButton(cell: cellContent) {
        guard let indexPath = homeTable.indexPath(for: cell) else { return }

        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Gönderiyi Sil", style: .destructive, handler: { _ in
            self.deletePost(at: indexPath)
        }))
        alert.addAction(UIAlertAction(title: "İptal", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    func didTapLike(cell: cellContent) {
        guard let indexPath = homeTable.indexPath(for: cell) else { return }
        var post = contents[indexPath.row]
        guard let docID = post.documentID,
              let uid = Auth.auth().currentUser?.uid else { return }

        let postRef = Firestore.firestore().collection("posts").document(docID)

        if post.likes.contains(uid) {
            postRef.updateData([
                "likes": FieldValue.arrayRemove([uid])
            ])
            post.likes.removeAll { $0 == uid }
        } else {
            postRef.updateData([
                "likes": FieldValue.arrayUnion([uid])
            ])
            post.likes.append(uid)
        }

        contents[indexPath.row] = post
        homeTable.reloadRows(at: [indexPath], with: .none)
    }

    func didDoubleTapImage(cell: cellContent) {
        didTapLike(cell: cell)
    }
    
    func didTapShare(cell: cellContent) {
        guard let indexPath = homeTable.indexPath(for: cell) else { return }
        let post = contents[indexPath.row]
        
        if let urlString = post.photo {
            UIPasteboard.general.string = urlString
            
            let alert = UIAlertController(title: "Kopyalandı ✅", message: "Fotoğraf bağlantısı panoya kopyalandı.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Tamam", style: .default))
            present(alert, animated: true)
        }
    }


    @objc func refreshData() {
        Firestore.firestore().collection("posts").order(by: "timestamp", descending: true).getDocuments { snapshot, error in
            self.contents.removeAll()

            if let documents = snapshot?.documents {
                for doc in documents {
                    let dataMap = doc.data()
                    let content = data(
                        id: 0,
                        photo: dataMap["imageURL"] as? String,
                        nickname: dataMap["nickname"] as? String,
                        content: dataMap["description"] as? String,
                        profileImageURL: dataMap["profileImageURL"] as? String,
                        documentID: doc.documentID,
                        likes: dataMap["likes"] as? [String] ?? []
                    )
                    self.contents.append(content)
                }
            }

            self.homeTable.reloadData()
            self.postCheckLabel.isHidden = !self.contents.isEmpty
            self.homeTable.refreshControl?.endRefreshing()
        }
    }
}

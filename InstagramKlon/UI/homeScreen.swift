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

class homeScreen: UIViewController {

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
                    content: dataMap["description"] as? String
                )
                self.contents.append(content)
            }

            self.homeTable.reloadData()
            self.postCheckLabel.isHidden = !self.contents.isEmpty

        }
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

        if let urlString = content.photo, let url = URL(string: urlString) {
            cell.photo.sd_setImage(with: url)
        }

        cell.nickname.text = content.nickname
        cell.content.text = content.content
        cell.selectionStyle = .none
        cell.delegate = self

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
                        content: dataMap["description"] as? String
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

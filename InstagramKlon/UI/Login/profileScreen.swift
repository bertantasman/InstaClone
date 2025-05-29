//
//  profileScreen.swift
//  InstagramKlon
//
//  Created by Bertan Taşman on 24.04.2025.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import SDWebImage

class profileScreen: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    
    @IBOutlet weak var checkStatusLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var profilePhoto: UIImageView!

    var selectedImage: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadProfileData()
    }

    func setupUI() {
        confirmButton.isHidden = true
        profilePhoto.contentMode = .scaleAspectFill
        profilePhoto.clipsToBounds = true
    }

    func loadProfileData() {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("UID bulunamadı!")
            return
        }

        let db = Firestore.firestore()
        db.collection("users").document(uid).getDocument { snapshot, error in
            if let error = error {
                print("Firestore Hatası: \(error.localizedDescription)")
                return
            }

            guard let data = snapshot?.data() else {
                print("Kullanıcı verisi bulunamadı!")
                return
            }

            print("Kullanıcı verisi alındı: \(data)")

            DispatchQueue.main.async {
                self.nicknameLabel.text = data["nickname"] as? String ?? "Kullanıcı"

                if let photoURL = data["profileImageURL"] as? String, !photoURL.isEmpty {
                    self.profilePhoto.sd_setImage(with: URL(string: photoURL), placeholderImage: UIImage(named: "defaultProfile")) { image, error, cacheType, url in
                        if let error = error {
                            print("Profil fotoğrafı yüklenemedi: \(error.localizedDescription)")
                        } else {
                            print("Profil fotoğrafı başarıyla yüklendi.")
                        }
                    }
                    self.checkStatusLabel.isHidden = true
                } else {
                    self.checkStatusLabel.text = "Profil fotoğrafı ekleyin."
                    self.checkStatusLabel.isHidden = false
                }
            }
        }
    }

    @IBAction func editButtonTapped(_ sender: UIButton) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        if let image = info[.originalImage] as? UIImage {
            self.selectedImage = image
            self.profilePhoto.image = image
            self.confirmButton.isHidden = false
            self.checkStatusLabel.isHidden = true
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    @IBAction func confirmButtonTapped(_ sender: UIButton) {
        guard let image = selectedImage,
              let imageData = image.jpegData(compressionQuality: 0.8),
              let uid = Auth.auth().currentUser?.uid else { return }

        let storageRef = Storage.storage().reference().child("profileImages/\(uid).jpg")

        storageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                self.showAlert(message: "Fotoğraf yüklenemedi: \(error.localizedDescription)")
                return
            }

            storageRef.downloadURL { url, error in
                guard let downloadURL = url else {
                    self.showAlert(message: "Fotoğraf URL alınamadı.")
                    return
                }

                let db = Firestore.firestore()
                db.collection("users").document(uid).updateData([
                    "profileImageURL": downloadURL.absoluteString
                ]) { error in
                    if let error = error {
                        self.showAlert(message: "Profil güncellenemedi: \(error.localizedDescription)")
                    } else {
                        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            let tabBarController = storyboard.instantiateViewController(withIdentifier: "MainTabBarController") as! UITabBarController
                            sceneDelegate.window?.rootViewController = tabBarController
                            sceneDelegate.window?.makeKeyAndVisible()
                        }

                    }
                }
            }
        }
    }

    func showAlert(message: String) {
        let alert = UIAlertController(title: "Bilgi", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default))
        present(alert, animated: true)
    }
}

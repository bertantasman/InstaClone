//
//  sharePostScreen.swift
//  InstagramKlon
//
//  Created by Bertan Taşman on 29.03.2025.
//

import UIKit
import FirebaseStorage
import FirebaseFirestore
import FirebaseAuth
import Reachability

class sharePostScreen: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var explainPlain: UITextField!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var selectedImageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        explainPlain.delegate = self
        explainPlain.isUserInteractionEnabled = false
        explainPlain.alpha = 0.5

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    @IBAction func addPhotoTapped(_ sender: UIButton) {
        openImagePicker(sourceType: .photoLibrary)
    }

    @IBAction func cameraButtonTapped(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            openImagePicker(sourceType: .camera)
        } else {
            showAlert(title: "Kamera Bulunamadı", message: "Cihazınızda kamera yok.")
        }
    }

    func openImagePicker(sourceType: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = sourceType
        present(picker, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        explainPlain.isUserInteractionEnabled = true
        explainPlain.alpha = 1.0
        picker.dismiss(animated: true, completion: nil)

        if let selectedImage = info[.originalImage] as? UIImage {
            selectedImageView.image = selectedImage
            statusLabel.text = ""
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    @IBAction func submitTapped(_ sender: UIButton) {
        if !isConnectedToNetwork() {
            showErrorAlert(errorMessage: "Internet bağlantısı yok.")
            return
        }

        guard let image = selectedImageView.image,
              let imageData = image.jpegData(compressionQuality: 0.8) else {
            statusLabel.text = "Lütfen bir fotoğraf seçin!"
            statusLabel.textColor = .systemRed
            return
        }

        let description = explainPlain.text ?? ""
        loadingIndicator.startAnimating()
        submitButton.isEnabled = false

        let imageID = UUID().uuidString
        let storageRef = Storage.storage().reference().child("posts/\(imageID).jpg")

        storageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                self.showErrorAlert(errorMessage: "Fotoğraf yüklenemedi: \(error.localizedDescription)")
                return
            }

            storageRef.downloadURL { url, error in
                guard let downloadURL = url else {
                    self.showErrorAlert(errorMessage: "Fotoğraf bağlantısı alınamadı.")
                    return
                }

                self.uploadPostToFirestore(imageURL: downloadURL.absoluteString, description: description)
            }
        }
    }

    func uploadPostToFirestore(imageURL: String, description: String) {
        guard let uid = Auth.auth().currentUser?.uid else {
            self.showErrorAlert(errorMessage: "Kullanıcı doğrulanamadı.")
            return
        }

        let firestore = Firestore.firestore()
        firestore.collection("users").document(uid).getDocument { snapshot, error in
            if let data = snapshot?.data() {
                let nickname = data["nickname"] as? String ?? "Bilinmeyen"
                let profileImageURL = data["profileImageURL"] as? String ?? ""

                firestore.collection("posts").addDocument(data: [
                    "imageURL": imageURL,
                    "description": description,
                    "nickname": nickname,
                    "profileImageURL": profileImageURL,
                    "timestamp": FieldValue.serverTimestamp()
                ]) { error in
                    self.loadingIndicator.stopAnimating()
                    self.submitButton.isEnabled = true

                    if error != nil {
                        self.showErrorAlert(errorMessage: "Gönderi kaydedilemedi.")
                    } else {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self.navigateToHomeTab()
                        }
                    }
                }
            } else {
                self.showErrorAlert(errorMessage: "Kullanıcı bilgisi alınamadı.")
            }
        }
    }

    func navigateToHomeTab() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let tabBarVC = storyboard.instantiateViewController(withIdentifier: "MainTabBarController") as? UITabBarController {
            tabBarVC.selectedIndex = 0
            if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                sceneDelegate.window?.rootViewController = tabBarVC
                sceneDelegate.window?.makeKeyAndVisible()
            }
        }
    }

    func isConnectedToNetwork() -> Bool {
        let reachability = try! Reachability()
        return reachability.connection != .unavailable
    }

    func showErrorAlert(errorMessage: String) {
        showAlert(title: "Hata", message: errorMessage)
    }

    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

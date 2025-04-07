//
//  sharePostScreen.swift
//  InstagramKlon
//
//  Created by Bertan Taşman on 29.03.2025.
//

import UIKit
import PhotosUI
import FirebaseStorage
import FirebaseFirestore
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
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
    }
    
    @IBAction func cameraButtonTapped(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .camera
            present(picker, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Kamera bulunamadı", message: "Cihazınızda kamera bulunmuyor.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Tamam", style: .default))
            present(alert, animated: true, completion: nil)
        }
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
    
    func isConnectedToNetwork() -> Bool {
        let reachability = try! Reachability()
        return reachability.connection != .unavailable
    }
    
    @IBAction func submitTapped(_ sender: UIButton) {
        if !isConnectedToNetwork() {
            showErrorAlert(errorMessage: "Internet Bağlantısı yok")
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

                let firestore = Firestore.firestore()
                firestore.collection("posts").addDocument(data: [
                    "imageURL": downloadURL.absoluteString,
                    "description": description,
                    "nickname": "Bertantasmann",
                    "timestamp": FieldValue.serverTimestamp()
                ]) { error in
                    self.loadingIndicator.stopAnimating()
                    self.submitButton.isEnabled = true

                    if error != nil {
                        self.showErrorAlert(errorMessage: "Gönderi kaydedilemedi.")
                    } else {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self.navigateToHome()
                        }
                    }
                }
            }
        }
    }
    func showErrorAlert(errorMessage: String) {
        let alert = UIAlertController(title: "Hata", message: errorMessage, preferredStyle: .alert)
 
        alert.addAction(UIAlertAction(title: "Tekrar Dene", style: .default, handler: { _ in
            self.submitTapped(self.submitButton)
        }))
        
        alert.addAction(UIAlertAction(title: "Tamam", style: .cancel, handler: { _ in
            self.navigateToHome()
        }))
            self.present(alert, animated: true, completion: nil)
    }
    
    func navigateToHome() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

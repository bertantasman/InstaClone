//
//  registerScreen.swift
//  InstagramKlon
//
//  Created by Bertan Taşman on 23.04.2025.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class registerScreen: UIViewController {

    @IBOutlet weak var createAccountButton: UIButton!
    @IBOutlet weak var rePasswordLabel: UITextField!
    @IBOutlet weak var reLabelNickname: UITextField!
    @IBOutlet weak var reNameLabel: UITextField!
    @IBOutlet weak var reEmailLabel: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupKeyboardDismiss()
    }

    func setupUI() {
        createAccountButton.layer.cornerRadius = 8
        rePasswordLabel.placeholder = "Şifre"
        reLabelNickname.placeholder = "Kullanıcı Adı"
        reNameLabel.placeholder = "Ad"
        reEmailLabel.placeholder = "Email"
        rePasswordLabel.isSecureTextEntry = true

        
        rePasswordLabel.delegate = self
        reLabelNickname.delegate = self
        reNameLabel.delegate = self
        reEmailLabel.delegate = self
    }

    func setupKeyboardDismiss() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    @IBAction func createAccountTapped(_ sender: UIButton) {
        guard let email = reEmailLabel.text, !email.isEmpty,
              let password = rePasswordLabel.text, !password.isEmpty,
              let nickname = reLabelNickname.text, !nickname.isEmpty,
              let name = reNameLabel.text, !name.isEmpty else {
            showAlert(message: "Lütfen tüm alanları doldurun!")
            return
        }

        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                self.showAlert(message: "Kayıt Hatası: \(error.localizedDescription)")
            } else {
                self.createUserProfile()
            }
        }
    }

    func createUserProfile() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        let db = Firestore.firestore()
        let profileData: [String: Any] = [
            "name": reNameLabel.text ?? "",
            "email": reEmailLabel.text ?? "",
            "nickname": reLabelNickname.text ?? "",
            "bio": "",
            "profileImageURL": ""
        ]

        db.collection("users").document(uid).setData(profileData) { error in
            if let error = error {
                self.showAlert(message: "Profil Kaydedilemedi: \(error.localizedDescription)")
            } else {
                self.performSegue(withIdentifier: "toProfileScreen", sender: nil)
            }
        }
    }

    func showAlert(message: String) {
        let alert = UIAlertController(title: "Uyarı", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}


extension registerScreen: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

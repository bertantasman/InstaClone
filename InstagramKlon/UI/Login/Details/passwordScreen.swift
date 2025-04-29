//
//  passwordScreen.swift
//  InstagramKlon
//
//  Created by Bertan Taşman on 23.04.2025.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class passwordScreen: UIViewController {

    @IBOutlet weak var passNameLabel: UITextField!
    @IBOutlet weak var passEmailLabel: UITextField!
    @IBOutlet weak var passNicknameLabel: UITextField!
    @IBOutlet weak var getCodeButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupKeyboardDismiss()
    }

    func setupUI() {
        getCodeButton.layer.cornerRadius = 8
        passNameLabel.placeholder = "Ad"
        passNicknameLabel.placeholder = "Kullanıcı Adı"
        passEmailLabel.placeholder = "Email"

        passNameLabel.delegate = self
        passNicknameLabel.delegate = self
        passEmailLabel.delegate = self
    }

    func setupKeyboardDismiss() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    @IBAction func getCodeTapped(_ sender: UIButton) {
        guard let name = passNameLabel.text, !name.isEmpty,
              let nickname = passNicknameLabel.text, !nickname.isEmpty,
              let email = passEmailLabel.text, !email.isEmpty else {
            showAlert(message: "Lütfen tüm alanları doldurun!")
            return
        }

        let db = Firestore.firestore()
        db.collection("users").whereField("email", isEqualTo: email).getDocuments { snapshot, error in
            if let error = error {
                self.showAlert(message: "Hata: \(error.localizedDescription)")
                return
            }

            guard let documents = snapshot?.documents, !documents.isEmpty else {
                self.showAlert(message: "Böyle bir kullanıcı bulunamadı!")
                return
            }

            let userData = documents[0].data()
            let fetchedName = userData["name"] as? String ?? ""
            let fetchedNickname = userData["nickname"] as? String ?? ""

            if fetchedName.lowercased() == name.lowercased() && fetchedNickname.lowercased() == nickname.lowercased() {
                Auth.auth().sendPasswordReset(withEmail: email) { error in
                    if let error = error {
                        self.showAlert(message: "Mail gönderilemedi: \(error.localizedDescription)")
                    } else {
                        self.showAlert(message: "Şifre sıfırlama maili gönderildi!")
                    }
                }
            } else {
                self.showAlert(message: "Bilgiler eşleşmedi. Lütfen kontrol edin.")
            }
        }
    }

    func showAlert(message: String) {
        let alert = UIAlertController(title: "Bilgi", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

extension passwordScreen: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()  // Geç (Return) tuşuna basınca klavye kapanır
        return true
    }
}

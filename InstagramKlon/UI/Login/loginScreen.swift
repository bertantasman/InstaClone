//
//  loginScreen.swift
//  InstagramKlon
//
//  Created by Bertan Taşman on 23.04.2025.
//

import UIKit
import FirebaseAuth

class loginScreen: UIViewController {
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        setupUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if Auth.auth().currentUser != nil {
            self.performSegue(withIdentifier: "toHomeScreen", sender: nil)
        }
    }

    func setupUI() {
        loginButton.layer.cornerRadius = 8
        emailTextField.placeholder = "Email"
        passwordTextField.placeholder = "Şifre"
        passwordTextField.isSecureTextEntry = true
    }

    @IBAction func loginButtonTapped(_ sender: UIButton) {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showAlert(message: "Lütfen email ve şifreyi girin.")
            return
        }

        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error as NSError? {
                let turkceMesaj = self.turkceHataMesaji(errorCode: error.code)
                self.showAlert(message: turkceMesaj)
            } else {
                self.performSegue(withIdentifier: "toHomeScreen", sender: nil)
            }
        }
    }

    func turkceHataMesaji(errorCode: Int) -> String {
        switch errorCode {
        case AuthErrorCode.wrongPassword.rawValue:
            return "Şifre yanlış. Lütfen tekrar deneyin."
        case AuthErrorCode.invalidEmail.rawValue:
            return "Geçersiz e-posta adresi girdiniz."
        case AuthErrorCode.userNotFound.rawValue:
            return "Böyle bir kullanıcı bulunamadı."
        case AuthErrorCode.networkError.rawValue:
            return "İnternet bağlantısı hatası. Lütfen bağlantınızı kontrol edin."
        case AuthErrorCode.userDisabled.rawValue:
            return "Bu hesap devre dışı bırakılmış."
        default:
            return "Bilinmeyen bir hata oluştu. Lütfen tekrar deneyin."
        }
    }

    func showAlert(message: String) {
        let alert = UIAlertController(title: "Giriş Hatası", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension loginScreen: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

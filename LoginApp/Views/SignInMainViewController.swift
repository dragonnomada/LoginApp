//
//  SignInMainViewController.swift
//  LoginApp
//
//  Created by Alan Badillo Salas on 24/05/23.
//

import UIKit

class SignInMainViewController: UIViewController {

    var userModel: UserModel?
    
    lazy var signInViewModel: SignInViewModel = {
        guard let userModel = userModel
        else {
            fatalError("[SignInMainViewController] Invalid user model")
        }
        
        let viewModel = SignInViewModel(userModel: userModel)
        
        // TODO: Configure view model
        
        return viewModel
    }()
    
    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: SecureTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        signInViewModel.delegate = self
    }
    
    @IBAction func forgotPasswordAction(_ sender: Any) {
        print("forgotPasswordAction")
        
        if username.isEmpty {
            showAlert(self, title: "Invalid username", message: "Please enter the username")
            return
        }
        
        let alert = UIAlertController(title: "Recover password", message: "\nRecover password for \(username)\n\nEnter the email:", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Email"
            textField.textContentType = .emailAddress
        }
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default) { _ in
            guard let textField = alert.textFields?.first
            else { return }
            
            self.signInViewModel.forgotPassword(self, username: self.username, email: textField.text ?? "<none>")
        })
        
        present(alert, animated: true)
    }
    
    @IBAction func signInAction(_ sender: Any) {
        print("signInAction")
        signInViewModel.signIn(self, username: username, password: password)
    }
    
    @IBAction func signUpAction(_ sender: Any) {
        print("signUpAction")
//        signInViewModel.signUp(username: username, password: password, confirmPassword: password)
        performSegue(withIdentifier: "signUpSegue", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "signUpSegue" {
            if let viewController = segue.destination as? SignUpViewController {
                viewController.signInViewModel = signInViewModel
            }
        }
    }
    
}

extension SignInMainViewController: SignInDelegate {
    var username: String {
        get {
            usernameTextField.text ?? ""
        }
        set {
            usernameTextField.text = newValue
        }
    }
    
    var password: String {
        get {
            passwordTextField.text ?? ""
        }
        set {
            passwordTextField.text = newValue
        }
    }
    
    func showAlert(_ viewController: UIViewController, title: String, message: String, completion: @escaping () -> Void = {}) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default) { _ in
            completion()
        })
        
        viewController.present(alert, animated: true)
    }
    
    func signIn(_ sender: Any?, user: UserEntity?, error: SignInError?) {
        if let error = error {
            print("[signIn] Error: \(error)")
            showAlert(self, title: "Signin error", message: "\(error)")
            return
        }
        
        guard let user = user
        else { return }
        
        print("[signIn] Username: \(user.username ?? "<unknown>") Password: \(user.password ?? "<none>")")
        showAlert(self, title: "Signin success", message: "Welcome \(user.username ?? "<unknown>")")
    }
    
    func signUp(_ sender: Any?, user: UserEntity?, error: SignUpError?) {
        guard let viewController = sender as? UIViewController
        else {
            showAlert(self, title: "Error", message: "Invalid View Controller")
            return
        }
        
        if let error = error {
            print("[SignInDelegate.signUp] Error: \(error)")
            showAlert(viewController, title: "Signup error", message: "\(error)")
            return
        }
        
        guard let user = user
        else { return }
        
        print("[SignInDelegate.signUp] Username: \(user.username ?? "<unknown>") Password: \(user.password ?? "<none>")")
        
        showAlert(viewController, title: "Signup success", message: "User \(user.username ?? "<unknown>") was created") {
            viewController.dismiss(animated: true)
        }
    }
    
    func forgotPassword(_ sender: Any?, user: UserEntity?, error: ForgotPasswordError?) {
        if let error = error {
            print("[SignInDelegate.forgotPassword] Error: \(error)")
            showAlert(self, title: "Recover password error", message: "\(error)")
            return
        }
        
        guard let user = user
        else { return }
        
        print("[SignInDelegate.forgotPassword] Username: \(user.username ?? "<unknown>") Password: \(user.password ?? "<none>")")
        
        showAlert(self, title: "Recover password success", message: "Check your email \(user.email ?? "<none>") to get your password")
    }
    
    
}

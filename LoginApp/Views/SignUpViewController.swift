//
//  SignUpViewController.swift
//  LoginApp
//
//  Created by Alan Badillo Salas on 24/05/23.
//

import UIKit

class SignUpViewController: UIViewController {

    var signInViewModel: SignInViewModel?
    
    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: SecureTextField!
    
    @IBOutlet weak var confirmPasswordTextField: SecureTextField!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    var username: String {
        usernameTextField.text ?? ""
    }
    
    var password: String {
        passwordTextField.text ?? ""
    }
    
    var confirmPassword: String {
        confirmPasswordTextField.text ?? ""
    }
    
    var email: String {
        emailTextField.text ?? ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func signUpAction(_ sender: Any) {
        
        signInViewModel?.signUp(self, username: username, password: password, confirmPassword: confirmPassword, email: email)
        
    }

}

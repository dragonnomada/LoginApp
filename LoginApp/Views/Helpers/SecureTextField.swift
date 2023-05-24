//
//  SecureTextField.swift
//  LoginApp
//
//  Created by Alan Badillo Salas on 24/05/23.
//

import Foundation
import UIKit

class SecureTextField: UITextField {
    
    let showPasswordButton = UIButton(type: .custom)
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        let width = 30
        let height = 30
        let paddingX = 10
        
        let outerView = UIView()
        outerView.frame = CGRect(origin: .zero, size: CGSize(width: width + paddingX, height: height))
        
        showPasswordButton.setImage(UIImage(systemName: "eye"), for: .normal)
        showPasswordButton.frame = CGRect(x: paddingX / 2, y: 0, width: width, height: height)
        showPasswordButton.addTarget(self, action: #selector(toggleShowPasswordAction), for: .touchUpInside)
        
        outerView.addSubview(showPasswordButton)
        
        rightViewMode = .always
        rightView = outerView
        isSecureTextEntry = true
        rightViewRect(forBounds: CGRect(x: -20, y: 0, width: 30, height: 30))
        
        print("Secure UITextField initialized")
    }
    
    @objc
    func toggleShowPasswordAction(button: UIButton) {
        toggleShowPassword()
    }
    
    func toggleShowPassword() {
        isSecureTextEntry = !isSecureTextEntry
        showPasswordButton.setImage(UIImage(systemName: isSecureTextEntry ? "eye" : "eye.slash"), for: .normal)
    }
    
}

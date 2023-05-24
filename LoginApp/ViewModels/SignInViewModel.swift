//
//  SignInCompleteViewModel.swift
//  LoginApp
//
//  Created by Alan Badillo Salas on 24/05/23.
//

import Foundation
import mailslurp

enum SignInError: Error {
    case userNotExists(username: String)
    case invalidPassword(username: String)
    case invalidTouchID(username: String)
    case invalidFaceID(username: String)
    case unknown(message: String)
}

enum ForgotPasswordError: Error {
    case userNotExists(username: String)
    case invalidEmail
    case unknown(message: String)
}

enum SignUpError: Error {
    case createUser(reason: String)
    case passwordNotMatch
    case unknown(message: String)
}

protocol SignInDelegate: AnyObject {
    
    var username: String { get set }
    var password: String { get set }
    
    func signIn(_ sender: Any?, user: UserEntity?, error: SignInError?)
    func forgotPassword(_ sender: Any?, user: UserEntity?, error: ForgotPasswordError?)
    func signUp(_ sender: Any?, user: UserEntity?, error: SignUpError?)
    
}

class SignInViewModel {
    
    let userModel: UserModel
    var delegate: SignInDelegate?
    
    lazy var apiKeys: NSDictionary = {
        
        guard let url = Bundle.main.url(forResource: "ApiKeys", withExtension: "plist")
        else {
            fatalError("Error to convert ApiKeys.plist path to url")
        }
        
        guard let apiKeys = NSDictionary(contentsOf: url)
        else {
            fatalError("Error while reading ApiKeys.plist")
        }
                
        return apiKeys
    }()
    
    init(userModel: UserModel) {
        self.userModel = userModel
    }
    
    func signIn(_ sender: Any?, username: String, password: String) {
        guard let user = userModel.get(byUsername: username)
        else {
            delegate?.signIn(sender, user: nil, error: .userNotExists(username: username))
            return
        }
        
        guard user.password == password
        else {
            delegate?.signIn(sender, user: nil, error: .invalidPassword(username: username))
            return
        }
        
        delegate?.signIn(sender, user: user, error: nil)
    }
    
    func forgotPassword(_ sender: Any?, username: String, email: String) {
        guard let user = userModel.get(byUsername: username)
        else {
            delegate?.forgotPassword(sender, user: nil, error: .userNotExists(username: username))
            return
        }
        
        guard user.email == email
        else {
            delegate?.forgotPassword(sender, user: nil, error: .invalidEmail)
            return
        }
        
        // TODO: Send email with password reset
        if let apiKey = apiKeys["mailslurp"] as? String {
            CommonActionsControllerAPI.sendEmailSimpleWithRequestBuilder(simpleSendEmailOptions: SimpleSendEmailOptions(to: email, body: "Your password is: \(user.password ?? "<error>")", subject: "LoginApp Password recovery"))
                .addHeader(name: "x-api-key", value: apiKey)
                .execute()
                .done { [self] response in
                    self.delegate?.forgotPassword(sender, user: user, error: nil)
                 }
                .catch(policy: .allErrors) { err in
                    // handle error
                    guard let e = err as? ErrorResponse else {
                        let error = err.localizedDescription
                        print(error)
                        self.delegate?.forgotPassword(sender, user: user, error: .unknown(message: "\(error)"))
                        return
                    }
                    // pattern match the error to access status code and data
                    // MailSlurp returns 4xx errors when invalid parameters or
                    // unsatisfiable request. See the message and status code
                    switch e {
                    case .error(let statusCode, let data, _, _):
                        let msg = String(decoding: data!, as: UTF8.self)
                        let error = "\(statusCode) Bad request: \(msg)"
                        print(error)
                        self.delegate?.forgotPassword(sender, user: user, error: .unknown(message: "\(error)"))
                    }
                  }
            return
        }
        
        
        delegate?.forgotPassword(sender, user: user, error: nil)
    }
    
    func signUp(_ sender: Any?, username: String, password: String, confirmPassword: String) {
        signUp(sender, username: username, password: password, confirmPassword: confirmPassword, email: nil)
    }
    
    func signUp(_ sender: Any?, username: String, password: String, confirmPassword: String, email: String?) {
        guard password == confirmPassword
        else {
            delegate?.signUp(sender, user: nil, error: .passwordNotMatch)
            return
        }
        
        do {
            let user = try userModel.add(username: username, password: password)
            
            if let email = email {
                let userUpdated = try userModel.edit(username: username, email: email)
                delegate?.signUp(sender, user: userUpdated, error: nil)
            } else {
                delegate?.signUp(sender, user: user, error: nil)
            }
        } catch UserModelError.userAlreadyExists(user: let user) {
            delegate?.signUp(sender, user: user, error: .createUser(reason: "User \(user.username ?? username) already exists"))
        } catch UserModelError.addUser(reason: let reason) {
            delegate?.signUp(sender, user: nil, error: .createUser(reason: reason))
        } catch UserModelError.saveContext {
            delegate?.signUp(sender, user: nil, error: .createUser(reason: "CoreData save context error"))
        } catch {
            delegate?.signUp(sender, user: nil, error: .unknown(message: "\(error)"))
        }
    }
    
}

extension SignInDelegate {
    func signIn(_ sender: Any?, user: UserEntity?, error: SignInError?) {
        if let error = error {
            print("[SignInDelegate.signIn] Error: \(error)")
            return
        }
        
        guard let user = user
        else { return }
        
        print("[SignInDelegate.signIn] Username: \(user.username ?? "<unknown>") Password: \(user.password ?? "<none>")")
    }
    
    func signUp(_ sender: Any?, user: UserEntity?, error: SignUpError?) {
        if let error = error {
            print("[SignInDelegate.signUp] Error: \(error)")
            return
        }
        
        guard let user = user
        else { return }
        
        print("[SignInDelegate.signUp] Username: \(user.username ?? "<unknown>") Password: \(user.password ?? "<none>")")
    }
    
    func forgotPassword(_ sender: Any?, user: UserEntity?, error: ForgotPasswordError?) {
        if let error = error {
            print("[SignInDelegate.forgotPassword] Error: \(error)")
            return
        }
        
        guard let user = user
        else { return }
        
        print("[SignInDelegate.forgotPassword] Username: \(user.username ?? "<unknown>") Password: \(user.password ?? "<none>")")
    }
}

//
//  UserModel.swift
//  LoginApp
//
//  Created by Alan Badillo Salas on 24/05/23.
//

import Foundation
import CoreData

enum UserModelError: Error {
    case addUser(reason: String)
    case userNotExists(username: String)
    case userAlreadyExists(user: UserEntity)
    case saveContext
    case editUser(user: UserEntity, reason: String)
    case unknown(message: String)
}

class UserModel {
    
    lazy var container: NSPersistentContainer = {
        
        let conteiner = NSPersistentContainer(name: "LoginApp")
        
        conteiner.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Error loading persistent container LoadApp")
            }
        }
        
        return conteiner
        
    }()
    
    var context: NSManagedObjectContext {
        container.viewContext
    }
    
    private func saveContext() throws {
        do {
            try context.save()
            throw UserModelError.saveContext
        } catch {
            context.rollback()
        }
    }
    
    func get(byUsername username: String) -> UserEntity? {
        do {
            return try context.fetch(UserEntity.fetchRequest()).first(where: {$0.username == username})
        } catch {
            return nil
        }
    }
    
    
    func exists(username: String) -> Bool {
        guard let _ = get(byUsername: username)
        else { return false }
        return true
    }
    
    func add(username: String, password: String) throws -> UserEntity {
        if username.isEmpty {
            throw UserModelError.addUser(reason: "Username is empty")
        }
        
        if password.isEmpty {
            throw UserModelError.addUser(reason: "Password is empty")
        }
        
        if let userExists = get(byUsername: username) {
            throw UserModelError.userAlreadyExists(user: userExists)
        }
        
        let user = UserEntity(context: context)
        
        user.username = username
        user.password = password
        user.remember = false
        user.touchID = false
        user.faceID = false
        
        try saveContext()
        
        return user
    }
    
    func edit(username: String, fullname: String? = nil, email: String? = nil, picture: Data? = nil, remember: Bool? = false, useTouchID: Bool? = false, useFaceID: Bool? = false, password: String? = nil, confirmPassword: String? = nil) throws -> UserEntity {
        guard let user = get(byUsername: username)
        else {
            throw UserModelError.userNotExists(username: username)
        }
        
        if let fullname = fullname {
            user.fullname = fullname
            try saveContext()
        }
        
        if let email = email {
            user.email = email
            try saveContext()
        }
        
        if let picture = picture {
            user.picture = picture
            try saveContext()
        }
        
        if let remember = remember {
            user.remember = remember
            try saveContext()
        }
        
        if let useTouchID = useTouchID {
            user.touchID = useTouchID
            try saveContext()
        }
        
        if let useFaceID = useFaceID {
            user.faceID = useFaceID
            try saveContext()
        }
        
        if let password = password, let confirmPassword = confirmPassword {
            if password == confirmPassword {
                user.password = password
                try saveContext()
            } else {
                throw UserModelError.editUser(user: user, reason: "Password and confirm password does not match")
            }
        }
        
        try saveContext()
        
        return user
    }
    
    func delete(username: String) throws -> UserEntity {
        guard let user = get(byUsername: username)
        else {
            throw UserModelError.userNotExists(username: username)
        }
        
        context.delete(user)
        
        try saveContext()
        
        return user
    }
    
}

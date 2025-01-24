//
//  Utility.swift
//  MobileSocket
//
//  Created by Aditya on 22/01/25.
//

import Foundation
import Security

class Utility {
    static let shared = Utility()
    
    func requestAdminAccess(completion: @escaping (Bool) -> Void) {
        // Define authorization flags
        let flags: AuthorizationFlags = [.interactionAllowed, .extendRights, .preAuthorize]
        
        // Create authorization reference
        var authRef: AuthorizationRef?
        let status = AuthorizationCreate(nil, nil, flags, &authRef)
        
        if status == errAuthorizationSuccess, let authRef = authRef {
            // Rights to request admin access
            let rights = AuthorizationRights(
                count: 1,
                items: UnsafeMutablePointer(mutating: [
                    AuthorizationItem(
                        name: kAuthorizationRightExecute,
                        valueLength: 0,
                        value: nil,
                        flags: 0
                    )
                ])
            )
            
            var rightsPointer = rights
            let status = AuthorizationCopyRights(
                authRef,
                &rightsPointer,
                nil,
                flags,
                nil
            )
            
            if status == errAuthorizationSuccess {
                completion(true) // Access granted
            } else {
                completion(false) // Access denied or canceled
            }
            
            AuthorizationFree(authRef, [.destroyRights])
        } else {
            completion(false) // Authorization creation failed
        }
    }
    
    func isCurrentUserAdmin() -> Bool {
        // Get the current user name
        let userName = NSUserName()
        
        // Create a task to get the groups the user belongs to
        let task = Process()
        task.launchPath = "/usr/bin/id"
        task.arguments = ["-Gn", userName]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        
        task.launch()
        task.waitUntilExit()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        if let output = String(data: data, encoding: .utf8) {
            let groups = output.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: " ")
            return groups.contains("admin")
        }
        return false
    }
}

// SPDX-License-Identifier: EUPL-1.2

//
//  KeychainManager.swift
//  KeychainWrapperPackage
//
//  Created by Matīss Mamedovs on 03/12/2024.
//

import Foundation

final public class KeychainManager: Sendable {
    
    public static let shared = KeychainManager()
    
    public func addItemToKeychain(query: CFDictionary, completion: @escaping (Bool) -> Void) {
        SecItemDelete(query as CFDictionary)  // Delete any existing data
        let status = SecItemAdd(query as CFDictionary, nil)
        if status == errSecSuccess {
            print("information securely stored.")
        } else {
            print("Failed to information securely.")
        }
        completion(status == errSecSuccess)
    }
    
    
    public func addItemToKeychainAsync(query: CFDictionary) async throws -> Bool {
        SecItemDelete(query as CFDictionary)  // Delete any existing data
        let status = SecItemAdd(query as CFDictionary, nil)
        if status == errSecSuccess {
            print("information securely stored.")
        } else {
            print("Failed to information securely.")
        }
        return(status == errSecSuccess)
    }
    
    public func updateKeychainItem(query: CFDictionary, updateField: CFDictionary, completion: @escaping (Bool) -> Void) {
        let status = SecItemUpdate(query, updateField)
        if status == errSecSuccess {
            print("Passcode updated securely.")
        } else {
            print("Failed to update login information securely.")
        }
        completion(status == errSecSuccess)
    }
    
    public func delete(query: CFDictionary, completion: @escaping (Bool) -> Void) {
        let status = SecItemDelete(query)
        
        completion(status == errSecSuccess)
    }
    
    public func retrieve(query: CFDictionary, completion: @escaping (Data?) -> Void) {
        var item: AnyObject?
        _ = SecItemCopyMatching(query, &item)
                
        guard let passcodeDict = item as? NSDictionary else {
            completion(item as? Data)
            return
        }
        
        guard let passcode = passcodeDict[kSecValueData] as? Data else {
            completion(nil)
            return
        }
        
        completion(passcode)
    }
    
    public func throwRetrieve(query: CFDictionary) throws -> Data? {
        var item: AnyObject?
        _ = SecItemCopyMatching(query, &item)
                
        guard let passcodeDict = item as? NSDictionary else {
            return item as? Data
        }
        
        guard let passcode = passcodeDict[kSecValueData] as? Data else {
            return nil
        }
        
        return passcode
    }
    
    public func convertToData(item: String) -> Data? {
        return item.data(using: .utf8)
    }
    
    public func convertToString(item: Data) -> String? {
        return String(data: item, encoding: .utf8)
    }
    
    public func convertToInt(item: Data) -> Int32? {
        return item.withUnsafeBytes( {(pointer: UnsafeRawBufferPointer) -> Int32 in
            return pointer.load(as: Int32.self)
        })
    }
    
    public func convertToData(item: Int) -> Data? {
        return withUnsafeBytes(of: item) { Data($0) }
    }
    
}

//
//  KeychainStore.swift
//  Persistence
//  
//  Created by Majd Alfhaily on 21.03.22.
//

import Foundation

#if os(macOS)

import KeychainAccess

public protocol KeychainStoreInterface {
    func value<T: Codable>(forKey itemKey: String) throws -> T?
    func setValue<T: Codable>(_ item: T, forKey itemKey: String) throws
    func remove(_ key: String) throws
}

public class KeychainStore: KeychainStoreInterface {
    private let keychain: Keychain

    public init(service: String) {
        self.keychain = Keychain(service: service)
    }

    public func value<T: Codable>(forKey itemKey: String) throws -> T? {
        guard let data = try keychain.getData(itemKey) else {
            return nil
        }

        return try JSONDecoder().decode(T.self, from: data)
    }

    public func setValue<T: Codable>(_ item: T, forKey itemKey: String) throws {
        let data = try JSONEncoder().encode(item)
        try keychain.set(data, key: itemKey)
    }

    public func remove(_ key: String) throws {
        try keychain.remove(key)
    }
}

#else

public protocol KeychainStoreInterface {
    func value<T: Codable>(forKey itemKey: String) throws -> T?
    func setValue<T: Codable>(_ item: T, forKey itemKey: String) throws
    func remove(_ key: String) throws
}

public class KeychainStore: KeychainStoreInterface {
    private var keychain = "{}"

    private let path = ".ipatool"

    public init(service: String) {
        do {
            let url = URL(fileURLWithPath: path)
            let data = try Data(contentsOf: url)
            keychain = String(data: data, encoding: .utf8)!
        } catch {
            print("Loading error: \(error)")
        }
    }

    public func value<T: Codable>(forKey itemKey: String) throws -> T? {
        let json = try JSONDecoder().decode(T.self, from: keychain.data(using: .utf8)!)
        return json
    }

    public func setValue<T: Codable>(_ item: T, forKey itemKey: String) throws {
        if let encodedData = try? JSONEncoder().encode(item) {
            keychain = String(data: encodedData, encoding: .utf8)!
            let url = URL(fileURLWithPath: path)
            do {
                try encodedData.write(to: url)
            } 
            catch {
                print("Failed to write JSON data: \(error.localizedDescription)")
            }
        }
    }

    public func remove(_ key: String) throws {
        keychain = "{}"
    }
}

#endif


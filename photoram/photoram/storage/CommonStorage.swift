//
//  CommonStorage.swift
//  photoram
//
//  Created by Anna Zharkova on 10.05.2021.
//  Copyright © 2021 azharkova. All rights reserved.
//

import Foundation

class CommonStorage: NSObject {
    private lazy var storage = UserDefaults.standard

    func saveData<T: Any&Codable>(data: T?, forKey: String) {
        storage.removeObject(forKey: forKey)
        guard let data = data, let encodedData =  try? JSONEncoder().encode(data) else {
            return
        }
        storage.set(encodedData, forKey: forKey)
        storage.synchronize()
    }

    func getData<T: Any&Codable>(forKey: String) -> T? {
        if  let decoded = storage.object(forKey: forKey) as? Data {
            return try? JSONDecoder().decode(T.self, from: decoded)
        } else {
            return nil
        }
    }

    func clearData(forKey: String) {
        storage.removeObject(forKey: forKey)
        storage.synchronize()
    }

    func getKeys() -> [String] {
        return Array(storage.dictionaryRepresentation().keys)
    }

}

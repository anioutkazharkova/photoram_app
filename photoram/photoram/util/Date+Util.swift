//
//  Date+Util.swift
//  photoram
//
//  Created by Anna Zharkova on 25.05.2021.
//  Copyright © 2021 azharkova. All rights reserved.
//

import Foundation
import Firebase
extension Date {
    func format(_ format: String)->String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
    
    func formatIso()->String {
        let dateFormatter = ISO8601DateFormatter()
        return dateFormatter.string(from: self)
    }
   
    var defaultText: String {
        return self.format("dd.MM hh:mm")
    }
    
    var iso: String {
        return self.formatIso()
    }
}
extension String {
    func fromIso()->Date? {
        let dateFormatter = ISO8601DateFormatter()
        return dateFormatter.date(from: self)
    }
}

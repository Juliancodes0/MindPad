//
//  String.swift
//  MindPad
//
//  Created by Julian Burton on 11/27/23.
//

import Foundation

extension String {
    func isOnlyNumbers () -> Bool {
        let numericRegex = "^[0-9]+$"
        let range = NSRange(location: 0, length: self.utf16.count)
        let regex = try! NSRegularExpression(pattern: numericRegex)
        return regex.firstMatch(in: self, options: [], range: range) != nil
    }
}

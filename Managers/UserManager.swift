//
//  UserManager.swift
//  MindPad
//
//  Created by Julian Burton on 11/27/23.
//

import Foundation
import SwiftUI

class UserManager {
    
    static let shared = UserManager()
    
    var userIsOnboarded: Bool = false
    var userNotesHasPasscode: Bool = false
    var notePasscode: String? = nil
    var sortsTasksBy: SortTaskBy = .dueDate
    var sortNotesBy: SortNoteBy = .title
    
    func saveUserIsOnboarded (_ isOnboarded: Bool) {
        self.userIsOnboarded = isOnboarded
        if let encoded = try? JSONEncoder().encode(self.userIsOnboarded) {
            UserDefaults.standard.setValue(encoded, forKey: "userOnboardStatus")
        }
    }
    
    @discardableResult
    func userIsOnboarded (_ key: String = "userOnboardStatus") -> Bool? {
        guard let userOnboardedStatus = UserDefaults.standard.data(forKey: key) else {return nil}
        guard let decoded = try? JSONDecoder().decode(Bool.self, from: userOnboardedStatus) else {return nil}
        self.userIsOnboarded = decoded
        return self.userIsOnboarded
    }
    
        func saveTaskSortingOption(_ option: SortTaskBy) {
            self.sortsTasksBy = option
            if let encoded = try? JSONEncoder().encode(self.sortsTasksBy) {
                UserDefaults.standard.set(encoded, forKey: "taskSortingPreference")
            }
        }
    
        func getDecodedTaskSortingOption() {
            guard let sortingPreference = UserDefaults.standard.data(forKey: "taskSortingPreference") else {return}
            guard let decodedOption = try? JSONDecoder().decode(SortTaskBy.self, from: sortingPreference) else {return}
            self.sortsTasksBy = decodedOption
        }
    
        func saveNoteSortingOption(_ option: SortNoteBy) {
            self.sortNotesBy = option
            if let encoded = try? JSONEncoder().encode(self.sortNotesBy) {
                UserDefaults.standard.set(encoded, forKey: "noteSortingPreference")
            }
        }
    
        func getDecodedNoteSortingOption () {
            guard let sortingPreference = UserDefaults.standard.data(forKey: "noteSortingPreference") else {return}
            guard let decodedOption = try? JSONDecoder().decode(SortNoteBy.self, from: sortingPreference) else {return}
            self.sortNotesBy = decodedOption
        }
    
        func saveNotePasscode (_ passcode: String) {
            guard passcode.count > 0 else {return}
            UserDefaults.standard.set(passcode, forKey: "notesPasscode")
            self.notePasscode = passcode
            self.userNotesHasPasscode = true
        }
    
        func saveUserHasPasscode (hasPasscode: Bool) {
            self.userNotesHasPasscode = hasPasscode
            if let encoded = try? JSONEncoder().encode(self.userNotesHasPasscode) {
                UserDefaults.standard.set(encoded, forKey: "userHasPasscode")
            }
        }
    
        func getUserHasPasscodeStatus () -> Bool {
            guard let userPasscodeStatus = UserDefaults.standard.data(forKey: "userHasPasscode") else {return false}
            guard let decoded = try? JSONDecoder().decode(Bool.self, from: userPasscodeStatus) else {return false}
            self.userNotesHasPasscode = decoded
            if decoded == true {
                return true
            } else {
                return false
            }
        }
    
        func getNotesPasscode () {
            guard self.userNotesHasPasscode == true else {return}
            self.notePasscode = UserDefaults.standard.string(forKey: "notesPasscode")
        }
    
        func removePasscode () {
            self.notePasscode = nil
            self.userNotesHasPasscode = false
        }
    }



enum SortTaskBy : Codable {
    case title
    case dueDate
}

enum SortNoteBy : Codable {
    case creationDate
    case title
}

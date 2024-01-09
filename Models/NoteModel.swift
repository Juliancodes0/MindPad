//
//  NoteModel.swift
//  MindPad
//
//  Created by Julian Burton on 11/27/23.
//

import CoreData

struct NoteModel {
    let note: Note
    var id: NSManagedObjectID {
        return note.objectID
    }
    var creationDate: Date {
        return note.lastEditedDate ?? Date()
    }
    var noteText: String {
        return note.note ?? ""
    }
    var title: String {
        return note.title ?? ""
    }
}

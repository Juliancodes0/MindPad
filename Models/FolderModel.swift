//
//  FolderModel.swift
//  MindPad
//
//  Created by Julian Burton on 11/27/23.
//

import CoreData

struct FolderModel {
    let folder: Folder
    var id: NSManagedObjectID {
        return folder.objectID
    }
    var uniqueId: String {
        return folder.uniqueId ?? "No Unique ID"
    }
    var title: String {
        return folder.title ?? ""
    }
}

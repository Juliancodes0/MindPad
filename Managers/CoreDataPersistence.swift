//
//  CoreDataPersistence.swift
//  MindPad
//
//  Created by Julian Burton on 11/27/23.
//

import Foundation
import CoreData

class CoreDataPersistence {
    
    static let shared = CoreDataPersistence()
    
    let persistentContainer: NSPersistentContainer

    private init () {
        persistentContainer = NSPersistentContainer(name: "MindPadModel")
        persistentContainer.loadPersistentStores { description, error in
            if let error {
                print ("Error in section 1")
                fatalError("Failed to init CoreData \(error.localizedDescription)")
            }
        }
                
        let directories = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        print(directories[0])
    }
    
    func save () {
        do {
            try self.persistentContainer.viewContext.save()
        } catch {
            print("Error \(error.localizedDescription)")
        }
    }
    
    func getTaskById(_ id: NSManagedObjectID) -> TaskItem? {
        do {
            return try self.persistentContainer.viewContext.existingObject(with: id) as? TaskItem
        } catch {
            return nil
        }
    }
    
    func getFolderById(_ id: NSManagedObjectID) -> Folder? {
        do {
            return try self.persistentContainer.viewContext.existingObject(with: id) as? Folder
        } catch {
            return nil
        }
    }
    
    func getNoteById(_ id: NSManagedObjectID) -> Note? {
        do {
            return try persistentContainer.viewContext.existingObject(with: id) as? Note
        } catch {
            return nil
        }
    }
    
    func deleteAllTasks () {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TaskItem")
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try persistentContainer.viewContext.execute(batchDeleteRequest)
            save()
        } catch {
            persistentContainer.viewContext.rollback()
        }
    }
    
    func getAllNotes () -> [Note] {
        let fetchRequest: NSFetchRequest<Note> = Note.fetchRequest()
        do {
            return try persistentContainer.viewContext.fetch(fetchRequest)
        } catch {
            return []
        }
    }
    
    func getAllFolders () -> [Folder] {
        let fetchRequest: NSFetchRequest<Folder> = Folder.fetchRequest()
        do {
            return try persistentContainer.viewContext.fetch(fetchRequest)
        } catch {
            return []
        }
    }
    
    func deleteAllNotes () {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try persistentContainer.viewContext.execute(batchDeleteRequest)
            save()
        } catch {
            persistentContainer.viewContext.rollback()
        }
    }
    
    func deleteTaskItem(_ task: TaskItem) {
        persistentContainer.viewContext.delete(task)
        do {
            try persistentContainer.viewContext.save()
        } catch {
            persistentContainer.viewContext.rollback()
        }
    }
    
    func deleteFolder(_ folder: Folder) {
        persistentContainer.viewContext.delete(folder)
        do {
            try persistentContainer.viewContext.save()
        } catch {
            persistentContainer.viewContext.rollback()
        }
    }
    
    func getAllTasks () -> [TaskItem] {
        let fetchRequest: NSFetchRequest<TaskItem> = TaskItem.fetchRequest()
        do {
            return try persistentContainer.viewContext.fetch(fetchRequest)
        } catch {
            return []
        }
    }
    
    func deleteNote (_ note: Note) {
        persistentContainer.viewContext.delete(note)
        do {
            try persistentContainer.viewContext.save()
        } catch {
            persistentContainer.viewContext.rollback()
        }
    }
}

//
//  TaskModel.swift
//  MindPad
//
//  Created by Julian 沙 on 11/27/23.
//

import CoreData

struct TaskModel: Identifiable, Hashable {
    let task: TaskItem
    var id: NSManagedObjectID {
        return task.objectID
    }
    var taskTitle: String {
        return task.taskTitle ?? ""
    }
    var dueDate: Date? {
        return task.dueDate ?? nil
    }
    var isComplete: Double {
        return task.isComplete
    }
    var details: String? {
        return task.details ?? nil
    }
    
    static func == (lhs: TaskModel, rhs: TaskModel) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

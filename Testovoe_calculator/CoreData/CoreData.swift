//
//  CoreData.swift
//  e_legion_TT
//
//  Created by Oleg on 21.02.2022.
//

import UIKit
import CoreData

class CoreData {
    static let shared = CoreData()
    private init() {}
    
    var tasks: [Tasks] = []
    
    func saveTask(withHistoryTitle historyTitle: String, withResultTitle resultTitle: String) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        guard let entity = NSEntityDescription.entity(forEntityName: "Tasks", in: context) else {return}
        let taskObject = Tasks(entity: entity, insertInto: context)
        taskObject.historyData = historyTitle
        taskObject.resultData = resultTitle
        do {
            try context.save()
            tasks.append(taskObject)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    func deleteTask() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Tasks> = Tasks.fetchRequest()
        if let tasks = try? context.fetch(fetchRequest){
            for task in tasks{
                context.delete(task)
            }
        }
        do {
            try context.save()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    
}



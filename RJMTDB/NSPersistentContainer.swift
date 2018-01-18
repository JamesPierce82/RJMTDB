//
//  MOCViewControllerType.swift
//  RJMTDB
//
//  Created by Web on 2018-01-12.
//  Copyright © 2018 James Pierce. All rights reserved.
//

import CoreData

extension NSPersistentContainer {
    func saveContextIfNeeded() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

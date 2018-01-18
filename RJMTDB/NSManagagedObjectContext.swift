//
//  MOCViewControllerType.swift
//  RJMTDB
//
//  Created by Web on 2018-01-12.
//  Copyright © 2018 James Pierce. All rights reserved.
//

import CoreData

extension NSManagedObjectContext {
    func persist(block: @escaping ()->Void) {
        perform {
            block()
            
            do {
                try self.save()
            } catch {
                self.rollback()
            }
        }
    }
}

//
//  MOCViewControllerType.swift
//  RJMTDB
//
//  Created by Web on 2018-01-12.
//  Copyright © 2018 James Pierce. All rights reserved.
//

import CoreData

protocol MOCViewControllerType{
    var managedObjectContext: NSManagedObjectContext? {get set}
}

//
//  TVShow.swift
//  RJMTDB
//
//  Created by Web on 2018-01-12.
//  Copyright © 2018 James Pierce. All rights reserved.
//

import CoreData

extension TVShow{
    static func find(byName name: String, inContext moc: NSManagedObjectContext) -> TVShow? {
        let predicate = NSPredicate(format: "name ==[dc] %@", name)
        let request: NSFetchRequest<TVShow> = TVShow.fetchRequest()
        request.predicate = predicate
        
        guard let result = try? moc.fetch(request)
            else { return nil }
        
        return result.first
    }
    
    static func find(byName name: String, orCreateIn moc: NSManagedObjectContext) -> TVShow {
        guard let show = find(byName: name, inContext: moc)
            else { return TVShow(context: moc) }
        
        return show
    }
}

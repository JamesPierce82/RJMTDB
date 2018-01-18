//
//  Movie.swift
//  RJMTDB
//
//  Created by Web on 2018-01-12.
//  Copyright © 2018 James Pierce. All rights reserved.
//

import CoreData

extension Movie{
    static func find(byName name: String, inContext moc: NSManagedObjectContext) -> Movie?{
        let predicate = NSPredicate(format: "name ==[dc] %@", name)
        let request: NSFetchRequest<Movie> = Movie.fetchRequest()

        
        request.predicate = predicate
        
        guard let result = try? moc.fetch(request) else {return nil}
        
        return result.first
    }
    
    static func find(byName name: String, orCreatIn moc: NSManagedObjectContext) -> Movie{
        guard let movie = find(byName: name, inContext: moc) else {return Movie(context: moc)}
        return movie
    }
}

//
//  IndexingFactory.swift
//  RJMTDB
//
//  Created by Web on 2018-01-16.
//  Copyright © 2018 James Pierce. All rights reserved.
//

import Foundation
import CoreSpotlight

struct IndexingFactory{
    enum ActivityType: String{
        case openTab = "com.RJMTDB.opentab"
        case movieDetailView = "com.RJMTDB.movieDetailView"
        case tvShowDetailView = "com.RJMTDB.tvShowDetailView"
    }
    
    enum DomainIdentifier: String{
        case movie = "Movie"
        case tvShow = "TVShow"
    }
    
    static func activity (withType type: ActivityType, name: String, makePublic: Bool) -> NSUserActivity{
        let userActivity = NSUserActivity(activityType: type.rawValue)
        userActivity.title = name
        userActivity.isEligibleForSearch = true
        userActivity.isEligibleForPublicIndexing = makePublic
        
        return userActivity
    }
    
    static func activity(forMovie movie: Movie) ->NSUserActivity{
        let activityItem = activity(withType: .movieDetailView, name: movie.name!, makePublic: false)
        
        let attributes = searchableAttributes(forMovie: movie)
        attributes.domainIdentifier = DomainIdentifier.movie.rawValue
        activityItem.contentAttributeSet = attributes
        
        return activityItem
        
    }
    static func activity(forTVShow show: TVShow) ->NSUserActivity{
        let activityItem = activity(withType: .tvShowDetailView, name: show.name!, makePublic: false)
        
        let attributes = searchableAttributes(forTVShow: show)
        attributes.domainIdentifier = DomainIdentifier.tvShow.rawValue
        activityItem.contentAttributeSet = attributes
        
        return activityItem
        
    }
    
    static func searchableAttributes(forMovie movie: Movie) -> CSSearchableItemAttributeSet{
        do{
            try movie.managedObjectContext?.obtainPermanentIDs(for: [movie])
        }
        catch{
            print("could not obtain permanent movie id")
        }
        
        let attributes = CSSearchableItemAttributeSet(itemContentType: ActivityType.movieDetailView.rawValue)
        
        attributes.title = movie.name
        
        //attributes.rating = NSNumber(value: movie.rating)
        attributes.identifier = "\(movie.objectID.uriRepresentation().absoluteString)"
        attributes.relatedUniqueIdentifier = "\(movie.objectID.uriRepresentation().absoluteString)"
        return attributes
    }
    
    static func searchableAttributes(forTVShow show: TVShow) -> CSSearchableItemAttributeSet{
        do{
            try show.managedObjectContext?.obtainPermanentIDs(for: [show])
        }
        catch{
            print("could not obtain permanent show id")
        }
        
        let attributes = CSSearchableItemAttributeSet(itemContentType: ActivityType.tvShowDetailView.rawValue)
        
        attributes.title = show.name
        
        attributes.rating = NSNumber(value: show.rating)
        attributes.identifier = "\(show.objectID.uriRepresentation().absoluteString)"
        attributes.relatedUniqueIdentifier = "\(show.objectID.uriRepresentation().absoluteString)"
        return attributes
    }
    
    static func searchableItem(forMovie movie: Movie) -> CSSearchableItem {
        let attributes = searchableAttributes(forMovie: movie)
        
        return searchableItem(withIdentifier: "\(movie.objectID.uriRepresentation().absoluteString)", domain: .movie, attributes: attributes)
    }
    
    private static func searchableItem(withIdentifier identifier: String, domain: DomainIdentifier, attributes: CSSearchableItemAttributeSet) -> CSSearchableItem {
        let item = CSSearchableItem(uniqueIdentifier: identifier, domainIdentifier: domain.rawValue, attributeSet: attributes)
        
        return item
    }
    
    static func searchableItem(forTVShow tvShow: TVShow) -> CSSearchableItem {
        let attributes = searchableAttributes(forTVShow: tvShow)
        
        return searchableItem(withIdentifier: "\(tvShow.objectID.uriRepresentation().absoluteString)", domain: .tvShow, attributes: attributes)
    }
    
}

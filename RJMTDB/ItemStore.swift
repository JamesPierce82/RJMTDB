//
//  ItemStore.swift
//  HomePwner
//
//  Created by web on 2017-03-03.
//  Copyright © 2017 JamesPierce.ca. All rights reserved.
//

//import Foundation
import UIKit

class MovieStore {
    
    var allMovies = [Movie]()
    
    func removeItem(_ item: Movie) {
        if let index = allMovies.index(of: item) {
            allMovies.remove(at: index)
        }
    }
    
    
    
}

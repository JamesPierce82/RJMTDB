//
//  SearchHelper.swift
//  RJMTDB
//
//  Created by Web on 2018-01-12.
//  Copyright © 2018 James Pierce. All rights reserved.
//

import Foundation

struct SearchHelper {
    
    typealias MovieDBCallback = (Int?, Double?, String?, String?, String?) -> Void
    typealias TVShowDBCallback = (Int?, Double?, String?, String?, String?) -> Void
    static let apiKey = "2c9f16a761d7943ea2d6935cf3a65f98"
    
    enum Endpoint {
        case searchMovie
        case searchShow
        case movieById(Int64)
        case showById(Int64)
        
        var urlString: String {
            let baseUrl = "https://api.themoviedb.org/3/"
            
            switch self {
            case .searchMovie:
                var urlString = "\(baseUrl)search/movie"
                urlString = urlString.appending("?api_key=\(SearchHelper.apiKey)")
                return urlString
            case .searchShow:
                var urlString = "\(baseUrl)search/tv"
                urlString = urlString.appending("?api_key=\(SearchHelper.apiKey)")
                return urlString
            case let .movieById(movieId):
                var urlString = "\(baseUrl)movie\(movieId)"
                urlString = urlString.appending("?api_key=\(SearchHelper.apiKey)")
                return urlString
            case let .showById(showId):
                var urlString = "\(baseUrl)tv\(showId)"
                urlString = urlString.appending("?api_key=\(SearchHelper.apiKey)")
                return urlString
            }
        }
    }
    
    
    // MOVIE FETCH RATING
    // This guard passes - First guard
    func fetchRating(forMovie movie: String, callback: @escaping MovieDBCallback) {
        let searchUrl = url(forMovie: movie)
        let extractData: DataExtractionCallback = { json in
            guard let results = json["results"] as? [[String:AnyObject]],
                results.count > 0,
                let popularity = results[0]["vote_average"] as? Double,
                let id = results[0]["id"] as? Int,
                let overview = results[0]["overview"] as? String,
                let poster_path = results[0]["poster_path"] as? String,
                let release_date = results[0]["release_date"] as? String
                else {return (nil, nil, nil, nil, nil)}
            
            print(results[0])
            print(poster_path)
            return (id, popularity, overview, poster_path, release_date)
        }
        
        fetchRating(fromUrl: searchUrl, extractData: extractData, callback: callback)
    }
    
    func fetchRating(forMovieId id: Int64, callback: @escaping MovieDBCallback) {
        let movieUrl = url(forMovieId: id)
        let extractData: DataExtractionCallback = { json in
            guard let popularity = json["vote_average"] as? Double,
                let id = json["id"] as? Int,
                let overview = json["overview"] as? String,
                let poster_path = json["poster_path"] as? String,
                let release_date = json["release_date"] as? String
                else { return (nil, nil, nil, nil, nil) }
            return (id, popularity, overview, poster_path, release_date)
        }
        
        fetchRating(fromUrl: movieUrl, extractData: extractData, callback: callback)
    }
    
    typealias JSON = [String: Any]
    typealias returnInfo = (id: Int?, rating: Double?, overview: String?, poster_path: String?, release_date: String?)
    typealias DataExtractionCallback = (JSON) -> returnInfo
    
    // Second guard Guard 1,2,3 passes
    private func fetchRating(fromUrl url: URL?, extractData: @escaping DataExtractionCallback, callback: @escaping MovieDBCallback) {
        guard let url = url else {
            callback(nil, nil, nil, nil, nil)
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            var rating: Double? = nil
            var remoteId: Int? = nil
            var overview: String? = nil
            var poster_path: String? = nil
            var release_date: String? = nil
            
            defer {
                callback(remoteId, rating, overview, poster_path, release_date)
            }
            
            guard error == nil
                else { return }
            
            guard let data = data,
                let json = try? JSONSerialization.jsonObject(with: data, options: [])
                else { return }
            
            let resultingData = extractData(json as! [String: Any])
            rating = resultingData.rating
            remoteId = resultingData.id
            overview = resultingData.overview
            poster_path = resultingData.poster_path
            release_date = resultingData.release_date
            
        }
        
        task.resume()
    }
    
    
    //TVSHOW FETCH RATING
    func fetchRating(forTVShow tvShow: String, callback: @escaping TVShowDBCallback) {
        let searchUrl = url(forShow: tvShow)
        let extractData: DataExtractionCallback = { json in
            guard let results = json["results"] as? [[String:AnyObject]],
                results.count > 0,
                let popularity = results[0]["vote_average"] as? Double,
                let id = results[0]["id"] as? Int,
                let overview = results[0]["overview"] as? String,
                let poster_path = results[0]["poster_path"] as? String,
                let release_date = results[0]["first_air_date"] as? String
                else {return (nil, nil, nil, nil, nil)}
            
            print(results[0])
            print(poster_path)
            return (id, popularity, overview, poster_path, release_date)
        }
        
        fetchRating(fromUrl: searchUrl, extractData: extractData, callback: callback)
    }
    
    func fetchRating(forTVShowId id: Int64, callback: @escaping TVShowDBCallback) {
        let tvShowUrl = url(forShowId: id)
        let extractData: DataExtractionCallback = { json in
            guard let popularity = json["vote_average"] as? Double,
                let id = json["id"] as? Int,
                let overview = json["overview"] as? String,
                let poster_path = json["poster_path"] as? String,
                let release_date = json["first_air_date"] as? String
                else { return (nil, nil, nil, nil, nil) }
            return (id, popularity, overview, poster_path, release_date)
        }
        
        fetchRating(fromUrl: tvShowUrl, extractData: extractData, callback: callback)
    }
    
    
    
    // URL CREATION
    func url(forMovie movie: String) -> URL? {
        guard let escapedMovie = movie.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
            else { return nil }
        
        var urlString = Endpoint.searchMovie.urlString
        urlString = urlString.appending("&query=\(escapedMovie)")
        
        return URL(string: urlString)
    }
    
    func url(forMovieId id: Int64) -> URL? {
        let urlString = Endpoint.movieById(id).urlString
        return URL(string: urlString)
    }
    
    func url(forShow show: String) -> URL? {
        guard let escapedShow = show.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
            else{ return nil }
        
        var urlString = Endpoint.searchShow.urlString
        urlString = urlString.appending("&query=\(escapedShow)")
        
        return URL(string: urlString)
    }
    
    func url(forShowId id: Int64) -> URL? {
        let urlString = Endpoint.showById(id).urlString
        return URL(string: urlString)
    }
    
}

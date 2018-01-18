//
//  SearchViewController.swift
//  RJMTDB
//
//  Created by James Pierce on 2017-12-27.
//  Copyright © 2017 James Pierce. All rights reserved.
//

import UIKit
import CoreData
import CoreSpotlight

class SearchViewController: UIViewController, SearchDelegate, MOCViewControllerType {
    
    @IBOutlet var searchField: UITextField!
    @IBOutlet var searchbutton: UIButton!
    @IBOutlet var optionSwitch: UISwitch!
    
    @IBOutlet weak var searchImage: UIImageView!
    @IBOutlet weak var searchName: UILabel!
    
    
    var managedObjectContext: NSManagedObjectContext?
    
    
    @IBAction func ChangeOption(_ sender: Any) {
        
        if(optionSwitch.isOn) {
            SearchViewController.option = "movie"
        } else {
            SearchViewController.option = "show"
        }
        
    }
    
    static var option: String = "movie"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
        
    }
    
    func getImage(_ urlString: String) {
        let imageURL = URL(string: urlString)!
        let task = URLSession.shared.dataTask(with: imageURL) {
            (data, respose, error) in
            if error == nil {
                let downloadImage = UIImage(data: data!)
                
                OperationQueue.main.addOperation {
                    self.searchImage.image = nil
                    self.searchImage.image = downloadImage
                }
            }
        }
        task.resume()
    }
    
    @IBAction func search() {
        searchFor(withName: searchField.text ?? "")
        dismiss(animated: true, completion: nil)
    }
    
    
    
    func searchFor(withName name: String) {
        guard let moc = managedObjectContext else { return }
        moc.persist {
            if(SearchViewController.option == "show"){
                let show = TVShow.find(byName: name, orCreateIn: moc)
                if show.name == nil || show.name?.isEmpty == true {
                    show.name = name
                }
                
                let helper = SearchHelper()
                helper.fetchRating(forTVShow: name) { remoteId, rating, overview, poster_path, first_air_date in
                    guard let rating = rating,
                        let remoteId = remoteId,
                        let overview = overview,
                        let poster_path = poster_path,
                        let release_date = first_air_date
                        else {
                            OperationQueue.main.addOperation {
                                self.searchImage.image = #imageLiteral(resourceName: "error")
                            }
                            self.searchName.text = "Nothing has been added!"
                            return }
                    
                    // We have the URL - I have to get the poster image
                    let imageURLString = "http://image.tmdb.org/t/p/w300\(poster_path)"
                    
                    // Make request for the image
                    self.getImage(imageURLString)
                    self.searchName.text = "\(show.name!) has been added!"
                    
                    
                    moc.persist {
                        show.rating = rating
                        show.remoteId = Int64(remoteId)
                        show.tvShowDescription = overview
                        show.posterPath = poster_path
                        show.releaseDate = release_date
                        
                    }
                    
                }
            }
            else if(SearchViewController.option == "movie"){
                let movie = Movie.find(byName: name, orCreatIn: moc)
                if movie.name == nil || movie.name?.isEmpty == true {
                    movie.name = name
                }
                
                let helper = SearchHelper()
                helper.fetchRating(forMovie: name) { remoteId, rating, overview, poster_path, release_date in
                    guard let rating = rating,
                        let remoteId = remoteId,
                        let overview = overview,
                        let poster_path = poster_path,
                        let release_date = release_date
                        else {
                            OperationQueue.main.addOperation {
                                self.searchImage.image = #imageLiteral(resourceName: "error")
                            }
                            self.searchName.text = "Nothing has been added!"
                            return }
                    
                        // We have the URL - I have to get the poster image
                        let imageURLString = "http://image.tmdb.org/t/p/w300\(poster_path)"
                        
                        // Make request for the image
                        self.getImage(imageURLString)
                        self.searchName.text = "\(movie.name!) has been added!"
                    
                    moc.persist {
                        movie.popularity = rating
                        movie.remoteId = Int64(remoteId)
                        movie.overview = overview
                        movie.poster_path = poster_path
                        movie.release_date = release_date

                    }
                }
            }
        }
        
        
    }
}

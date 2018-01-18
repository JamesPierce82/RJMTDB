//
//  MovieViewController.swift
//  RJMTDB
//
//  Created by Web on 2018-01-12.
//  Copyright © 2018 James Pierce. All rights reserved.
//

import UIKit
import CoreData

class MovieDetailViewController: UIViewController, MOCViewControllerType {
    @IBOutlet var MovieNameLabel: UILabel!
    @IBOutlet var MovieImageView: UIImageView!
    @IBOutlet var MovieDescriptionLabel: UILabel!
    @IBOutlet var MovieReleaseLabel: UILabel!
    @IBOutlet var MovieRatingLabel: UILabel!
    
    var managedObjectContext: NSManagedObjectContext?
    var movie: Movie?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let movie = self.movie
        
        MovieNameLabel.text = movie!.name
        MovieDescriptionLabel.text = movie!.overview
        MovieReleaseLabel.text = movie!.release_date
        MovieRatingLabel.text = "\(movie!.popularity) / 10"
        
        if(movie!.poster_path) != nil{
            // We have the URL - I have to get the poster image
            var imageURLString = "http://image.tmdb.org/t/p/w300\(movie!.poster_path!)"
            
            // Make request for the image
            self.getImage(imageURLString)
        } else {
            OperationQueue.main.addOperation {
                self.MovieImageView.image = #imageLiteral(resourceName: "error")
            }
        }
        
        
        
        
        
    }
    
    func getImage(_ urlString: String) {
        let imageURL = URL(string: urlString)!
        let task = URLSession.shared.dataTask(with: imageURL) {
            (data, respose, error) in
            if error == nil {
                let downloadImage = UIImage(data: data!)
                
                OperationQueue.main.addOperation {
                    self.MovieImageView.image = downloadImage
                }
            }
        }
        task.resume()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super .viewDidAppear(animated)
        
        guard let movie = self.movie else{return}
        
        self.userActivity = IndexingFactory.activity(forMovie: movie)
        self.userActivity?.becomeCurrent()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

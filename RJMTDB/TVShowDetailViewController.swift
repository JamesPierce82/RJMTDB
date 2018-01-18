//
//  TVShowViewController.swift
//  RJMTDB
//
//  Created by Web on 2018-01-12.
//  Copyright © 2018 James Pierce. All rights reserved.
//

import UIKit
import CoreData

class TVShowDetailViewController: UIViewController, MOCViewControllerType {
    @IBOutlet var TVShowNameLabel: UILabel!
    @IBOutlet var TVShowImage: UIImageView!
    @IBOutlet var TVShowDescriptionLabel: UILabel!
    @IBOutlet var TVShowRuntimeLabel: UILabel!
    @IBOutlet var TVShowRatingLabel: UILabel!

    var managedObjectContext: NSManagedObjectContext?
    var tvShow: TVShow?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tvShow = self.tvShow
        
        TVShowNameLabel.text = tvShow?.name
        TVShowDescriptionLabel.text = tvShow?.tvShowDescription
        TVShowRuntimeLabel.text = tvShow?.releaseDate
        TVShowRatingLabel.text = "\(tvShow!.rating)"
        
        if(tvShow!.posterPath) != nil{
            // We have the URL - I have to get the poster image
            var imageURLString = "http://image.tmdb.org/t/p/w300\(tvShow!.posterPath!)"
            
            // Make request for the image
            self.getImage(imageURLString)
        } else {
            OperationQueue.main.addOperation {
                self.TVShowImage.image = #imageLiteral(resourceName: "error")
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
                    self.TVShowImage.image = downloadImage
                }
            }
        }
        task.resume()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super .viewDidAppear(animated)
        
        guard let show = self.tvShow else{return}
        
        self.userActivity = IndexingFactory.activity(forTVShow: show)
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

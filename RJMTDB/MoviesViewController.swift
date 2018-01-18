//
//  ViewController.swift
//  RJMTDB
//
//  Created by James Pierce on 2017-12-27.
//  Copyright © 2017 James Pierce. All rights reserved.
//

import UIKit
import CoreData
import CoreSpotlight

// These are the image resource links for the tab bar icons
// https://icons8.com/icon/2998/movie
// https://icons8.com/icon/2998/tv-show
// https://icons8.com/icon/7695/search-filled
// Do not have a working link for the about icon, but it comes from icons8 as well
// TV and Play buttons designed by Smashicons from Flaticon
// The above from Flaticon used to make the app icon

class MoviesViewController: UIViewController, MOCViewControllerType, NSFetchedResultsControllerDelegate, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var MoviesListTableView: UITableView!
    @IBOutlet var MoviesWatchedLabel: UILabel!
    @IBOutlet var tableView: UITableView!
    
    var managedObjectContext: NSManagedObjectContext?
    var fetchedResultsController: NSFetchedResultsController<Movie>?
    var movie: Movie?

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let moc = managedObjectContext else {
            return}
        
        
        let center = NotificationCenter.default
        center.addObserver(self,
                           selector: #selector(self.managedObjectContextDidChange(notification:)),
                           name: Notification.Name.NSManagedObjectContextObjectsDidChange,
                           object: nil)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        let alphaSort: NSSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [alphaSort]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultsController?.delegate = self
        
        
        do{
            try fetchedResultsController?.performFetch()
            MoviesWatchedLabel.text = "\(fetchedResultsController?.fetchedObjects?.count ?? 0) Movies"
            
        }
        catch{
            print("fetch request failed")
        }
        tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //self.MoviesListTableView.reloadData()
        self.tableView.reloadData()
        
        MoviesWatchedLabel.text = "\(fetchedResultsController?.fetchedObjects?.count ?? 0) Movies"
    }
    
    deinit{
        let center = NotificationCenter.default
        center.removeObserver(self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        guard let selectedIndex = MoviesListTableView.indexPathForSelectedRow else{return}
        
        MoviesListTableView.deselectRow(at: selectedIndex, animated: true)
        
        if let movieVC = segue.destination as? MovieDetailViewController, let movie = fetchedResultsController?.object(at: selectedIndex){
            movieVC.managedObjectContext = managedObjectContext
            movieVC.movie = movie
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}

extension MoviesViewController{
    func numberOfSections(in tableView: UITableView) -> Int{
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return fetchedResultsController?.fetchedObjects?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell")
            else { fatalError("Wrong cell identifier requested") }
        
        guard let movie = fetchedResultsController?.object(at: indexPath) else{return cell}
        
        cell.textLabel?.text = movie.name
        cell.detailTextLabel?.text = "\(movie.popularity)"
        
        return cell
    }
}

extension MoviesViewController{
    func managedObjectContextDidChange(notification: NSNotification){
        MoviesListTableView.reloadData()
        guard let userInfo = notification.userInfo
            else {return}
        
        if let updatedObjects = userInfo[NSUpdatedObjectsKey] as? Set<Movie>,
            let movie = self.movie, updatedObjects.contains(movie){
            let item = IndexingFactory.searchableItem(forMovie: movie)
            CSSearchableIndex.default().indexSearchableItems([item], completionHandler: nil)
            tableView.reloadData()
            MoviesListTableView.reloadData()
        }
    }
}
extension MoviesViewController{
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            guard let insertIndex = newIndexPath
                else { return }
            tableView.insertRows(at: [insertIndex],
                                 with: .automatic)
        case .delete:
            guard let deleteIndex = indexPath
                else { return }
            tableView.deleteRows(at: [deleteIndex],
                                 with: .automatic)
        case .move:
            guard let fromIndex = indexPath,
                let toIndex = newIndexPath
                else { return }
            tableView.moveRow(at: fromIndex, to: toIndex)
        case .update:
            guard let updateIndex = indexPath
                else { return }
            tableView.reloadRows(at: [updateIndex], with: .automatic)
        }
    }
    
}



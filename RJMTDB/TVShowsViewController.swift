//
//  TVShowsViewController.swift
//  RJMTDB
//
//  Created by James Pierce on 2017-12-27.
//  Copyright © 2017 James Pierce. All rights reserved.
//

import UIKit
import CoreData
import CoreSpotlight

class TVShowsViewController: UIViewController, MOCViewControllerType, NSFetchedResultsControllerDelegate, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var TVShowsListTableView: UITableView!
    @IBOutlet var ShowsWatchedLabel: UILabel!
    @IBOutlet var tableView: UITableView!
    
    var managedObjectContext: NSManagedObjectContext?
    var fetchedResultsController: NSFetchedResultsController<TVShow>?
    var tvShow: TVShow?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let moc = managedObjectContext else {return}
        
        let center = NotificationCenter.default
        center.addObserver(self,
                           selector: #selector(self.managedObjectContextDidChange(notification:)),
                           name: Notification.Name.NSManagedObjectContextObjectsDidChange,
                           object: nil)
        
        tableView.delegate = self
        tableView.dataSource = self

        
        let fetchRequest: NSFetchRequest<TVShow> = TVShow.fetchRequest()
        let alphaSort: NSSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [alphaSort]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultsController?.delegate = self
        
        
        
        do{
            try fetchedResultsController?.performFetch()
            ShowsWatchedLabel.text = "\(fetchedResultsController?.fetchedObjects?.count ?? 0) Shows"
        }
        catch{
            print("fetch request failed")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //self.MoviesListTableView.reloadData()
        self.tableView.reloadData()
        
        ShowsWatchedLabel.text = "\(fetchedResultsController?.fetchedObjects?.count ?? 0) Shows"
    }
    
    deinit{
        let center = NotificationCenter.default
        center.removeObserver(self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        guard let selectedIndex = TVShowsListTableView.indexPathForSelectedRow else{return}
        
        TVShowsListTableView.deselectRow(at: selectedIndex, animated: true)
        
        if let showVC = segue.destination as? TVShowDetailViewController, let tvShow = fetchedResultsController?.object(at: selectedIndex){
            showVC.managedObjectContext = managedObjectContext
            showVC.tvShow = tvShow
        }
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}


extension TVShowsViewController{
    func numberOfSections(in tableView: UITableView) -> Int{
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return fetchedResultsController?.fetchedObjects?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TVShowCell")
            else { fatalError("Wrong cell identifier requested") }
        
        guard let show = fetchedResultsController?.object(at: indexPath) else{return cell}
        
        cell.textLabel?.text = show.name
        cell.detailTextLabel?.text = "\(show.rating)"
        
        return cell
    }
}

extension TVShowsViewController{
    func managedObjectContextDidChange(notification: NSNotification){
        tableView.reloadData()
        guard let userInfo = notification.userInfo
            else {return}
        
        if let updatedObjects = userInfo[NSUpdatedObjectsKey] as? Set<TVShow>,
            let tvShow = self.tvShow, updatedObjects.contains(tvShow){
            let item = IndexingFactory.searchableItem(forTVShow: tvShow)
            CSSearchableIndex.default().indexSearchableItems([item], completionHandler: nil)
            tableView.reloadData()
            tableView.reloadData()
        }
    }
}
extension TVShowsViewController{
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


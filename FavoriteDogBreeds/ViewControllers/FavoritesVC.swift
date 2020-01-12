//
//  SecondViewController.swift
//  FavoriteDogBreeds
//
//  Created by Jordan Leeper on 12/6/19.
//  Copyright © 2019 Jordan Leeper. All rights reserved.
//

import UIKit
import CoreData

class FavoritesVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var favorites: [Favorite] = []
    
    // MARK: viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getFavorites()
    }

    func getFavorites() {
        let favoritesRequest: NSFetchRequest<Favorite> = Favorite.fetchRequest()
        favoritesRequest.sortDescriptors = [NSSortDescriptor(key: "label", ascending: true)]
        
        let context = AppDelegate.viewContext
        let favorites = try? context.fetch(favoritesRequest)
        
        if favorites?.count ?? 0 > 0 {
            self.favorites = favorites!
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
}

// MARK: TableView Extension
extension FavoritesVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.favorites.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dog = self.favorites[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "DogBreedTableViewCell") as! DogBreedTableCell
        
        cell.setData(label: dog.label!)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let fav = self.favorites[indexPath.row]
        let dog = Dog(label: fav.label!, breed: fav.breed!, subBreed: fav.subBreed)
        
        let detailVC = storyboard?.instantiateViewController(identifier: "BreedDetailVC") as! BreedDetailVC
        detailVC.selectedDogBreed = dog
        detailVC.favorite = fav
        
        self.navigationController!.pushViewController(detailVC, animated: true)
    }
}




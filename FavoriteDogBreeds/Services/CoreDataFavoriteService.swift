//
//  CoreDataFavoriteService.swift
//  FavoriteDogBreeds
//
//  Created by Jordan Leeper on 1/19/20.
//  Copyright © 2020 Jordan Leeper. All rights reserved.
//

import Foundation
import CoreData

class CoreDataFavoriteService {
    
    static let instance = CoreDataFavoriteService()
    let context = AppDelegate.viewContext
    
    func fetchFavorites(completion: (_ favorites: [Favorite]?) -> Void) {
        let favoritesRequest: NSFetchRequest<Favorite> = Favorite.fetchRequest()
        favoritesRequest.sortDescriptors = [NSSortDescriptor(key: "label", ascending: true)]
        
        let favorites = try? context.fetch(favoritesRequest)
        
        if let breedFavorites = favorites {
            if breedFavorites.count > 0 {
                completion(breedFavorites)
            } else {
                completion([])
            }
        } else {
            completion([])
        }
    }
    
    func fetchFavoriteBy(dog: Dog) -> Favorite? {
        let favoritesRequest: NSFetchRequest<Favorite> = Favorite.fetchRequest()
        favoritesRequest.sortDescriptors = [NSSortDescriptor(key: "label", ascending: true)]
        favoritesRequest.predicate = NSPredicate(format: "label == %@", dog.label)
        
        let favorites = try? context.fetch(favoritesRequest)
        
        if favorites?.count ?? 0 > 0 {
            return favorites![0]
        }
        return nil
    }
    
    func addFavorite(dog: Dog) -> Favorite {
        let favorite = Favorite(context: context)
        favorite.label = dog.label
        favorite.breed = dog.breed
        favorite.subBreed = dog.subBreed
        
        do {
            try context.save()
        } catch let error as NSError {
            print(error)
        }
        
        return favorite
    }
    
    func deleteFavorite(favorite: Favorite) {
        context.delete(favorite)
        
        do {
            try context.save()
        } catch let error as NSError {
            print(error)
        }
    }
}

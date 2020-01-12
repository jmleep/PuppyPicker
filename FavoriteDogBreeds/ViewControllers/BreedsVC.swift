//
//  FirstViewController.swift
//  FavoriteDogBreeds
//
//  Created by Jordan Leeper on 12/6/19.
//  Copyright © 2019 Jordan Leeper. All rights reserved.
//

import UIKit
import CoreData

class BreedsVC: UIViewController {
    
    // MARK: outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    // MARK: vars
    var dogBreeds: [Dog] = [Dog]()
    var filteredBreeds: [Dog] = [Dog]()
    var isSearching = false
    var spinner = UIActivityIndicatorView(style: .large)
    var favorites: [Favorite] = []
    
    // MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.tableHeaderView = self.searchBar
        
        setupSpinner()
        setupSearchBar()
        fetchDogBreeds()
    }
    
    // MARK: viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let favoritesRequest: NSFetchRequest<Favorite> = Favorite.fetchRequest()
        favoritesRequest.sortDescriptors = [NSSortDescriptor(key: "label", ascending: true)]
        
        let context = AppDelegate.viewContext
        let favorites = try? context.fetch(favoritesRequest)
        
        if favorites != nil && favorites!.count > 0 {            
            self.favorites = favorites!
        }
    }
    
    func setupSearchBar() {
        self.searchBar.delegate = self
    }
    
    func setupSpinner() {
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()
        view.addSubview(spinner)

        spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    // MARK: fetchDogBreeds
    func fetchDogBreeds() {
        let dogBreedsURL = URL(string: "https://dog.ceo/api/breeds/list/all")!
        
        let task = URLSession.shared.dataTask(with: dogBreedsURL) { (data, response, error) in
            guard let data = data else { return }
            let decoder = JSONDecoder()
            
            do {
                let breeds = try decoder.decode(DogBreedsResponse.self, from: data)
                
                /*
                 Example response from API (usually much longer list):
                 ["beagle": [], "ridgeback": ["rhodesian"], "terrier": ["american", "australian", "bedlington", "border", "dandie", "fox", "irish", "kerryblue", "lakeland", "norfolk", "norwich", "patterdale", "russell", "scottish", "sealyham", "silky", "tibetan", "toy", "westhighland", "wheaten", "yorkshire"]]
                 */
                
                var tempDogArray = [Dog]()
                
                for breed in breeds.message {
                    if (breed.value.isEmpty) {
                        tempDogArray.append(Dog(label: breed.key.firstUppercased, breed: breed.key))
                    } else {
                        for subBreed in breed.value {
                            tempDogArray.append(Dog(label: "\(subBreed.firstUppercased) \(breed.key.firstUppercased)", breed: breed.key, subBreed: subBreed))
                        }
                    }
                }
                
                self.dogBreeds = tempDogArray.sorted { (dog1, dog2) -> Bool in
                    dog1.label < dog2.label
                }
                
                DispatchQueue.main.async {
                    self.spinner.stopAnimating()
                    self.tableView.reloadData()
                }
                
            } catch {
                print(error)
            }
        }
        task.resume()
    }
}

// MARK: TableView Extension
extension BreedsVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isSearching {
            return self.filteredBreeds.count
        }
        
        return self.dogBreeds.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var dog: Dog
        
        if isSearching {
            dog = self.filteredBreeds[indexPath.row]
        } else {
            dog = self.dogBreeds[indexPath.row]
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "DogBreedTableViewCell") as! DogBreedTableCell
        
        cell.setData(label: dog.label)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var dog: Dog
        
        if isSearching {
            dog = self.filteredBreeds[indexPath.row]
            self.searchBar.endEditing(true)
        } else {
            dog = self.dogBreeds[indexPath.row]
        }
        
        let favorite = determineIsFavorite(dog: dog)
        
        let detailVC = storyboard?.instantiateViewController(identifier: "BreedDetailVC") as! BreedDetailVC
        detailVC.selectedDogBreed = dog
        detailVC.favorite = favorite
        
        self.navigationController!.pushViewController(detailVC, animated: true)
    }
    
    func determineIsFavorite(dog: Dog) -> Favorite? {
        let favoritesRequest: NSFetchRequest<Favorite> = Favorite.fetchRequest()
        favoritesRequest.sortDescriptors = [NSSortDescriptor(key: "label", ascending: true)]
        favoritesRequest.predicate = NSPredicate(format: "label == %@", dog.label)
        
        let context = AppDelegate.viewContext
        let favorites = try? context.fetch(favoritesRequest)
        
        if favorites?.count ?? 0 > 0 {
            return favorites![0]
        }
        return nil
    }
}

extension BreedsVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == nil || searchBar.text == "" {
            self.isSearching = false
            
            searchBar.endEditing(true)
        } else {
            self.isSearching = true
            
            self.filteredBreeds = dogBreeds.filter({ (dog) -> Bool in
                if dog.label.contains(searchText) {
                    return true
                }
                return false
            })
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.resignFirstResponder()
    }
}

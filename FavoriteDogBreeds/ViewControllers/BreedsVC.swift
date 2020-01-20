//
//  FirstViewController.swift
//  FavoriteDogBreeds
//
//  Created by Jordan Leeper on 12/6/19.
//  Copyright © 2019 Jordan Leeper. All rights reserved.
//

import UIKit
import GoogleMobileAds

class BreedsVC: UIViewController {
    
    // MARK: outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var adBanner: GADBannerView!
    
    // MARK: vars
    fileprivate var dogBreeds: [Dog] = [Dog]()
    fileprivate var filteredBreeds: [Dog] = [Dog]()
    fileprivate var isSearching = false
    private var spinner = UIActivityIndicatorView(style: .large)
    fileprivate var activeRow = 0
    
    // MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.tableHeaderView = self.searchBar
          
        setupAdBanner()
        setupSpinner()
        setupSearchBar()
        fetchDogBreeds()
    }
    
    func setupAdBanner() {
        adBanner.rootViewController = self
        adBanner.adUnitID = Environment.BREED_VC_BANNER_AD_ID
        adBanner.load(GADRequest())
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
        DogAPIService.instance.fetchDogBreeds { (breeds, error) in
            if let dogs = breeds {
                DispatchQueue.main.async {
                    self.dogBreeds = dogs
                    self.spinner.stopAnimating()
                    self.tableView.reloadData()
                }
            } else {
                print(error!)
            }
        }
    }
    
    @objc func handleGesture(_ sender: UISwipeGestureRecognizer) {
        
        if sender.direction == UISwipeGestureRecognizer.Direction.right {
            if self.activeRow == 0 {
                return
            }
            
            self.activeRow -= 1
            
            let detailVC = configureDetailViewFor(row: self.activeRow)
            let VCs = self.navigationController!.viewControllers
            let editedVCs = [VCs[0], detailVC]

            let transition: CATransition = CATransition()
            transition.duration = 0.3
            transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            transition.type = CATransitionType.push
            transition.subtype = CATransitionSubtype.fromLeft
            self.navigationController!.view.layer.add(transition, forKey: kCATransition)
            self.navigationController!.setViewControllers(editedVCs, animated: true)
            
        } else if sender.direction == UISwipeGestureRecognizer.Direction.left {
            var totalNumBreeds = dogBreeds.count - 1
            
            if isSearching && filteredBreeds.count <= 1 {
                return
            } else if isSearching && filteredBreeds.count > 1 {
                totalNumBreeds = filteredBreeds.count - 1
            }
            
            if (self.activeRow >= totalNumBreeds) {
                return
            } else {
                self.activeRow += 1
            }
            
            let detailVC = configureDetailViewFor(row: self.activeRow)
            let VCs = self.navigationController!.viewControllers
            let editedVCs = [VCs[0], detailVC]
            self.navigationController!.setViewControllers(editedVCs, animated: true)
        }
    }
    
    func configureDetailViewFor(row: Int) -> BreedDetailVC {
        var dog: Dog
        
        if isSearching {
            dog = self.filteredBreeds[row]
            self.searchBar.endEditing(true)
        } else {
            dog = self.dogBreeds[row]
        }
        
        let detailVC = storyboard?.instantiateViewController(identifier: "BreedDetailVC") as! BreedDetailVC
        detailVC.selectedDogBreed = dog
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action:  #selector(handleGesture(_:)))
        swipeRight.direction = UISwipeGestureRecognizer.Direction.right
        detailVC.swipeRight = swipeRight
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action:  #selector(handleGesture(_:)))
        swipeLeft.direction = UISwipeGestureRecognizer.Direction.left
        detailVC.swipeLeft = swipeLeft
        
        return detailVC
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
//        var dog: Dog
//
//        if isSearching {
//            dog = self.filteredBreeds[indexPath.row]
//            self.searchBar.endEditing(true)
//        } else {
//            dog = self.dogBreeds[indexPath.row]
//        }
        
        self.activeRow = indexPath.row
        
//        let detailVC = storyboard?.instantiateViewController(identifier: "BreedDetailVC") as! BreedDetailVC
//        detailVC.selectedDogBreed = dog
//
//        let swipeRight = UISwipeGestureRecognizer(target: self, action:  #selector(handleGesture(_:)))
//        swipeRight.direction = UISwipeGestureRecognizer.Direction.right
//        detailVC.swipeRight = swipeRight
//
//        let swipeLeft = UISwipeGestureRecognizer(target: self, action:  #selector(handleGesture(_:)))
//        swipeLeft.direction = UISwipeGestureRecognizer.Direction.left
//        detailVC.swipeLeft = swipeLeft
        let detailVC = configureDetailViewFor(row: indexPath.row)
        
        self.navigationController!.pushViewController(detailVC, animated: true)
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


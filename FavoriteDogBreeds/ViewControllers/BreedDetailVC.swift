//
//  BreedDetailVC.swift
//  FavoriteDogBreeds
//
//  Created by Jordan Leeper on 1/5/20.
//  Copyright © 2020 Jordan Leeper. All rights reserved.
//

import UIKit

class BreedDetailVC: UIViewController {
    
    // MARK: outlets
    @IBOutlet weak var breedImage: UIImageView?
    @IBOutlet weak var favoriteBtn: UIBarButtonItem!
    
    // MARK: vars
    var selectedDogBreed: Dog?
    var favorite: Favorite?
    var spinner = UIActivityIndicatorView(style: .large)
    var swipeRight: UIGestureRecognizer?
    var swipeLeft: UIGestureRecognizer?
    
    // MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.largeTitleDisplayMode = .never
        
        if let swipeRight = swipeRight {
            self.view.addGestureRecognizer(swipeRight)
        }
        if let swipeLeft = swipeLeft {
           self.view.addGestureRecognizer(swipeLeft)
        }
        
        if let dog = self.selectedDogBreed {
            self.title = dog.label
            
            if self.favorite == nil {
                self.favorite = CoreDataFavoriteService.instance.fetchFavoriteBy(dog: dog)
            }
        }
        
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()
        view.addSubview(spinner)
        
        spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        if self.favorite != nil {
            updateFavoriteButtonFill(filled: true)
        }
        
        getDogBreedImage()
    }
    
    @IBAction func randomImageTapped(_ sender: UIButton) {
        breedImage?.image = nil
        spinner.startAnimating()
        getDogBreedImage()
    }
    
    @IBAction func sharePhoto(_ sender: UIButton) {
        let items = [breedImage?.image]
        let ac = UIActivityViewController(activityItems: items as [Any], applicationActivities: nil)
        
        ac.popoverPresentationController?.sourceView = self.view
        ac.popoverPresentationController?.sourceRect = sender.frame
        
        present(ac, animated: true)
    }
    
    // MARK: save photo
    @IBAction func downloadPhoto(_ sender: UIButton) {
        guard let img = self.breedImage?.image else {
            return
        }
        
        self.spinner.startAnimating()
        
        UIImageWriteToSavedPhotosAlbum(img, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if error != nil {
            let displayName = Bundle.main.displayName ?? "the app"
            presentAlertController(title: "Error saving", message: "Make sure you have enabled photo access for \(displayName) under Settings")
        } else {
            presentAlertController(title: "Saved!", message: "The \(self.selectedDogBreed?.label ?? "dog") photo has been saved")
        }
        self.spinner.stopAnimating()
    }
    
    func presentAlertController(title: String, message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    // MARK: favoriteTapped
    @IBAction func favoriteTapped(_ sender: UIBarButtonItem) {
        guard let selectedDog = self.selectedDogBreed else { return }
        
        if let fav = self.favorite {
            CoreDataFavoriteService.instance.deleteFavorite(favorite: fav)
            updateFavoriteButtonFill(filled: false)
        } else {
            self.favorite = CoreDataFavoriteService.instance.addFavorite(dog: selectedDog)
            updateFavoriteButtonFill(filled: true)
        }
    }
    
    // MARK: updateFavoriteButtonFill
    func updateFavoriteButtonFill(filled: Bool) {
        if filled {
            if let buttonStarFilled = UIImage(systemName: "star.fill") {
                favoriteBtn.image = buttonStarFilled
            }
        } else {
            if let buttonStarEmpty = UIImage(systemName: "star") {
                favoriteBtn.image = buttonStarEmpty
            }
        }
    }
    
    // MARK: getDogBreedImage
    func getDogBreedImage() {
        if let dogBreed = selectedDogBreed {
            DogAPIService.instance.fetchImageBy(dog: dogBreed) { (image, error) in
                if let dogImage = image {
                    DispatchQueue.main.async {
                        self.spinner.stopAnimating()
                        self.breedImage?.image = dogImage
                    }
                } else {
                    print(error!)
                }
            }
        }
    }
}


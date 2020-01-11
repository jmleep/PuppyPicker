//
//  BreedDetailVC.swift
//  FavoriteDogBreeds
//
//  Created by Jordan Leeper on 1/5/20.
//  Copyright © 2020 Jordan Leeper. All rights reserved.
//

import UIKit
import CoreData

class BreedDetailVC: UIViewController {

    // MARK: outlets
    @IBOutlet weak var breedImage: UIImageView?
    @IBOutlet weak var favoriteBtn: UIBarButtonItem!
    
    // MARK: vars
    var selectedDogBreed: Dog?
    var favorite: Favorite?
    var spinner = UIActivityIndicatorView(style: .large)
    
    // MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let dog = self.selectedDogBreed {
            self.title = dog.label
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
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
        
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
        let context = AppDelegate.viewContext
        
        if let fav = self.favorite {
            context.delete(fav)
            updateFavoriteButtonFill(filled: false)
        } else {
            let favorite = Favorite(context: context)
            favorite.label = selectedDog.label
            favorite.breed = selectedDog.breed
            favorite.subBreed = selectedDog.subBreed
            
            self.favorite = favorite
            updateFavoriteButtonFill(filled: true)
        }
        
        do {
            try context.save()
        } catch let error as NSError {
            print(error)
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
        guard let selectedDog = self.selectedDogBreed else { return }
        
        var url = "https://dog.ceo/api/breed/\(selectedDog.breed)"
        
        if let subBreed = selectedDog.subBreed {
            url += "/\(subBreed)"
        }
        
        url += "/images/random"

        let dogBreedRandomImgUrl = URL(string: url)!
        let getImageUrltask = URLSession.shared.dataTask(with: dogBreedRandomImgUrl) { (data, response, error) in
            guard let data = data else { return }
            let decoder = JSONDecoder()
            
            do {
                let imageResponse = try decoder.decode(DogBreedRandomImageResponse.self, from: data)
        
                let imageUrl = URL(string: imageResponse.message)!
                
                let downloadImageTask = URLSession.shared.dataTask(with: imageUrl) { (data, response, error) in
                    guard let data = data else { return }
                    
                    DispatchQueue.main.async {
                        self.spinner.stopAnimating()
                        self.breedImage?.image = UIImage(data: data)
                    }
                }
                
                downloadImageTask.resume()
            } catch {
                print(error)
            }
        }
    
        getImageUrltask.resume()
    }
}


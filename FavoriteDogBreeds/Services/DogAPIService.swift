//
//  DogAPIService.swift
//  FavoriteDogBreeds
//
//  Created by Jordan Leeper on 1/19/20.
//  Copyright © 2020 Jordan Leeper. All rights reserved.
//

import Foundation
import UIKit

class DogAPIService {
    
    // Create singleton
    static let instance = DogAPIService()
    private let dogAPIURLBase = "https://dog.ceo/api"
    
    func fetchDogBreeds(completion: @escaping (_ breeds: [Dog]?, _ error: Error?) -> Void) {
        let fetchBreedsAction = "/breeds/list/all"
        let fetchBreedsURL = URL(string: "\(dogAPIURLBase)\(fetchBreedsAction)")!
        
        let task = URLSession.shared.dataTask(with: fetchBreedsURL) { (data, response, error) in
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
                
                let dogBreeds = tempDogArray.sorted { (dog1, dog2) -> Bool in
                    dog1.label < dog2.label
                }
                
                
                completion(dogBreeds, nil)
                
            } catch {
                print(error)
                completion(nil, error)
            }
        }
        task.resume()
    }
    
    func fetchImageBy(dog: Dog, completion: @escaping (_ image: UIImage?, _ error: Error?) -> Void) {
        var fetchImageAction = "/breed/\(dog.breed)"
        if let subBreed = dog.subBreed {
            fetchImageAction += "/\(subBreed)"
        }
        fetchImageAction += "/images/random"
        let fetchImageURL = URL(string: "\(dogAPIURLBase)\(fetchImageAction)")!
        
        let getImageUrltask = URLSession.shared.dataTask(with: fetchImageURL) { (data, response, error) in
            guard let data = data else { return }
            let decoder = JSONDecoder()
            
            do {
                let imageResponse = try decoder.decode(DogBreedRandomImageResponse.self, from: data)
                
                let imageUrl = URL(string: imageResponse.message)!
                
                let downloadImageTask = URLSession.shared.dataTask(with: imageUrl) { (data, response, error) in
                    guard let data = data else { return }
                    
                    let image = UIImage(data: data)
                    
                    completion(image, nil)
                }
                
                downloadImageTask.resume()
            } catch {
                completion(nil, error)
            }
        }
        
        getImageUrltask.resume()
    }
}

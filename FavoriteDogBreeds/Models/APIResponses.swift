// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let dogBreeds = try? newJSONDecoder().decode(DogBreeds.self, from: jsonData)

import Foundation

// MARK: - DogBreeds
struct DogBreedsResponse: Codable {
    let message: [String: [String]]
    let status: String
}

struct DogBreedRandomImageResponse: Codable {
    let message: String
    let status: String
}

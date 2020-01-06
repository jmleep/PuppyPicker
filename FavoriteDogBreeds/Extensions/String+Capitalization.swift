//
//  String+FavDogBreeds.swift
//  FavoriteDogBreeds
//
//  Created by Jordan Leeper on 1/5/20.
//  Copyright © 2020 Jordan Leeper. All rights reserved.
//

import UIKit

extension String {
    var firstUppercased: String {
        return prefix(1).uppercased() + dropFirst()
    }
}


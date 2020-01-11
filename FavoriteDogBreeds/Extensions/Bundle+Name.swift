//
//  Bundle+Name.swift
//  FavoriteDogBreeds
//
//  Created by Jordan Leeper on 1/10/20.
//  Copyright © 2020 Jordan Leeper. All rights reserved.
//

import Foundation

extension Bundle {
    var displayName: String? {
        return object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ?? object(forInfoDictionaryKey: "CFBundleName") as? String
    }
}

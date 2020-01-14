//
//  Environment.swift
//  FavoriteDogBreeds
//
//  Created by Jordan Leeper on 1/13/20.
//  Copyright © 2020 Jordan Leeper. All rights reserved.
//
import Foundation

public enum Environment {
  private static let infoDictionary: [String: Any] = {
    guard let dict = Bundle.main.infoDictionary else {
      fatalError("Plist file not found")
    }
    return dict
  }()

  static let BREED_VC_BANNER_AD_ID: String = {
    guard let id = Environment.infoDictionary["BREED_VC_BANNER_AD_ID"] as? String else {
      fatalError("BREED_VC_AD_BANNER_ID not set in plist for this environment")
    }
    return id
  }()
}

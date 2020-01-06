//
//  DogBreedTableCell.swift
//  FavoriteDogBreeds
//
//  Created by Jordan Leeper on 1/5/20.
//  Copyright © 2020 Jordan Leeper. All rights reserved.
//

import UIKit

class DogBreedTableCell: UITableViewCell {

    @IBOutlet weak var breedLabel: UILabel!
    
    func setData(label: String) {
        self.breedLabel.text = label
    }
}

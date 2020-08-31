//
//  GeohashModel.swift
//  pinit
//
//  Created by Janmajaya Mall on 17/8/2020.
//  Copyright © 2020 Janmajaya Mall. All rights reserved.
//

import Foundation

struct GeohashModel {
    var currentLocationGeohash: String
    var neighborGeohashes: Array<String>
    var currentAreaGeohashes: Array<String> {
        // generating geohashes array containing geohashes describing current location under watch
        var geohashes = self.neighborGeohashes
        geohashes.append(self.currentLocationGeohash)
        
        return geohashes
    }
    
}

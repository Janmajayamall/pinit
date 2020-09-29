//
//  UserActiveDataModel.swift
//  pinit
//
//  Created by Janmajaya Mall on 29/9/2020.
//  Copyright © 2020 Janmajaya Mall. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct UserActiveDataModel: Codable {
    var lastActive: Timestamp = Timestamp()
    var lastUpload: Timestamp?
    var lastLocation: GeoPoint?
    @DocumentID var id: String? = UUID().uuidString
}

//
//  ReportUserModel.swift
//  pinit
//
//  Created by Janmajaya Mall on 8/10/2020.
//  Copyright © 2020 Janmajaya Mall. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct ReportUserModel: Codable {
    var userId: String
    var username: String
    var email: String
    var reportedUsername: String
    var reason: String
    var createdAt: Timestamp = Timestamp()
    var reportLocation: GeoPoint
    @DocumentID var id: String? = UUID().uuidString
}

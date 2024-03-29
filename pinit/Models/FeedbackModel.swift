//
//  FeedbackModel.swift
//  pinit
//
//  Created by Janmajaya Mall on 8/10/2020.
//  Copyright © 2020 Janmajaya Mall. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct FeedbackModel: Codable {
    var userId: String
    var username: String
    var email: String
    var topic: String
    var description: String
    var createdAt: Timestamp = Timestamp()
    @DocumentID var id: String? = UUID().uuidString
}

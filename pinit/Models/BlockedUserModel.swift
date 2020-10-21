//
//  BlockedUserModel.swift
//  pinit
//
//  Created by Janmajaya Mall on 21/10/2020.
//  Copyright © 2020 Janmajaya Mall. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct BlockedUserModel: Codable, Identifiable {
    var blockedByUID: String
    var blockedUID: String
    var blockedUsername: String
    var createdAt: Timestamp = Timestamp()
    @DocumentID var id: String? = UUID().uuidString
}

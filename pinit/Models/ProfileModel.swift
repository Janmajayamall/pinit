//
//  ProfileModel.swift
//  pinit
//
//  Created by Janmajaya Mall on 16/8/2020.
//  Copyright © 2020 Janmajaya Mall. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct ProfileModel: Codable {
    var username: String
    var profileImageUrl: String
    var userId: String
    @DocumentID var id: String? = UUID().uuidString
}
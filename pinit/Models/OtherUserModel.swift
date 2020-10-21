//
//  OtherUserModel.swift
//  pinit
//
//  Created by Janmajaya Mall on 21/10/2020.
//  Copyright © 2020 Janmajaya Mall. All rights reserved.
//

import Foundation
struct OtherUserModel: Identifiable {
    var uid: String
    var username: String
    var id: UUID = UUID()
}

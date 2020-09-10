//
//  PostDisplayTypeService.swift
//  pinit
//
//  Created by Janmajaya Mall on 27/8/2020.
//  Copyright © 2020 Janmajaya Mall. All rights reserved.
//

import Foundation
import Combine
import FirebaseAuth

class PostDisplayTypeService: ObservableObject {

    @Published var postDisplayType: PostDisplayType = .allPosts
    var user: User?
    
    private var cancellables: Set<AnyCancellable> = []
    
    func switchPostDisplayType(to type: PostDisplayType){
        
        // checking whether user exists or not - if user does not exists then dont respond to the switch
        guard let user = self.user else {return}
        
        self.postDisplayType = type
        
    }
}

// extension for subscribing to publishers
extension PostDisplayTypeService {
    func subscribeAuthenticationServicePublishers() {
        Publishers.authenticationServiceDidAuthStatusChangePublisher.sink { (user) in
            self.user = user
        }.store(in: &cancellables)
    }
}

enum PostDisplayType {
    case privateOnlyPosts
    case allPosts
}

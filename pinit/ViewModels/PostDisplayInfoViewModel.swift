//
//  PostDisplayInfoViewModel.swift
//  pinit
//
//  Created by Janmajaya Mall on 3/9/2020.
//  Copyright © 2020 Janmajaya Mall. All rights reserved.
//

import Foundation
import Combine

class PostDisplayInfoViewModel: ObservableObject {
    @Published var postDisplayInfo: PostDisplayInfoModel?
    @Published var displayPostInfo: Bool = false
    
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        self.subscribeToGroupSCNNodePublishers()
    }
    
    func displayInfo(for postDisplayInfo: PostDisplayInfoModel){
        self.displayPostInfo = true
        self.postDisplayInfo = postDisplayInfo
    }
    
    func closeDisplayedInfo() {
        self.displayPostInfo = false
        self.postDisplayInfo = nil
    }
}

// extension for subscribers
extension PostDisplayInfoViewModel {
    func subscribeToGroupSCNNodePublishers() {
        Publishers.groupSCNNodeDidRequestCurrentPostDisplayInfoPublisher.sink { (postDisplayInfo) in
            self.displayInfo(for: postDisplayInfo)
        }.store(in: &cancellables)
    }
}

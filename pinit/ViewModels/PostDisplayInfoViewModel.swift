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
        self.subscribeToArViewPublishers()
    }
    
    func displayInfo(for postDisplayInfo: PostDisplayInfoModel){
        self.postDisplayInfo = postDisplayInfo
        self.displayPostInfo = true
        
    }
    
    func closeDisplayedInfo() {
        self.displayPostInfo = false
    }
}

// extension for subscribers
extension PostDisplayInfoViewModel {
    func subscribeToGroupSCNNodePublishers() {
        Publishers.groupSCNNodeDidRequestCurrentPostDisplayInfoPublisher.sink { (postDisplayInfo) in
            self.displayInfo(for: postDisplayInfo)
        }.store(in: &cancellables)
    }
    
    func subscribeToArViewPublishers() {
        Publishers.aRViewUserDidTapViewPublisher.sink { (value) in
            guard value == true else {return}
            self.closeDisplayedInfo()
        }.store(in: &cancellables)
    }
}

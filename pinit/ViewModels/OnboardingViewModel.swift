//
//  OnboardingViewModel.swift
//  pinit
//
//  Created by Janmajaya Mall on 25/10/2020.
//  Copyright © 2020 Janmajaya Mall. All rights reserved.
//

import Foundation

class OnboardingViewModel: ObservableObject {
    init() {
//        self.removeAllUserDefaults()
    }
    
    func checkOnboardingStatus(for type: OnboardingStatusType) -> Int {
        let val = UserDefaults().integer(forKey: type.rawValue)
        return val
    }
    
    func markOnboardingStatus(for type: OnboardingStatusType, to value: Int){
        UserDefaults().set(value, forKey: type.rawValue)
        self.objectWillChange.send()
    }
    
    func removeAllUserDefaults() {
        UserDefaults().removeObject(forKey: OnboardingStatusType.unauthenticatedMainARView.rawValue)
        UserDefaults().removeObject(forKey: OnboardingStatusType.authenticatedMainARView.rawValue)
        UserDefaults().removeObject(forKey: OnboardingStatusType.cameraFeedView.rawValue)
        UserDefaults().removeObject(forKey: OnboardingStatusType.captureView.rawValue)
        //
        //        print(self.checkOnboardingStatus(for: .authenticatedMainARView))
        //        print(self.checkOnboardingStatus(for: .unauthenticatedMainARView))
        //        print(self.checkOnboardingStatus(for: .cameraFeedView))
        //        print(self.checkOnboardingStatus(for: .captureView))
    }
    
    enum OnboardingStatusType: String {
        case unauthenticatedMainARView
        case authenticatedMainARView
        case cameraFeedView
        case captureView
    }
}

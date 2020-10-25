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
        self.removeAllUserDefaults()
    }
    
    func checkOnboardingStatus(for type: OnboardingStatusType) -> Bool {
        return UserDefaults().bool(forKey: type.rawValue)
    }
        
    func markOnboardingStatus(for type: OnboardingStatusType, to value: Bool){
        UserDefaults().set(value, forKey: type.rawValue)
    }
    
    func removeAllUserDefaults() {
        UserDefaults().removeObject(forKey: OnboardingStatusType.unauthenticatedMainARView.rawValue)
        UserDefaults().removeObject(forKey: OnboardingStatusType.authenticatedMainARView.rawValue)
        UserDefaults().removeObject(forKey: OnboardingStatusType.cameraFeedView.rawValue)
        UserDefaults().removeObject(forKey: OnboardingStatusType.captureView.rawValue)
    }
    
    enum OnboardingStatusType: String {
        case unauthenticatedMainARView
        case authenticatedMainARView
        case cameraFeedView
        case captureView
    }
}

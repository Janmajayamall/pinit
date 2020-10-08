//
//  AnalyticsService.swift
//  pinit
//
//  Created by Janmajaya Mall on 20/9/2020.
//  Copyright © 2020 Janmajaya Mall. All rights reserved.
//

import Foundation
import FirebaseAnalytics
import FirebaseAuth
import Combine

class AnalyticsService {
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(){
        self.subscribeToAuthenticationService()
    }
    
    static func logSignUpEvent(withProvider authProvider: AnalyticsService.AnalyticsAuthProvider){
        Analytics.logEvent(AnalyticsEventSignUp, parameters: [AnalyticsParameterSignUpMethod: authProvider.rawValue] )
                          
    }
    
    static func logLogInEvent(withProvider authProvider: AnalyticsService.AnalyticsAuthProvider){
        Analytics.logEvent(AnalyticsEventLogin,  parameters: [AnalyticsParameterSignUpMethod: authProvider.rawValue])
    }
    
    static func logAppOpenEvent() {
        Analytics.logEvent(AnalyticsEventAppOpen,  parameters:nil)
    }

    static func logNodeTap(inDirection nodeDirection: NodeDirection){
        Analytics.logEvent(AnalyticsConstants.AnalyticsEventUserTapNode,  parameters:[AnalyticsConstants.AnalyticsParameterTapNodeDirection: nodeDirection.rawValue])
    }
    
    static func logUserDidPost(withContentType contentType: PostContentType){
        Analytics.logEvent(AnalyticsConstants.AnalyticsEventUserDidPost, parameters: [AnalyticsConstants.AnalyticsParameterPostContentType: contentType.rawValue])
    }
        
}

extension AnalyticsService {
    func subscribeToAuthenticationService() {
        Publishers.authenticationServiceDidAuthStatusChangePublisher.sink { (user) in
            // setting up user id for analytics
            Analytics.setUserID(user?.uid)
            
            if (user == nil){
                Analytics.setUserProperty("false", forName: AnalyticsConstants.AnalyticsAuthProperty
)
            }else {
                Analytics.setUserProperty("true", forName: AnalyticsConstants.AnalyticsAuthProperty
)
            }
        }.store(in: &cancellables)
    }
}

extension AnalyticsService {
    enum AnalyticsAuthProvider: String {
        case email
        case apple
    }
    
    class AnalyticsConstants {
        // events
        static let AnalyticsEventUserTapNode = "AnalyticsEventUserTapNode"
        static let AnalyticsEventUserDidPost = "AnalyticsEventUserDidPost"
        
        // parameters
        static let AnalyticsParameterTapNodeDirection = "AnalyticsParameterTapNodeDirection"
        static let AnalyticsParameterPostContentType = "AnalyticsParameterPostContentType"
        
        // user property
        static let AnalyticsAuthProperty = "AnalyticsAuthProperty"
        
    }
}

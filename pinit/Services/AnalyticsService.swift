//
//  AnalyticsService.swift
//  pinit
//
//  Created by Janmajaya Mall on 20/9/2020.
//  Copyright © 2020 Janmajaya Mall. All rights reserved.
//

import Foundation
import FirebaseAnalytics

class AnalyticsService {
    
    
    static func logSignInEvent(withProvider authProvider: AnalyticsService.AnalyticsAuthProvider){
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
        
}

extension AnalyticsService {
    enum AnalyticsAuthProvider: String {
        case email
        case apple
    }
    
    class AnalyticsConstants {
        static let AnalyticsEventUserTapNode = "AnalyticsEventUserTapNode"
        static let AnalyticsParameterTapNodeDirection = "AnalyticsParameterTapNodeDirection"
    }
}

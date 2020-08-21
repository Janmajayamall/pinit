//
//  EnvironmentValues+Extensions.swift
//  pinit
//
//  Created by Janmajaya Mall on 21/8/2020.
//  Copyright © 2020 Janmajaya Mall. All rights reserved.
//

import Foundation
import SwiftUI

struct WindowKey: EnvironmentKey {
    static var defaultValue: UIWindow? = nil
}

extension EnvironmentValues {
    var window: UIWindow? {
        get {
            self[WindowKey.self]
        }
        set {
            self[WindowKey.self] = newValue
        }
    }
}

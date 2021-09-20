//
//  UIView+Extensions.swift
//  pinit
//
//  Created by Janmajaya Mall on 21/8/2020.
//  Copyright © 2020 Janmajaya Mall. All rights reserved.
//

import Foundation
import UIKit

extension UIView{
    func toImage(rect: CGRect) -> UIImage{
        //UIGraphicsImageRenderer is used for creating CG backed Image when supplied with bounds
        let renderer = UIGraphicsImageRenderer(bounds: rect)
        return renderer.image{(context) in
            self.layer.render(in: context.cgContext)
        }
    }
}

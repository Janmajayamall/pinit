//
//  UIKitMapBox.swift
//  pinit
//
//  Created by Janmajaya Mall on 19/8/2020.
//  Copyright © 2020 Janmajaya Mall. All rights reserved.
//

import SwiftUI
import Mapbox



struct UIKitMapBox : UIViewRepresentable {
    class CustomUserLocationAnnotation: MGLUserLocationAnnotationView {
        override func layoutSubviews() {
            super.layoutSubviews()
            
            // Use CALayer’s corner radius to turn this view into a circle.
            layer.cornerRadius = bounds.width / 2
            layer.borderWidth = 2
            layer.borderColor = UIColor.white.cgColor
        }
        
        override func setSelected(_ selected: Bool, animated: Bool) {
            super.setSelected(selected, animated: animated)
            
            // Animate the border width in/out, creating an iris effect.
            let animation = CABasicAnimation(keyPath: "borderWidth")
            animation.duration = 0.1
            layer.borderWidth = selected ? bounds.width / 4 : 2
            layer.add(animation, forKey: "borderWidth")
        }

    }
    
    class Coordinator: NSObject, MGLMapViewDelegate {
        
        func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
            
            if(annotation is MGLUserLocation){
                let userAnnotation = CustomUserLocationAnnotation()
                // setting up the bounds
                userAnnotation.bounds = CGRect(x: 0, y: 0, width: 20, height: 20)
                // setting up the color
                userAnnotation.backgroundColor = UIColor(named: "primaryColor")
                return userAnnotation
            }
            
            guard annotation is CustomPointAnnotation else {return nil}
            
            //defining reuse identifier for this view annotaition
            let reusableIdentifier = "\(annotation.coordinate.latitude)+\(annotation.coordinate.longitude)"
            
            //if identifier already exists then using it
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reusableIdentifier)
            
            if annotationView == nil {
                
                annotationView = MGLAnnotationView()
                
                annotationView!.bounds = CGRect(x: 0, y: 0, width: 10, height: 10)
                
                // Set the annotation view’s background color to a value determined by its longitude.
                let hue = CGFloat(annotation.coordinate.longitude) / 100
                annotationView!.backgroundColor = UIColor(hue: hue, saturation: 0.5, brightness: 1, alpha: 1)
            }
            
            return annotationView
            
        }
        
    }
    
    @Binding var mapAnnotations: Array<CLLocationCoordinate2D>
    
    func makeUIView(context: Context) -> MGLMapView {
        let mapView = MGLMapView(frame: .zero, styleURL: MGLStyle.streetsStyleURL)
        
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        //        mapView.setCenter(CLLocationCoordinate2D(latitude: 59.31, longitude: 18.06), zoomLevel: 1, animated: true)
        mapView.isZoomEnabled = true
        mapView.isPitchEnabled = true
        mapView.delegate = context.coordinator
        
        
        // Enable heading tracking mode so that the arrow will appear.
        mapView.userTrackingMode = .followWithHeading
        // Enable the permanent heading indicator, which will appear when the tracking mode is not `.followWithHeading`.
        mapView.showsUserHeadingIndicator = true
        
        
        return mapView
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }
    
    func updateUIView(_ uiView: MGLMapView, context: Context) {
        
        uiView.addAnnotations(self.mapAnnotations.compactMap({locationCoord2D in
            let mapAnnotation = CustomPointAnnotation(coordinates: locationCoord2D, isUser: false)
            return mapAnnotation
        }))
    }
    
    enum AnnotationTypes: String {
        case mine = "Mine"
        case others = "Others"
    }
}

// writing custom annotations points for differentating between user's points & others points
extension UIKitMapBox {
    class CustomPointAnnotation: NSObject, MGLAnnotation {
        var coordinate: CLLocationCoordinate2D
        var isUser: Bool
        
        init(coordinates: CLLocationCoordinate2D, isUser: Bool){
            self.coordinate = coordinates
            self.isUser = isUser
        }
    }
}

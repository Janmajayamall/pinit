//
//  UIKitMapBox.swift
//  pinit
//
//  Created by Janmajaya Mall on 19/8/2020.
//  Copyright © 2020 Janmajaya Mall. All rights reserved.
//

import SwiftUI
import Mapbox
import FirebaseAuth
import CoreLocation


struct UIKitMapBox : UIViewRepresentable {
    class CustomUserLocationAnnotationView: MGLUserLocationAnnotationView {
        let size: CGFloat = 40
        var dot: CALayer!
        var arrow: CAShapeLayer!
        
        override func update() {
            
            // setting up the tint color
            self.tintColor = UIColor(named: "primaryColor")
            
            if self.frame.isNull {
                self.frame = CGRect(x: 0, y: 0, width: size, height:size)
                self.setNeedsLayout()
            }
            
            // checking whether we have user's location or not
            if CLLocationCoordinate2DIsValid(self.userLocation!.coordinate){
                self.setupLayers()
                self.updateHeading()
            }
        }
        
        private func setupLayers(){
            // This dot forms the base of the annotation.
            if dot == nil {
                dot = CALayer()
                dot.bounds = CGRect(x: 0, y: 0, width: size, height: size)
                
                // Use CALayer’s corner radius to turn this layer into a circle.
                dot.cornerRadius = size / 2
                dot.backgroundColor = super.tintColor.cgColor
                dot.borderWidth = 4
                dot.borderColor = UIColor.white.cgColor
                layer.addSublayer(dot)
            }
            
            // This arrow overlays the dot and is rotated with the user’s heading.
            if arrow == nil {
                arrow = CAShapeLayer()
                arrow.path = self.arrowPath()
                arrow.frame = CGRect(x: 0, y: 0, width: size / 2, height: size / 2)
                arrow.position = CGPoint(x: dot.frame.midX, y: dot.frame.midY)
                arrow.fillColor = dot.borderColor
                layer.addSublayer(arrow)
            }
        }
        
        private func updateHeading() {
            // Show the heading arrow, if the heading of the user is available.
            if let heading = userLocation!.heading?.trueHeading {
                arrow.isHidden = false
                
                // Get the difference between the map’s current direction and the user’s heading, then convert it from degrees to radians.
                let rotation: CGFloat = -MGLRadiansFromDegrees(mapView!.direction - heading)
                
                // If the difference would be perceptible, rotate the arrow.
                if abs(rotation) > 0.01 {
                    // Disable implicit animations of this rotation, which reduces lag between changes.
                    CATransaction.begin()
                    CATransaction.setDisableActions(true)
                    arrow.setAffineTransform(CGAffineTransform.identity.rotated(by: rotation))
                    CATransaction.commit()
                }
            } else {
                arrow.isHidden = true
            }
        }
        
        // Calculate the vector path for an arrow, for use in a shape layer.
        private func arrowPath() -> CGPath {
            let max: CGFloat = size / 2
            let pad: CGFloat = 3
            
            let top =    CGPoint(x: max * 0.5, y: 0)
            let left =   CGPoint(x: 0 + pad,   y: max - pad)
            let right =  CGPoint(x: max - pad, y: max - pad)
            let center = CGPoint(x: max * 0.5, y: max * 0.6)
            
            let bezierPath = UIBezierPath()
            bezierPath.move(to: top)
            bezierPath.addLine(to: left)
            bezierPath.addLine(to: center)
            bezierPath.addLine(to: right)
            bezierPath.addLine(to: top)
            bezierPath.close()
            
            return bezierPath.cgPath
        }
        
    }
    
    class CustomMapAnnotationView: MGLAnnotationView {
        override func layoutSubviews() {
            super.layoutSubviews()
            
            // Use CALayer’s corner radius to turn this view into a circle.
            layer.cornerRadius = bounds.width / 2
            layer.borderWidth = 1
            layer.borderColor = UIColor.white.cgColor
        }
    }
    
    class Coordinator: NSObject, MGLMapViewDelegate {
        
        func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
            
            if(annotation is MGLUserLocation){
                let userAnnotation = CustomUserLocationAnnotationView()
                return userAnnotation
            }
            
            guard let customAnnotation = annotation as? CustomPointAnnotation else {return nil}
            
            //defining reuse identifier for this view annotaition
            let reusableIdentifier = "\(customAnnotation.coordinate.latitude)+\(customAnnotation.coordinate.longitude)"
            
            //if identifier already exists then using it
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reusableIdentifier)
            
            if annotationView == nil {
                
                annotationView = CustomMapAnnotationView()
                
                if (customAnnotation.isUser == true){
                    annotationView!.bounds = CGRect(x: 0, y: 0, width: 15, height: 15)
                    annotationView!.backgroundColor = UIColor(named: "primaryColor")
                }else{
                    annotationView!.bounds = CGRect(x: 0, y: 0, width: 10, height: 10)
                    // Set the annotation view’s background color to a value determined by its longitude.
                    let hue = CGFloat(annotation.coordinate.longitude) / 100
                    annotationView!.backgroundColor = UIColor(hue: hue, saturation: 0.5, brightness: 1, alpha: 1)
                }
            }
            
            return annotationView
            
        }
        
        // Optional: tap the user location annotation to toggle heading tracking mode.
        func mapView(_ mapView: MGLMapView, didSelect annotation: MGLAnnotation) {
            if mapView.userTrackingMode != .followWithHeading {
                mapView.userTrackingMode = .followWithHeading
            } else {
                mapView.resetNorth()
            }
            
            // We're borrowing this method as a gesture recognizer, so reset selection state.
            mapView.deselectAnnotation(annotation, animated: false)
        }
        
    }
    
    @Binding var posts: Dictionary<String, PostModel>
    @Binding var user: User?
    
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
        uiView.addAnnotations(self.posts.values.compactMap({post -> MGLAnnotation in
            // getting location coordinates
            let geolocation = post.geolocation
            let location = CLLocationCoordinate2D(latitude: geolocation.latitude, longitude: geolocation.longitude)
            
            // checking whether the post belongs to user
            var isUserPost = false
            if let user = self.user, post.userId == user.uid {
                isUserPost = true
            }
            
            let mapAnnotation = CustomPointAnnotation(coordinates: location, isUser: isUserPost)
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

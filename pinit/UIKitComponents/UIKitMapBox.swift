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
        
    class Coordinator: NSObject, MGLMapViewDelegate {
        
        func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
            
            if(annotation is MGLUserLocation){
                let userAnnotation = MGLUserLocationAnnotationView()
                userAnnotation.bounds = CGRect(x: 0, y: 0, width: 10, height: 10)
                 
                // Set the annotation view’s background color to a value determined by its longitude.
                let hue = CGFloat(39) / 100
                userAnnotation.backgroundColor = UIColor(hue: hue, saturation: 0.5, brightness: 1, alpha: 1)
                return userAnnotation
            }
            
            guard annotation is MGLPointAnnotation else {return nil}
            
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
        let mapView = MGLMapView(frame: .zero, styleURL: MGLStyle.darkStyleURL)
        
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
            let mapAnnotation = MGLPointAnnotation()
            mapAnnotation.coordinate = locationCoord2D
            return mapAnnotation
        }))
    }
}

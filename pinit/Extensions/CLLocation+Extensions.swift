//
//  CLLocation+Extensions.swift
//  pinit
//
//  Created by Janmajaya Mall on 17/8/2020.
//  Copyright © 2020 Janmajaya Mall. All rights reserved.
//

import Foundation
import CoreLocation

extension CLLocation {
    
    func getLocationAfterTranslation(by locationTranslation: CLLocationTranslation) -> CLLocation {
        let latitudeCoordinate = self.coordinate.coordinateWithBearing(bearing: 0, distanceMeters: locationTranslation.latitudeTranslation)
        let longitudeCoordinate = self.coordinate.coordinateWithBearing(bearing: 90, distanceMeters: locationTranslation.longitudeTranslation)
        
        let coordinate = CLLocationCoordinate2D( latitude: latitudeCoordinate.latitude, longitude: longitudeCoordinate.longitude)
        let altitude = self.altitude + locationTranslation.altitudeTranslation
        
        return CLLocation(coordinate: coordinate, altitude: altitude, horizontalAccuracy: self.horizontalAccuracy, verticalAccuracy: self.verticalAccuracy, timestamp: self.timestamp)
    }
    
    func getTranslation(to location: CLLocation) -> CLLocationTranslation {
    
        let locationWithin = CLLocation(latitude: self.coordinate.latitude, longitude: location.coordinate.longitude)
        
        let latitudeDistance = location.distance(from: locationWithin)
        var latitudeTranslation = location.coordinate.latitude > locationWithin.coordinate.latitude ? latitudeDistance : -latitudeDistance
        
        let longitudeDistance = self.distance(from: locationWithin)
        var longitudeTranslation = self.coordinate.longitude > locationWithin.coordinate.longitude ? -longitudeDistance : longitudeDistance
        
        let altitudeTranslation = location.altitude - self.altitude
        
        // making sure that all 3 translations isn't in the range of -minTranslation to minTranslation so that
        // image does not becomes bigger
        let minTranslation: Double = 1
        if (-minTranslation < latitudeTranslation && latitudeTranslation < minTranslation){
            latitudeTranslation = latitudeTranslation < 0 ? -minTranslation : minTranslation
        }
        if (-minTranslation < longitudeTranslation && longitudeTranslation < minTranslation){
            longitudeTranslation = longitudeTranslation < 0 ? -minTranslation : minTranslation
        }
        
        return CLLocationTranslation(latitudeTranslation: latitudeTranslation, longitudeTranslation: longitudeTranslation, altitudeTranslation: 0)
    }
    
    func checkAltitudeInRange(forAltitude otherAltitude: Double) -> Bool {
        let currentAltitude = self.altitude
        let altitudeRange: Double = 10.0
        
        // checking whether altitude is in range or not
        if (otherAltitude >= (currentAltitude - altitudeRange) && otherAltitude <= (currentAltitude + altitudeRange)){
            return true
        }else{
            return false
        }
    }
}

class CLLocationTranslation {
    var latitudeTranslation: Double
    var longitudeTranslation: Double
    var altitudeTranslation: Double
    
    init(latitudeTranslation: Double, longitudeTranslation: Double, altitudeTranslation: Double) {
        self.latitudeTranslation = latitudeTranslation
        self.longitudeTranslation = longitudeTranslation
        self.altitudeTranslation = altitudeTranslation
    }
}


extension CLLocationCoordinate2D {

    /// Returns a new `CLLocationCoordinate2D` at the given bearing and distance from the original point.
    /// This function uses a great circle on ellipse formula.
    /// - Parameter bearing: bearing in degrees clockwise from north.
    /// - Parameter distanceMeters: distance in meters.
    func coordinateWithBearing(bearing: Double, distanceMeters: Double) -> CLLocationCoordinate2D {
        // From https://www.movable-type.co.uk/scripts/latlong.html:
        //    All these formulas are for calculations on the basis of a spherical earth (ignoring ellipsoidal effects) –
        //    which is accurate enough* for most purposes… [In fact, the earth is very slightly ellipsoidal; using a
        //    spherical model gives errors typically up to 0.3%1 – see notes for further details].
        //
        //  Destination point given distance and bearing from start point**
        //
        //  Given a start point, initial bearing, and distance, this will calculate the destina­tion point and
        //      final bearing travelling along a (shortest distance) great circle arc.
        //
        //  Formula:    φ2 = asin( sin φ1 ⋅ cos δ + cos φ1 ⋅ sin δ ⋅ cos θ )
        //  λ2 = λ1 + atan2( sin θ ⋅ sin δ ⋅ cos φ1, cos δ − sin φ1 ⋅ sin φ2 )
        //  where    φ is latitude, λ is longitude, θ is the bearing (clockwise from north),
        //           δ is the angular distance d/R; d being the distance travelled, R the earth’s radius
        //
        //  JavaScript: (all angles in radians)
        //  var φ2 = Math.asin( Math.sin(φ1)*Math.cos(d/R) +
        //                      Math.cos(φ1)*Math.sin(d/R)*Math.cos(brng) );
        //  var λ2 = λ1 + Math.atan2(Math.sin(brng)*Math.sin(d/R)*Math.cos(φ1),
        //                           Math.cos(d/R)-Math.sin(φ1)*Math.sin(φ2));
        //  The longitude can be normalised to −180…+180 using (lon+540)%360-180
        //
        //  Excel:
        //  (all angles
        //  in radians)
        //  lat2: =ASIN(SIN(lat1)*COS(d/R) + COS(lat1)*SIN(d/R)*COS(brng))
        //  lon2: =lon1 + ATAN2(COS(d/R)-SIN(lat1)*SIN(lat2), SIN(brng)*SIN(d/R)*COS(lat1))
        //  * Remember that Excel reverses the arguments to ATAN2 – see notes below
        //  For final bearing, simply take the initial bearing from the end point to the start point and
        //  reverse it with (brng+180)%360.
        //

        let phi = self.latitude.degreesToRadians
        let lambda = self.longitude.degreesToRadians
        let theta = bearing.degreesToRadians

        let sigma = distanceMeters / self.earthRadiusMeters()

        let phi2 = asin(sin(phi) * cos(sigma) + cos(phi) * sin(sigma) * cos(theta))
        let lambda2 = lambda + atan2(sin(theta) * sin(sigma) * cos(phi), cos(sigma) - sin(phi) * sin(phi2))

        let result = CLLocationCoordinate2D(latitude: phi2.radiansToDegrees, longitude: lambda2.radiansToDegrees)
        return result
    }

    /// Return the WGS-84 radius of the earth, in meters, at the given point.
    func earthRadiusMeters() -> Double {
        // source: https://planetcalc.com/7721/ from https://en.wikipedia.org/wiki/Earth_radius#Geocentric_radius
        let WGS84EquatorialRadius  = 6_378_137.0
        let WGS84PolarRadius = 6_356_752.3

        // shorter versions to make formulas easier to read
        let a = WGS84EquatorialRadius
        let b = WGS84PolarRadius
        let phi = self.latitude.degreesToRadians

        let numerator = pow(a * a * cos(phi), 2) + pow(b * b * sin(phi), 2)
        let denominator = pow(a * cos(phi), 2) + pow(b * sin(phi), 2)
        let radius = sqrt(numerator/denominator)
        return radius
    }
}

public extension FloatingPoint {
    var degreesToRadians: Self { return self * .pi / 180 }
    var radiansToDegrees: Self { return self * 180 / .pi }
}

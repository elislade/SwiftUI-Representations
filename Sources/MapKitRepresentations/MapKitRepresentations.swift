@_exported import SwiftUI
@_exported import MapKit
@_exported import RepresentationUtils


public typealias MapKitViewRepresentation = RepresentationUtils.OSViewRepresentation

extension CLLocationCoordinate2D : Equatable {
    
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
    
}

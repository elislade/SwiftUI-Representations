import WebKit
import Combine
import RepresentationUtils


public class MKMapViewObservable: MKMapView, ObservableObject {

    public override var mapType: MKMapType {
        willSet { objectWillChange.send() }
    }
    
    #if canImport(UIKit)
    @available(iOS 16.0, *)
    public override var selectableMapFeatures: MKMapFeatureOptions {
        willSet { objectWillChange.send() }
    }
    #endif
    
    public override var region: MKCoordinateRegion {
        willSet { objectWillChange.send() }
    }
    
    public override var centerCoordinate: CLLocationCoordinate2D {
        willSet { objectWillChange.send() }
    }
    
    public override var visibleMapRect: MKMapRect {
        willSet { objectWillChange.send() }
    }
    
    public override var isZoomEnabled: Bool {
        willSet { objectWillChange.send() }
    }
    
    public override var isScrollEnabled: Bool {
        willSet { objectWillChange.send() }
    }
    
    public override var isRotateEnabled: Bool {
        willSet { objectWillChange.send() }
    }
    
    public override var isPitchEnabled: Bool {
        willSet { objectWillChange.send() }
    }
    
    public override var showsUserTrackingButton: Bool {
        willSet { objectWillChange.send() }
    }
    
    public override var pitchButtonVisibility: MKFeatureVisibility {
        willSet { objectWillChange.send() }
    }
    
    public override var showsCompass: Bool {
        willSet { objectWillChange.send() }
    }
    
    public override var showsScale: Bool {
        willSet { objectWillChange.send() }
    }
    
    public override var showsBuildings: Bool {
        willSet { objectWillChange.send() }
    }
    
    public override var showsTraffic: Bool {
        willSet { objectWillChange.send() }
    }
    
    public override var showsUserLocation: Bool {
        willSet { objectWillChange.send() }
    }
    
    public override var userTrackingMode: MKUserTrackingMode {
        willSet { objectWillChange.send() }
    }
    
    public override var selectedAnnotations: [any MKAnnotation] {
        willSet { objectWillChange.send() }
    }
    
    public var cameraBinding: Binding<MKMapCamera> {
        .init(get: { [camera] in camera }, set: { [unowned self] new in
            objectWillChange.send()
            setCamera(camera, animated: false)
        })
    }
    
    public var annotationsBinding: Binding<[any MKAnnotation]> {
        .init(
            get: { [annotations] in annotations },
            set: { [unowned self] new in
                objectWillChange.send()
                
                let diff = new.difference(from: annotations, by: { $0.hash == $1.hash })

                for change in diff.insertions {
                    switch change {
                    case let .insert(_, element, _): addAnnotation(element)
                    case .remove: continue
                    }
                }
                
                for change in diff.removals {
                    switch change {
                    case .insert: continue
                    case let .remove(_, element, _):
                        deselectAnnotation(element, animated: false)
                        removeAnnotation(element)
                    }
                }
            }
        )
    }
    

}

import MapKit
import Combine
import RepresentationUtils


public class MKMapViewObservable: MKMapView, ObservableObject {

    public override var mapType: MKMapType {
        willSet { objectWillChange.send() }
    }
    
    #if os(iOS)
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
    
    public override var userTrackingMode: MKUserTrackingMode {
        willSet { objectWillChange.send() }
    }
    
    
    // MARK: - Enabled Features
    
    
    public override var isZoomEnabled: Bool {
        willSet { objectWillChange.send() }
    }
    
    public override var isScrollEnabled: Bool {
        willSet { objectWillChange.send() }
    }
    
    #if !os(tvOS)
    
    public override var isRotateEnabled: Bool {
        willSet { objectWillChange.send() }
    }
    
    public override var isPitchEnabled: Bool {
        willSet { objectWillChange.send() }
    }
    
    #endif
    
    // MARK: - Interface Visibility
    
    
    public override var showsUserTrackingButton: Bool {
        willSet { objectWillChange.send() }
    }
    
    public override var pitchButtonVisibility: MKFeatureVisibility {
        willSet { objectWillChange.send() }
    }
    
    public var visibleUIElements: MapUIElements {
        get {
            var result = MapUIElements()
            #if !os(tvOS)
            if showsCompass { result.insert(.compass) }
            #endif
            if showsScale { result.insert(.scale) }
            if showsBuildings { result.insert(.buildings) }
            if showsTraffic { result.insert(.traffic) }
            if showsUserLocation { result.insert(.userLocation) }
            return result
        }
        set {
            showsScale = newValue.contains(.scale)
            #if !os(tvOS)
            showsCompass = newValue.contains(.compass)
            #endif
            showsBuildings = newValue.contains(.buildings)
            showsTraffic = newValue.contains(.traffic)
            showsUserLocation = newValue.contains(.userLocation)
        }
    }
    
    #if !os(tvOS)
    public override var showsCompass: Bool {
        willSet { objectWillChange.send() }
    }
    #endif
    
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
    
    
    // MARK: - Camera
    
    
    public override func setCameraZoomRange(_ cameraZoomRange: MKMapView.CameraZoomRange?, animated: Bool) {
        objectWillChange.send()
        super.setCameraZoomRange(cameraZoomRange, animated: animated)
    }
    
    public override func setCameraBoundary(_ cameraBoundary: MKMapView.CameraBoundary?, animated: Bool) {
        objectWillChange.send()
        super.setCameraBoundary(cameraBoundary, animated: animated)
    }
    
    public override func setCamera(_ camera: MKMapCamera, animated: Bool) {
        objectWillChange.send()
        super.setCamera(camera, animated: animated)
    }
    
    public var cameraBinding: Binding<MKMapCamera> {
        .init(
            get: { [unowned self] in camera },
            set: { [unowned self] new, transaction in
                setCamera(new, animated: transaction.animation != nil)
            }
        )
    }
    
    
    // MARK: - Annotations
    
    
    public override var selectedAnnotations: [any MKAnnotation] {
        willSet { objectWillChange.send() }
    }
    
    public override func addAnnotation(_ annotation: any MKAnnotation) {
        objectWillChange.send()
        super.addAnnotation(annotation)
    }
    
    public override func removeAnnotation(_ annotation: any MKAnnotation) {
        objectWillChange.send()
        super.removeAnnotation(annotation)
    }
    
    public override func selectAnnotation(_ annotation: any MKAnnotation, animated: Bool) {
        objectWillChange.send()
        super.selectAnnotation(annotation, animated: animated)
    }
    
    public override func deselectAnnotation(_ annotation: (any MKAnnotation)?, animated: Bool) {
        objectWillChange.send()
        super.deselectAnnotation(annotation, animated: animated)
    }
    
    public var annotationsBinding: Binding<[any MKAnnotation]> {
        .init(
            get: { [unowned self] in annotations },
            set: { [unowned self] new, transaction in
                let changes = new.difference(from: annotations, by: { $0.hash == $1.hash })

                for change in changes {
                    switch change {
                    case let .insert(_, element, _):
                        addAnnotation(element)
                    case let .remove(_, element, _):
                        deselectAnnotation(element, animated: transaction.animation != nil)
                        removeAnnotation(element)
                    }
                }
            }
        )
    }
    

}


public struct MapUIElements: OptionSet, Hashable, Sendable {
    
    public let rawValue: Int8
    
    public init(rawValue: Int8) {
        self.rawValue = rawValue
    }
    
    public static let compass: MapUIElements = .init(rawValue: 1 << 0)
    public static let scale: MapUIElements = .init(rawValue: 1 << 1)
    public static let buildings: MapUIElements = .init(rawValue: 1 << 2)
    public static let traffic: MapUIElements = .init(rawValue: 1 << 3)
    public static let userLocation: MapUIElements = .init(rawValue: 1 << 4)
    
}

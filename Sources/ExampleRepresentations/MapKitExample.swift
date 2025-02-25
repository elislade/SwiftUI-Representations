import MapKitRepresentations
import UIKitRepresentations


struct MapKitExample: View {
    
    @Environment(\.colorScheme) private var colorScheme
    @StateObject private var view = MKMapViewObservable()
    @State private var visibleAnnotations: [MKAnnotation] = []
    
    private let bottomHeight: CGFloat = 280
    
    private var backgroundView: some View {
        Rectangle().fill(.bar)
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            OSViewRepresentation(view)
                .ignoresSafeArea()
                .onAppear{
                    view.annotationsBinding.wrappedValue = [
                        MKPlacemark.a, MKPlacemark.b, MKPlacemark.c
                    ]
                    
                    view.layoutMargins.bottom = bottomHeight
                }
            
            VStack(spacing: 0) {
                TypeToggle(type: $view.mapType)
                    .labelsHidden()
                
                Divider()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 0){
                        ControlsSection(
                            showCompass: $view.showsCompass,
                            showScale: $view.showsScale,
                            showLocation: $view.showsUserLocation,
                            showTraffic: $view.showsTraffic
                        )
                        
                        Divider()
                        
                        CameraSection(camera: view.cameraBinding)
                        
                        Divider()
                        
                        AnnotationSection(
                            annotations: view.annotationsBinding,
                            selected: $view.selectedAnnotations.animation(.default),
                            visible: $visibleAnnotations.animation(.default)
                        )
                    }
                }
            }
            .frame(height: bottomHeight)
            .background(backgroundView.ignoresSafeArea())
            .preferredColorScheme(view.mapType == .standard ? .light : .dark)
        }
    }
    
    
    struct TypeToggle: View {
        
        @Binding var type: MKMapType
        
        var body: some View {
            Picker("Map Type", selection: $type){
                Text("Standard").tag(MKMapType.standard)
                Text("Satellite").tag(MKMapType.satellite)
                Text("Hybrid").tag(MKMapType.hybrid)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.vertical, 12)
        }
        
    }
    
    
    struct ControlsSection: View {
        
        @Binding var showCompass: Bool
        @Binding var showScale: Bool
        @Binding var showLocation: Bool
        @Binding var showTraffic: Bool
        
        var body: some View {
            VStack(alignment: .leading, spacing: 6) {
                Text("UI Visibility")
                    .font(.title3.bold())
                
                Toggle(isOn: $showCompass){
                    Text("Compass").font(.headline)
                }
                
                Toggle(isOn: $showScale){
                    Text("Scale").font(.headline)
                }
                
                Toggle(isOn: $showLocation){
                    Text("User Location").font(.headline)
                }
                
                Toggle(isOn: $showTraffic){
                    Text("Traffic").font(.headline)
                }
            }
            .padding()
        }
        
    }
    
    
    struct CameraSection: View {
        
        @Binding var camera: MKMapCamera
        
        private var distance: String {
            MKDistanceFormatter()
                .string(fromDistance: camera.centerCoordinateDistance)
        }
        
        var body: some View {
            Section {
                VStack(alignment: .leading) {
                    HStack {
                        HStack {
                            Text("Heading").font(.headline)
                            Spacer(minLength: 8)
                            Text("\(Int(camera.heading))º")
                                .font(.body.monospacedDigit())
                                .opacity(0.6)
                        }
                        .frame(width: 110)
                        
                        Slider(value: $camera.heading, in: 0...359)
                            .disabled(camera.centerCoordinateDistance > 1_100_000)
                    }
                    
                    HStack {
                        HStack {
                            Text("Pitch").font(.headline)
                            Spacer(minLength: 8)
                            Text("\(Int(camera.pitch))º")
                                .font(.body.monospacedDigit())
                                .opacity(0.6)
                        }
                        .frame(width: 110)
                        
                        Slider(value: $camera.pitch, in: 0...35)
                    }
                    
                    HStack {
                        HStack {
                            Text("Zoom").font(.headline)
                            Spacer(minLength: 8)
                            Text(distance)
                                .font(.body.monospacedDigit())
                                .opacity(0.6)
                        }
                        .frame(width: 110)
                        
                        Slider(
                            value: $camera.centerCoordinateDistance,
                            in: 1000...3_000_000
                        )
                    }
                }
                .padding([.horizontal, .bottom])
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            } header: {
                Text("Camera")
                    .font(.title3.bold())
                    .padding()
            }
        }
        
    }
    
    
    struct AnnotationSection: View {
        
        @Binding var annotations: [MKAnnotation]
        @Binding var selected: [MKAnnotation]
        @Binding var visible: [MKAnnotation]
        
        private func toggle(_ annotation: MKAnnotation) {
            if selected.contains(where: { $0.coordinate == annotation.coordinate }){
                selected.removeAll(where: { $0.isEqual(annotation) })
            } else {
                selected.append(annotation)
            }
        }
        
        private func isSelected(_ annotation: MKAnnotation) -> Bool {
            selected.contains(where: { $0.coordinate == annotation.coordinate })
        }
        
        private func isVisible(_ annotation: MKAnnotation) -> Bool {
            visible.contains(where: { $0.coordinate == annotation.coordinate })
        }
        
        private func delete(_ annotation: MKAnnotation) {
            annotations.removeAll(where: { $0.isEqual(annotation) })
        }
        
        private func moveTo(_ annotation: MKAnnotation) {
            guard !isVisible(annotation) else { return }
            visible = [annotation]
        }
        
        var body: some View {
            Section {
                ScrollView(.horizontal, showsIndicators: false){
                    HStack(spacing: 16) {
                        ForEach(annotations, id: \.hash){ annotation in
                            HStack(spacing: 1) {
                                Button(action: { toggle(annotation) }){
                                    VStack(alignment: .leading) {
                                        if let title = annotation.title as? String {
                                            Text(title)
                                        }
                                        
                                        if let subtitle = annotation.subtitle as? String {
                                            Text(subtitle)
                                                .font(.footnote)
                                                .opacity(0.5)
                                        }
                                    }
                                    .lineLimit(1)
                                    .padding(10)
                                    .background(
                                        isSelected(annotation) ? .accentColor : Color.secondary.opacity(0.2)
                                    )
                                }
                                .buttonStyle(.plain)
                                .contextMenu {
                                    Button("Delete", action: { delete(annotation) })
                                }
                                .foregroundColor(isSelected(annotation) ? .white : .accentColor)
                                
                                Button(action: { moveTo(annotation) }){
                                    Image(systemName: "eye")
                                        .resizable()
                                        .scaledToFit()
                                        .padding(10)
                                        .background(
                                            isVisible(annotation) ? .accentColor : Color.secondary.opacity(0.2)
                                        )
                                        .contentShape(Rectangle())
                                }
                                .foregroundColor(isVisible(annotation) ? .white : .accentColor)
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                    .animation(.smooth, value: annotations.count)
                    .buttonStyle(.plain)
                    .padding([.horizontal, .bottom])
                }
            } header: {
                Text("Annotations")
                    .font(.title3.bold())
                    .padding()
                
                //Text("\(selected.count)")
            }
        }
        
    }
    
    
}

#Preview("MapKit Example") {
    MapKitExample()
        .previewSize()
}


extension MKPlacemark {
    
    static var a = MKPlacemark(coordinate: .a)
    static var b = MKPlacemark(coordinate: .b)
    static var c = MKPlacemark(coordinate: .c)
    
}


extension MKShape {
    
    static let polyLocations: [CLLocationCoordinate2D] = [.a, .b, .c]
    static var circle = MKCircle(center: .a, radius: 100_000)
    static var poly = MKPolygon(coordinates: polyLocations, count: 3)
    
}


extension CLLocationCoordinate2D {
    
    static var a: Self { .init(latitude: 49, longitude: -123.00) }
    static var b: Self { .init(latitude: 63.74, longitude: 142.00) }
    static var c: Self { .init(latitude: 25, longitude: 68.00) }
    
}

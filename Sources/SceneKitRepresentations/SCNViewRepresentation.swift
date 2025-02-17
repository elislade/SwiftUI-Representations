import SwiftUI
import RepresentationUtils
import SceneKit

public struct SCNViewRepresentation {
    
    let scene: SCNScene
    let pointOfView: Binding<SCNNode?>?
    let debugOptions: SCNDebugOptions
    let rendersContinuously: Bool
    let allowsCameraControl: Bool
    let hitTested: ([SCNHitTestResult]) -> Void
    let willMakeView: (SCNView) -> Void
    
    public init(
        scene: SCNScene,
        pointOfView: Binding<SCNNode?>? = nil,
        debugOptions: SCNDebugOptions = [],
        rendersContinuously: Bool = false,
        allowsCameraControl: Bool = false,
        hitTested: @escaping ([SCNHitTestResult]) -> Void = { _ in },
        willMakeView: @escaping (SCNView) -> Void = { _ in }
    ) {
        self.scene = scene
        self.pointOfView = pointOfView
        self.debugOptions = debugOptions
        self.rendersContinuously = rendersContinuously
        self.allowsCameraControl = allowsCameraControl
        self.hitTested = hitTested
        self.willMakeView = willMakeView
    }
    
    private func sync(view: SCNView) {
        view.backgroundColor = .clear
        
        if scene.hashValue != view.scene.hashValue {
            view.scene = scene
        }
        
        if debugOptions != view.debugOptions {
            view.debugOptions = debugOptions
        }
        
        if allowsCameraControl != view.allowsCameraControl {
            view.allowsCameraControl = allowsCameraControl
        }
        
        if rendersContinuously != view.rendersContinuously {
            view.rendersContinuously = rendersContinuously
        }
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(hitTested)
    }
    
    public class Coordinator {
        
        var hitTested: ([SCNHitTestResult]) -> Void = { _ in }
        
        init(_ hitTested: @escaping ([SCNHitTestResult]) -> Void) {
            self.hitTested = hitTested
        }
        
        @objc func tap(g: OSGestureRecognizer) {
            let res = (g.view as! SCNView).hitTest(g.location(in: g.view), options: nil)
            hitTested(res)
        }
    }
    
}


#if canImport(UIKit)

extension SCNViewRepresentation: UIViewRepresentable {
    
    public func makeUIView(context: Context) -> SCNView {
        let view = SCNView(frame: .zero)
        view.addGestureRecognizer(OSTapGestureRecognizer(
            target: context.coordinator,
            action: #selector(context.coordinator.tap)
        ))
        
        sync(view: view)
        willMakeView(view)
        return view
    }
    
    public func updateUIView(_ uiView: SCNView, context: Context) {
        sync(view: uiView)
    }
    
}

#elseif canImport(AppKit) && !targetEnvironment(macCatalyst)

extension SCNViewRepresentation: NSViewRepresentable {
    
    public func makeNSView(context: Context) -> SCNView {
        let view = SCNView(frame: .zero)
        view.addGestureRecognizer(OSTapGestureRecognizer(
            target: context.coordinator,
            action: #selector(context.coordinator.tap)
        ))
        sync(view: view)
        willMakeView(view)
        return view
    }
    
    public func updateNSView(_ nsView: SCNView, context: Context) {
        sync(view: nsView)
    }
    
}

#endif

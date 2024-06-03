import SwiftUI

public struct LayerRepresentation {
    
    let layer: CALayer
    
    public init(_ layer: CALayer) {
        self.layer = layer
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator{ parent in
            CATransaction.begin()
            CATransaction.setAnimationDuration(0)
            layer.frame = parent.bounds
            CATransaction.commit()
        }
    }
    
    public class Coordinator: NSObject, CALayerDelegate {
        let layoutLayer: (CALayer) -> Void
        
        public init(layoutLayer: @escaping (CALayer) -> Void) {
            self.layoutLayer = layoutLayer
        }
        
        public func layoutSublayers(of layer: CALayer) {
            layoutLayer(layer)
        }
    }
}


#if canImport(UIKit)

extension LayerRepresentation: UIViewRepresentable {
    
    public func makeUIView(context: Context) -> UIView {
        let view = UIView()
        layer.contentsScale = context.environment.displayScale
        view.layer.addSublayer(layer)
        view.layer.delegate = context.coordinator
        return view
    }

    public func updateUIView(_ uiView: UIView, context: Context) {
        
    }
    
}

#Preview {
    LayerRepresentation({
        let l = CATextLayer()
        l.string = "Hello World"
        l.fontSize = 50
        l.alignmentMode = .center
        l.foregroundColor = CGColor(red: 0.5, green: 0.2, blue: 0.8, alpha: 1)
        return l
    }()
    )
    .padding()
}

#endif


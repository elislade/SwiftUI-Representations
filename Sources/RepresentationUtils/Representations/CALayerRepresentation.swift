import SwiftUI

public struct CALayerRepresentation  {
    
    let layer: CALayer
    
    public init(_ layer: @escaping () -> CALayer) {
        self.layer = layer()
    }
    
}


#if canImport(UIKit)

extension CALayerRepresentation: UIViewRepresentable {
    
    public func makeUIView(context: Context) -> CALayerHostView {
        layer.contentsScale = context.environment.displayScale
        return CALayerHostView(layer)
    }

    public func updateUIView(_ uiView: CALayerHostView, context: Context) { }
    
    @available(iOS 16.0, tvOS 16.0, *)
    public func sizeThatFits(_ proposal: ProposedViewSize, uiView: CALayerHostView, context: Context) -> CGSize? {
        return uiView.hostedLayer.preferredFrameSize()
    }
    
}

public class CALayerHostView: UIView {

    var hostedLayer: CALayer
    
    init(_ layer: CALayer) {
        self.hostedLayer = layer
        super.init(frame: .zero)
        self.layer.addSublayer(hostedLayer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        hostedLayer.frame = bounds
    }

}

#elseif canImport(AppKit)

extension CALayerRepresentation: NSViewRepresentable {
    
    public func makeNSView(context: Context) -> NSView {
        let view = NSView()
        layer.contentsScale = context.environment.displayScale
        view.layer = layer
        view.wantsLayer = true
        return view
    }
    
    public func updateNSView(_ nsView: NSView, context: Context) { }
}

#endif


import SwiftUI

public struct ActivityIndicatorViewRepresentation {
    
    public init() {}
    
}


#if canImport(UIKit)

extension ActivityIndicatorViewRepresentation: UIViewRepresentable {
    
    public func makeUIView(context: Context) -> UIActivityIndicatorView {
        let view = UIActivityIndicatorView(style: style)
        view.startAnimating()
        return view
    }
    
    public func updateUIView(_ uiView: UIActivityIndicatorView, context: Context) {
        
    }
    
}

#elseif canImport(AppKit)

extension ActivityIndicatorViewRepresentation : NSViewRepresentable {
    
    public func makeNSView(context: Context) -> NSProgressIndicator {
        let view = NSProgressIndicator()
        view.startAnimation(nil)
        return view
    }
    
    public func updateNSView(_ nsView: NSProgressIndicator, context: Context) {
        switch context.environment.controlSize {
        case .mini: nsView.controlSize = .mini
        case .small: nsView.controlSize = .small
        case .regular: nsView.controlSize = .regular
        case .large: nsView.controlSize = .large
        case .extraLarge: nsView.controlSize = .large
        @unknown default: return
        }
    }
    
}

#endif

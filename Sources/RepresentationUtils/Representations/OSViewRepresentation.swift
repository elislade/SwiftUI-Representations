import SwiftUI

public struct OSViewRepresentation {
    
    let view: OSView
    
    public init(_ view: OSView) {
        self.view = view
    }
    
}


#if canImport(UIKit)

extension OSViewRepresentation: UIViewRepresentable {
    
    public func makeUIView(context: Context) -> OSView {
        view
    }
    
    public func updateUIView(_ uiView: OSView, context: Context) { }
    
}

#elseif canImport(AppKit)

extension OSViewRepresentation: NSViewRepresentable {
    
    public func makeNSView(context: Context) -> OSView {
        view
    }
    
    public func updateNSView(_ nsView: OSView, context: Context) { }
    
}

#endif

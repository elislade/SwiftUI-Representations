import SwiftUI

public struct OSViewControllerRepresentation {
    
    let ctrl: OSViewController
    
    public init(_ ctrl: OSViewController) {
        self.ctrl = ctrl
    }
    
}


#if canImport(UIKit)

extension OSViewControllerRepresentation: UIViewControllerRepresentable {
    
    public func makeUIViewController(context: Context) -> OSViewController {
        ctrl
    }
    
    public func updateUIViewController(_ uiViewController: OSViewController, context: Context) { }
    
}

#endif


#if canImport(AppKit) && !targetEnvironment(macCatalyst)

extension OSViewControllerRepresentation: NSViewControllerRepresentable {
    
    public func makeNSViewController(context: Context) -> OSViewController {
        ctrl
    }
    
    public func updateNSViewController(_ nsViewController: OSViewController, context: Context) { }
    
}

#endif

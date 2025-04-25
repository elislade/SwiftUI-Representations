#if canImport(SafariServices) && !os(macOS) && !os(tvOS)

import SwiftUI
import SafariServices

public struct SFSafariViewControllerRepresentation {

    let url: URL
    let didFinish: () -> Void
    let configuration: SFSafariViewController.Configuration
    let preferredBarTintColor: UIColor?
    let preferredControlTintColor: UIColor?
    let dismissButtonStyle: DismissButtonStyle
    
    public init(
        url: URL,
        configuration: SFSafariViewController.Configuration = .init(),
        preferredBarTintColor: UIColor? = nil,
        preferredControlTintColor: UIColor? = nil,
        dismissButtonStyle: DismissButtonStyle = .close,
        didFinish: @escaping () -> Void = {}
    ) {
        self.url = url
        self.configuration = configuration
        self.didFinish = didFinish
        self.preferredBarTintColor = preferredBarTintColor
        self.preferredControlTintColor = preferredControlTintColor
        self.dismissButtonStyle = dismissButtonStyle
    }
    
    private func sync(ctrl: SFSafariViewController, ctx: Context){
        #if !os(visionOS)
        ctrl.preferredBarTintColor = preferredBarTintColor
        ctrl.preferredControlTintColor = preferredControlTintColor
        ctrl.dismissButtonStyle = dismissButtonStyle
        #endif
    }
    
    #if !os(visionOS)
    
    public class Coordinator: NSObject, SFSafariViewControllerDelegate {
        let didFinish: (() -> Void)?
        
        public init(_ didFinish: @escaping () -> Void) {
            self.didFinish = didFinish
        }
        
        public func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
            self.didFinish?()
        }
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(didFinish)
    }
    
    #endif
}


extension SFSafariViewControllerRepresentation: UIViewControllerRepresentable {
    
    public func makeUIViewController(context: Context) -> SFSafariViewController {
        let c = SFSafariViewController(url: url, configuration: configuration)
        #if !os(visionOS)
        c.delegate = context.coordinator
        #endif
        sync(ctrl: c, ctx: context)
        return c
    }

    public func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
        sync(ctrl: uiViewController, ctx: context)
    }
    
}

#endif

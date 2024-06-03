#if canImport(UIKit)

import SwiftUI
import SafariServices

public struct SafariViewCtrlRepresentation {

    let url: URL
    let didFinish: () -> Void
    let configuration: SFSafariViewController.Configuration
    let preferredBarTintColor: UIColor?
    let preferredControlTintColor: UIColor?
    let dismissButtonStyle: SFSafariViewController.DismissButtonStyle

    public init(
        url: URL,
        configuration: SFSafariViewController.Configuration = .init(),
        preferredBarTintColor: UIColor? = nil,
        preferredControlTintColor: UIColor? = nil,
        dismissButtonStyle: SFSafariViewController.DismissButtonStyle = .close,
        didFinish: @escaping () -> Void = {}
    ) {
        self.url = url
        self.configuration = configuration
        self.didFinish = didFinish
        self.preferredBarTintColor = preferredBarTintColor
        self.preferredControlTintColor = preferredControlTintColor
        self.dismissButtonStyle = dismissButtonStyle
    }
    
    private func sync(ctrl: SFSafariViewController){
        ctrl.preferredBarTintColor = preferredBarTintColor
        ctrl.preferredControlTintColor = preferredControlTintColor
        ctrl.dismissButtonStyle = dismissButtonStyle
    }
    
    public class Coordinator: NSObject, SFSafariViewControllerDelegate {
        let didFinish: () -> Void
        
        var prewarmedTokens: [AnyObject] = []
        
        public init(_ didFinish: @escaping () -> Void) {
            self.didFinish = didFinish
        }
        
        public func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
            self.didFinish()
        }
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(didFinish)
    }
    
}


extension SafariViewCtrlRepresentation: UIViewControllerRepresentable {
    
    public func makeUIViewController(context: Context) -> SFSafariViewController {
        let c = SFSafariViewController(url: url, configuration: configuration)
        c.delegate = context.coordinator
        sync(ctrl: c)
        return c
    }

    public func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
        sync(ctrl: uiViewController)
    }
    
}

#endif

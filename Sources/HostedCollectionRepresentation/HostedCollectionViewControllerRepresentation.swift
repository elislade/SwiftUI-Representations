import SwiftUI

@available(iOS 16, macOS 11, *)
public struct HostedCollectionViewControllerRepresentation {

    public typealias Content = [CollectionSection]
    
    let updateDiffing: Bool
    let insets: EdgeInsets
    let scrollState: Binding<ScrollState>
    let content: Content
    
    public init(
        updateDiffing: Bool = true,
        insets: EdgeInsets = .init(),
        scrollState: Binding<ScrollState> = .constant(.section(0)),
        @CollectionSectionBuilder content: @escaping () -> Content
    ) {
        self.updateDiffing = updateDiffing
        self.insets = insets
        self.scrollState = scrollState
        self.content = content()
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(scrollState: scrollState)
    }
    
    public final class Coordinator: ScrollStateDelegate {
        
        let scrollState: Binding<ScrollState>
        
        init(scrollState: Binding<ScrollState>) {
            self.scrollState = scrollState
        }
        
        func stateDidChange(state: ScrollState) {
            
        }
    }
    
}


#if canImport(UIKit) || targetEnvironment(macCatalyst)

@available(iOS 16, *)
extension HostedCollectionViewControllerRepresentation : UIViewControllerRepresentable {
    
    public func makeUIViewController(context: Context) -> HostingCollectionViewController {
        let collection = HostingCollectionViewController(
            insets: .init(top: insets.top, left: insets.leading, bottom: insets.bottom, right: insets.trailing),
            initialScrollState: scrollState.wrappedValue,
            content: content
        )
        collection.scrollStateDelegate = context.coordinator
        return collection
    }
    
    public func updateUIViewController(_ uiViewController: HostingCollectionViewController, context: Context) {
        if updateDiffing {
            uiViewController.update(content, transaction: context.transaction)
        }
        uiViewController.update(scrollState: scrollState.wrappedValue)
        uiViewController.update(insets: insets)
    }
    
}


#endif

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
@available(macOS 11, *)
extension HostedCollectionViewControllerRepresentation : NSViewControllerRepresentable {
    
    public typealias NSViewControllerType = NSViewController //HostingCollectionViewController
    
    public func makeNSViewController(context: Context) -> NSViewControllerType {
       // let c = NSViewController()
        let collection = HostingCollectionViewController(
            insets: .init(top: insets.top, left: insets.leading, bottom: insets.bottom, right: insets.trailing),
            initialScrollState: scrollState.wrappedValue,
            content: content
        )
        collection.scrollStateDelegate = context.coordinator
//        c.view.layer = CALayer()
//        c.view.wantsLayer = true
//        c.view.backgroundColor = .init(gray: 0, alpha: 1)
        return collection
    }
    
    public func updateNSViewController(_ nsViewController: NSViewControllerType, context: Context) {
//        if updateDiffing {
//            nsViewController.update(content, transaction: context.transaction)
//        }
//        nsViewController.update(scrollState: scrollState.wrappedValue)
//        nsViewController.update(insets: insets)
    }
    
}
#endif


// MARK: - Scroll State


public enum ScrollState {
    case section(Int)
    case location(CGPoint)
    
    var value: (index: Int?, location: CGPoint?) {
        switch self {
        case .section(let i): return (i, nil)
        case .location(let p): return (nil, p)
        }
    }
}

extension ScrollState: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.value == rhs.value
    }
    
    public static func != (lhs: Self, rhs: Self) -> Bool {
        lhs.value != rhs.value
    }
}

protocol ScrollStateDelegate: AnyObject {
    func stateDidChange(state: ScrollState)
}

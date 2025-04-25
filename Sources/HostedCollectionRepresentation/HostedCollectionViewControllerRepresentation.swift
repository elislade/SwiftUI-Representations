import SwiftUI

@available(iOS 16, macOS 11, *)
public struct HostedCollectionRepresentation {

    public typealias Content = [CollectionSection]
    
    let updateDiffing: Bool
    let insets: EdgeInsets
    let sectionIndex: Binding<Int>
    let content: Content
    
    /// Initializes instance.
    ///
    /// - Note: You can disable update diffing to optimize performance where you know when or if data updates, to reduce unnecessary collection diffing.
    ///
    /// - Parameters:
    ///   - updateDiffing: Bool indicating if value update should trigger view update. Defaults to true.
    ///   - insets: EdgeInsets to inset scroll content by. Defaults to zero.
    ///   - sectionIndex: Binding to Current sectionIndex. Defaults to constant 0 binding.)
    ///   - content: Content that will be built with the CollectionSectionBuilder.
    public init(
        updateDiffing: Bool = true,
        insets: EdgeInsets = .init(),
        sectionIndex: Binding<Int> = .constant(0),
        @CollectionSectionBuilder content: @escaping () -> Content
    ) {
        self.updateDiffing = updateDiffing
        self.insets = insets
        self.sectionIndex = sectionIndex
        self.content = content()
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(section: sectionIndex)
    }
    
    public final class Coordinator: ScrollStateDelegate {
        
        let section: Binding<Int>
        
        init(section: Binding<Int>) {
            self.section = section
        }
        
        func didChangeOffset(offset: CGPoint) {}
        
        func didChangeSection(index: Int) {
            if index != section.wrappedValue {
                section.wrappedValue = index
            }
        }
    }
    
}


#if canImport(UIKit) || targetEnvironment(macCatalyst)

@available(iOS 16, tvOS 16.0, *)
extension HostedCollectionRepresentation : UIViewControllerRepresentable {
    
    public func makeUIViewController(context: Context) -> HostingCollectionViewController {
        let collection = HostingCollectionViewController(
            insets: insets,
            content: content
        )
        collection.update(insets: insets, layout: context.environment.layoutDirection)
        collection.scrollStateDelegate = context.coordinator
        return collection
    }
    
    public func updateUIViewController(_ uiViewController: HostingCollectionViewController, context: Context) {
        if updateDiffing {
            uiViewController.update(content, transaction: context.transaction)
        }
  
        uiViewController.scrollTo(section: sectionIndex.wrappedValue, transaction: sectionIndex.transaction)
        uiViewController.update(insets: insets, layout: context.environment.layoutDirection)
    }
    
}


#endif

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
@available(macOS 11, *)
extension HostedCollectionRepresentation : NSViewControllerRepresentable {
    
    public typealias NSViewControllerType = HostingCollectionViewController
    
    public func makeNSViewController(context: Context) -> NSViewControllerType {
        let collection = HostingCollectionViewController(
            insets: insets,
            content: content
        )
        collection.scrollStateDelegate = context.coordinator
        return collection
    }
    
    public func updateNSViewController(_ nsViewController: NSViewControllerType, context: Context) {
        if updateDiffing {
            nsViewController.update(content, transaction: context.transaction)
        }
        nsViewController.update(insets: insets)
        nsViewController.scrollTo(section: sectionIndex.wrappedValue, transaction: sectionIndex.transaction)
    }
    
}
#endif



protocol ScrollStateDelegate: AnyObject {
    func didChangeOffset(offset: CGPoint)
    func didChangeSection(index: Int)
}

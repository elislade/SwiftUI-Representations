import SwiftUI
#if canImport(QuickLook) && canImport(UIKit)
import QuickLook

public struct QLPreviewControllerRepresentation {
    
    let items: [any QLPreviewItem]
    let currentPreviewItemIndex: Int
    
    public init(
        items: [any QLPreviewItem],
        currentPreviewItemIndex: Int = 0
    ) {
        self.items = items
        self.currentPreviewItemIndex = currentPreviewItemIndex
    }
    
    private func sync(ctrl: QLPreviewController){
        ctrl.currentPreviewItemIndex = currentPreviewItemIndex
        ctrl.reloadData()
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator{ items }
    }
    
    public class Coordinator: QLPreviewControllerDataSource {
        
        let items: () -> [any QLPreviewItem]
        
        public init(_ items: @escaping () -> [any QLPreviewItem]) {
            self.items = items
        }
        
        // MARK: QLPreviewControllerDataSource
        
        public func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
            items().count
        }
        
        public func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
            items()[index]
        }
        
    }
}


extension QLPreviewControllerRepresentation: UIViewControllerRepresentable {
    
    public func makeUIViewController(context: Context) -> QLPreviewController {
        let c = QLPreviewController()
        c.dataSource = context.coordinator
        sync(ctrl: c)
        return c
    }
    
    public func updateUIViewController(_ uiViewController: QLPreviewController, context: Context) {
        sync(ctrl: uiViewController)
    }
    
}

#endif

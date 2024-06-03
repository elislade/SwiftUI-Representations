import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

@available(iOS 14.0, macOS 13.0, *)
public struct PhotoPickerViewCtrlRepresentation {

    let config: PHPickerConfiguration
    let results: ([PHPickerResult]) -> Void
    
    public init(
        config: PHPickerConfiguration = PHPickerConfiguration(),
        results: @escaping ([PHPickerResult]) -> Void
    ) {
        self.config = config
        self.results = results
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(results)
    }
    
    private func create(ctx: Context) -> PHPickerViewController {
        let c = PHPickerViewController(configuration: config)
        c.delegate = ctx.coordinator
        return c
    }
    
    public class Coordinator: PHPickerViewControllerDelegate {
        let results: ([PHPickerResult]) -> Void
        
        public init(_ res: @escaping ([PHPickerResult]) -> Void) {
            results = res
        }
        
        public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            self.results(results)
        }
    }
    
}

#if canImport(UIKit)

@available(iOS 14.0, *)
extension PhotoPickerViewCtrlRepresentation: UIViewControllerRepresentable {
    
    public func makeUIViewController(context: Context) -> PHPickerViewController {
        create(ctx: context)
    }
    
    public func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
        
    }
    
}

#elseif canImport(AppKit)

@available(macOS 13.0, *)
extension PhotoPickerViewCtrlRepresentation: NSViewControllerRepresentable {
    
    public func makeNSViewController(context: Context) -> PHPickerViewController {
        create(ctx: context)
    }
    
    public func updateNSViewController(_ nsViewController: PHPickerViewController, context: Context) { }
    
}

#endif

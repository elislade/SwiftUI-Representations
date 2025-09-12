import SwiftUI
import UniformTypeIdentifiers


public struct DocumentPicker {
    
    public enum Action {
        case exporting([URL])
        case importing([UTType])
    }
    
    let action: Action
    let copyResource: Bool
    let allowMultipleSelection: Bool
    let showFileExtension: Bool
    let directoryURL: URL?
    let completion: (Result<[URL], Error>) -> Void
    
    public init(
        _ action: Action,
        copyResource: Bool = false,
        allowMultipleSelection: Bool = true,
        showFileExtension: Bool = false,
        directoryURL: URL? = nil,
        completion: @escaping (Result<[URL], Error>) -> Void
    ) {
        self.action = action
        self.copyResource = copyResource
        self.allowMultipleSelection = allowMultipleSelection
        self.showFileExtension = showFileExtension
        self.directoryURL = directoryURL
        self.completion = completion
    }
    
    
    public enum Error: LocalizedError {
        case cancelled
        
        public var errorDescription: String? { "Cancelled" }
    }
    
}


#if canImport(UIKit)

extension DocumentPicker: UIViewControllerRepresentable {
    
    public func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        switch action {
        case .exporting(let urls):
            let c = UIDocumentPickerViewController(forExporting: urls, asCopy: copyResource)
            c.delegate = context.coordinator
            return c
        case .importing(let types):
            let c = UIDocumentPickerViewController(forOpeningContentTypes: types, asCopy: copyResource)
            c.delegate = context.coordinator
            return c
        }
    }
    
    public func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {
        uiViewController.allowsMultipleSelection = allowMultipleSelection
        uiViewController.shouldShowFileExtensions = showFileExtension
        uiViewController.directoryURL = directoryURL
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(completion: completion)
    }
    
    public final class Coordinator: NSObject, UIDocumentPickerDelegate {
        
        private var completion: (Result<[URL], Error>) -> Void
        
        public init(completion: @escaping (Result<[URL], Error>) -> Void = { _ in }) {
            self.completion = completion
        }
        
        public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            completion(.success(urls))
        }
        
        public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            completion(.failure(Error.cancelled))
        }
        
    }
    
}


public class UIDocumentPickerViewControllerObservable: UIDocumentPickerViewController, ObservableObject, Identifiable {
    
    public var id: Int { hashValue }
    
    public override var allowsMultipleSelection: Bool {
        willSet { objectWillChange.send() }
    }

    public override var shouldShowFileExtensions: Bool {
        willSet { objectWillChange.send() }
    }

    public override var directoryURL: URL? {
        willSet { objectWillChange.send() }
    }
    
}

#endif

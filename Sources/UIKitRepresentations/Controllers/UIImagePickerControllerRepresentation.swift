#if canImport(UIKit)

import SwiftUI

public struct UIImagePickerControllerRepresentation {
    
    let sourceType: UIImagePickerController.SourceType
    let picked: (UIImage?) -> Void
    
    public init(
        sourceType: UIImagePickerController.SourceType = .camera,
        picked: @escaping (UIImage?) -> Void
    ) {
        self.sourceType = sourceType
        self.picked = picked
    }
    
    private func sync(ctrl: UIImagePickerController){
        ctrl.sourceType = sourceType
    }
    
    public class Coordinator: NSObject, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
        let picked: (UIImage?) -> Void
        
        public init(_ picked: @escaping (UIImage?) -> Void) {
            self.picked = picked
        }
        
        public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picked(nil)
        }
        
        public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            picked(info[.originalImage] as? UIImage)
        }
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(picked)
    }
}


extension UIImagePickerControllerRepresentation: UIViewControllerRepresentable {
    
    public func makeUIViewController(context: Context) -> UIImagePickerController {
        let ctrl = UIImagePickerController()
        ctrl.delegate = context.coordinator
        sync(ctrl: ctrl)
        return ctrl
    }

    public func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        sync(ctrl: uiViewController)
    }
    
}

#endif


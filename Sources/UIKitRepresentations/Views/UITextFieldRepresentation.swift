import SwiftUI
import RepresentationUtils

#if canImport(UIKit)
import UIKit

public struct UITextFieldRepresentation {
    
    let placeholder: String?
    let text: Binding<String>
    let isFocused: Binding<Bool>
    
    public init(
        placeholder: String? = nil,
        text: Binding<String>,
        isFocused: Binding<Bool>
    ) {
        self.placeholder = placeholder
        self.text = text
        self.isFocused = isFocused
    }
    
    private func sync(view: UITextField, context: Context){
        view.placeholder = placeholder
        view.text = text.wrappedValue

        if let font = context.environment.font {
            let provider = resolveFont(font)
            view.font = provider?.font(with: nil)
        }
        
        if isFocused.wrappedValue {
            if view.canBecomeFirstResponder {
                view.becomeFirstResponder()
            }
        } else {
            if view.canResignFirstResponder {
                view.resignFirstResponder()
            }
        }
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(text: text, isFocused: isFocused)
    }
    
    final public class Coordinator: NSObject, UITextFieldDelegate {
        
        let text: Binding<String>
        let isFocused: Binding<Bool>
        
        init(text: Binding<String>, isFocused: Binding<Bool>) {
            self.text = text
            self.isFocused = isFocused
        }
        
        public func textFieldDidBeginEditing(_ textField: UITextField) {
            if isFocused.wrappedValue == false {
                isFocused.wrappedValue = true
            }
        }
        
        public func textFieldDidChangeSelection(_ textField: UITextField) {
            text.wrappedValue = textField.text ?? ""
        }
        
    }
}


extension UITextFieldRepresentation: UIViewRepresentable {
    
    public func makeUIView(context: Context) -> UITextField {
        let view = UITextField()
        view.delegate = context.coordinator
        sync(view: view, context: context)
        return view
    }
    
    public func updateUIView(_ uiView: UITextField, context: Context) {
        sync(view: uiView, context: context)
    }
    
}

#endif

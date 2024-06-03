import SwiftUI

#if canImport(UIKit)

import UIKit

public struct VisualEffectViewRepresentation: UIViewRepresentable {
    
    let effect: UIVisualEffect
    
    public init(effect: UIVisualEffect = UIBlurEffect(style: .systemUltraThinMaterial)){
        self.effect = effect
    }
    
    public func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: effect)
    }
    
    public func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        if effect != uiView.effect {
            uiView.effect = effect
        }
    }
    
}


#endif

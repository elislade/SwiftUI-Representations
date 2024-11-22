#if canImport(AppKit) && !targetEnvironment(macCatalyst)

import AppKit
import SwiftUI


public func resolveAnimation(_ animation: Animation) -> CustomAnimatable? {
    // TODO:
    return nil
}

final class NSAnimatedDelegateWrapper: NSObject, NSAnimationDelegate {
    
    var animationDidEnd: ((NSAnimation) -> Void)?
    var valueForProgress: ((NSAnimation, Float) -> Float)?
    
    func animationDidEnd(_ animation: NSAnimation) {
        animationDidEnd?(animation)
    }
    
    nonisolated func animation(_ animation: NSAnimation, valueForProgress progress: NSAnimation.Progress) -> Float {
        valueForProgress?(animation, progress) ?? progress
    }
    
}

struct InternalCustomAnimation {
    
    private let animation = NSAnimation()
    private let delegate = NSAnimatedDelegateWrapper()
    
    init(){
        animation.delegate = delegate
    }
    
}


extension InternalCustomAnimation : CustomAnimatable {
    
    func animate(block: @escaping () -> Void, completion: @escaping () -> Void) {
        NSAnimationContext.beginGrouping()
        NSAnimationContext.current.allowsImplicitAnimation = true
        NSAnimationContext.current.completionHandler = completion
        NSAnimationContext.current.timingFunction = .init(name: .linear)
        NSAnimationContext.current.duration = 1
        
        block()
        
        NSAnimationContext.endGrouping()
    }
    
}

#endif

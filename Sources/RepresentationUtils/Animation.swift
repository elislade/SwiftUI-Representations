import SwiftUI

public protocol CustomAnimatable {
    func animate(block: @escaping () -> Void, completion: @escaping () -> Void)
}

public extension CustomAnimatable {
    func animate(block: @escaping () -> Void){
        self.animate(block: block, completion: {})
    }
}


#if canImport(UIKit)
import UIKit


struct SpeedAnimationModifier: InternalCustomAnimationModifier {

    let speed: Double
    
    func modify(_ animation: inout InternalCustomAnimation) {
        animation.speed *= speed
    }
    
}


struct DelayAnimationModifier: InternalCustomAnimationModifier {
    
    let delay: Double
    
    func modify(_ animation: inout InternalCustomAnimation) {
        animation.delay += delay
    }
    
}


public func resolveAnimation(_ animation: Animation) -> CustomAnimatable? {
    let mirror = animation.customMirror

    guard let provider = mirror.descendant("base") else {
        return nil
    }
    
    return resolveAnimationProvider(provider)
}


func resolveAnimationProvider(_ animation: Any) -> InternalCustomAnimation? {
    let mirror = Mirror(reflecting: animation)
    let description = String(describing: type(of: animation))

    switch description {
    case "FluidSpringAnimation":
        guard
            let _ = mirror.descendant("response") as? Double,
            let dampingFraction = mirror.descendant("dampingFraction") as? Double,
            let blendDuration = mirror.descendant("blendDuration") as? Double
        else {
            return nil
        }
        
        let animator = UIViewPropertyAnimator(
            duration: blendDuration,
            timingParameters: UISpringTimingParameters(dampingRatio: dampingFraction)
        )
        
        return InternalCustomAnimation(animator: animator)
    case "SpringAnimation":
        guard
            let mass = mirror.descendant("mass") as? Double,
            let stiffness = mirror.descendant("stiffness") as? Double,
            let damping = mirror.descendant("damping") as? Double,
            let _ = mirror.descendant("_initialVelocity")
        else {
            return nil
        }
        
        let animator = UIViewPropertyAnimator(
            duration: 0,
            timingParameters: UISpringTimingParameters(
                mass: mass,
                stiffness: stiffness,
                damping: damping,
                initialVelocity: .zero
            )
        )
        
        return InternalCustomAnimation(animator: animator)
    case "BezierAnimation":
        guard
            let duration = mirror.descendant("duration") as? Double,
            let curve = mirror.descendant("curve")
        else {
            return nil
        }

        let animator = UIViewPropertyAnimator(
            duration: duration,
            timingParameters: resolveTimingCurve(curve) ?? UICubicTimingParameters()
        )
        
        return InternalCustomAnimation(animator: animator)
    case "InternalCustomAnimationModifiedContent<Animation, Modifier>" :
        // TODO: Delay and Speed
        return nil
    default:
        dump(animation)
        return nil
    }
}

final class InternalCustomAnimation {
    
    var speed: Double = 1
    var delay: Double = 0
    
    private let animator: UIViewImplicitlyAnimating
    
    init(animator: UIViewImplicitlyAnimating) {
        self.animator = animator
    }
    
}


extension InternalCustomAnimation: CustomAnimatable {
    
    public func animate(block: @escaping () -> Void, completion: @escaping () -> Void = {}){
        animator.addAnimations? { block() }
        animator.addCompletion? { _ in
            completion()
        }
        animator.startAnimation(afterDelay: delay)
    }
    
}

protocol InternalCustomAnimationModifier {
    
    func modify(_ animation: inout InternalCustomAnimation)
    
}


final class InternalCustomAnimationModifiedContent: CustomAnimatable {
    
    let modifiers: [InternalCustomAnimationModifier]
    private var content: InternalCustomAnimation
    
    init(_ modifiers: [InternalCustomAnimationModifier], content: InternalCustomAnimation) {
        self.modifiers = modifiers
        self.content = content
    }
    
    public func animate(block: @escaping () -> Void, completion: @escaping () -> Void) {
        for modifier in modifiers {
            modifier.modify(&content)
        }
        
        content.animate(block: block, completion: completion)
    }
    
}

#endif

#if (canImport(UIKit) || targetEnvironment(macCatalyst)) && !os(watchOS)

import UIKit

func resolveTimingCurve(_ obj: Any) -> UICubicTimingParameters? {
    let mirror = Mirror(reflecting: obj)

    if
        let ax = mirror.descendant("ax") as? Double,
        let bx = mirror.descendant("bx") as? Double,
        let _ = mirror.descendant("cx") as? Double,
        let ay = mirror.descendant("ay") as? Double,
        let by = mirror.descendant("by") as? Double,
        let _ = mirror.descendant("cy") as? Double
    {
        return UICubicTimingParameters(
            controlPoint1: CGPoint(x: ax, y: ay),
            controlPoint2: CGPoint(x: bx, y: by)
        )
    }
    
    return nil
}

#endif

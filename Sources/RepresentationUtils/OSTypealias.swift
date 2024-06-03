

// MARK: - OSHostingController


#if canImport(AppKit) && canImport(SwiftUI)

    import SwiftUI
    import AppKit
    public typealias OSHostingController = NSHostingController

#elseif canImport(UIKit) && canImport(SwiftUI)

    import SwiftUI
    import UIKit
    public typealias OSHostingController = UIHostingController

#else

public typealias OSHostingController = Never

#endif


// MARK: - OSView


#if canImport(AppKit)

    import AppKit
    public typealias OSView = NSView

    public extension NSView {
        var backgroundColor: CGColor? {
            get { layer?.backgroundColor }
            set { layer?.backgroundColor = newValue }
        }
    }

#elseif canImport(UIKit)

    import UIKit
    public typealias OSView = UIView

#else

public typealias OSView = Never

#endif


// MARK: - OSEdgeInsets


#if canImport(Cocoa)

    import Cocoa
    public typealias OSEdgeInsets = NSEdgeInsets

    extension NSEdgeInsets : Equatable {
        
        public static func == (lhs: NSEdgeInsets, rhs: NSEdgeInsets) -> Bool {
            lhs.bottom == rhs.bottom && lhs.top == rhs.top && lhs.left == rhs.left && lhs.right == rhs.right
        }
    
    }

#elseif canImport(UIKit)

    import UIKit
    public typealias OSEdgeInsets = UIEdgeInsets


#else

public typealias OSEdgeInsets = Never

#endif



// MARK: - OSViewController


#if canImport(AppKit)

    import AppKit
    public typealias OSViewController = NSViewController

#elseif canImport(UIKit)

    import UIKit
    public typealias OSViewController = UIViewController


#else

public typealias OSViewController = Never

#endif


// MARK: - OSFont


#if canImport(AppKit)

    import AppKit
    public typealias OSFont = NSFont
    public typealias OSFontDescriptor = NSFontDescriptor

#elseif canImport(UIKit)

    import UIKit
    public typealias OSFont = UIFont
    public typealias OSFontDescriptor = UIFontDescriptor

#else

public typealias OSFont = Never
public typealias OSFontDescriptor = Never

#endif



#if canImport(AppKit) && !targetEnvironment(macCatalyst)

    import SwiftUI
    import AppKit

    public typealias OSViewController = NSViewController
    public typealias OSHostingController = NSHostingController
    public typealias OSView = NSView
    public typealias OSColor = NSColor
    public typealias OSBezierPath = NSBezierPath

    public extension NSView {
        
        var backgroundColor: CGColor? {
            get { layer?.backgroundColor }
            set { layer?.backgroundColor = newValue }
        }
        
        var layoutMargins: NSEdgeInsets {
            get { additionalSafeAreaInsets }
            set { additionalSafeAreaInsets = newValue }
        }
        
        subscript<V>(key: ReferenceWritableKeyPath<CALayer, V>) -> V {
            get {
                if layer == nil {
                    layer = CALayer()
                    wantsLayer = true
                }
                return layer![keyPath: key]
            }
            set {
                if layer == nil {
                    layer = CALayer()
                    wantsLayer = true
                }
                layer?[keyPath: key] = newValue
            }
        }
    }

#elseif canImport(UIKit) && canImport(SwiftUI) && !os(watchOS)

    import SwiftUI
    import UIKit

    public typealias OSViewController = UIViewController
    public typealias OSHostingController = UIHostingController
    public typealias OSView = UIView
    public typealias OSColor = UIColor
    public typealias OSBezierPath = UIBezierPath

    public extension UIView {
        subscript<V>(key: ReferenceWritableKeyPath<CALayer, V>) -> V {
            get { layer[keyPath: key] }
            set { layer[keyPath: key] = newValue }
        }
    }

#else

    public typealias OSViewController = Never
    public typealias OSHostingController = Never
    public typealias OSView = Never
    public typealias OSColor = Never
    public typealias OSBezierPath = Never

#endif


// MARK: - EdgeInsets


#if canImport(Cocoa) && !targetEnvironment(macCatalyst)

    import Cocoa
    public typealias OSEdgeInsets = NSEdgeInsets

    extension NSEdgeInsets : @retroactive Equatable {
        
        public static var zero: Self = .init()
        
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


// MARK: - Font


#if canImport(AppKit) && !targetEnvironment(macCatalyst)

    import AppKit
    public typealias OSFont = NSFont
    public typealias OSFontDescriptor = NSFontDescriptor
    public typealias OSTraitCollection = Never
    
#elseif canImport(UIKit)

    import UIKit
    public typealias OSFont = UIFont
    public typealias OSFontDescriptor = UIFontDescriptor
    public typealias OSTraitCollection = UITraitCollection

#else

    public typealias OSFont = Never
    public typealias OSFontDescriptor = Never
    public typealias OSTraitCollection = Never

#endif


// MARK: - Image


#if canImport(AppKit) && !targetEnvironment(macCatalyst)

    import AppKit
    public typealias OSImage = NSImage

    public extension Image {
        init(osImage: OSImage){
            self.init(nsImage: osImage)
        }
    }

#elseif canImport(UIKit)

    import UIKit
    public typealias OSImage = UIImage

    public extension Image {
        init(osImage: OSImage){
            self.init(uiImage: osImage)
        }
    }

#else

    public typealias OSImage = Never

#endif


// MARK: - Gesture


#if canImport(AppKit) && !targetEnvironment(macCatalyst)

    import AppKit
    public typealias OSGestureRecognizer = NSGestureRecognizer
    public typealias OSTapGestureRecognizer = NSClickGestureRecognizer
    public typealias OSPanGestureRecognizer = NSPanGestureRecognizer
    public typealias OSRotationGestureRecognizer = NSRotationGestureRecognizer
    public typealias OSMagnificationGestureRecognizer = NSMagnificationGestureRecognizer

#elseif canImport(UIKit) && !os(watchOS)

    import UIKit
    public typealias OSGestureRecognizer = UIGestureRecognizer
    public typealias OSTapGestureRecognizer = UITapGestureRecognizer
    public typealias OSPanGestureRecognizer = UIPanGestureRecognizer
    #if os(tvOS)
    public typealias OSRotationGestureRecognizer = Never
    public typealias OSMagnificationGestureRecognizer = Never
    #else
    public typealias OSRotationGestureRecognizer = UIRotationGestureRecognizer
    public typealias OSMagnificationGestureRecognizer = UIPinchGestureRecognizer
    #endif

#else

    public typealias OSGestureRecognizer = Never
    public typealias OSTapGestureRecognizer = Never
    public typealias OSPanGestureRecognizer = Never
    public typealias OSRotationGestureRecognizer = Never
    public typealias OSMagnificationGestureRecognizer = Never

#endif


// MARK: - Text


#if canImport(AppKit) && !targetEnvironment(macCatalyst)

    import AppKit
    public typealias OSTextView = NSTextView

    public extension NSTextView {
        
        var text: String {
            get { string }
            set { string = newValue }
        }
        
        var textAlignment: NSTextAlignment {
            get { alignment }
            set { alignment = newValue }
        }
        
    }

#elseif canImport(UIKit)

    import UIKit
    public typealias OSTextView = UITextView

#else

    public typealias OSTextView = Never

#endif

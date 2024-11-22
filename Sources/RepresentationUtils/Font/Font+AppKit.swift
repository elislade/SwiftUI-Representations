#if canImport(AppKit) && !canImport(UIKit)

import AppKit


public extension NSFont {
    
    class func preferredFont(forTextStyle style: NSFont.TextStyle, compatibleWith traitCollection: OSTraitCollection?) -> NSFont {
        NSFont.preferredFont(forTextStyle: style, options: [:])
    }
    
}


public extension NSFontDescriptor {
    
    func withSymbolicTraits(_ symbolicTraits: NSFontDescriptor.SymbolicTraits) -> NSFontDescriptor? {
        let descriptor: NSFontDescriptor = withSymbolicTraits(symbolicTraits)
        return descriptor
    }
    
}


public extension NSFontDescriptor.SymbolicTraits {
    
    static var traitItalic: Self { .italic }
    static var traitBold: Self { .bold }
    static var traitExpanded: Self { .expanded }
    static var traitCondensed: Self { .condensed }
    static var traitMonoSpace: Self { .monoSpace }
    static var traitVertical: Self { .vertical }
    static var traitUIOptimized: Self { .UIOptimized }
    static var traitTightLeading: Self { .tightLeading }
    static var traitLooseLeading: Self { .looseLeading  }
    
}


#endif

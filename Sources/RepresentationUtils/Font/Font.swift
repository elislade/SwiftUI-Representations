import SwiftUI

// MARK: - Contracts


public protocol FontProvider {
    func fontDescriptor(with traitCollection: OSTraitCollection?) -> OSFontDescriptor
}

public extension FontProvider {
    
    func font(with traitCollection: OSTraitCollection?) -> OSFont {
        OSFont(descriptor: fontDescriptor(with: traitCollection), size: 0) ?? OSFont()
    }
    
}


public protocol FontModifier {
    func modify(_ fontDescriptor: inout OSFontDescriptor)
}


public protocol StaticFontModifier: FontModifier {
    init()
}


// MARK: - Mocks


struct SystemProvider: FontProvider {
    
    var size: CGFloat
    var design: OSFontDescriptor.SystemDesign
    var weight: OSFont.Weight?

    func fontDescriptor(with traitCollection: OSTraitCollection?) -> OSFontDescriptor {
        OSFont
            .preferredFont(forTextStyle: .body, compatibleWith: traitCollection)
            .fontDescriptor
            .withDesign(design)!
            .addingAttributes([
                .size: size
            ])
    }
}


struct NamedProvider: FontProvider {
    
    var name: String
    var size: CGFloat
    var textStyle: OSFont.TextStyle?

    func fontDescriptor(with traitCollection: OSTraitCollection?) -> OSFontDescriptor {
        guard let textStyle = textStyle else {
            return OSFontDescriptor(fontAttributes: [
                .family: name,
                .size: size
            ])
        }
        
        #if canImport(UIKit)
        
        let metrics = UIFontMetrics(forTextStyle: textStyle)

        return OSFontDescriptor(fontAttributes: [
            .family: name,
            .size: metrics.scaledValue(for: size, compatibleWith: traitCollection)
        ])
        
        #else
        
        return OSFontDescriptor(fontAttributes: [
            .family: name,
            .size: size
        ])
        
        #endif
    }
    
}


struct TextStyleProvider: FontProvider {
    
    var design: OSFontDescriptor.SystemDesign
    var textStyle: OSFont.TextStyle?

    func fontDescriptor(with traitCollection: OSTraitCollection?) -> OSFontDescriptor {
        OSFont
            .preferredFont(forTextStyle: textStyle ?? .body, compatibleWith: traitCollection)
            .fontDescriptor
            .withDesign(design)!
    }
    
}

struct StaticModifierProvider<M: StaticFontModifier>: FontProvider {
    
    var base: FontProvider

    func fontDescriptor(with traitCollection: OSTraitCollection?) -> OSFontDescriptor {
        var descriptor = base.fontDescriptor(with: traitCollection)

        M().modify(&descriptor)

        return descriptor
    }
    
}

struct ModifierProvider: FontProvider {
    
    let base: FontProvider
    let modifier: FontModifier
    
    func fontDescriptor(with traitCollection: OSTraitCollection?) -> OSFontDescriptor {
        var descriptor = base.fontDescriptor(with: traitCollection)
        modifier.modify(&descriptor)
        return descriptor
    }
    
}

struct ItalicModifier: StaticFontModifier {
    
    init() {}

    func modify(_ fontDescriptor: inout OSFontDescriptor) {
        fontDescriptor = fontDescriptor.withSymbolicTraits(.traitItalic) ?? fontDescriptor
    }
    
}


struct WeightModifier: FontModifier {
    
    let weight: OSFont.Weight
    
    init(weight: OSFont.Weight) {
        self.weight = weight
    }

    func modify(_ fontDescriptor: inout OSFontDescriptor) {
        fontDescriptor = fontDescriptor.addingAttributes([
            OSFontDescriptor.AttributeName.traits : [
                OSFontDescriptor.TraitKey.weight : weight.rawValue
            ]
        ])
    }
    
}


// MARK: - Extensions


public extension Font.Design {
    
    var osSystemDesign: OSFontDescriptor.SystemDesign {
        switch self {
        case .default: return .default
        case .serif: return .serif
        case .rounded: return .rounded
        case .monospaced: return .monospaced
        @unknown default: return .default
        }
    }
    
}


public extension Font.Weight {
    
    var osFontWeight: OSFont.Weight {
        if self == .black {
            return .black
        } else if self == .bold {
            return .bold
        } else if self == .heavy {
            return .heavy
        } else if self == .semibold {
            return .semibold
        } else if self == .medium {
            return .medium
        } else if self == .regular {
            return .regular
        } else if self == .thin {
            return .thin
        } else if self == .light {
            return .light
        } else if self == .ultraLight {
            return .ultraLight
        } else {
            return .regular
        }
    }
    
}

public extension Font.TextStyle {
    
    var osTextStyle: OSFont.TextStyle {
        switch self {
        case .largeTitle: return .largeTitle
        case .title: return .title1
        case .title2: return .title2
        case .title3: return .title3
        case .headline: return .headline
        case .subheadline: return .subheadline
        case .body: return .body
        case .callout: return .callout
        case .footnote: return .footnote
        case .caption: return .caption1
        case .caption2: return .caption2
        case .extraLargeTitle:
            #if canImport(UIKit)
            if #available(iOS 17.0, *) {
                return .extraLargeTitle
            } else {
                return .largeTitle
            }
            #else
            return .largeTitle
            #endif
        case .extraLargeTitle2:
            #if canImport(UIKit)
            if #available(iOS 17.0, *) {
                return .extraLargeTitle2
            } else {
                return .largeTitle
            }
            #else
            return .largeTitle
            #endif
        @unknown default:
            return .body
        }
    }
    
}


// MARK: - Resolvers


public func resolveFont(_ font: Font) -> FontProvider? {
    let mirror = Mirror(reflecting: font)

    guard let provider = mirror.descendant("provider", "base") else {
        return nil
    }

    return resolveFontProvider(provider)
}

func resolveFontProvider(_ provider: Any) -> FontProvider? {
    let mirror = Mirror(reflecting: provider)
    let description = String(describing: type(of: provider))
    switch description {
    case "StaticModifierProvider<ItalicModifier>":
        guard let base = mirror.descendant("base", "provider", "base") else {
            return nil
        }

        return resolveFontProvider(base).map(StaticModifierProvider<ItalicModifier>.init)
    case "SystemProvider":
        guard 
            let size = mirror.descendant("size") as? CGFloat,
            let design = mirror.descendant("design") as? Font.Design
        else {
            return nil
        }

        let weight = mirror.descendant("weight") as? Font.Weight

        return SystemProvider(size: size, design: design.osSystemDesign, weight: weight?.osFontWeight)
    case "NamedProvider":
        guard 
            let name = mirror.descendant("name") as? String,
            let size = mirror.descendant("size") as? CGFloat
        else {
            return nil
        }

        let textStyle = mirror.descendant("textStyle") as? Font.TextStyle

        return NamedProvider(name: name, size: size, textStyle: textStyle?.osTextStyle)
    case "TextStyleProvider":
        guard
            let style = mirror.descendant("style") as? Font.TextStyle,
            let design = mirror.descendant("design") as? Font.Design
        else {
            return nil
        }
        
        return TextStyleProvider(design: design.osSystemDesign, textStyle: style.osTextStyle)
    case "ModifierProvider<WeightModifier>":
        guard 
            let base = mirror.descendant("base", "provider", "base"),
            let weight = mirror.descendant("modifier", "weight") as? Font.Weight
        else {
            return nil
        }

        if let provider = resolveFontProvider(base) {
            return ModifierProvider(
                base: provider,
                modifier: WeightModifier(weight: weight.osFontWeight)
            )
        } else {
            return nil
        }
    default:
        print("Font", description)
        dump(provider)
        return nil
    }
}

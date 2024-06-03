import SwiftUI

#if canImport(UIKit)

import UIKit

///
/// A more fleshed out version of what is described here
/// https://movingparts.io/fonts-in-swiftui
///


// MARK: - Contracts


public protocol FontProvider {
    func fontDescriptor(with traitCollection: UITraitCollection?) -> UIFontDescriptor
}

public extension FontProvider {
    func font(with traitCollection: UITraitCollection?) -> UIFont {
        UIFont(descriptor: fontDescriptor(with: traitCollection), size: 0)
    }
}

public protocol FontModifier {
    func modify(_ fontDescriptor: inout UIFontDescriptor)
}

public protocol StaticFontModifier: FontModifier {
    init()
}


// MARK: - Mocks


struct SystemProvider: FontProvider {
    
    var size: CGFloat
    var design: UIFontDescriptor.SystemDesign
    var weight: UIFont.Weight?

    func fontDescriptor(with traitCollection: UITraitCollection?) -> UIFontDescriptor {
        UIFont
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
    var textStyle: UIFont.TextStyle?

    func fontDescriptor(with traitCollection: UITraitCollection?) -> UIFontDescriptor {
        if let textStyle = textStyle {
            let metrics = UIFontMetrics(forTextStyle: textStyle)

            return UIFontDescriptor(fontAttributes: [
                .family: name,
                .size: metrics.scaledValue(for: size, compatibleWith: traitCollection)
            ])
        } else {
            return UIFontDescriptor(fontAttributes: [
                .family: name,
                .size: size
            ])
        }
    }
}

struct TextStyleProvider: FontProvider {
    
    var design: UIFontDescriptor.SystemDesign
    var textStyle: UIFont.TextStyle?

    func fontDescriptor(with traitCollection: UITraitCollection?) -> UIFontDescriptor {
        UIFont
            .preferredFont(forTextStyle: textStyle ?? .body, compatibleWith: traitCollection)
            .fontDescriptor
            .withDesign(design)!
    }
}

struct StaticModifierProvider<M: StaticFontModifier>: FontProvider {
    
    var base: FontProvider

    func fontDescriptor(with traitCollection: UITraitCollection?) -> UIFontDescriptor {
        var descriptor = base.fontDescriptor(with: traitCollection)

        M().modify(&descriptor)

        return descriptor
    }
}

struct ModifierProvider: FontProvider {
    
    let base: FontProvider
    let modifier: FontModifier
    
    func fontDescriptor(with traitCollection: UITraitCollection?) -> UIFontDescriptor {
        var descriptor = base.fontDescriptor(with: traitCollection)
        modifier.modify(&descriptor)
        return descriptor
    }
}

struct ItalicModifier: StaticFontModifier {
    
    init() {}

    func modify(_ fontDescriptor: inout UIFontDescriptor) {
        fontDescriptor = fontDescriptor.withSymbolicTraits(.traitItalic) ?? fontDescriptor
    }
}

struct WeightModifier: FontModifier {
    
    let weight: UIFont.Weight
    
    init(weight: UIFont.Weight) {
        self.weight = weight
    }

    func modify(_ fontDescriptor: inout UIFontDescriptor) {
        fontDescriptor = fontDescriptor.addingAttributes([
            UIFontDescriptor.AttributeName.traits : [
                UIFontDescriptor.TraitKey.weight : weight.rawValue
            ]
        ])
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

        return SystemProvider(size: size, design: design.uiSystemDesign, weight: weight?.uiFontWeight)
    case "NamedProvider":
        guard 
            let name = mirror.descendant("name") as? String,
            let size = mirror.descendant("size") as? CGFloat
        else {
            return nil
        }

        let textStyle = mirror.descendant("textStyle") as? Font.TextStyle

        return NamedProvider(name: name, size: size, textStyle: textStyle?.uiTextStyle)
    case "TextStyleProvider":
        guard
            let style = mirror.descendant("style") as? Font.TextStyle,
            let design = mirror.descendant("design") as? Font.Design
        else {
            return nil
        }
        
        return TextStyleProvider(design: design.uiSystemDesign, textStyle: style.uiTextStyle)
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
                modifier: WeightModifier(weight: weight.uiFontWeight)
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

#endif

import SwiftUI

#if canImport(UIKit)

import UIKit

public extension Font.Design {
    var uiSystemDesign: UIFontDescriptor.SystemDesign {
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
    var uiFontWeight: UIFont.Weight {
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
    var uiTextStyle: UIFont.TextStyle {
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
            if #available(iOS 17.0, *) {
                return .extraLargeTitle
            } else {
                return .largeTitle
            }
        case .extraLargeTitle2:
            if #available(iOS 17.0, *) {
                return .extraLargeTitle2
            } else {
                return .largeTitle
            }
        @unknown default:
            return .body
        }
    }
}

#endif

@_exported import SwiftUI

#if canImport(SafariServices) && !os(macOS)
@_exported import SafariServices


#if os(visionOS)

public enum DismissButtonStyle: Int {
    case done = 0
    case close = 1
    case cancel = 2
}

#else

public typealias DismissButtonStyle = SFSafariViewController.DismissButtonStyle

#endif

#endif

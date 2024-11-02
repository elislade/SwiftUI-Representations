@_exported import SwiftUI
@_exported import WebKit
@_exported import RepresentationUtils


public typealias WKWebViewRepresentation = RepresentationUtils.OSViewRepresentation


extension OSEdgeInsets {
    
    func insets(ignoring edges: Edge.Set, leftToRight: Bool = true) -> Self {
        var copy = self
        if leftToRight {
            if edges.contains(.leading) { copy.left = 0 }
            if edges.contains(.trailing) { copy.right = 0 }
        } else {
            if edges.contains(.trailing) { copy.left = 0 }
            if edges.contains(.leading) { copy.right = 0 }
        }
        if edges.contains(.top) { copy.top = 0 }
        if edges.contains(.bottom) { copy.bottom = 0 }
        return copy
    }
    
}

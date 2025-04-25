@_exported import SwiftUI
@_exported import SceneKit
@_exported import RepresentationUtils


#if os(iOS) || os(visionOS) || os(tvOS)
public typealias SCNFloat = Float
#elseif os(macOS)
public typealias SCNFloat = CGFloat
#else
public typealias SCNFloat = Never
#endif

@_exported import SwiftUI
@_exported import PDFKit
@_exported import RepresentationUtils


public typealias PDFViewRepresentation = RepresentationUtils.OSViewRepresentation


public extension PDFDisplayMode {
    
    var columns: Int {
        self == .twoUp || self == .twoUpContinuous ? 2 : 1
    }
    
}

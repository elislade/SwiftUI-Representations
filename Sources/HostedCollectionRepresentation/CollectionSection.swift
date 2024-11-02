import SwiftUI


public struct CollectionSection {
    
    let layout: Layout
    let header: () -> AnyView
    let cells: [Cell]
    
    public init<Header: View>(
        layout: Layout = .init(),
        @CollectionSectionCellBuilder cells: @escaping () -> [Cell],
        @ViewBuilder header: @escaping () -> Header
    ) {
        self.layout = layout
        self.header = { AnyView(header()) }
        self.cells = cells()
    }
    
}


// MARK: - Layout

extension CollectionSection {
    
    public struct Layout: Equatable, Sendable {
        
        let isHeaderPinned: Bool
        let spacing: Double
        let insets: EdgeInsets
        let columns: Int
        
        public init(
            columns: Int = 2,
            spacing: Double = 0,
            isHeaderPinned: Bool = false,
            insets: EdgeInsets = .init()
        ) {
            self.columns = columns
            self.spacing = spacing
            self.insets = insets
            self.isHeaderPinned = isHeaderPinned
        }
        
    }
    
}


//MARK: - Cell

extension CollectionSection {
    
    public struct Cell: Hashable {
        
        public static func == (lhs: CollectionSection.Cell, rhs: CollectionSection.Cell) -> Bool {
            lhs.id == rhs.id
        }
        
        public func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
        
        public let id: AnyHashable
        public let view: () -> AnyView
        
        public init<V: View>(id: AnyHashable, @ViewBuilder view: @escaping () -> V) {
            self.id = id
            self.view = { AnyView(view()) }
        }
    }
    
}


//MARK: - View

extension CollectionSection: View {
    
    /// Empty View conformance to allow for the SwiftUI ForEach to accept A CollectionSection so that the result builders work correctly.
    public var body: EmptyView { EmptyView() }
    
}

import SwiftUI


public struct CollectionSection {
    
    let layout: Layout
    let header: () -> AnyView
    let cells: [Cell]
    
    public nonisolated init<Header: View>(
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
    
    public struct Layout: Equatable, Sendable, BitwiseCopyable {
        
        public var pinHeader: Bool
        public var spacing: Double
        public var insets: EdgeInsets
        public var columns: Int
        
        public init(
            columns: Int = 2,
            spacing: Double = 0,
            pinHeader: Bool = false,
            insets: EdgeInsets = .init()
        ) {
            self.columns = columns
            self.spacing = spacing
            self.insets = insets
            self.pinHeader = pinHeader
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
    
    // Fallback to SwiftUI.Section View when being built by normal ViewBuilder as a View.
    public var body: some View {
        Section {
            LazyVGrid(
                columns: Array(repeating: .init(spacing: layout.spacing), count: layout.columns),
                spacing: layout.spacing
            ){
                ForEach(cells, id: \.id){
                    $0.view()
                }
            }
            .padding(layout.insets)
            .animation(.smooth, value: layout)
            .animation(.smooth, value: cells.indices)
        } header: {
            header()
        }
    }
    
}

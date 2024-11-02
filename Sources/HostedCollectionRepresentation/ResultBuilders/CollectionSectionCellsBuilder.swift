import SwiftUI


@resultBuilder public struct CollectionSectionCellBuilder {
    
    public typealias Result = [CollectionSection.Cell]
    
    public static func buildBlock() -> Result {
        []
    }
    
    public static func buildBlock<Content: View>(_ content: Content) -> Result {
        return [CollectionSection.Cell(id: 0){ content }]
    }
    
    public static func buildBlock<each C: View>(_ c: repeat each C) -> Result {
        var res = Result()
        repeat res.append(contentsOf: CollectionSectionCellBuilder.buildBlock(each c))
        return res
    }
    
    
    // SwiftUI View
    
    public static func buildPartialBlock<Data: RandomAccessCollection, ID: Hashable, Element: View>(first: ForEach<Data, ID, Element>) -> Result where Data.Index : Hashable, ID == Data.Index {
        first.data.indices.map { idx in
            CollectionSection.Cell(id: idx){ first.content(first.data[idx]) }
        }
    }
    
    public static func buildPartialBlock<V: View>(first: V) -> Result {
        CollectionSectionCellBuilder.buildBlock(first)
    }
    
    
    public static func buildPartialBlock<V: View>(accumulated: Result, next: V) -> Result {
        accumulated + CollectionSectionCellBuilder.buildBlock(next)
    }
    
    
    // ForEach
    
    public static func buildPartialBlock<Data: RandomAccessCollection, ID: Hashable, Element: View>(first: ForEach<Data, ID, Element>) -> Result {
        CollectionSectionCellBuilder.buildBlock(first)
    }
    
    public static func buildPartialBlock<Data: RandomAccessCollection, ID: Hashable, Element: View>(accumulated: Result, next: ForEach<Data, ID, Element>) -> Result where Data.Index : Hashable, ID == Data.Index {
        
        accumulated + next.data.indices.map { idx in
            CollectionSection.Cell(id: idx){ next.content(next.data[idx]) }
        }
    }
    
    public static func buildPartialBlock<Data: RandomAccessCollection, ID: Hashable, Element: View>(accumulated: Result, next: ForEach<Data, ID, Element>) -> Result {
        accumulated + CollectionSectionCellBuilder.buildBlock(next)
    }
    
    public static func buildFinalResult(_ component: Result) -> Result {
        component.enumerated().map {
            if let int = $0.element.id as? Int, int == 0 {
                return .init(id: $0.offset, view: $0.element.view)
            } else {
                return $0.element
            }
        }
    }
    
    public static func buildEither<V: View>(second component: V) -> Result {
        CollectionSectionCellBuilder.buildBlock(component)
    }
    
    public static func buildEither<V: View>(first component: V) -> Result {
        CollectionSectionCellBuilder.buildBlock(component)
    }
    
    public static func buildBlock<C: View>(_ c: C...) -> Result {
        var res = Result()
        
        for item in c {
            res.append(contentsOf: CollectionSectionCellBuilder.buildBlock(item))
        }
        
        return res
    }
    
}

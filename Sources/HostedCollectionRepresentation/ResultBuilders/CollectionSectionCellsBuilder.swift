import SwiftUI


@resultBuilder public struct CollectionSectionCellBuilder {
    
    public typealias Result = [CollectionSection.Cell]
    
    public static func buildBlock() -> Result {
        []
    }
    
    public static func buildBlock<Content: View>(_ content: Content) -> Result {
        if let id = Mirror(reflecting: content).descendant("id") as? AnyHashable {
            return [CollectionSection.Cell(id: id){ content }]
        } else {
            return [CollectionSection.Cell(id: 0){ content }]
        }
    }
    
    public static func buildBlock<each C: View>(_ c: repeat each C) -> Result {
        var res = Result()
        repeat res.append(contentsOf: CollectionSectionCellBuilder.buildBlock(each c))
        return res
    }
    
    
    // Tuple
    
    public static func buildBlock<First: View, Second: View>(_ content: TupleView<(First,Second)>) -> Result {
        let a = CollectionSectionCellBuilder.buildBlock(content.value.0)
        let b = CollectionSectionCellBuilder.buildBlock(content.value.1)
        return a + b
    }
        
    
    // SwiftUI View
    
    public static func buildPartialBlock<V: View>(first: V) -> Result {
        return CollectionSectionCellBuilder.buildBlock(first)
    } 
    
    public static func buildPartialBlock<V: View>(accumulated: Result, next: V) -> Result {
        if let id = Mirror(reflecting: next).descendant("id") as? AnyHashable {
            return accumulated + [CollectionSection.Cell(id: id){ next }]
        } else {
            return accumulated + [CollectionSection.Cell(id: accumulated.count + 1){ next }]
        }
    }
    
    
    // ForEach
    
    
    public static func buildBlock<Data: RandomAccessCollection, ID: Hashable, Element: View>(_ content: ForEach<Data, ID, Element>) -> Result {
        let mirror = Mirror(reflecting: content)
        let idPath = mirror.descendant("idGenerator", "keyPath") as! KeyPath<Data.Element, ID>
        
        return content.data.lazy.map { ele in
            CollectionSection.Cell(id: ele[keyPath: idPath]){
                content.content(ele)
            }
        }
    }
    
    public static func buildPartialBlock<Data: RandomAccessCollection, ID: Hashable, Element: View>(first: ForEach<Data, ID, Element>) -> Result {
        Self.buildBlock(first)
    }
    
    public static func buildPartialBlock<Data: RandomAccessCollection, ID: Hashable, Element: View>(accumulated: Result, next: ForEach<Data, ID, Element>) -> Result {
        return accumulated + Self.buildBlock(next)
    }
    
    public static func buildFinalResult(_ component: Result) -> Result {
        return component
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

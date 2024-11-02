import SwiftUI


@resultBuilder public struct CollectionSectionBuilder {
    
    public typealias Result = [CollectionSection]
    
    public static func buildBlock() -> Result {
        []
    }
    
    public static func buildBlock(_ content: CollectionSection) -> Result {
        return [content]
    }
    
    public static func buildBlock<Content: View>(_ content: Content) -> Result {
        return [CollectionSection{ content } header: { EmptyView() } ]
    }
    
    public static func buildBlock<each C: View>(_ c: repeat each C) -> Result {
        var res = Result()
        repeat res.append(contentsOf: CollectionSectionBuilder.buildBlock(each c))
        return res
    }
    
    
    // SwiftUI View
    
    
    public static func buildPartialBlock(first: CollectionSection) -> Result {
        CollectionSectionBuilder.buildBlock(first)
    }
    
    public static func buildPartialBlock<V: View>(first: V) -> Result {
        CollectionSectionBuilder.buildBlock(first)
    }
    
    public static func buildPartialBlock(accumulated: Result, next: CollectionSection) -> Result {
        accumulated + CollectionSectionBuilder.buildBlock(next)
    }
    
    public static func buildPartialBlock<V: View>(accumulated: Result, next: V) -> Result {
        accumulated + CollectionSectionBuilder.buildBlock(next)
    }
    
    
    // ForEach
    
    public static func buildPartialBlock<Data: RandomAccessCollection, ID: Hashable>(first: ForEach<Data, ID, CollectionSection>) -> Result {
        first.data.map { first.content($0) }
    }
    
    public static func buildPartialBlock<Data: RandomAccessCollection,ID: Hashable, Element: View>(first: ForEach<Data, ID, Element>) -> Result {
        CollectionSectionBuilder.buildBlock(first)
    }
    
    public static func buildPartialBlock<Data: RandomAccessCollection, ID: Hashable>(accumulated: Result, next: ForEach<Data, ID, CollectionSection>) -> Result {
        accumulated + next.data.map { next.content($0) }
    }
    
    public static func buildPartialBlock<Data: RandomAccessCollection,ID: Hashable, Element: View>(accumulated: Result, next: ForEach<Data, ID, Element>) -> Result {
        accumulated + CollectionSectionBuilder.buildBlock(next)
    }
    
    public static func buildFinalResult(_ component: Result) -> Result {
        component
    }
    
    public static func buildEither<V: View>(second component: V) -> Result {
        CollectionSectionBuilder.buildBlock(component)
    }
    
    public static func buildEither<V: View>(first component: V) -> Result {
        CollectionSectionBuilder.buildBlock(component)
    }
    
    public static func buildBlock<C: View>(_ c: C...) -> Result {
        var res = Result()
        
        for item in c {
            res.append(contentsOf: CollectionSectionBuilder.buildBlock(item))
        }
        
        return res
    }
    
    public static func buildBlock<Data: RandomAccessCollection, ID: Hashable, Element: View>(_ content: ForEach<Data, ID, Element>) -> Result {
        content.data.map {
            CollectionSectionBuilder.buildBlock(content.content($0))
        }.flatMap{ $0 }
    }
    
}

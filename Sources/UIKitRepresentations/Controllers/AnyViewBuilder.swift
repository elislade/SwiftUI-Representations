import RepresentationUtils


@resultBuilder public struct AnyViewBuilder {
    
    public typealias Result = [AnyView]
    
    public static func buildBlock() -> Result {
        []
    }
    
    public static func buildBlock<Content: View>(_ content: Content) -> Result {
        return [AnyView(content)]
    }
    
    public static func buildBlock<each C: View>(_ c: repeat each C) -> Result {
        var res = Result()
        repeat res.append(contentsOf: AnyViewBuilder.buildBlock(each c))
        return res
    }
    
    
    // SwiftUI View
    
    
    public static func buildPartialBlock<V: View>(first: V) -> Result {
        AnyViewBuilder.buildBlock(first)
    }
    
    
    public static func buildPartialBlock<V: View>(accumulated: Result, next: V) -> Result {
        accumulated + AnyViewBuilder.buildBlock(next)
    }
    
    
    // ForEach
    
    public static func buildPartialBlock<Data: RandomAccessCollection,ID: Hashable, Element: View>(first: ForEach<Data, ID, Element>) -> Result {
        AnyViewBuilder.buildBlock(first)
    }
    
    public static func buildPartialBlock<Data: RandomAccessCollection, ID: Hashable, Element: View>(accumulated: Result, next: ForEach<Data, ID, Element>) -> Result {
        accumulated + AnyViewBuilder.buildBlock(next)
    }
    
    public static func buildFinalResult(_ component: Result) -> Result {
        component
    }
    
    public static func buildEither<V: View>(second component: V) -> Result {
        AnyViewBuilder.buildBlock(component)
    }
    
    public static func buildEither<V: View>(first component: V) -> Result {
        AnyViewBuilder.buildBlock(component)
    }
    
    public static func buildBlock<C: View>(_ c: C...) -> Result {
        var res = Result()
        
        for item in c {
            res.append(contentsOf: AnyViewBuilder.buildBlock(item))
        }
        
        return res
    }
    
    public static func buildBlock<Data: RandomAccessCollection, ID: Hashable, Element: View>(_ content: ForEach<Data, ID, Element>) -> Result {
        content.data.map {
            AnyViewBuilder.buildBlock(content.content($0))
        }.flatMap{ $0 }
    }
    
}


import RepresentationUtils


@resultBuilder public struct ViewControllerBuilder {
    
    public typealias Result = [OSViewController]
    
    public static func buildBlock() -> Result {
        []
    }
    
    public static func buildBlock(_ content: OSViewController) -> Result {
        return [content]
    }
    
    public static func buildBlock<Content: View>(_ content: Content) -> Result {
        return [OSHostingController(rootView: content)]
    }
    
    public static func buildBlock<each C: View>(_ c: repeat each C) -> Result {
        var res = Result()
        repeat res.append(contentsOf: ViewControllerBuilder.buildBlock(each c))
        return res
    }
    
    
    // OSViewController
    
    public static func buildPartialBlock(first: OSViewController) -> Result {
        [first]
    }
    
    public static func buildPartialBlock(accumulated: Result, next: OSViewController) -> Result {
        accumulated + [next]
    }
    
    
    // SwiftUI View
    
    
    public static func buildPartialBlock<V: View>(first: V) -> Result {
        ViewControllerBuilder.buildBlock(first)
    }
    
    
    public static func buildPartialBlock<V: View>(accumulated: Result, next: V) -> Result {
        accumulated + ViewControllerBuilder.buildBlock(next)
    }
    
    
    // ForEach
    
//    public static func buildPartialBlock<Data: RandomAccessCollection,ID: Hashable>(first: SwiftUI.ForEach<Data, ID, Result>) -> Result {
//        ViewControllerBuilder.buildBlock(first)
//    }
    
    public static func buildPartialBlock<Data: RandomAccessCollection,ID: Hashable, Element: View>(first: ForEach<Data, ID, Element>) -> Result {
        ViewControllerBuilder.buildBlock(first)
    }
    
    public static func buildPartialBlock<Data: RandomAccessCollection,ID: Hashable, Element: View>(accumulated: Result, next: ForEach<Data, ID, Element>) -> Result {
        accumulated + ViewControllerBuilder.buildBlock(next)
    }
    
    
    public static func buildFinalResult(_ component: Result) -> Result {
        component
    }
    
    public static func buildEither<V: View>(second component: V) -> Result {
        ViewControllerBuilder.buildBlock(component)
    }
    
    public static func buildEither<V: View>(first component: V) -> Result {
        ViewControllerBuilder.buildBlock(component)
    }
    
    public static func buildBlock<C: View>(_ c: C...) -> Result {
        var res = Result()
        
        for item in c {
            res.append(contentsOf: ViewControllerBuilder.buildBlock(item))
        }
        
        return res
    }
    
    public static func buildBlock<Data: RandomAccessCollection, ID: Hashable, Element: View>(_ content: ForEach<Data, ID, Element>) -> Result {
        content.data.map {
            ViewControllerBuilder.buildBlock(content.content($0))
        }.flatMap{ $0 }
    }
    
    
//    public static func buildBlock<Data: RandomAccessCollection, ID: Hashable>(_ content: ForEach<Data, ID, OSViewController>) -> Result {
//        content.data.map {
//            ViewControllerBuilder.buildBlock(content.content($0))
//        }.flatMap{ $0 }
//    }
    
}

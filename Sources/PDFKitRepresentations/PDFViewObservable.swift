import PDFKit
import Combine
import RepresentationUtils


public class PDFViewObservable: PDFView, ObservableObject {
    
    public init(){
        super.init(frame: .zero)
        listenForChanges()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var bag: Set<AnyCancellable> = []
    private func listenForChanges() {
        NotificationCenter.default
           .publisher(for: .PDFViewPageChanged, object: self)
           .sink{ [weak self] _ in
               self?.objectWillChange.send()
           }
           .store(in: &bag)
        
        publisher(for: \.canGoBack).sink { [weak self] _ in
            self?.objectWillChange.send()
        }
        .store(in: &bag)
        
        publisher(for: \.canGoForward).sink { [weak self] _ in
            self?.objectWillChange.send()
        }
        .store(in: &bag)
        
        publisher(for: \.canZoomIn).sink { [weak self] _ in
            self?.objectWillChange.send()
        }
        .store(in: &bag)
        
        publisher(for: \.canZoomOut).sink { [weak self] _ in
            self?.objectWillChange.send()
        }
        .store(in: &bag)
        
        publisher(for: \.currentPage).sink { [weak self] _ in
            self?.objectWillChange.send()
        }
        .store(in: &bag)
        
        publisher(for: \.currentDestination).sink { [weak self] _ in
            self?.objectWillChange.send()
        }
        .store(in: &bag)
        
        #if os(iOS)
        publisher(for: \.isUsingPageViewController).sink { [weak self] _ in
            self?.objectWillChange.send()
        }
        .store(in: &bag)
        #endif
        
        publisher(for: \.scaleFactorForSizeToFit).sink { [weak self] _ in
            self?.objectWillChange.send()
        }
        .store(in: &bag)
    }
    
    public override var document: PDFDocument? {
        willSet { objectWillChange.send() }
    }
    
    public override var displayMode: PDFDisplayMode {
        willSet { objectWillChange.send() }
    }
    
    public override var displayDirection: PDFDisplayDirection {
        willSet { objectWillChange.send() }
    }
    
    public override var displaysPageBreaks: Bool {
        willSet { objectWillChange.send() }
    }
    
    
    public override var pageBreakMargins: OSEdgeInsets {
        willSet { objectWillChange.send() }
    }
    
    public override var displaysAsBook: Bool {
        willSet { objectWillChange.send() }
    }
    
    public override var displaysRTL: Bool {
        willSet { objectWillChange.send() }
    }
    
    public override var interpolationQuality: PDFInterpolationQuality {
        willSet { objectWillChange.send() }
    }
    
    public override var pageShadowsEnabled: Bool {
        willSet { objectWillChange.send() }
    }
   
    public override var scaleFactor: CGFloat {
        willSet { objectWillChange.send() }
    }
    
    public override var minScaleFactor: CGFloat {
        willSet { objectWillChange.send() }
    }
    
    public override var maxScaleFactor: CGFloat {
        willSet { objectWillChange.send() }
    }
    
    public override var autoScales: Bool {
        willSet { objectWillChange.send() }
    }
    
    public override var highlightedSelections: [PDFSelection]? {
        willSet { objectWillChange.send() }
    }
    
    public override var enableDataDetectors: Bool {
        willSet { objectWillChange.send() }
    }
    
    public override var isInMarkupMode: Bool {
        willSet { objectWillChange.send() }
    }
    
    public var pageCount: Int {
        guard let document else { return 0 }
        return document.pageCount
    }
    
    public var currentPageIndex: Int {
        guard let document, let currentPage else { return 0 }
        return document.index(for: currentPage)
    }
    
}

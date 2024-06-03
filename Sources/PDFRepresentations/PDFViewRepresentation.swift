import SwiftUI
import RepresentationUtils
import PDFKit
import Combine

public struct PDFViewRepresentation {

    public enum PageBreaks: Equatable {
        case disabled
        case enabled(margins: OSEdgeInsets = OSEdgeInsets(top: 4.75, left: 4, bottom: 4.75, right: 4))
        
        var isDisabled: Bool { self == .disabled }
        
        public static func == (l: Self, r: Self) -> Bool {
            guard
                case let .enabled(lmargins) = l,
                case let .enabled(rmargins) = r
            else {
                return l.isDisabled == r.isDisabled
            }
            
            return lmargins == rmargins
        }
    }
    
    public enum Scale {
        case automatic
        case manual(scale: CGFloat, range: ClosedRange<CGFloat>)
    }
    
    let document: PDFDocument?
    let displayMode: PDFDisplayMode
    let displayDirection: PDFDisplayDirection
    let pageBreaks: PageBreaks
    let displayBox: PDFDisplayBox
    let displaysAsBook: Bool
    let usePageViewController: Bool
    let interpolationQuality: PDFInterpolationQuality
    let pageShadowsEnabled: Bool
    let scaling: Scale
    let selection: Binding<PDFSelection?>
    let destination: Binding<PDFDestination?>
    let enableDataDetectors: Bool
    
    public init(
        document: PDFDocument?,
        displayMode: PDFDisplayMode = .singlePageContinuous,
        displayDirection: PDFDisplayDirection = .vertical,
        pageBreaks: PageBreaks = .disabled,
        displayBox: PDFDisplayBox = .cropBox,
        displaysAsBook: Bool = false,
        usePageViewController: Bool = false,
        interpolationQuality: PDFInterpolationQuality = .none,
        pageShadowsEnabled: Bool = true,
        scaling: Scale = .automatic,
        selection: Binding<PDFSelection?> = .constant(nil),
        destination: Binding<PDFDestination?> = .constant(nil),
        enableDataDetectors: Bool = false
    ) {
        self.document = document
        self.displayMode = displayMode
        self.displayDirection = displayDirection
        self.pageBreaks = pageBreaks
        self.displayBox = displayBox
        self.displaysAsBook = displaysAsBook
        self.usePageViewController = usePageViewController
        self.interpolationQuality = interpolationQuality
        self.pageShadowsEnabled = pageShadowsEnabled
        self.scaling = scaling
        self.selection = selection
        self.destination = destination
        self.enableDataDetectors = enableDataDetectors
    }
    
    private func sync(view: PDFView, context: Context) {
        view.document = document
        view.displayMode = displayMode
        view.displayDirection = displayDirection
        view.displayBox = displayBox
        view.displaysAsBook = displaysAsBook
        view.interpolationQuality = interpolationQuality
        view.pageShadowsEnabled = pageShadowsEnabled
        #if canImport(UIKit)
        view.usePageViewController(usePageViewController)
        #endif
        view.currentSelection = selection.wrappedValue
        view.enableDataDetectors = enableDataDetectors
        
        if let dest = destination.wrappedValue{//, dest.page != view.currentDestination?.page {
            print("Zoom", dest.zoom)
            view.go(to: dest)
        }
        
        switch scaling {
        case .automatic: view.autoScales = true
        case let .manual(scale, range):
            view.scaleFactor = scale
            view.minScaleFactor = range.lowerBound
            view.maxScaleFactor = range.upperBound
        }
        
        switch pageBreaks {
        case .disabled: view.displaysPageBreaks = false
        case .enabled(let margins):
            view.displaysPageBreaks = true
            view.pageBreakMargins = margins
        }
        
        switch context.environment.layoutDirection {
        case .leftToRight: view.displaysRTL = false
        case .rightToLeft: view.displaysRTL = true
        @unknown default: view.displaysRTL = false
        }
    }
    
    public func makeView(context: Context) -> PDFView {
        let view  = PDFView()
        context.coordinator.setup(view)
        view.backgroundColor = .clear
        sync(view: view, context: context)
        return view
    }
    
    public final class Coordinator: NSObject {
        
        private var bag: Set<AnyCancellable> = []
        private let destination: Binding<PDFDestination?>
        
        init(destination: Binding<PDFDestination?>) {
            self.destination = destination
        }
        
        func setup(_ object: PDFView){
            bag.removeAll()
            
            NotificationCenter.default
                .publisher(for: .PDFViewPageChanged, object: object)
                .compactMap({ $0.object as? PDFView })
                .sink{ [weak self] in
                    self?.destination.wrappedValue = $0.currentDestination
                }
                .store(in: &bag)
        }
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(destination: destination)
    }
    
}

#if canImport(AppKit)

extension PDFViewRepresentation: NSViewRepresentable {
    public func makeNSView(context: Context) -> PDFView {
        makeView(context: context)
    }
    
    public func updateNSView(_ nsView: PDFView, context: Context) {
        sync(view: nsView, context: context)
    }
}

#elseif canImport(UIKit)

extension PDFViewRepresentation: UIViewRepresentable {
    
    public func makeUIView(context: Context) -> PDFView {
        makeView(context: context)
    }
    
    public func updateUIView(_ uiView: PDFView, context: Context) {
        sync(view: uiView, context: context)
    }
    
}

#endif

public extension PDFDisplayMode {
    var columns: Int {
        self == .twoUp || self == .twoUpContinuous ? 2 : 1
    }
}

private extension URL {
    static let testPDF = URL(string: "https://www.apple.com/environment/pdf/Apple_Environmental_Progress_Report_2024.pdf")!
}

private struct TestView: View {
    
    @State private var doc = PDFDocument(url: .testPDF)!
    @State private var destination: PDFDestination?
    
    let displayMode: PDFDisplayMode = .singlePageContinuous
    
    private var currentPage: Int {
        guard let page = destination?.page else { return 0 }
        return doc.index(for: page)
    }
    
    private var canPrevious: Bool { currentPage > 0 }
    
    private func prevPage() {
        guard canPrevious else { return }
        let nextIndex = currentPage - displayMode.columns
        if let page = doc.page(at: nextIndex){
            destination = PDFDestination(page: page, at: .zero)
        }
    }
    
    private var canNext: Bool { currentPage < doc.pageCount }
    
    private func nextPage() {
        guard canNext else { return }
        let nextIndex = currentPage + displayMode.columns
        if let page = doc.page(at: nextIndex){
            destination = PDFDestination(page: page, at: .zero)
        }
    }
    
    var body: some View {
        VStack(spacing: 0){
            PDFViewRepresentation(
                document: doc,
                displayMode: displayMode,
                destination: $destination
            )
            
            Divider().edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 16) {
                HStack(spacing: 0) {
                    Button(action: prevPage){
                        Image(systemName: "arrow.left")
                            .font(.system(size: 28).bold())
                    }
                    .disabled(!canPrevious)
                    
                    Spacer(minLength: 10)
                    
                    HStack {
                        Text("\(currentPage)").font(.body.weight(.bold).monospacedDigit())
                        Text("of").opacity(0.6)
                        Text("\(doc.pageCount)").font(.body.weight(.bold).monospacedDigit())
                    }
                    
                    Spacer(minLength: 10)
                    
                    Button(action: nextPage){
                        Image(systemName: "arrow.right")
                            .font(.system(size: 28).bold())
                    }
                    .disabled(!canNext)
                }
            }
            .padding()
        }
    }
}

#Preview{
    TestView()
}

import WebKit
import Combine


public class WKWebViewObservable: WKWebView, ObservableObject {
    
    private var bag: Set<AnyCancellable> = []
    
    public init(configuration: WKWebViewConfiguration = .init()){
        super.init(frame: .zero, configuration: configuration)
        listenForChanges()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func listenForChanges(){
        publisher(for: \.backForwardList).sink{ [weak self] _ in
            self?.objectWillChange.send()
        }.store(in: &bag)
        
        publisher(for: \.title).sink{ [weak self] _ in
            self?.objectWillChange.send()
        }.store(in: &bag)
        
        publisher(for: \.url).sink{ [weak self] _ in
            self?.objectWillChange.send()
        }.store(in: &bag)
        
        publisher(for: \.isLoading).sink{ [weak self] _ in
            self?.objectWillChange.send()
        }.store(in: &bag)
        
        publisher(for: \.estimatedProgress).sink{ [weak self] _ in
            self?.objectWillChange.send()
        }.store(in: &bag)
        
        publisher(for: \.hasOnlySecureContent).sink{ [weak self] _ in
            self?.objectWillChange.send()
        }.store(in: &bag)
        
        publisher(for: \.serverTrust).sink{ [weak self] _ in
            self?.objectWillChange.send()
        }.store(in: &bag)
        
        publisher(for: \.canGoBack).sink{ [weak self] _ in
            self?.objectWillChange.send()
        }.store(in: &bag)
        
        publisher(for: \.canGoForward).sink{ [weak self] _ in
            self?.objectWillChange.send()
        }.store(in: &bag)
        
        if #available(iOS 15.0, macOS 12.0, macCatalyst 15.0, *) {
            publisher(for: \.cameraCaptureState).sink{ [weak self] _ in
                self?.objectWillChange.send()
            }.store(in: &bag)
            
            publisher(for: \.microphoneCaptureState).sink{ [weak self] _ in
                self?.objectWillChange.send()
            }.store(in: &bag)
        }
    }
    
    #if os(macOS)
    public override var magnification: CGFloat {
        willSet { objectWillChange.send() }
    }
    #endif
    
    public override var pageZoom: CGFloat {
        willSet { objectWillChange.send() }
    }
    
    public override var allowsBackForwardNavigationGestures: Bool {
        willSet { objectWillChange.send() }
    }
    
    public override var customUserAgent: String? {
        willSet { objectWillChange.send() }
    }
    
    public func load(_ content: WebContent) {
        switch content {
        case .request(let request):
            load(request)
        case let .data(data , mimeType, characterEncodingName, baseURL):
            load(
                data,
                mimeType: mimeType,
                characterEncodingName: characterEncodingName,
                baseURL: baseURL
            )
        case let .local(url, readAccessURL):
            loadFileURL(url, allowingReadAccessTo: readAccessURL)
        case let .html(string, baseURL):
            loadHTMLString(string, baseURL: baseURL)
        }
    }
    
}

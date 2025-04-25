import WebKitRepresentations
import RepresentationUtils

#if canImport(WebKit)

struct WebKitExample: View {
    
    @StateObject private var view = WKWebViewObservable(
        configuration: .allowsInlineVideo
    )
    
    @State private var addressField = ""
  
    var body: some View {
        GeometryReader { proxy in
            OSViewRepresentation(view)
                .ignoresSafeArea()
                .onAppear {
                    view.allowsBackForwardNavigationGestures = true
                    #if canImport(UIKit)
                    view.scrollView.contentInsetAdjustmentBehavior = .never
                    view.scrollView.contentInset.top =  proxy.safeAreaInsets.top
                    view.scrollView.contentInset.bottom =  proxy.safeAreaInsets.bottom
                    #endif
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        view.load(.url(.googleWebSite))
                    }
                }
                .onChange(of: view.url){
                    addressField = $0?.absoluteString ?? ""
                }
        }
        .safeAreaInset(edge: .top, spacing: 0){
            VStack(spacing: 0) {
                HStack {
                    Text(view.title ?? "")
                    
                    if view.hasOnlySecureContent {
                        Text("-")
                        Image(systemName: "lock.fill")
                            .opacity(0.4)
                    }
                }
                .padding(8)
                
                Divider().ignoresSafeArea()
            }
            .font(.caption.weight(.semibold))
            .lineLimit(1)
            .frame(maxWidth: .infinity)
            .background(.regularMaterial)
        }
        .safeAreaInset(edge: .bottom, spacing: 0){
            VStack(spacing: 0) {
                Divider().ignoresSafeArea()
                
                if view.isLoading {
                    Rectangle()
                        .fill(.blue)
                        .ignoresSafeArea()
                        .frame(height: 5)
                        .scaleEffect(x: view.estimatedProgress, anchor: .leading)
                }
                
                HStack(spacing: 14) {
                    HStack {
                        Button{ view.goBack() } label: {
                            Label("Back", systemImage: "chevron.left")
                        }
                        .disabled(!view.canGoBack)
                        
                        Button{ view.goForward() } label: {
                            Label("Forward", systemImage: "chevron.right")
                        }
                        .disabled(!view.canGoForward)
                    }
                    .labelStyle(.iconOnly)
                    
                    TextField("Location", text: $addressField)
                        .autocorrectionDisabled()
                        #if !os(macOS)
                        .keyboardType(.webSearch)
                        #endif
                        .textFieldStyle(.roundedBorder)
                        .onSubmit {
                            if let url = URL(string: addressField){
                                if url.scheme != nil {
                                    view.load(.url(url))
                                } else if let url = URL(string: "https://" + addressField){
                                    view.load(.url(url))
                                }
                            }
                        }
                    
                    Menu {
                        Button{ view.pageZoom -= 0.1 } label : {
                            Label("Zoom Out", systemImage: "minus.magnifyingglass")
                        }
                        .labelStyle(.titleAndIcon)
                        
                        Button{ view.pageZoom += 0.1 } label : {
                            Label("Zoom In", systemImage: "plus.magnifyingglass")
                        }
                        .labelStyle(.titleAndIcon)
                    } label: {
                        Label("Menu", systemImage: "ellipsis")
                            #if os(macOS)
                            .labelStyle(.titleOnly)
                            #else
                            .labelStyle(.iconOnly)
                            #endif
                    }
                }
                .padding()
            }
            .animation(.smooth, value: view.estimatedProgress)
            .animation(.smooth, value: view.isLoading)
            .background(.bar)
        }
    }

}


#Preview("WebKit Example") {
    WebKitExample()
        .previewSize()
}


extension WKWebViewConfiguration {
    
    static var allowsInlineVideo: WKWebViewConfiguration {
        let c = WKWebViewConfiguration()
        #if canImport(UIKit)
        c.allowsInlineMediaPlayback = true
        #endif
        return c
    }
    
}

#endif

import WebKitRepresentations
import RepresentationUtils


struct WebKitExample: View {
    
    @StateObject private var view = WKWebViewObservable(
        configuration: .allowsInlineVideo
    )
    
    @State private var addressField = ""
  
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(view.title ?? "")
                
                if view.hasOnlySecureContent {
                    Text("-")
                    Image(systemName: "lock.fill")
                        .opacity(0.4)
                }
            }
            .font(.caption.weight(.semibold))
            .lineLimit(1)
            .padding(8)
            
            Divider().ignoresSafeArea()
            
            OSViewRepresentation(view)
                .onAppear{
                    view.allowsBackForwardNavigationGestures = true
                    view.load(.url(.googleWebSite))
                }
                .onChange(of: view.url){
                    addressField = $0?.absoluteString ?? ""
                }
            
            Divider().ignoresSafeArea()
            
            VStack(spacing: 0) {
                if view.isLoading {
                    Rectangle()
                        .fill(.blue)
                        .frame(height: 5)
                        .scaleEffect(x: view.estimatedProgress, anchor: .leading)
                }
                
                HStack(spacing: 14) {
                    Button("Back", systemImage: "chevron.left"){
                        view.goBack()
                    }
                    .disabled(!view.canGoBack)
                    
                    Button("Forward", systemImage: "chevron.right"){
                        view.goForward()
                    }
                    .disabled(!view.canGoForward)
                    
                    TextField("Location", text: $addressField, onCommit: {
                        if let url = URL(string: addressField){
                            if url.scheme != nil {
                                view.load(.url(url))
                            } else if let url = URL(string: "https://" + addressField){
                                view.load(.url(url))
                            }
                        }
                    })
                    //.autocapitalization(.none)
                    .autocorrectionDisabled()
                    //.textFieldStyle(.roundedBorder)
                    
                    Button("Zoom Out", systemImage: "minus.magnifyingglass"){
                        view.pageZoom -= 0.1
                    }
                    
                    Button("Zoom In", systemImage: "plus.magnifyingglass"){
                        view.pageZoom += 0.1
                    }
                }
                .padding()
                .labelStyle(.iconOnly)
                .imageScale(.large)
            }
            .animation(.smooth, value: view.estimatedProgress)
            .animation(.smooth, value: view.isLoading)
        }
    }

}


#Preview("WebKit Example") {
    WebKitExample()
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

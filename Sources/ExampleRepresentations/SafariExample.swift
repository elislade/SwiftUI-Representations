import SafariRepresentations

#if canImport(UIKit)

struct SafariExample: View {
    
    @State private var controlTint: CGColor = .init(red: 0, green: 0.3, blue: 0.8, alpha: 1)
    @State private var barTint: CGColor = .init(gray: 1, alpha: 1)
    @State private var dismissStyle: SFSafariViewController.DismissButtonStyle = .cancel
    
    @State private var isShown = false
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Color.secondary
                    //.ignoresSafeArea()
                    .opacity(0.5)
                
                Button("Show"){ isShown = true }
                
                if isShown {
                    SFSafariViewControllerRepresentation(
                        url: .eliSladeWebSite,
                        preferredBarTintColor: .init(cgColor: barTint),
                        preferredControlTintColor: .init(cgColor: controlTint),
                        dismissButtonStyle: dismissStyle,
                        didFinish: { isShown = false }
                    )
                    .transition(.move(edge: .bottom))
                    .id(controlTint.hashValue + barTint.hashValue)
                }
            }
            .mask(Rectangle())
            .ignoresSafeArea()
            .animation(.smooth, value: isShown)
            
            VStack(spacing: 0) {
                Toggle(isOn: $isShown){
                    Text("Presented")
                        .font(.headline)
                }
                .padding()
                
                Divider()
                
                HStack {
                    Text("Dismiss Button")
                        .font(.headline)
                    
                    Spacer()
                    
                    Picker("", selection: $dismissStyle){
                        Text("Done")
                            .tag(SFSafariViewController.DismissButtonStyle.done)
                        
                        Text("Close")
                            .tag(SFSafariViewController.DismissButtonStyle.close)
                        
                        Text("Cancel")
                            .tag(SFSafariViewController.DismissButtonStyle.cancel)
                    }
                }
                .padding()
                
                Divider()
                
                ColorPicker(selection: $controlTint){
                    Text("Control Tint")
                        .font(.headline)
                }
                .padding()
                
                Divider()
                
                ColorPicker(selection: $barTint){
                    Text("Bar Tint")
                        .font(.headline)
                }
                .padding()
                
            }
        }
    }
    
}


#Preview("Safari Example") {
    SafariExample()
}

#endif

import SwiftUI
import RepresentationUtils

@resultBuilder public struct ViewControllerBuilder {
    public static func buildBlock(_ components: any View...) -> [OSViewController] {
        components.map({ comp in
            let c = OSHostingController(rootView: AnyView(comp))
            c.view.backgroundColor = .clear
            return c
        })
    }
}

public struct TabViewRepresentation {
    
    let index: Int
    let additonalInsets: EdgeInsets
    let tabs: [OSViewController]
    
    public init(
        index: Int,
        additonalInsets: EdgeInsets = .init(),
        tabs: [OSViewController]
    ) {
        self.index = index
        self.additonalInsets = additonalInsets
        self.tabs = tabs
    }
    
    public init(
        index: Int,
        additonalInsets: EdgeInsets = .init(),
        @ViewControllerBuilder tabs: @escaping () -> [OSViewController]
    ) {
        self.init(index: index, additonalInsets: additonalInsets, tabs: tabs())
    }
    
}

#if canImport(UIKit)

extension TabViewRepresentation: UIViewControllerRepresentable {
    
    public func makeUIViewController(context: Context) -> UITabBarController {
        let c = UITabBarController()
        c.view.backgroundColor = .clear
        c.setViewControllers(tabs, animated: false)
        c.tabBar.isHidden = true
        return c
    }
    
    public func updateUIViewController(_ uiViewController: UITabBarController, context: Context) {
        uiViewController.selectedIndex = index
    }
    
}

#elseif canImport(AppKit)

extension TabViewRepresentation: NSViewControllerRepresentable {
    
    public func makeNSViewController(context: Context) -> NSTabViewController {
        let c = NSTabViewController()
        c.tabStyle = .unspecified
        c.view.backgroundColor = .clear
        for tab in tabs {
            c.addChild(tab)
        }
        for item in c.tabViewItems {
            item.view?.isHidden = true
        }
        return c
    }
    
    public func updateNSViewController(_ nsViewController: NSTabViewController, context: Context) {
        nsViewController.selectedTabViewItemIndex = index
    }
    
}

#endif

fileprivate struct TestView: View {
    @State private var index = 0
    
    var body: some View {
        VStack(spacing: 0) {
            TabViewRepresentation(index: index){
                ScrollView{
                    LinearGradient(colors: [.red, .blue], startPoint: .top, endPoint: .bottom)
                        .frame(height: 1300)
                }
                
                ScrollView{
                    LinearGradient(colors: [.green, .blue], startPoint: .top, endPoint: .bottom)
                        .frame(height: 1300)
                        .frame(height: 1300)
                }
            }.edgesIgnoringSafeArea(.all)
            
            Divider()
            
            Button(action: { index = index == 1 ? 0 : 1 }){
                Text("Toggle").padding()
            }
        }
    }
}

#Preview {
    TestView()
}

import SwiftUI
import RepresentationUtils


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

public final class CustomTabBarController: UIViewController {
    
    #if !os(tvOS)
    public override var childForStatusBarStyle: UIViewController? { nil }
    #endif
    
    #if !os(visionOS) && !os(tvOS)
    public override func setNeedsStatusBarAppearanceUpdate() { }
    #endif
    
    public var selectedIndex: Int = 0 {
        willSet {
            guard
                newValue != selectedIndex,
                children.indices.contains(newValue),
                children.indices.contains(selectedIndex)
            else { return }
            
            transition(
                from: children[selectedIndex],
                to: children[newValue],
                duration: 0,
                animations: nil
            )
        }
    }
    
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        guard children.indices.contains(selectedIndex) else { return }
        children[selectedIndex].view.frame = view.bounds
    }
    
    public override func viewDidLoad() {
        guard children.indices.contains(selectedIndex) else { return }
        view.addSubview(children[selectedIndex].view)
        children[selectedIndex].didMove(toParent: self)
    }
    
}

//extension TabViewRepresentation: UIViewControllerRepresentable {
//    
//    public func makeUIViewController(context: Context) -> CustomTabBarController {
//        let ctrl = CustomTabBarController()
//        for tab in tabs { ctrl.addChild(tab) }
//        return ctrl
//    }
//    
//    public func updateUIViewController(_ uiViewController:CustomTabBarController, context: Context) {
//        uiViewController.selectedIndex = index
//    }
//    
//}

extension TabViewRepresentation: UIViewControllerRepresentable {
    
    public func makeUIViewController(context: Context) -> UITabBarController {
        let ctrl = UITabBarController()
        ctrl.view.backgroundColor = .clear
        ctrl.setViewControllers(tabs, animated: false)
        if #available(iOS 18.0, tvOS 18.0, visionOS 2.0, *) {
            ctrl.isTabBarHidden = true
        }
        ctrl.tabBar.isHidden = true
        return ctrl
    }
    
    public func updateUIViewController(_ uiViewController: UITabBarController, context: Context) {
        uiViewController.selectedIndex = index
    }
    
}

#elseif canImport(AppKit)

public final class CustomTabBarController: NSViewController {
    
    public var selectedIndex: Int = 0 {
        willSet {
            guard
                newValue != selectedIndex,
                children.indices.contains(selectedIndex),
                children.indices.contains(newValue)
            else { return }
            
            transition(
                from: children[selectedIndex],
                to: children[newValue]
            )
        }
    }
    
    public override func viewWillLayout() {
        guard children.indices.contains(selectedIndex) else { return }
        children[selectedIndex].view.frame = view.bounds
    }
    
    public override func viewDidLoad() {
        guard children.indices.contains(selectedIndex) else { return }
        view.addSubview(children[selectedIndex].view)
    }
    
}

extension TabViewRepresentation: NSViewControllerRepresentable {
    
    public func makeNSViewController(context: Context) -> CustomTabBarController {
        let ctrl = CustomTabBarController()
        for tab in tabs { ctrl.addChild(tab) }
        return ctrl
    }
    
    public func updateNSViewController(_ nsViewController: CustomTabBarController, context: Context) {
        nsViewController.selectedIndex = index
    }
    
}

//extension TabViewRepresentation: NSViewControllerRepresentable {
//    
//    public func makeNSViewController(context: Context) -> NSTabViewController {
//        let c = NSTabViewController()
//        c.tabStyle = .unspecified
//        for tab in tabs {
//            tab.removeFromParent()
//            c.addChild(tab)
//        }
//        return c
//    }
//    
//    public func updateNSViewController(_ nsViewController: NSTabViewController, context: Context) {
//        nsViewController.selectedTabViewItemIndex = index
//    }
//    
//}

#endif

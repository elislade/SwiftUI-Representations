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

extension TabViewRepresentation: UIViewControllerRepresentable {
    
    public func makeUIViewController(context: Context) -> CustomTabBarController {
        let ctrl = CustomTabBarController()
        for tab in tabs {
            let c = TabWrapperViewController(tab)
            ctrl.addChild(c)
            c.didMove(toParent: ctrl)
        }
        return ctrl
    }
    
    public func updateUIViewController(_ uiViewController:CustomTabBarController, context: Context) {
        if index != uiViewController.selectedIndex {
            uiViewController.selectedIndex = index
        }
    }
    
}


final class TabWrapperViewController: UIViewController {
    
    
    let backing: UIViewController
    
    private var hasBecomeVisible = false
    
    init(_ backing: UIViewController) {
        self.backing = backing
        super.init(nibName: nil, bundle: nil)
        addChild(backing)
        backing.didMove(toParent: self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = View(backing.view)
    }
    
    override func viewIsAppearing(_ animated: Bool) {
        guard !hasBecomeVisible else { return }
        super.viewIsAppearing(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        view.isHidden = false
        guard !hasBecomeVisible else { return }
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        guard !hasBecomeVisible else { return }
        super.viewDidAppear(animated)
        hasBecomeVisible = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        guard !hasBecomeVisible else { return }
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        guard !hasBecomeVisible else { return }
        super.viewDidDisappear(animated)
    }
    
    
    final class View: UIView {
        
        let backing: UIView
        
        override var isHidden: Bool {
            didSet {
                backing.isHidden = isHidden
                backing.frame = bounds
            }
        }
        
        init(_ backing: UIView) {
            self.backing = backing
            super.init(frame: .zero)
            backing.backgroundColor = .clear
            backgroundColor = .clear
            addSubview(backing)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func removeFromSuperview() {
            // don't remove from view so onDisappear and onAppear don't get called for every tab switch.
            isHidden = true
        }
        
        override func layoutSubviews() {
            if isHidden { return }
            super.layoutSubviews()
            CATransaction.begin()
            CATransaction.setAnimationDuration(0)
            backing.frame = bounds
            CATransaction.commit()
        }
        
        override func layoutIfNeeded() {
            if isHidden { return }
            super.layoutIfNeeded()
        }
        
        override func setNeedsLayout() {
            if isHidden { return }
            super.setNeedsLayout()
        }
        
        override func setNeedsDisplay() {
            if isHidden { return }
            super.setNeedsDisplay()
        }
        
        override func setNeedsUpdateConstraints() {
            if isHidden { return }
            super.setNeedsUpdateConstraints()
        }
        
        override func safeAreaInsetsDidChange() {
            if isHidden { return }
            super.safeAreaInsetsDidChange()
        }
        
    }

    
}

//extension TabViewRepresentation: UIViewControllerRepresentable {
//    
//    public func makeUIViewController(context: Context) -> UITabBarController {
//        let ctrl = UITabBarController()
//        ctrl.view.backgroundColor = .clear
//        ctrl.setViewControllers(tabs, animated: false)
//        if #available(iOS 18.0, tvOS 18.0, visionOS 2.0, *) {
//            ctrl.isTabBarHidden = true
//        }
//        ctrl.tabBar.isHidden = true
//        return ctrl
//    }
//    
//    public func updateUIViewController(_ uiViewController: UITabBarController, context: Context) {
//        uiViewController.selectedIndex = index
//    }
//    
//}

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

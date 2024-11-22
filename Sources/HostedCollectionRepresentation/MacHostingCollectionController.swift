#if canImport(AppKit) && !targetEnvironment(macCatalyst)

import SwiftUI
import Combine
import RepresentationUtils


// MARK: - Collection View


@available(macOS 11, *)
public final class HostingCollectionViewController: NSViewController, NSCollectionViewDataSource {
    
    
    public typealias Content = [CollectionSection]
    
    
    // MARK: Public Instance Vars
    
    
    weak var scrollStateDelegate: ScrollStateDelegate?
    

    // MARK: Private Instance Vars
    
    private let scrollView = NSScrollView()
    private let collectionView: NSCollectionView
    private var body: Content
    
    private var initialScrollState: ScrollState?
    private var lastScrollStateUpdate: ScrollState?
    private var bag: Set<AnyCancellable> = []
    
    private let cellID = NSUserInterfaceItemIdentifier("Cell")
    private let headerID = NSUserInterfaceItemIdentifier("Header")
    
    // MARK: Lifecycle
    
    init(
        insets: NSEdgeInsets = .init(),
        initialScrollState: ScrollState,
        content: Content
    ) {
        self.body = content
        self.initialScrollState = initialScrollState
        self.collectionView = NSCollectionView(frame: .init(x: 0, y: 0, width: 10, height: 0))
        
        super.init(nibName: nil, bundle: nil)
        
        collectionView.isSelectable = false
        collectionView.dataSource = self
        collectionView.collectionViewLayout = NSCollectionViewFlowLayout()
        collectionView.allowsMultipleSelection = false
    }
    
    private func makeLayout() -> NSCollectionViewLayout {
        let configuration = NSCollectionViewCompositionalLayoutConfiguration()
        configuration.scrollDirection = .vertical
        return NSCollectionViewCompositionalLayout { [body] index, env in
            NSCollectionLayoutSection(layout: body[index].layout)
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupReusableViews()
        collectionView.collectionViewLayout = makeLayout()
        collectionView.backgroundColors = [.clear]
    }
    
    
    private func setupReusableViews() {
        collectionView.register(Cell.self, forItemWithIdentifier: cellID)
        
        collectionView.register(
            NSHostingView<AnyView>.self,
            forSupplementaryViewOfKind: CONST.headerKind,
            withIdentifier: headerID
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func loadView() {
        scrollView.documentView = collectionView
        scrollView.documentView?.backgroundColor = .clear
        self.view = scrollView
    }
    
    public override func viewDidAppear() {
        super.viewDidAppear()
        
        if let initialScrollState {
            update(scrollState: initialScrollState)
            self.initialScrollState = nil
        }
    }
    
    public override func viewWillDisappear() {
        super.viewWillDisappear()
        //scrollStateDelegate?.stateDidChange(state: .location(collectionView.contentOffset))
    }
    
    public override func viewWillLayout() {
        super.viewWillLayout()
        //collectionView.frame = scrollView.bounds
    }
    
    // MARK: Update Methods
    
    func update(scrollState: ScrollState, animated: Bool = false) {
        guard scrollState != lastScrollStateUpdate else { return }
        lastScrollStateUpdate = scrollState
        
        switch scrollState {
        case .section(let int):
            collectionView.scrollToItems(at: [IndexPath(item: 0, section: int)], scrollPosition: .top)
        case .location(let point):
            print("Collection Loc", point)
            //collectionView.contentOffset = point
        }
    }
    
    func update(insets: EdgeInsets) {
//        let inset = NSEdgeInsets(top: insets.top, left: insets.leading, bottom: insets.bottom, right: insets.trailing)
//        guard inset != additionalSafeAreaInsets else { return }
//        additionalSafeAreaInsets = inset
    }
    
    func update(_ newContent: Content, transaction: Transaction) {
        //TODO:
    }
    
    
    // MARK: CollectionViewDataSource
    
    
    public func numberOfSections(in collectionView: NSCollectionView) -> Int {
        body.count
    }
    
    public func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        body[section].cells.count
    }
    
    public func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: cellID, for: indexPath) as! Cell
        let itemView = body[indexPath.section].cells[indexPath.item].view()
        item.hostingView.rootView = itemView
        return item
    }
    
    public func collectionView(_ collectionView: NSCollectionView, viewForSupplementaryElementOfKind kind: NSCollectionView.SupplementaryElementKind, at indexPath: IndexPath) -> NSView {

        let cell = collectionView.makeSupplementaryView(
            ofKind: kind,
            withIdentifier: headerID,
            for: indexPath
        ) as! NSHostingView<AnyView>

        cell.rootView = body[indexPath.section].header()

        return cell
    }
    
}


extension HostingCollectionViewController {
    
    final class Cell: NSCollectionViewItem {

        weak var hostingView: NSHostingView<AnyView>!
        
        override func loadView() {
            let v = NSHostingView(rootView: AnyView(EmptyView()))
            self.view = v
            self.hostingView = v
        }
        
    }
    
}


#endif


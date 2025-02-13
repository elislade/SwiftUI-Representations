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
    
    private var currentSectionIndex: Int = 0
    private var bag: Set<AnyCancellable> = []
    
    private let cellID = NSUserInterfaceItemIdentifier("Cell")
    private let headerID = NSUserInterfaceItemIdentifier("Header")
    
    // MARK: Lifecycle
    
    init(
        insets: EdgeInsets,
        content: Content
    ) {
        self.body = content
        self.collectionView = NSCollectionView(frame: .init(x: 0, y: 0, width: 10, height: 0))
        
        super.init(nibName: nil, bundle: nil)
        
        collectionView.isSelectable = false
        collectionView.dataSource = self
        collectionView.collectionViewLayout = NSCollectionViewFlowLayout()
        collectionView.allowsMultipleSelection = false
    }
    
    private func makeLayout() -> NSCollectionViewLayout {
        let layout = NSCollectionViewCompositionalLayout { [unowned self] index, env in
            NSCollectionLayoutSection(layout: body[index].layout)
        }
        layout.configuration.scrollDirection = .vertical
        return layout
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
            SupplementaryViewHost.self,
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
        
        if currentSectionIndex == 0 {
            collectionView.scrollToItems(at: [IndexPath(item: 0, section: 0)], scrollPosition: .top)
        }
    }
    
    
    // MARK: Update Methods
    
    func scrollTo(section: Int, transaction: Transaction) {
        guard section != currentSectionIndex else { return }
        currentSectionIndex = section
        collectionView.scrollToItems(at: [IndexPath(item: 0, section: section)], scrollPosition: .top)
    }
    
    func update(insets: EdgeInsets) {
        scrollView.additionalSafeAreaInsets = .init(top: insets.top, left: 0, bottom: 0, right: 0)
    }
    
    func update(_ newContent: Content, transaction: Transaction) {
        guard !(body.isEmpty && newContent.isEmpty) else { return }

        if body.isEmpty && !newContent.isEmpty {
            body = newContent
            collectionView.reloadData()
            return
        }
        
        var updateLayoutIndices: Set<IndexPath> = []
        
        var removeSections: IndexSet = []
        var addSections: IndexSet = []
        var insertIndices: Set<IndexPath> = []
        var removeIndices: Set<IndexPath> = []
        
        let max = max(body.count, newContent.count)
        
        for sectionIndex in 0..<max {
            if !newContent.indices.contains(sectionIndex) && body.indices.contains(sectionIndex) {
                removeSections.insert(sectionIndex)
                removeIndices.formUnion(body[sectionIndex].cells.indices.map{
                    IndexPath(item: $0, section: sectionIndex)
                })
                continue
            } else if !body.indices.contains(sectionIndex) && newContent.indices.contains(sectionIndex) {
                addSections.insert(sectionIndex)
                insertIndices.formUnion(newContent[sectionIndex].cells.indices.map{
                    IndexPath(item: $0, section: sectionIndex)
                })
                continue
            }
            
            let newSection = newContent[sectionIndex]
            let currentSection = body[sectionIndex]
            
            if newSection.layout != currentSection.layout {
                updateLayoutIndices.insert(IndexPath(item: 0, section: sectionIndex))
            }

            let difference = newSection.cells.difference(from: currentSection.cells){ $0.id == $1.id }
            
            for item in difference {
                switch item {
                case let .insert(offset, _, _):
                    insertIndices.insert(IndexPath(item: offset, section: sectionIndex))
                case let .remove(offset, _, _):
                    removeIndices.insert(IndexPath(item: offset, section: sectionIndex))
                }
            }
        }
        
        guard !insertIndices.isEmpty || !removeIndices.isEmpty || !updateLayoutIndices.isEmpty else { return }
        
        func update() {
            collectionView.performBatchUpdates { [unowned self] in
                body = newContent
                collectionView.deleteItems(at: removeIndices)
                collectionView.deleteSections(removeSections)
                collectionView.insertItems(at: insertIndices)
                collectionView.insertSections(addSections)
                
                if !updateLayoutIndices.isEmpty {
                    let ctx = NSCollectionViewLayoutInvalidationContext()
                    ctx.invalidateItems(at: updateLayoutIndices)
                    collectionView.collectionViewLayout?.invalidateLayout(with: ctx)
                }
            }
        }
        
        if
            !transaction.disablesAnimations,
            let animation = transaction.animation,
            let animator = resolveAnimation(animation)
        {
            animator.animate(block: update)
        } else {
            update()
        }
        
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
        ) as! SupplementaryViewHost

        cell.host.rootView = body[indexPath.section].header()

        return cell
    }
    
}


extension HostingCollectionViewController {
    
    final class Cell: NSCollectionViewItem {

        weak var hostingView: NSHostingView<AnyView>!
        
        override func loadView() {
            let v = NSHostingView(rootView: AnyView(EmptyView()))
//            if #available(macOS 13.0, *) {
//                v.sizingOptions = .maxSize
//            }
            self.view = v
            self.hostingView = v
        }
        
    }
    
    final class SupplementaryViewHost: NSView, NSCollectionViewElement  {
        
        unowned let host: NSHostingView<AnyView>
        
        override init(frame frameRect: NSRect) {
            let host = NSHostingView(rootView: AnyView(EmptyView()))
            if #available(macOS 13.0, *) {
                host.sizingOptions = .maxSize
            }
            self.host = host
            super.init(frame: frameRect)
            addSubview(host)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func layout() {
            super.layout()
            host.frame = bounds
        }
        
    }
    
}


#endif


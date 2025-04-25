

#if canImport(UIKit)

import UIKit
import SwiftUI
import Combine
import RepresentationUtils



// MARK: - Collection View

class CollectionView: UICollectionView {
    
    var _safeAreaInset: UIEdgeInsets = .init() {
        didSet {
            safeAreaInsetsDidChange()
        }
    }
    
    override var safeAreaInsets: UIEdgeInsets {
        get {
            _safeAreaInset
        }
        set {
            
        }
    }
}

@available(iOS 16, tvOS 16.0, *)
public final class HostingCollectionViewController : UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    
    public typealias Content = [CollectionSection]
    
    
    // MARK: Public Instance Vars
    
    
    weak var scrollStateDelegate: ScrollStateDelegate?
    

    // MARK: Private Instance Vars
    
    
    private let collectionView: CollectionView
    private var body: Content
    private var currentSectionIndex: Int = 0
    private var currentInsets: EdgeInsets
    private var bag: Set<AnyCancellable> = []
    
    
    // MARK: Lifecycle
    
    
    init(insets: EdgeInsets = .init(), content: Content) {
        self.body = content
        self.currentInsets = .init()
        self.collectionView = CollectionView(
            frame: .zero,
            collectionViewLayout: .init()
        )
        
        super.init(nibName: nil, bundle: nil)
        
        setupReusableViews()
        collectionView.allowsSelection = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.collectionViewLayout = makeLayout()
        collectionView.automaticallyAdjustsScrollIndicatorInsets = false
    }
    
    private func makeLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { [unowned self] index, env in
            if body.indices.contains(index) {
                return NSCollectionLayoutSection(layout: body[index].layout)
            } else {
                return .list(using: .init(appearance: .grouped), layoutEnvironment: env)
            }
        }
        
        layout.configuration.scrollDirection = .vertical
        layout.configuration.contentInsetsReference = .safeArea
        return layout
    }
    
    private func setupReusableViews() {
        collectionView.register(
            UICollectionViewCell.self,
            forCellWithReuseIdentifier: "Cell"
        )
        
        collectionView.register(
            UICollectionViewCell.self,
            forSupplementaryViewOfKind: CONST.headerKind,
            withReuseIdentifier: "HeaderCell"
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func loadView() {
        self.view = collectionView
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColor = .clear
    }
    
    // MARK: Update Methods
    
    
    func scrollTo(section: Int, transaction: Transaction) {
        guard currentSectionIndex != section else { return }
        currentSectionIndex = section
        let animated = transaction.animation != nil && transaction.disablesAnimations == false
        collectionView.scrollToItem(at: IndexPath(item: 0, section: section), at: .top, animated: animated)
    }
    
    func update(insets: EdgeInsets, layout: LayoutDirection) {
        guard currentInsets != insets else { return }
        currentInsets = insets
        
        let insets = UIEdgeInsets(
            top: insets.top,
            left: layout == .leftToRight ? insets.leading : insets.trailing,
            bottom: insets.bottom,
            right: layout == .leftToRight ? insets.trailing: insets.leading
        )
        
        collectionView._safeAreaInset = insets
        collectionView.verticalScrollIndicatorInsets.top = insets.top
        collectionView.verticalScrollIndicatorInsets.bottom = insets.bottom
    }
    
    func update(_ newContent: Content, transaction: Transaction) {
        guard !(body.isEmpty && newContent.isEmpty) else { return }

        if body.isEmpty && !newContent.isEmpty {
            body = newContent
            collectionView.reloadData()
            return
        }
        
        var updateLayoutIndices: [IndexPath] = []
        
        var removeSections: IndexSet = []
        var addSections: IndexSet = []
        var insertIndices: [IndexPath] = []
        var removeIndices: [IndexPath] = []
        
        let max = max(body.count, newContent.count)
        
        for sectionIndex in 0..<max {
            if !newContent.indices.contains(sectionIndex) && body.indices.contains(sectionIndex) {
                removeSections.insert(sectionIndex)
                removeIndices.append(contentsOf: body[sectionIndex].cells.indices.map{
                    IndexPath(item: $0, section: sectionIndex)
                })
                continue
            } else if !body.indices.contains(sectionIndex) && newContent.indices.contains(sectionIndex) {
                addSections.insert(sectionIndex)
                insertIndices.append(contentsOf: newContent[sectionIndex].cells.indices.map{
                    IndexPath(item: $0, section: sectionIndex)
                })
                continue
            }
            
            let newSection = newContent[sectionIndex]
            let currentSection = body[sectionIndex]
            
            if newSection.layout != currentSection.layout {
                updateLayoutIndices.append(IndexPath(item: 0, section: sectionIndex))
            }

            let difference = newSection.cells.difference(from: currentSection.cells){ $0.id == $1.id }
            
            for item in difference {
                switch item {
                case let .insert(offset, _, _):
                    insertIndices.append(IndexPath(item: offset, section: sectionIndex))
                case let .remove(offset, _, _):
                    removeIndices.append(IndexPath(item: offset, section: sectionIndex))
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
                    let ctx = UICollectionViewLayoutInvalidationContext()
                    ctx.invalidateItems(at: updateLayoutIndices)
                    collectionView.collectionViewLayout.invalidateLayout(with: ctx)
                }
            } completion: { _ in }
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
    
    
    // MARK: - UICollectionViewDelegate
    
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        guard !collectionView.indexPathsForVisibleItems.isEmpty else { return }
        
        typealias SectionIndex = Int
        var sectionCellCounts: [SectionIndex : Int] = [:]
        
        // Which ever section that owns the majority of visible cells, will be the one that is considered current.
        // In the case of a tie where one of the ties is the last section no change will be propagated up to the delegate.
        // In the case of a tie where neither of the ties were the last section. Sort the index closest to the last one.
        let sections = collectionView.indexPathsForVisibleItems.map(\.section)
        
        for section in sections {
            if let count = sectionCellCounts[section] {
                sectionCellCounts[section] = count + 1
            } else {
                sectionCellCounts[section] = 1
            }
        }
        
        let sortedSections = sectionCellCounts.sorted(by: { $0.value > $1.value })
        
        if sortedSections.count > 1 {
            let isTied = sortedSections[0].value == sortedSections[1].value
            let isOneLastValue = sortedSections[0].key == currentSectionIndex || sortedSections[1].key == currentSectionIndex
            if isTied && !isOneLastValue {
                let winner = [currentSectionIndex, sortedSections[0].key, sortedSections[1].key].sorted()[1]
                if winner != currentSectionIndex {
                    currentSectionIndex = winner
                    scrollStateDelegate?.didChangeSection(index: winner)
                }
                return
            }
        }
        
        if sortedSections[0].key != currentSectionIndex {
            currentSectionIndex = sortedSections[0].key
            scrollStateDelegate?.didChangeSection(index: sortedSections[0].key )
        }
    }
    
    
    // MARK: - UICollectionViewDataSource
    
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        body.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        body[section].cells.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        cell.contentConfiguration = UIHostingConfiguration{
            body[indexPath.section].cells[indexPath.item].view()
        }.margins(.all, 0)
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HeaderCell", for: indexPath) as! UICollectionViewCell

        view.contentConfiguration = UIHostingConfiguration{
            body[indexPath.section].header()
        }.margins(.all, 0)
        
        return view
    }
    
}

#endif

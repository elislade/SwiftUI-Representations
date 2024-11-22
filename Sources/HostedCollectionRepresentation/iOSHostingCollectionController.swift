

#if canImport(UIKit)

import UIKit
import SwiftUI
import Combine
import RepresentationUtils



// MARK: - Collection View


@available(iOS 16, *)
public final class HostingCollectionViewController : UIViewController, UICollectionViewDataSource {
    
    
    public typealias Content = [CollectionSection]
    
    
    // MARK: Public Instance Vars
    
    
    weak var scrollStateDelegate: ScrollStateDelegate?
    

    // MARK: Private Instance Vars
    
    
    private let collectionView: UICollectionView
    private var body: Content
    
    private var initialScrollState: ScrollState?
    private var lastScrollStateUpdate: ScrollState?
    private var bag: Set<AnyCancellable> = []
    
    
    // MARK: Lifecycle
    
    
    init(
        insets: UIEdgeInsets = .zero,
        initialScrollState: ScrollState,
        content: Content
    ) {
        self.body = content
        self.initialScrollState = initialScrollState
        self.collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewFlowLayout()
        )
        
        super.init(nibName: nil, bundle: nil)
        
        setupReusableViews()
        
        collectionView.collectionViewLayout = makeLayout()
        collectionView.insetsLayoutMarginsFromSafeArea = false
        collectionView.backgroundColor = .clear
        collectionView.allowsSelection = false
        collectionView.dataSource = self
        additionalSafeAreaInsets = insets
    }
    
    private func makeLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { [body] index, env in
            if body.indices.contains(index) {
                return NSCollectionLayoutSection(layout: body[index].layout)
            } else {
                return nil
            }
        }
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
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let initialScrollState {
            update(scrollState: initialScrollState)
            self.initialScrollState = nil
        }
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        scrollStateDelegate?.stateDidChange(state: .location(collectionView.contentOffset))
    }

    
    // MARK: Update Methods
    
    
    func update(scrollState: ScrollState, animated: Bool = false) {
        guard scrollState != lastScrollStateUpdate else { return }
        lastScrollStateUpdate = scrollState
        
        switch scrollState {
        case .section(let int):
            collectionView.scrollToItem(at: IndexPath(row: 0, section: int), at: .top, animated: animated)
        case .location(let point):
            print("Collection Loc", point)
            //collectionView.contentOffset = point
        }
    }
    
    func update(insets: EdgeInsets) {
        let inset = UIEdgeInsets(top: insets.top, left: insets.leading, bottom: insets.bottom, right: insets.trailing)
        guard inset != additionalSafeAreaInsets else { return }
        additionalSafeAreaInsets = inset
    }
    
    func update(_ newContent: Content, transaction: Transaction) {
        var updateLayoutIndices: [IndexPath] = []
        
        var removeSections: IndexSet = []
        var addSections: IndexSet = []
        var insertIndices: [IndexPath] = []
        var removeIndices: [IndexPath] = []
        
        let max = max(body.count, newContent.count)
        
        for offset in 0..<max {
            if !newContent.indices.contains(offset) && body.indices.contains(offset) {
                removeSections.insert(offset)
                removeIndices.append(contentsOf: body[offset].cells.indices.map{
                    IndexPath(row: $0, section: offset)
                })
                continue
            } else if !body.indices.contains(offset) && newContent.indices.contains(offset) {
                addSections.insert(offset)
                insertIndices.append(contentsOf: newContent[offset].cells.indices.map{
                    IndexPath(row: $0, section: offset)
                })
                continue
            }
            
            let newSection = newContent[offset]
            let currentSection = body[offset]
            
            if newSection.layout != currentSection.layout {
                updateLayoutIndices.append(IndexPath(row: 0, section: offset))
            }
            
            let difference = newSection.cells.difference(from: currentSection.cells){ $0.id == $1.id }
            
            for item in difference {
                switch item {
                case let .insert(roffset, _, _):
                    insertIndices.append(IndexPath(row: roffset, section: offset))
                case let .remove(roffset, _, _):
                    removeIndices.append(IndexPath(row: roffset, section: offset))
                }
            }
        }
        
        guard !insertIndices.isEmpty || !removeIndices.isEmpty || !updateLayoutIndices.isEmpty else { return }
        
        self.body = newContent
        let new = makeLayout()
        self.collectionView.collectionViewLayout.prepareForTransition(to: new)
        
        if
            !transaction.disablesAnimations,
            let animation = transaction.animation,
            let animator = resolveAnimation(animation)
        {
            animator.animate { [weak self] in
                guard let self else { return }
                self.collectionView.performBatchUpdates {
                    self.collectionView.insertSections(addSections)
                    self.collectionView.deleteSections(removeSections)
                    self.collectionView.insertItems(at: insertIndices)
                    self.collectionView.deleteItems(at: removeIndices)
                }
            } completion: { [collectionView] in
                collectionView.collectionViewLayout = new
            }
        } else {
            collectionView.performBatchUpdates {
                collectionView.insertSections(addSections)
                collectionView.deleteSections(removeSections)
                collectionView.insertItems(at: insertIndices)
                collectionView.deleteItems(at: removeIndices)
            } completion: { [unowned self] _ in
                collectionView.collectionViewLayout = new
            }
        }
    }
    
    
    // MARK: UICollectionViewDataSource
    
    
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
        }
        .margins(.all, 0)
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

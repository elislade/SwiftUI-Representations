@_exported import SwiftUI


enum CONST {
    static let headerKind = "Header"
}


@available(iOS 16, macOS 11, *)
extension NSCollectionLayoutSection {
    
    convenience init(layout: CollectionSection.Layout) {
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: .init(
                widthDimension: .fractionalWidth(1),
                heightDimension: .estimated(40)
            ),
            elementKind: CONST.headerKind,
            alignment: .top
        )
        
        header.pinToVisibleBounds = layout.pinHeader
        
        let size: NSCollectionLayoutSize = .init(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(1000)
        )
        
        let subitem: NSCollectionLayoutItem = .init(layoutSize: .init(
            widthDimension: .fractionalWidth((1 / CGFloat(layout.columns))),
            heightDimension: .estimated(50)
        ))
        
        let layoutGroup: NSCollectionLayoutGroup! = .horizontal(layoutSize: size, subitems: [subitem])
        layoutGroup.interItemSpacing = .fixed(layout.spacing)
        
        self.init(group: layoutGroup)
        
        #if os(iOS)
        self.supplementaryContentInsetsReference = .none
        //self.contentInsetsReference = .none
        #endif
        
        self.boundarySupplementaryItems = [ header ]
        self.interGroupSpacing = layout.spacing
        self.contentInsets = .init(layout.insets)
    }
    
}


extension NSDirectionalEdgeInsets {
    
    public nonisolated init(_ insets: EdgeInsets){
        self.init(top: insets.top, leading: insets.leading, bottom: insets.bottom, trailing: insets.trailing)
    }
    
}

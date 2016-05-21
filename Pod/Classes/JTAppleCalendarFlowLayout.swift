//
//  JTAppleCalendarFlowLayout.swift
//  JTAppleCalendar
//
//  Created by Jay Thomas on 2016-03-01.
//  Copyright © 2016 OS-Tech. All rights reserved.
//

protocol JTAppleCalendarLayoutProtocol: class {
    var sectionInset: UIEdgeInsets {get set}
    var itemSize: CGSize {get set}
    var pointForFocusItem: CGPoint {get set}
    var headerReferenceSize: CGSize {get set}
    var footerReferenceSize: CGSize {get set}
    var scrollDirection: UICollectionViewScrollDirection {get set}
    var minimumInteritemSpacing: CGFloat {get set}
    var minimumLineSpacing: CGFloat {get set}
    
    func targetContentOffsetForProposedContentOffset(proposedContentOffset: CGPoint) -> CGPoint
}

protocol JTAppleCalendarDelegateProtocol: class {
    func numberOfRows() -> Int
    func numberOfColumns() -> Int
    func numberOfsectionsPermonth() -> Int
    func numberOfSections() -> Int
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize
}

/// Base class for the Horizontal layout
public class JTAppleCalendarBaseFlowLayout: UICollectionViewLayout, JTAppleCalendarLayoutProtocol {
    var sectionInset: UIEdgeInsets = UIEdgeInsetsZero
    var itemSize: CGSize = CGSizeZero
    var headerReferenceSize: CGSize = CGSizeZero
    var footerReferenceSize: CGSize = CGSizeZero
    var pointForFocusItem = CGPointZero
    var scrollDirection: UICollectionViewScrollDirection = .Horizontal
    var minimumInteritemSpacing: CGFloat = 0
    var minimumLineSpacing: CGFloat = 0

    
    /// Returns the content offset to use after an animation layout update or change.
    /// - Parameter proposedContentOffset: The proposed point for the upper-left corner of the visible content
    /// - returns: The content offset that you want to use instead
    public override func targetContentOffsetForProposedContentOffset(proposedContentOffset: CGPoint) -> CGPoint {
        return proposedContentOffset
    }
}
/// Vertical flow layout for calendar view
public class JTAppleCalendarVerticalFlowLayout: UICollectionViewFlowLayout, JTAppleCalendarLayoutProtocol {
    var pointForFocusItem: CGPoint = CGPointZero
    weak var delegate: JTAppleCalendarDelegateProtocol?
    
    /// Returns the content offset to use after an animation layout update or change.
    /// - Parameter proposedContentOffset: The proposed point for the upper-left corner of the visible content
    /// - returns: The content offset that you want to use instead
    public override func targetContentOffsetForProposedContentOffset(proposedContentOffset: CGPoint) -> CGPoint {
        return pointForFocusItem
    }
//    public override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
//        let x = super.layoutAttributesForElementsInRect(rect)
//        return x
//    }
//    
//    public override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
//        let x = super.layoutAttributesForItemAtIndexPath(indexPath)
//        
//        return x
//    }
//    public override func layoutAttributesForSupplementaryViewOfKind(elementKind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
//        let x = super.layoutAttributesForItemAtIndexPath(indexPath)
//        
//        let size = delegate!.collectionView(collectionView!, layout: self, referenceSizeForHeaderInSection: indexPath.section)
//        itemSize.height = (collectionView!.frame.height - size.height) / CGFloat(6)
//        
//        return x
//    }
    
    init(withDelegate delegate: JTAppleCalendarDelegateProtocol) {
        super.init()
        self.delegate = delegate
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
/// The JTAppleCalendarFlowLayout class is a concrete layout object that organizes day-cells into a grid
public class JTAppleCalendarHorizontalFlowLayout: JTAppleCalendarBaseFlowLayout {
    var numberOfColumns: Int { get { return delegate!.numberOfColumns() } }
    var numberOfSections: Int { get { return delegate!.numberOfSections() } }
    var numberOfSectionsPerMonth: Int { get { return delegate!.numberOfsectionsPermonth() } }
    var numberOfRows: Int { get { return delegate!.numberOfRows() } }
    
    
    var sectionInsets: UIEdgeInsets = UIEdgeInsetsZero
    
    weak var delegate: JTAppleCalendarDelegateProtocol?
    
    init(withDelegate delegate: JTAppleCalendarDelegateProtocol) {
        super.init()
        self.delegate = delegate
        minimumInteritemSpacing = 0
        minimumLineSpacing = 0
    }
    
    
    /// Returns an object initialized from data in a given unarchiver. self, initialized using the data in decoder.
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    /// Tells the layout object to update the current layout.
    public override func prepareLayout() {
//        super.prepareLayout()
//        print(numberOfColumns)
//        print(numberOfSections)
//        print(numberOfSectionsPerMonth)
//        print(numberOfRows)
        
//        if UIApplication.sharedApplication().statusBarOrientation != 
//        self
    }
    
    /// Returns the layout attributes for all of the cells and views in the specified rectangle.
    override public func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        // Determine how many columns needs to be displayed
        let requestedWidth = rect.width
        
        let requestedColumns = Int(requestedWidth / itemSize.width) + 2
        let requestSections = (requestedColumns / numberOfColumns) + 1
        
        var startColumn = Int(rect.origin.x / itemSize.width)
        var endColumn = startColumn + requestedColumns
        
        var startSection = (startColumn + 1) / 7
        var endSection = startSection + requestSections
        
//        print("requestedWidth: \(requestedWidth) itemSize: \(itemSize) = \(requestedWidth / itemSize.width)")
//        print("requestedColumns: \(requestedColumns)")
//        print("range: \(endColumn - startColumn)")
//        print("startColumn: \(startColumn)")
//        print("endColumn: \(endColumn)")
        
        let maxColumns = numberOfSections * numberOfSectionsPerMonth * 7
        let maxSections = numberOfSections * numberOfSectionsPerMonth
        
        if endColumn > maxColumns {
            endColumn = maxColumns
        } // range for this loop loads an extra column so that it will not flicker when a user scrolls. // however you will get outOfBounds error if reached the end. Do check here
        if startColumn >= endColumn { startColumn = endColumn - 1 }
        if startColumn < 0 { startColumn = 0 } // If the user scrolls beyond the left end boundary

        
        
        var attributes: [UICollectionViewLayoutAttributes] = []
        
        if headerViewXibs.count > 0 {
            if endSection >= maxSections {
                endSection = maxSections - 1
            }
            if startSection >= endSection {
                startSection = endSection - 1
            }
            if startSection < 0 {
                startSection = 0
            }
            
            for index in startSection...endSection {
                let sectionIndexPath = NSIndexPath(forItem: 0, inSection: index)
                if let aHeaderAttr = layoutAttributesForSupplementaryViewOfKind(UICollectionElementKindSectionHeader, atIndexPath: sectionIndexPath) {
                    attributes.append(aHeaderAttr)
                    
                } else {
                    print("error")
                }
            }
        }
        
        for index in 0..<numberOfRows {
            for columnNumber in startColumn..<endColumn {
                let section = columnNumber / numberOfColumns
                
                
                let sectionIndex = (columnNumber % numberOfColumns) + (index * numberOfColumns)
                let indexPath = NSIndexPath(forItem: sectionIndex, inSection: section)

                if let attribute = layoutAttributesForItemAtIndexPath(indexPath) {
                    attributes.append(attribute)
                } else {
                    print("error")
                }
            }
        }
        return attributes
    }
    /// Returns the layout attributes for the item at the specified index path. A layout attributes object containing the information to apply to the item’s cell.
    override  public func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        let attr = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
        applyLayoutAttributes(attr)
        return attr
    }
    
    func applyLayoutAttributes(attributes : UICollectionViewLayoutAttributes) {
        if attributes.representedElementKind != nil {
            return
        }
        
        if let collectionView = self.collectionView {
            let stride = collectionView.frame.size.width
            let offset = CGFloat(attributes.indexPath.section) * stride
            var xCellOffset : CGFloat = CGFloat(attributes.indexPath.item % 7) * self.itemSize.width
            xCellOffset += offset
            
            
            
            
            let headerHeight = delegate?.collectionView(collectionView, layout: self, referenceSizeForHeaderInSection: attributes.indexPath.section)
            if headerViewXibs.count > 0 && headerHeight != nil {
                itemSize.height = (collectionView.frame.height - headerHeight!.height) / CGFloat(numberOfRows)
            } else {
                assert(false, "error")
            }
            
            var yCellOffset : CGFloat = CGFloat(attributes.indexPath.item / 7) * self.itemSize.height
            
            if headerViewXibs.count > 0 && headerHeight != nil {
                yCellOffset += headerHeight!.height
            } else {
                assert(false, "error")
            }
            

            attributes.frame = CGRectMake(xCellOffset, yCellOffset, self.itemSize.width, self.itemSize.height)
            attributes.bounds = CGRectMake(0, 0, self.itemSize.width, self.itemSize.height)
        }
    }
    
    
    /// Returns the width and height of the collection view’s contents. The width and height of the collection view’s contents.
    public override func collectionViewContentSize() -> CGSize {
        var size = super.collectionViewContentSize()
        
        size.width = self.collectionView!.bounds.size.width * CGFloat(numberOfSections * numberOfSectionsPerMonth)
        return size
    }
    
    public override func layoutAttributesForSupplementaryViewOfKind(elementKind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        var attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: elementKind, withIndexPath: indexPath)
        let size = delegate!.collectionView(collectionView!, layout: self, referenceSizeForHeaderInSection: indexPath.section)
        let modifiedSize = CGSize(width: collectionView!.frame.size.width, height: size.height)
        let stride = collectionView!.frame.size.width
        let offset = CGFloat(attributes.indexPath.section) * stride

        attributes.frame = CGRect(x: offset, y: 0, width: modifiedSize.width, height: modifiedSize.height)
        
        if attributes.frame == CGRectZero {
            return nil
        }
        
        return attributes
    }
}



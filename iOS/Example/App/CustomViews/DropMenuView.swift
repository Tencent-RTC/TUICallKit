//
//  DropMenuView.swift
//  TUICallKitApp
//
//  Created by vincepzhang on 2023/5/16.
//

import UIKit

public protocol SwiftDropMenuControlContentAppearAble: SwiftDropMenuControlDelegate {
    func on(appear element: SwiftDropMenuControl.AppearElement, forDropMenu menu: SwiftDropMenuControl)
}

@objc public protocol SwiftDropMenuControlDelegate: NSObjectProtocol {
    
    @objc optional func shouldTouchMe(forDropMenu menu: SwiftDropMenuControl) -> Bool
}

open class SwiftDropMenuControl: UIButton {
    
    public typealias ListView = UIView & SwiftDropMenuControlContentAppearAble
    public typealias Delegate = SwiftDropMenuControlDelegate
    
    public enum AppearElement {
        case willDisplay
        case didDisplay
        case willHidden
        case didHidden
    }
    
    public enum Status {
        case opened
        case closed
    }
    
    // MARK: - Properties
    
    open var contentBackgroundColor: UIColor = .white {
        didSet {
            self.listView.backgroundColor = contentBackgroundColor
        }
    }
    
    open var listView: ListView
    weak open var delegate: Delegate?
    public var animateDuration: TimeInterval = 0.25
    public private(set) var status: Status = .closed
    fileprivate lazy var contentView = SwiftDropMenuContentView(contentView: listView)
    
    fileprivate var shouldTouchMe: Bool {
        if let delegate = self.delegate, delegate.responds(to: #selector(SwiftDropMenuListViewDelegate.shouldTouchMe(forDropMenu:))) {
            return delegate.shouldTouchMe?(forDropMenu: self) ?? false
        }
        return true
    }
    
    fileprivate static var currentKeyWindow: UIWindow {
        let windows = UIApplication.shared.windows
        let UIRemoteKeyboardWindow: AnyClass? = NSClassFromString("UIRemoteKeyboardWindow")
        let YYTextEffectWindow: AnyClass? = NSClassFromString("YYTextEffectWindow")
        let UITextEffectsWindow: AnyClass? = NSClassFromString("UITextEffectsWindow")
        let topWindow = windows.last {
            if $0.bounds.equalTo(UIScreen.main.bounds) == true {
                if let UIRemoteKeyboardWindow = UIRemoteKeyboardWindow, $0.isKind(of: UIRemoteKeyboardWindow) {
                    return false
                }
                if let YYTextEffectWindow = YYTextEffectWindow, $0.isKind(of: YYTextEffectWindow) {
                    return false
                }
                if let UITextEffectsWindow = UITextEffectsWindow, $0.isKind(of: UITextEffectsWindow) {
                    return false
                }
                return true
            }
            return false
        }
        if let window = topWindow {
            return window
        }
        return UIApplication.shared.keyWindow ?? UIWindow()
    }
    
    
    fileprivate var screenPosition: CGPoint {
        return self.superview?.convert(self.frame.origin, to: Self.currentKeyWindow) ?? .zero
    }
    
    // MARK: - Initialize
    
    deinit {
        self.contentView.removeFromSuperview()
    }
    
    public init(frame: CGRect, listView: ListView) {
        self.listView = listView
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder: NSCoder) {
        self.listView = UIView() as! SwiftDropMenuControl.ListView
        super.init(coder: coder)
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        
        commonInit()
    }
    
    fileprivate func commonInit() {
        self.addTarget(self, action: #selector(touchMe(sender:)), for: .touchUpInside)
        
        contentView.isHidden = true
        contentView.addTarget(self, action: #selector(tapOnContentView), for: .touchUpInside)
        
        self.listView.backgroundColor = self.contentBackgroundColor
    }
    
    // MARK: - Public Methods
    
    open func toggle() {
        if status == .closed {
            show()
        }
        else {
            dismiss()
        }
    }
    
    open func show() {
        if status == .opened {
            return
        }
        status = .opened
        
        contentView.touchNotInContentBlock = {[weak self] point in
            self?.dismiss()
        }
        
        let newPosition = self.screenPosition
        contentView.masksViewTop?.constant = newPosition.y + self.frame.size.height
        
        contentView.masksView.layer.borderColor  = self.layer.borderColor
        contentView.masksView.layer.borderWidth  = self.layer.borderWidth
        contentView.masksView.layer.cornerRadius = self.layer.cornerRadius
        contentView.coverViewTop?.constant = newPosition.y + self.frame.size.height
        
        let window = SwiftDropMenuControl.currentKeyWindow
        window.addSubview(contentView)
        contentView.frame = window.bounds
        
        willDisplay()
        
        contentView.layoutIfNeeded()
        contentView.isHidden = false
        
        if contentView.frame.size.height == 0 {
            assertionFailure("ListView height is empty and should not be expanded.")
        }
        
        contentView.contentViewTop?.constant = 0.0
        UIView.animate(withDuration: self.animateDuration, animations: { [unowned self] in
            contentView.layoutIfNeeded()
        }) { [unowned self] (isFinished) in
            didDisplay()
        }
    }
    
    open func dismiss() {
        if status == .closed {
            return
        }
        
        self.contentView.touchNotInContentBlock = nil
        
        willHidden()
        
        self.contentView.contentViewTop?.constant = -contentView.masksView.frame.size.height
        UIView.animate(withDuration: self.animateDuration, delay: 0, options: .curveEaseInOut) { [unowned self] in
            contentView.alpha = 0
            contentView.layoutIfNeeded()
        } completion: { [unowned self] isFinished in
            contentView.isHidden = true
            contentView.alpha = 1
            status = .closed
            didHidden()
        }
    }
    
    // MARK: - Actions
    
    @objc private func touchMe(sender: UIButton) {
        if self.shouldTouchMe == true {
            self.toggle()
        }
    }
    
    @objc private func tapOnContentView() {
        dismiss()
    }
    
    // MARK: - Appear Callback
    
    private func willDisplay() {
        (delegate as? SwiftDropMenuControlContentAppearAble)?.on(appear: .willDisplay, forDropMenu: self)
        listView.on(appear: .willDisplay, forDropMenu: self)
    }
    
    private func didDisplay() {
        (delegate as? SwiftDropMenuControlContentAppearAble)?.on(appear: .didDisplay, forDropMenu: self)
        listView.on(appear: .didDisplay, forDropMenu: self)
    }
    
    private func willHidden() {
        (delegate as? SwiftDropMenuControlContentAppearAble)?.on(appear: .willHidden, forDropMenu: self)
        listView.on(appear: .willHidden, forDropMenu: self)
    }
    
    private func didHidden() {
        (delegate as? SwiftDropMenuControlContentAppearAble)?.on(appear: .didHidden, forDropMenu: self)
        listView.on(appear: .didHidden, forDropMenu: self)
    }
}

@objc public protocol SwiftDropMenuListViewDataSource: NSObjectProtocol {
    
    func numberOfItems(in menu: SwiftDropMenuListView) -> Int
    func dropMenu(_ menu: SwiftDropMenuListView, titleForItemAt index: Int) -> String
    @objc optional func heightOfRow(in menu: SwiftDropMenuListView) -> CGFloat
    @objc optional func indexOfSelectedItem(in menu: SwiftDropMenuListView) -> Int
    @objc optional func numberOfColumns(in menu: SwiftDropMenuListView) -> Int
    
}


@objc public protocol SwiftDropMenuListViewDelegate: SwiftDropMenuControlDelegate {
    
    @objc optional func dropMenu(_ menu: SwiftDropMenuListView, didSelectItem: String?, atIndex index: Int)
}

open class SwiftDropMenuListView: SwiftDropMenuControl {
    
    open weak var dataSource: SwiftDropMenuListViewDataSource?
    open var numberOfMaxRows: Int?
    
    open var collectionView: UICollectionView {
        return self.listView as! UICollectionView
    }
    
    private var collectionViewHeight: NSLayoutConstraint?
    
    open var numberOfColumns: Int {
        
        if self.dataSource?.responds(to: #selector(SwiftDropMenuListViewDataSource.numberOfColumns(in:))) == false {
            return 1
        }
        let numberOfOnline = self.dataSource?.numberOfColumns?(in: self) ?? 1
        return max(1, numberOfOnline)
    }
    
    private var totalRows: Int {
        guard let count = dataSource?.numberOfItems(in: self) else {
            return 0
        }
        let totalRows = ceil(Float(count) / Float(numberOfColumns))
        return Int(totalRows)
    }
    
    private var heightOfRow: CGFloat {
        if dataSource?.responds(to: #selector(SwiftDropMenuListViewDataSource.heightOfRow(in:))) == false {
            return 30.0
        }
        return dataSource?.heightOfRow?(in: self) ?? 30.0
    }
    
    open var listHeight: CGFloat {
        var totalRows = self.totalRows
        if let maxLines = self.numberOfMaxRows, totalRows > maxLines {
            totalRows = maxLines
            collectionView.isScrollEnabled = true
        }
        else {
            collectionView.isScrollEnabled = false
        }
        var listHeight = floor(self.heightOfRow * CGFloat(totalRows))
        let insets = self.collectionView(collectionView,
                                         layout: collectionView.collectionViewLayout as! UICollectionViewFlowLayout,
                                         insetForSectionAt: 0)
        
        listHeight += insets.top + insets.bottom
        let linePadding = self.collectionView(collectionView,
                                              layout: collectionView.collectionViewLayout as! UICollectionViewFlowLayout,
                                              minimumLineSpacingForSectionAt: 0)
        listHeight += CGFloat(totalRows - 1) * linePadding
        return listHeight
    }
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    public init(frame: CGRect) {
        super.init(frame: frame, listView: Self.createCollectionView())
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    fileprivate override func commonInit() {
        super.commonInit()
        collectionView.delegate = self
        collectionView.dataSource  = self
        collectionViewHeight = collectionView.heightAnchor.constraint(equalToConstant: 0)
        collectionViewHeight?.isActive = true
    }
    
    open func reloadData() {
        self.collectionView.reloadData()
    }
    
    open override func show() {
        collectionViewHeight?.constant = listHeight
        super.show()
    }
    
    private static func createCollectionView() -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isScrollEnabled  = false
        collectionView.backgroundColor = .clear
        collectionView.register(SwiftDropMenuDefaultCell.self, forCellWithReuseIdentifier: "SwiftDropMenuDefaultCell")
        return collectionView
    }
}

extension SwiftDropMenuListView: UICollectionViewDataSource {
    
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataSource?.numberOfItems(in: self) ?? 0
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SwiftDropMenuDefaultCell", for: indexPath) as! SwiftDropMenuDefaultCell
        let title = self.dataSource?.dropMenu(self, titleForItemAt: indexPath.row)
        let selectIndex = self.dataSource?.indexOfSelectedItem?(in: self)
        if selectIndex == indexPath.row {
            cell.contentView.layer.borderColor = UIColor(red: 255/255.0, green: 49/255.0, blue: 74/255.0, alpha: 1.0).cgColor
            cell.contentView.backgroundColor = UIColor(red: 253/255.0, green: 248/255.0, blue: 248/255.0, alpha: 1.0)
            cell.titleLabel.textColor = UIColor(red: 253/255.0, green: 49/255.0, blue: 74/255.0, alpha: 1.0)
        }
        else {
            cell.contentView.layer.borderColor = UIColor(red: 221/255.0, green: 221/255.0, blue: 221/255.0, alpha: 1.0).cgColor
            cell.contentView.backgroundColor = .white
            cell.titleLabel.textColor = UIColor(red: 111/255.0, green: 111/255.0, blue: 112/255.0, alpha: 1.0)
        }
        cell.titleLabel.text = title
        return cell
    }
    
}

extension SwiftDropMenuListView: UICollectionViewDelegateFlowLayout {
    
    open func collectionView(_ collectionView: UICollectionView,
                             layout collectionViewLayout: UICollectionViewLayout,
                             sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numberOfOnline = CGFloat(self.numberOfColumns)
        let insets = self.collectionView(collectionView, layout: collectionViewLayout,
                                         insetForSectionAt: indexPath.section)
        let padding = self.collectionView(collectionView, layout: collectionViewLayout,
                                          minimumInteritemSpacingForSectionAt: indexPath.section)
        
        let contentWidth = ((collectionView.frame.size.width - insets.left - insets.right) - (numberOfOnline - 1) * padding)
        let itemWidth = floor(contentWidth / numberOfOnline)
        
        return CGSize(width: itemWidth, height: self.heightOfRow)
    }
    
    open func collectionView(_ collectionView: UICollectionView,
                             layout collectionViewLayout: UICollectionViewLayout,
                             insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 10, left: 15, bottom: 10, right: 15)
    }
    
    open func collectionView(_ collectionView: UICollectionView,
                             layout collectionViewLayout: UICollectionViewLayout,
                             minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }
    
    open func collectionView(_ collectionView: UICollectionView,
                             layout collectionViewLayout: UICollectionViewLayout,
                             minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }
    
    open func collectionView(_ collectionView: UICollectionView,
                             didSelectItemAt indexPath:  IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! SwiftDropMenuDefaultCell
        if let delegate = self.delegate as? SwiftDropMenuListViewDelegate,
           delegate.responds(to: #selector(SwiftDropMenuListViewDelegate.dropMenu(_:didSelectItem:atIndex:))) == true {
            delegate.dropMenu?(self, didSelectItem: cell.titleLabel.text, atIndex: indexPath.row)
        }
        
        collectionView.reloadData()
        
        DispatchQueue.main.async {
            self.dismiss()
        }
    }
}

private class SwiftDropMenuContentView: UIControl {
    
    lazy var masksView: UIView = {
        let masksView = UIView()
        masksView.layer.masksToBounds = true
        return masksView
    }()
    lazy var coverView: UIView = {
        let coverView = UIView()
        coverView.isUserInteractionEnabled = false
        coverView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        return coverView
    }()
    
    var contentView: UIView
    
    weak var masksViewTop: NSLayoutConstraint?
    weak var coverViewTop: NSLayoutConstraint?
    weak var contentViewTop: NSLayoutConstraint?
    
    var touchNotInContentBlock: ((_ point: CGPoint) -> Void)?
    
    init(contentView: UIView) {
        self.contentView = contentView
        super.init(frame: .zero)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }
    
    private func commonInit() {
        
        backgroundColor = .clear
        
        addSubview(coverView)
        addSubview(masksView)
        masksView.addSubview(contentView)
        
        coverView.translatesAutoresizingMaskIntoConstraints = false
        masksView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        let coverViewTop = coverView.topAnchor.constraint(equalTo: self.topAnchor)
        coverViewTop.isActive = true
        self.coverViewTop = coverViewTop
        coverView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        coverView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        coverView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        masksView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        masksView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        masksView.heightAnchor.constraint(equalTo: contentView.heightAnchor).isActive = true
        let masksViewTop = masksView.topAnchor.constraint(equalTo: self.topAnchor)
        masksViewTop.isActive = true
        self.masksViewTop = masksViewTop
        
        contentView.leadingAnchor.constraint(equalTo: masksView.leadingAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: masksView.trailingAnchor).isActive = true
        let contentViewTop = contentView.topAnchor.constraint(equalTo: masksView.topAnchor)
        contentViewTop.isActive = true
        self.contentViewTop = contentViewTop
    }
    
    func shouldTouchInCover(point: CGPoint) -> Bool {
        return self.coverView.frame.contains(point) == true
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let flag = shouldTouchInCover(point: point)
        if flag == true {
            return super.hitTest(point, with: event)
        }
        if let block = self.touchNotInContentBlock {
            block(point)
        }
        return nil
    }
    
}

private class SwiftDropMenuDefaultCell: UICollectionViewCell {
    lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.systemFont(ofSize: 12.0)
        return titleLabel
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }
    
    private func commonInit() {
        self.contentView.addSubview(self.titleLabel)
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        var constraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[titleLabel]|",
                                                         options: [],
                                                         metrics: nil,
                                                         views: ["titleLabel": self.titleLabel])
        constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "H:|[titleLabel]|",
                                                                      options: [],
                                                                      metrics: nil,
                                                                      views: ["titleLabel": self.titleLabel]))
        NSLayoutConstraint.activate(constraints)
        
        
        self.contentView.layer.borderColor = UIColor(red: 221/255.0, green: 221/255.0, blue: 221/255.0, alpha: 1.0).cgColor
        self.contentView.backgroundColor = .white
        self.titleLabel.textColor = UIColor(red: 111/255.0, green: 111/255.0, blue: 112/255.0, alpha: 1.0)
        
        self.contentView.clipsToBounds = true
        self.contentView.layer.cornerRadius = 5.0
        self.contentView.layer.borderWidth = 1.0
    }
}

extension SwiftDropMenuControlContentAppearAble where Self: UICollectionView {
    public func on(appear element: SwiftDropMenuControl.AppearElement, forDropMenu menu: SwiftDropMenuControl) {}
}
extension UICollectionView: SwiftDropMenuControlContentAppearAble {}

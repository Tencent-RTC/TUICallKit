//
//  DropMenuView.swift
//  TUICallKitApp
//
//  Created by vincepzhang on 2023/5/16.
//

import UIKit

/// 反内容馈显示或消失的回调
public protocol SwiftDropMenuControlContentAppearable: SwiftDropMenuControlDelegate {
     
     func on(appear element: SwiftDropMenuControl.AppearElement, forDropMenu menu: SwiftDropMenuControl)
}

@objc public protocol SwiftDropMenuControlDelegate: NSObjectProtocol {
     
     @objc optional func shouldTouchMe(forDropMenu menu: SwiftDropMenuControl) -> Bool
}

/// 下拉菜单的基类，单独使用时可自定义一个下拉菜单，需在初始化方法中传入`listView`，这个`listView`作为展开菜单的内容
///
/// 使用方式简单，像创建`UIButton`一样，因为它继承自`UIButton`，
/// 另外扩展两个方法：`show()`和`dismiss()`，用于展开和收起菜单
/// - Warning: 展开菜单的高度，取决于`listView`自身，所以`listView`需要有其自身的高度约束
///
///
///       func createMenuControl() {
///            /// 使用`frame`
///            let menuControl = SwiftDropMenuControl(frame: CGRect(x: 100, y: 280, width: 120, height: 44), listView: NearbyFilterDropMenuView())
///            menuControl.setTitle("自定义菜单", for: .normal)
///            menuControl.setTitleColor(.gray, for: .normal)
///            menuControl.setTitleColor(.gray, for: .normal)
///            menuControl.setTitleColor(.red, for: .selected)
///            menuControl.setImage(UIImage(named: "icon_sort_arrow_down_1"), for: .normal)
///            menuControl.setImage(UIImage(named: "icon_sort_arrow_up_1"), for: .selected)
///            menuControl.contentHorizontalAlignment = .right
///            menuControl.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 50)
///            menuControl.animateDuration = 0.1
///            menuControl.delegate = self
///            menuControl.sizeToFit()
///            self.view.addSubview(menuControl)
///       }
open class SwiftDropMenuControl: UIButton {
     
     public typealias ListView = UIView & SwiftDropMenuControlContentAppearable
     public typealias Delegate = SwiftDropMenuControlDelegate
     
     public enum AppearElement {
          /// 即将展开下拉列表
          case willDisplay
          /// 已经展开下拉列表
          case didDisplay
          /// 即将收起下拉列表
          case willHidden
          /// 已经收起下拉列表
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
     
     /// 展示下拉列表的内容视图
     open var listView: ListView
     
     weak open var delegate: Delegate?
     
     /// 下拉动画时间 default: 0.25
     public var animateDuration: TimeInterval = 0.25
     /// 下拉菜单的状态，默认为关闭
     public private(set) var status: Status = .closed
     /// 下拉菜单的背景视图
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
     
     /// 初始化方法
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
     
     /// 展开下拉菜单
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
               assertionFailure("ListView 高度为空，不应该被展开")
          }
          // 执行展开动画
          contentView.contentViewTop?.constant = 0.0
          UIView.animate(withDuration: self.animateDuration, animations: { [unowned self] in
               contentView.layoutIfNeeded()
          }) { [unowned self] (isFinished) in
               didDisplay()
          }
     }
     
     /// 收起下拉菜单
     open func dismiss() {
          if status == .closed {
               return
          }
          
          self.contentView.touchNotInContentBlock = nil
          
          willHidden()
          
          // 执行关闭动画，让contentView 在`masksView`(`contentView`的父视图)之上，让其消失
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
     /// 即将显示下拉列表
     private func willDisplay() {
          (delegate as? SwiftDropMenuControlContentAppearable)?.on(appear: .willDisplay, forDropMenu: self)
          listView.on(appear: .willDisplay, forDropMenu: self)
     }
     /// 已经显示下拉列表
     private func didDisplay() {
          (delegate as? SwiftDropMenuControlContentAppearable)?.on(appear: .didDisplay, forDropMenu: self)
          listView.on(appear: .didDisplay, forDropMenu: self)
     }
     /// 即将隐藏下拉列表
     private func willHidden() {
          (delegate as? SwiftDropMenuControlContentAppearable)?.on(appear: .willHidden, forDropMenu: self)
          listView.on(appear: .willHidden, forDropMenu: self)
     }
     /// 已经隐藏下拉列表
     private func didHidden() {
          (delegate as? SwiftDropMenuControlContentAppearable)?.on(appear: .didHidden, forDropMenu: self)
          listView.on(appear: .didHidden, forDropMenu: self)
     }
}

@objc public protocol SwiftDropMenuListViewDataSource: NSObjectProtocol {
     
     /// 总数量
     func numberOfItems(in menu: SwiftDropMenuListView) -> Int
     /// 标题
     func dropMenu(_ menu: SwiftDropMenuListView, titleForItemAt index: Int) -> String
     /// 获取每行的高度，默认30.0
     @objc optional func heightOfRow(in menu: SwiftDropMenuListView) -> CGFloat
     /// 获取选中的index
     @objc optional func indexOfSelectedItem(in menu: SwiftDropMenuListView) -> Int
     /// 每行展示的数量
     @objc optional func numberOfColumns(in menu: SwiftDropMenuListView) -> Int
}


@objc public protocol SwiftDropMenuListViewDelegate: SwiftDropMenuControlDelegate {
     
     @objc optional func dropMenu(_ menu: SwiftDropMenuListView, didSelectItem: String?, atIndex index: Int)
}

/// 基于`SwiftDropMenuControl`,使用`CollectionView`作为下拉菜单的`listView`
///
/// 使用方式简单，像创建`UIButton`一样，因为它继承自`UIButton`，
/// 另外扩展两个方法：`show()`和`dismiss()`，用于展开和收起菜单
/// - Warning: 展开的内容高度根据内容自适应，展开菜单的样式需实现`SwiftDropMenuListViewDataSource`自定义
///
///       func createMenuListView() {
///            let menuView = SwiftDropMenuListView(frame: CGRect(x: 0, y: 0, width: 50, height: 40))
///            menuView.setTitle("menu", for: .normal)
///            self.view.addSubview(menuView)
///            menuView.delegate = self
///            menuView.dataSource = self
///       }
open class SwiftDropMenuListView: SwiftDropMenuControl {
     
     open weak var dataSource: SwiftDropMenuListViewDataSource?
     /// 最多展示的行数，当实际行数大于numberOfMaxRows时，支持滚动
     open var numberOfMaxRows: Int?
     
     /// 下拉列表 == listView
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
          // 计算行数
          let totalRows = ceil(Float(count) / Float(numberOfColumns))
          return Int(totalRows)
     }
     
     private var heightOfRow: CGFloat {
          if dataSource?.responds(to: #selector(SwiftDropMenuListViewDataSource.heightOfRow(in:))) == false {
               return 30.0
          }
          return dataSource?.heightOfRow?(in: self) ?? 30.0
     }
     
     
     /// 计算行数
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
          
          // 加上每行之间的间距
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

/// 展示下拉菜单的视图，以填充整个屏幕显示
private class SwiftDropMenuContentView: UIControl {
     
     /// 用做`contentView`的父视图，当做动画时，`contentView`向上移动时，超出其父视图部分会被裁切
     lazy var masksView: UIView = {
          let masksView = UIView()
          masksView.layer.masksToBounds = true
          return masksView
     }()
     /// 背景视图
     lazy var coverView: UIView = {
          let coverView = UIView()
          coverView.isUserInteractionEnabled = false
          coverView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
          return coverView
     }()
     /// 展示内容的视图
     var contentView: UIView
     
     weak var masksViewTop: NSLayoutConstraint?
     weak var coverViewTop: NSLayoutConstraint?
     weak var contentViewTop: NSLayoutConstraint?
     
     /// 点击了不在contentView 上的坐标
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
     
     /// 只有相对在coverView上的坐标才可以点击
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
     
     //    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
     //        return shouldTouch(point: point)
     //    }
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

/// 适配`SwiftDropMenuListView.ListView`
extension SwiftDropMenuControlContentAppearable where Self: UICollectionView {
     public func on(appear element: SwiftDropMenuControl.AppearElement, forDropMenu menu: SwiftDropMenuControl) {}
}
extension UICollectionView: SwiftDropMenuControlContentAppearable {}

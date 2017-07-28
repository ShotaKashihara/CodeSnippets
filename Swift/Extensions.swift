//
//  Extensions.swift
//
//  Created by Shota Kashihara on 2017/06/01.
//  Copyright © 2017年 plusr. All rights reserved.
//

import Foundation

public extension NSPredicate {
    
    public static var empty: NSPredicate {
        return NSPredicate(value: true)
    }
    
    private convenience init(expression property: String, _ operation: String, _ value: AnyObject) {
        self.init(format: "\(property) \(operation) %@", argumentArray: [value])
    }
    
    public convenience init(_ property: String, equal value: AnyObject) {
        self.init(expression: property, "=", value)
    }
    
    public convenience init(_ property: String, notEqual value: AnyObject) {
        self.init(expression: property, "!=", value)
    }
    
    public convenience init(_ property: String, equalOrGreaterThan value: AnyObject) {
        self.init(expression: property, ">=", value)
    }
    
    public convenience init(_ property: String, equalOrLessThan value: AnyObject) {
        self.init(expression: property, "<=", value)
    }
    
    public convenience init(_ property: String, greaterThan value: AnyObject) {
        self.init(expression: property, ">", value)
    }
    
    public convenience init(_ property: String, lessThan value: AnyObject) {
        self.init(expression: property, "<", value)
    }
    
    // 前後方一致検索(いわゆる、あいまい検索)
    public convenience init(_ property: String, contains q: String) {
        self.init(format: "\(property) CONTAINS '\(q)'")
    }
    
    // 前方一致検索
    public convenience init(_ property: String, beginsWith q: String) {
        self.init(format: "\(property) BEGINSWITH '\(q)'")
    }
    
    // 後方一致検索
    public convenience init(_ property: String, endsWith q: String) {
        self.init(format: "\(property) ENDSWITH '\(q)'")
    }
    
    public convenience init(_ property: String, valuesIn values: [AnyObject]) {
        self.init(format: "\(property) IN %@", argumentArray: [values])
    }
    
    public convenience init(_ property: String, between min: AnyObject, to max: AnyObject) {
        self.init(format: "\(property) BETWEEN {%@, %@}", argumentArray: [min, max])
    }
    
    public convenience init(_ property: String, fromDate: NSDate?, toDate: NSDate?) {
        var format = "", args = [AnyObject]()
        if let from = fromDate {
            format += "\(property) >= %@"
            args.append(from)
        }
        if let to = toDate {
            if !format.isEmpty {
                format += " AND "
            }
            format += "\(property) <= %@"
            args.append(to)
        }
        if !args.isEmpty {
            self.init(format: format, argumentArray: args)
        } else {
            self.init(value: true)
        }
    }
    
    public func compound(_ predicates: [NSPredicate], type: NSCompoundPredicate.LogicalType = .and) -> NSPredicate {
        var p = predicates; p.insert(self, at: 0)
        switch type {
        case .and: return NSCompoundPredicate(andPredicateWithSubpredicates: p)
        case .or:  return NSCompoundPredicate(orPredicateWithSubpredicates:  p)
        case .not: return NSCompoundPredicate(notPredicateWithSubpredicate:  self.compound(p))
        }
    }
    
    public func and(predicate: NSPredicate) -> NSPredicate {
        return self.compound([predicate], type: .and)
    }
    
    public func or(predicate: NSPredicate) -> NSPredicate {
        return self.compound([predicate], type: .or)
    }
    
    public func not(predicate: NSPredicate) -> NSPredicate {
        return self.compound([predicate], type: .not)
    }
}

extension NSObject {
    class var className: String {
        return String(describing: self)
    }
    
    var className: String {
        return type(of: self).className
    }
}

extension UITableView {
    func register<T: UITableViewCell>(cellType: T.Type) {
        let className = cellType.className
        let nib = UINib(nibName: className, bundle: nil)
        register(nib, forCellReuseIdentifier: className)
    }
    
    func register<T: UITableViewCell>(cellTypes: [T.Type]) {
        cellTypes.forEach { register(cellType: $0) }
    }
    
    func dequeueReusableCell<T: UITableViewCell>(with type: T.Type, for indexPath: IndexPath) -> T {
        return self.dequeueReusableCell(withIdentifier: type.className, for: indexPath) as! T
    }
}

extension UICollectionView {
    func register<T: UICollectionViewCell>(cellType: T.Type) {
        let className = cellType.className
        let nib = UINib(nibName: className, bundle: nil)
        register(nib, forCellWithReuseIdentifier: className)
    }
    
    func register<T: UICollectionViewCell>(cellTypes: [T.Type]) {
        cellTypes.forEach { register(cellType: $0) }
    }
    
    func register<T: UICollectionReusableView>(reusableViewType: T.Type, of kind: String) {
        let className = reusableViewType.className
        let nib = UINib(nibName: className, bundle: nil)
        register(nib, forSupplementaryViewOfKind: kind, withReuseIdentifier: className)
    }
    
    func register<T: UICollectionReusableView>(reusableViewTypes: [T.Type], kind: String) {
        reusableViewTypes.forEach { register(reusableViewType: $0, of: kind) }
    }
    
    func dequeueReusableCell<T: UICollectionViewCell>(with type: T.Type, for indexPath: IndexPath) -> T {
        return dequeueReusableCell(withReuseIdentifier: type.className, for: indexPath) as! T
    }
    
    func dequeueReusableView<T: UICollectionReusableView>(with type: T.Type, for indexPath: IndexPath, of kind: String) -> T {
        return dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: type.className, for: indexPath) as! T
    }
}

protocol StoryBoardInstantiatable {}
extension UIViewController: StoryBoardInstantiatable {}

extension StoryBoardInstantiatable where Self: UIViewController {
    
    static func instantiateInitial() -> Self {
        let storyboard = UIStoryboard.init(name: Self.className, bundle: nil)
        return storyboard.instantiateInitialViewController() as! Self
    }
    
    static func instantiate(withStoryboard storyboard: String) -> Self {
        let storyboard = UIStoryboard(name: storyboard, bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: Self.className) as! Self
    }
    
    static func instantiateInitialNav() -> UINavigationController {
        let storyboard = UIStoryboard.init(name: Self.className, bundle: nil)
        let nc = storyboard.instantiateInitialViewController() as! UINavigationController
        return nc
    }
}

extension UIStoryboard {
    
    func instantiate<T: UIViewController>(viewController: T.Type) -> T {
        return self.instantiateViewController(withIdentifier: T.className) as! T
    }
    
}

protocol NibInstantiatable {}
extension UIView: NibInstantiatable {}

extension NibInstantiatable where Self: UIView {
    static func instantiate(withOwner ownerOrNil: Any? = nil) -> Self {
        let nib = UINib(nibName: self.className, bundle: nil)
        return nib.instantiate(withOwner: ownerOrNil, options: nil)[0] as! Self
    }
}

extension Collection {
    subscript(safe index: Index) -> _Element? {
        return index >= startIndex && index < endIndex ? self[index] : nil
    }
}

extension UITextField {
    
    func setToolBar(_ title: String, handler: @escaping ((UIBarButtonItem) -> Void)) {
        // ツールバー
        let pickerToolBar = UIToolbar.init(frame: CGRect.init(x: 0, y: DeviceSize.screenHeight() / 6, width: DeviceSize.screenWidth(), height: 44))
        pickerToolBar.layer.position = CGPoint(x: DeviceSize.screenWidth().toCGFloat() / 2.0, y: DeviceSize.screenHeight().toCGFloat() - 20.0)
        pickerToolBar.barStyle = .default
        pickerToolBar.isTranslucent = true
        pickerToolBar.tintColor = UIColor.xFontColor
        pickerToolBar.backgroundColor = UIColor.xWheat
        
        // ツールバーにボタンの設定
        // 右寄せのためのスペース設定
        let spaceBarBtn = UIBarButtonItem.init(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        
        // 完了ボタンを設定
        let toolBarBtn = UIBarButtonItem.init(title: title, style: .done, handler: handler)
        
        // ツールバーにボタンを表示
        pickerToolBar.items = [spaceBarBtn, toolBarBtn]
        self.inputAccessoryView = pickerToolBar
    }
}

extension UIView {
    
    // 影のオフセット、位置
    @IBInspectable var shadowOffset: CGSize {
        get {
            return self.layer.shadowOffset
        }
        set {
            self.layer.shadowOffset = newValue
        }
    }
    
    // 影の不透明度
    @IBInspectable var shadowOpacity: Float {
        get {
            return self.layer.shadowOpacity
        }
        set {
            self.layer.shadowOpacity = newValue
        }
    }
    
    // 影の色
    @IBInspectable var shadowColor: UIColor {
        get {
            guard let color = self.layer.shadowColor else {
                return UIColor.black
            }
            return UIColor.init(cgColor: color)
        }
        set {
            self.layer.shadowColor = newValue.cgColor
        }
    }
    
    // 角丸の設定
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return self.layer.cornerRadius
        }
        set {
            self.layer.cornerRadius = newValue
        }
    }
    
    // ぼかしの量
    @IBInspectable var shadowRadius: CGFloat {
        get {
            return self.layer.shadowRadius
        }
        set {
            self.layer.shadowRadius = newValue
        }
    }
    
    //ボーダーに対してradiusはかかるので必須
    @IBInspectable var borderWidth: CGFloat {
        get {
            return self.layer.borderWidth
        }
        set {
            self.layer.borderWidth = newValue
        }
    }
    
    //透明にしておけば大丈夫
    @IBInspectable var borderColor: UIColor {
        get {
            guard let color = self.layer.borderColor else {
                return UIColor.clear
            }
            return UIColor.init(cgColor: color)
        }
        set {
            self.layer.borderColor = newValue.cgColor
        }
    }
}

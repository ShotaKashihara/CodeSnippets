//
//  Extensions.swift
//
//  Created by Shota Kashihara on 2017/06/01.
//  Copyright © 2017年 plusr. All rights reserved.
//

import UIKit
import Foundation
import AdSupport

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
    
    func registerHeaderFooter<T: UIView>(cellType: T.Type) {
        let className = cellType.className
        let nib = UINib(nibName: className, bundle: nil)
        register(nib, forHeaderFooterViewReuseIdentifier: className)
    }
    
    func registerHeaderFooter<T: UIView>(cellTypes: [T.Type]) {
        cellTypes.forEach { registerHeaderFooter(cellType: $0) }
    }
    
    func dequeueReusableHeaderFooterView<T: UIView>(with type: T.Type) -> T {
        return self.dequeueReusableHeaderFooterView(withIdentifier: type.className) as! T
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
    subscript(safe index: Index) -> Element? {
        return index >= startIndex && index < endIndex ? self[index] : nil
    }
}

extension UIView {
    
    /// 可変長ラベルのフィッティング
    @discardableResult
    internal func sizeFitting() -> Self {
        // 重要：xibと実機のwidthが違うと、systemLayoutSizeFittingが正しく計測されないため事前にwidthを合わせる。
        self.frame = CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: self.frame.height)
        
        self.setNeedsLayout()
        self.layoutIfNeeded()
        let size = self.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
        self.frame = CGRect.init(x: 0, y: 0, width: size.width, height: size.height)
        return self
    }
}

extension UIScrollView {
    
    public convenience init(frame: CGRect, subviews: [UIView]) {
        self.init(frame: frame)
        
        // コンテンツサイズの高さ計算
        self.contentSize = CGSize.init(width: frame.width, height: subviews.map { $0.frame.height }.reduce(0, +))
        
        // ビュー連結
        var heightSummary: CGFloat = 0.0
        for subview in subviews {
            subview.frame = CGRect.init(x: 0.0, y: heightSummary, width: frame.width, height: subview.frame.height)
            heightSummary += subview.frame.height
            self.addSubview(subview)
        }
    }
}

/// http://blogios.stack3.net/archives/2468
class ModifiableScrollView: UIScrollView {
    
    var tagViews: [UIView] = []
    
    func resetContentSize() {
        self.contentSize = CGSize.init(width: frame.width, height: self.tagViews.map { $0.frame.height }.reduce(0, +))
    }
    
    func addTagView(tagView: UIView) {
        self.addSubview(tagView)
        self.tagViews.append(tagView)
        self.resetContentSize()
    }
    
    func addTagViews(tagViews: [UIView]) {
        for tagView in tagViews {
            self.addSubview(tagView)
            self.tagViews.append(tagView)
        }
        self.resetContentSize()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        var heightSummary: CGFloat = 0.0
        for tagView in tagViews {
            tagView.frame = CGRect.init(x: 0.0, y: heightSummary, width: frame.width, height: tagView.frame.height)
            heightSummary += tagView.frame.height
        }
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

extension String {
    
    func toInt() -> Int? {
        return Int(self)
    }
    
    func toDate(_ format: String) -> Date? {
        let dateFormatter = DateFormatter.init()
        dateFormatter.locale = Locale.init(identifier: "ja_JP")
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: self)
    }
}

extension Date {
    
    static func fromStringPOSIX(_ dateString: String) -> Date? {
        let dateFormatter = DateFormatter.init()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone.init(secondsFromGMT: -1 * 60 * 60 * 9)
        dateFormatter.calendar = Calendar.current
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'.000Z'"
        return dateFormatter.date(from: dateString)
    }
    
    func toStringPOSIX() -> String {
        let dateFormatter = DateFormatter.init()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone.init(secondsFromGMT: 1 * 60 * 60 * 9)
        dateFormatter.calendar = Calendar.current
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'.000Z'"
        return dateFormatter.string(from: self)
    }
    
    func toString(_ format: String) -> String {
        let dateFormatter = DateFormatter.init()
        dateFormatter.locale = Locale.init(identifier: "ja_JP")
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
    
    func addYear(_ year: Int) -> Date {
        let calendar = Calendar(identifier: .gregorian)
        let comps = DateComponents(year: year)
        return calendar.date(byAdding: comps, to: self)!
    }
    
    func addMonth(_ month: Int) -> Date {
        let calendar = Calendar(identifier: .gregorian)
        let comps = DateComponents(month: month)
        return calendar.date(byAdding: comps, to: self)!
    }
    
    func minusMonth(_ month: Int) -> Date {
        let calendar = Calendar(identifier: .gregorian)
        let comps = DateComponents(month: -1 * month)
        return calendar.date(byAdding: comps, to: self)!
    }
    
    func addDay(_ day: Int) -> Date {
        let calendar = Calendar(identifier: .gregorian)
        let comps = DateComponents(day: day)
        return calendar.date(byAdding: comps, to: self)!
    }
    
    func minusDay(_ day: Int) -> Date {
        let calendar = Calendar(identifier: .gregorian)
        let comps = DateComponents(day: -1 * day)
        return calendar.date(byAdding: comps, to: self)!
    }
    
    func addHour(_ hour: Int) -> Date {
        let calendar = Calendar(identifier: .gregorian)
        let comps = DateComponents(hour: hour)
        return calendar.date(byAdding: comps, to: self)!
    }
    
    func minusHour(_ hour: Int) -> Date {
        let calendar = Calendar(identifier: .gregorian)
        let comps = DateComponents(hour: -1 * hour)
        return calendar.date(byAdding: comps, to: self)!
    }
    
    func addMinute(_ minute: Int) -> Date {
        let calendar = Calendar(identifier: .gregorian)
        let comps = DateComponents(minute: minute)
        return calendar.date(byAdding: comps, to: self)!
    }
    
    func minusMinute(_ minute: Int) -> Date {
        let calendar = Calendar(identifier: .gregorian)
        let comps = DateComponents(hour: -1 * minute)
        return calendar.date(byAdding: comps, to: self)!
    }
    
    func addSecond(_ second: Int) -> Date {
        let calendar = Calendar(identifier: .gregorian)
        let comps = DateComponents(second: 1 * second)
        return calendar.date(byAdding: comps, to: self)!
    }
    
    func minusSecond(_ second: Int) -> Date {
        let calendar = Calendar(identifier: .gregorian)
        let comps = DateComponents(second: -1 * second)
        return calendar.date(byAdding: comps, to: self)!
    }
    
    func setTime(hour: Int, minute: Int, second: Int) -> Date {
        let calendar = Calendar(identifier: .gregorian)
        var comp = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self)
        comp.hour = hour
        comp.minute = minute
        comp.second = second
        return calendar.date(from: comp)!
    }
    
    func toComponentsYYYYMMDD() -> (year: Int, month: Int, day: Int) {
        let calendar = Calendar.init(identifier: .gregorian)
        let yearOfNow = calendar.component(.year, from: self)
        let monthOfNow = calendar.component(.month, from: self)
        let dayOfNow = calendar.component(.day, from: self)
        return (year: yearOfNow, month: monthOfNow, day: dayOfNow)
    }
    
    func toComponents(_ components: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute, .second]) -> DateComponents {
        let calendar = Calendar.init(identifier: .gregorian)
        return calendar.dateComponents(components, from: self)
    }
    
    func atStartOfDay() -> Date {
        let calendar = Calendar.init(identifier: .gregorian)
        let c = self.toComponents()
        return calendar.date(from: DateComponents.init(year: c.year, month: c.month, day: c.day))!
    }
}

extension UIColor {
    convenience init?(hexStr: NSString, alpha: CGFloat = 1.0) {
        let hex = hexStr.replacingOccurrences(of: "#", with: "")
        let scanner = Scanner(string: hex as String)
        var color: UInt32 = 0
        if scanner.scanHexInt32(&color) {
            let r = CGFloat((color & 0xFF0000) >> 16) / 255.0
            let g = CGFloat((color & 0x00FF00) >> 8) / 255.0
            let b = CGFloat(color & 0x0000FF) / 255.0
            self.init(red:r, green:g, blue:b, alpha:alpha)
        } else {
            print("invalid hex string")
            return nil;
        }
    }
}

extension UIAlertController {
    
    func addAction(title: String, style: UIAlertActionStyle = .default, handler: ((UIAlertAction) -> Void)? = nil) -> Self {
        let okAction = UIAlertAction(title: title, style: style, handler: handler)
        addAction(okAction)
        return self
    }
    
    func addActionWithTextFields(title: String, style: UIAlertActionStyle = .default, handler: ((UIAlertAction, [UITextField]) -> Void)? = nil) -> Self {
        let okAction = UIAlertAction(title: title, style: style) { [weak self] action in
            handler?(action, self?.textFields ?? [])
        }
        addAction(okAction)
        return self
    }
    
    func configureForIPad(sourceRect: CGRect, sourceView: UIView? = nil) -> Self {
        popoverPresentationController?.sourceRect = sourceRect
        if let sourceView = UIApplication.shared.topViewController?.view {
            popoverPresentationController?.sourceView = sourceView
        }
        return self
    }
    
    func configureForIPad(barButtonItem: UIBarButtonItem) -> Self {
        popoverPresentationController?.barButtonItem = barButtonItem
        return self
    }
    
    func addTextField(handler: @escaping (UITextField) -> Void) -> Self {
        addTextField(configurationHandler: handler)
        return self
    }
    
    func show() {
        UIApplication.shared.topViewController?.present(self, animated: true, completion: nil)
    }
}

extension UIApplication {
    var topViewController: UIViewController? {
        guard var topViewController = UIApplication.shared.keyWindow?.rootViewController else { return nil }
        
        while let presentedViewController = topViewController.presentedViewController {
            topViewController = presentedViewController
        }
        return topViewController
    }
    
    var topNavigationController: UINavigationController? {
        return topViewController as? UINavigationController
    }
}

public extension UIImage {
    func save(_ fileURL: URL) -> Bool {
        guard let imageData = UIImagePNGRepresentation(self) else { return false }
        do {
            try imageData.write(to: fileURL)
            return true
        } catch {
            print("error " + error.localizedDescription)
            return false
        }
    }
}

extension Array {
    public mutating func appendRange(_ newElements: [Element]) {
        for e in newElements {
            self.append(e)
        }
    }
}

public extension UIDevice {
    
    func idfa() -> String? {
        let manager = ASIdentifierManager.shared()
        if manager.isAdvertisingTrackingEnabled {
            return manager.advertisingIdentifier.uuidString.lowercased()
        } else {
            return nil
        }
    }
}

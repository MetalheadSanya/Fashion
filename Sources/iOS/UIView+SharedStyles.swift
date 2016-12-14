import UIKit

extension UIView {

  fileprivate struct AssociatedKeys {
    static var stylesApplied = "fashion_StylesAppliedAssociatedKey"
  }

  // MARK: - Method Swizzling

  override open class func initialize() {
    struct Static {
      static let token = UUID().uuidString
    }

    if self !== UIView.self { return }

    DispatchQueue.once(token: Static.token) {
      Swizzler.swizzle(method: "willMoveToSuperview:", cls: self, prefix: "fashion")
    }
  }

  func fashion_willMoveToSuperview(_ newSuperview: UIView?) {
    fashion_willMoveToSuperview(newSuperview)

    guard runtimeStyles else {
      return
    }

    guard Stylist.master.applyShared(self) && stylesApplied != true else {
      return
    }

    stylesApplied = true

    if let styles = styles {
      self.styles = styles
    }
  }

  fileprivate var stylesApplied: Bool? {
    get {
      return objc_getAssociatedObject(self, &AssociatedKeys.stylesApplied) as? Bool
    }
    set (newValue) {
      objc_setAssociatedObject(self, &AssociatedKeys.stylesApplied,
        newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }
}

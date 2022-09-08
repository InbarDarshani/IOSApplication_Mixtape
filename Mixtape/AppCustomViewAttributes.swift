import Foundation
import UIKit

//Custom view attributes for interface builder

extension UIView{
    @IBInspectable var isBordered: Bool {
        get { return layer.cornerRadius != 0 }
        set{
            if (newValue){
                layer.cornerRadius = 10
                layer.borderWidth = 1
                layer.borderColor = UIColor.lightGray.cgColor
            } else {
                layer.borderWidth = 0
            }
        }
    }
}

extension UITextView {
    @IBInspectable var padding: CGFloat {
        get { return contentInset.top }
        set { contentInset = UIEdgeInsets(top: newValue, left: newValue, bottom: newValue, right: newValue) }
    }
}

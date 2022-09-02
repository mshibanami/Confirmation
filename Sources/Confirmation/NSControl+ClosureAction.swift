//
//  File.swift
//  
//
//  Created by Manabu Nakazawa on 2/9/2022.
//

#if os(macOS)
import AppKit

@objc class ClosureSleeve: NSObject {
    let closure: () -> Void

    init (_ closure: @escaping () -> Void) {
        self.closure = closure
    }

    @objc func invoke() {
        closure()
    }
}

extension NSControl {
    func addAction(_ closure: @escaping () -> Void) {
        let sleeve = ClosureSleeve(closure)
        target = sleeve
        action = #selector(ClosureSleeve.invoke)
        objc_setAssociatedObject(self, "[\(arc4random())]", sleeve, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
    }
}
#endif

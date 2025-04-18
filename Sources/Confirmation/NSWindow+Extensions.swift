//
//  File.swift
//  
//
//  Created by Manabu Nakazawa on 2/9/2022.
//

#if canImport(AppKit)
import AppKit

extension NSWindow {
  func endBeingSheeted() {
    guard sheetParent != nil else {
        return
    }
    sheetParent?.endSheet(self)
  }
}
#endif

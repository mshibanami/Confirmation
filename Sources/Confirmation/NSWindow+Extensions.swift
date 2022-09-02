//
//  File.swift
//  
//
//  Created by Manabu Nakazawa on 2/9/2022.
//

#if os(macOS)
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

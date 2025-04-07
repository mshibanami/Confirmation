//
//  File.swift
//  
//
//  Created by Manabu Nakazawa on 2/9/2022.
//

#if canImport(UIKit)
import UIKit
import SwiftUI

struct ConfirmationSourceView: UIViewRepresentable {
    var uiView: UIView

    public init(_ uiView: UIView) {
        self.uiView = uiView
    }

    public func makeUIView(context: Context) -> UIView {
        uiView
    }

    public func updateUIView(_ uiView: UIView, context: Context) {
    }
}

public extension View {
    func confirmationSourceView(_ uiView: UIView) -> some View {
        overlay(
            ConfirmationSourceView(uiView)
                .allowsHitTesting(false))
    }
}
#endif

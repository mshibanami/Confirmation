//
//  ContentView.swift
//  Example
//
//  Created by Manabu Nakazawa on 2/9/2022.
//

import SwiftUI
import Confirmation

struct ContentView: View {
#if os(iOS)
    private var sheetButtonSourceView = UIView()
#endif

    var body: some View {
        VStack {
            Button(action: { Task { await showAlert() }}) {
                Text("Show an alert")
            }

            Button(action: { Task { await showSheet() }}) {
                Text("Show a sheet")
            }
#if os(iOS)
            .confirmationSourceView(sheetButtonSourceView)
#endif
        }
        .buttonStyle(.borderedProminent)
        .frame(minWidth: 200, maxWidth: .infinity, minHeight: 300, maxHeight: .infinity)
    }

    func showAlert() async {
        let selected = await Confirmation.show(
            title: "Title",
            description: "Description",
            actions: [
                .default(title: "Default"),
                .default(title: "Default (Preferred)", isPreferred: true),
                .cancel()
            ],
            style: .alert())
        guard let selected = selected else {
            return
        }
        handleSelectedAction(selected)
    }

    func showSheet() async {
#if os(macOS)
        let style: Confirmation.Style = .sheet()
#elseif os(iOS)
        let style: Confirmation.Style = .sheet(sourceView: sheetButtonSourceView)
#endif

        let selected = await Confirmation.show(
            title: "Title",
            description: "Description",
            actions: [
                .destructive(title: "Destructive"),
                .default(title: "Default"),
                .cancel()
            ],
            style: style)
        guard let selected = selected else {
            return
        }
        handleSelectedAction(selected)
    }
    
    func handleSelectedAction(_ action: Confirmation.Action) {
        switch action {
        case .cancel:
            print("Canceled")
        case .destructive(title: let title, _):
            print("\"\(title)\" has been selected.")
        case .default(title: let title, _):
            print("\"\(title)\" has been selected.")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

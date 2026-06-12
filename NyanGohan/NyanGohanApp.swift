//
//  NyanGohanApp.swift
//  NyanGohan
//
//  Created by 下村俊介 on 2026/06/10.
//

import SwiftUI

@main
struct NyanGohanApp: App {
    @StateObject private var store = AppStore()
    @StateObject private var purchaseManager = PurchaseManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .environmentObject(purchaseManager)
        }
    }
}

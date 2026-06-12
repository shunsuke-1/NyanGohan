import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: AppStore
    @EnvironmentObject private var purchaseManager: PurchaseManager

    var body: some View {
        RootTabView()
            .task {
                await purchaseManager.prepare(using: store)
            }
            .sheet(item: $store.activePremiumSheet) { reason in
                PremiumView(reason: reason)
                    .environmentObject(store)
                    .environmentObject(purchaseManager)
            }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppStore.preview)
        .environmentObject(PurchaseManager())
}

import Combine
import Foundation
import StoreKit

@MainActor
final class PurchaseManager: ObservableObject {
    @Published private(set) var product: Product?
    @Published private(set) var isLoading = false
    @Published var purchaseMessage: String?

    private let productID = "com.shunsuke.NyanGohan.premium.lifetime"

    func prepare(using store: AppStore) async {
        if product != nil {
            await syncCurrentEntitlements(using: store)
            return
        }

        isLoading = true
        defer { isLoading = false }
        do {
            product = try await Product.products(for: [productID]).first
            await syncCurrentEntitlements(using: store)
        } catch {
            purchaseMessage = "商品情報を取得できませんでした。App Store Connect の設定を確認してください。"
        }
    }

    func purchase(using store: AppStore) async {
        if product == nil {
            await prepare(using: store)
        }
        guard let product else {
            purchaseMessage = "購入商品が未設定です。product id: \(productID)"
            return
        }

        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                switch verification {
                case .verified(let transaction):
                    store.setPremiumUnlocked(true)
                    await transaction.finish()
                    purchaseMessage = "プレミアムを有効化しました。"
                case .unverified:
                    purchaseMessage = "購入の検証に失敗しました。"
                }
            case .pending:
                purchaseMessage = "購入処理は保留中です。"
            case .userCancelled:
                purchaseMessage = "購入はキャンセルされました。"
            @unknown default:
                purchaseMessage = "不明な購入状態です。"
            }
        } catch {
            purchaseMessage = "購入処理に失敗しました。"
        }
    }

    func restorePurchases(using store: AppStore) async {
        isLoading = true
        defer { isLoading = false }

        do {
            try await StoreKit.AppStore.sync()
            await syncCurrentEntitlements(using: store)
            purchaseMessage = store.premiumUnlocked ? "購入情報を復元しました。" : "復元できる購入情報が見つかりませんでした。"
        } catch {
            purchaseMessage = "購入情報の復元に失敗しました。"
        }
    }

    private func syncCurrentEntitlements(using store: AppStore) async {
        var unlocked = false

        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }
            if transaction.productID == productID && transaction.revocationDate == nil {
                unlocked = true
                break
            }
        }

        store.setPremiumUnlocked(unlocked)
    }
}

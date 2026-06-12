import Combine
import Foundation
import PhotosUI
import SwiftUI
import UIKit

@MainActor
final class AppStore: ObservableObject {
    @Published var cats: [CatProfile]
    @Published var foods: [FoodItem]
    @Published var histories: [CalculationHistory]
    @Published var premiumUnlocked: Bool
    @Published var selectedCatID: UUID?
    @Published var selectedFoodID: UUID?
    @Published var latestResult: CalculationResult?
    @Published var activePremiumSheet: PremiumSheetReason?

    static let preview = AppStore(snapshot: .sample)

    private let saveURL: URL

    init(snapshot: AppSnapshot? = nil) {
        saveURL = Self.dataURL
        if let snapshot {
            cats = snapshot.cats
            foods = snapshot.foods
            histories = snapshot.histories
            premiumUnlocked = snapshot.premiumUnlocked
        } else if let loaded = Self.loadSnapshot(from: saveURL) {
            cats = loaded.cats
            foods = loaded.foods
            histories = loaded.histories
            premiumUnlocked = loaded.premiumUnlocked
        } else {
            cats = []
            foods = []
            histories = []
            premiumUnlocked = false
            persist()
        }

        selectedCatID = cats.first?.id
        selectedFoodID = foods.first?.id
    }

    var selectedCat: CatProfile? {
        cats.first(where: { $0.id == selectedCatID })
    }

    var selectedFood: FoodItem? {
        foods.first(where: { $0.id == selectedFoodID })
    }

    var catLimit: Int { premiumUnlocked ? .max : 2 }
    var foodLimit: Int { premiumUnlocked ? .max : 5 }
    var historyLimit: Int { premiumUnlocked ? .max : 5 }

    func saveCat(_ draft: CatDraft, editing: CatProfile?) async {
        guard let weight = Double(draft.weightText), weight > 0 else { return }
        let imagePath = await persistImage(data: draft.imageData, existingPath: editing?.imagePath, prefix: "cat")
        if var editing {
            editing.name = draft.name
            editing.birthday = draft.birthday
            editing.weight = weight
            editing.isNeutered = draft.isNeutered
            editing.imagePath = imagePath ?? editing.imagePath
            editing.memo = draft.memo
            editing.updatedAt = .now
            replaceCat(editing)
        } else {
            guard cats.count < catLimit else {
                activePremiumSheet = .catLimit
                return
            }
            let cat = CatProfile(
                name: draft.name,
                birthday: draft.birthday,
                weight: weight,
                isNeutered: draft.isNeutered,
                imagePath: imagePath,
                memo: draft.memo,
                createdAt: .now,
                updatedAt: .now
            )
            cats.insert(cat, at: 0)
            selectedCatID = cat.id
        }
        persist()
    }

    func deleteCat(_ cat: CatProfile) {
        deleteImageIfNeeded(path: cat.imagePath)
        cats.removeAll { $0.id == cat.id }
        histories.removeAll { $0.catId == cat.id }
        if selectedCatID == cat.id {
            selectedCatID = cats.first?.id
        }
        persist()
    }

    func saveFood(_ draft: FoodDraft, editing: FoodItem?) async {
        guard let calorieValue = Double(draft.calorieText), calorieValue > 0 else { return }
        let imagePath = await persistImage(data: draft.imageData, existingPath: editing?.imagePath, prefix: "food")
        if var editing {
            editing.name = draft.name
            editing.calorieValue = calorieValue
            editing.calorieUnit = draft.calorieUnit
            editing.imagePath = imagePath ?? editing.imagePath
            editing.memo = draft.memo
            editing.updatedAt = .now
            replaceFood(editing)
        } else {
            guard foods.count < foodLimit else {
                activePremiumSheet = .foodLimit
                return
            }
            let food = FoodItem(
                name: draft.name,
                calorieValue: calorieValue,
                calorieUnit: draft.calorieUnit,
                imagePath: imagePath,
                memo: draft.memo,
                createdAt: .now,
                updatedAt: .now
            )
            foods.insert(food, at: 0)
            selectedFoodID = food.id
        }
        persist()
    }

    func deleteFood(_ food: FoodItem) {
        deleteImageIfNeeded(path: food.imagePath)
        foods.removeAll { $0.id == food.id }
        histories.removeAll { $0.foodId == food.id }
        if selectedFoodID == food.id {
            selectedFoodID = foods.first?.id
        }
        persist()
    }

    func calculateCurrentSelection() {
        guard let cat = selectedCat, let food = selectedFood else { return }
        latestResult = FeedCalculator.calculate(cat: cat, food: food)
    }

    func saveLatestResultToHistory() {
        guard let result = latestResult else { return }
        let record = CalculationHistory(
            catId: result.cat.id,
            foodId: result.food.id,
            requiredCalories: result.requiredCalories,
            feedingAmount: result.feedingAmount,
            calculatedAt: .now
        )
        histories.insert(record, at: 0)
        if histories.count > historyLimit {
            if premiumUnlocked {
                histories = Array(histories.prefix(historyLimit))
            } else {
                histories = Array(histories.prefix(5))
                activePremiumSheet = .historyLimit
            }
        }
        persist()
    }

    func historyDetails(for history: CalculationHistory) -> (CatProfile?, FoodItem?) {
        (cats.first(where: { $0.id == history.catId }), foods.first(where: { $0.id == history.foodId }))
    }

    func unlockPremium() {
        premiumUnlocked = true
        persist()
    }

    func setPremiumUnlocked(_ unlocked: Bool) {
        premiumUnlocked = unlocked
        persist()
    }

    func showPremium() {
        activePremiumSheet = .manual
    }

    private func replaceCat(_ cat: CatProfile) {
        guard let index = cats.firstIndex(where: { $0.id == cat.id }) else { return }
        cats[index] = cat
    }

    private func replaceFood(_ food: FoodItem) {
        guard let index = foods.firstIndex(where: { $0.id == food.id }) else { return }
        foods[index] = food
    }

    private func persist() {
        let snapshot = AppSnapshot(
            cats: cats,
            foods: foods,
            histories: histories,
            premiumUnlocked: premiumUnlocked
        )

        do {
            let data = try JSONEncoder().encoded(snapshot)
            try FileManager.default.createDirectory(at: saveURL.deletingLastPathComponent(), withIntermediateDirectories: true)
            try data.write(to: saveURL, options: .atomic)
        } catch {
            print("Save error: \(error)")
        }
    }

    private func persistImage(data: Data?, existingPath: String?, prefix: String) async -> String? {
        guard let data, let image = UIImage(data: data), let jpeg = image.jpegData(compressionQuality: 0.85) else {
            return existingPath
        }

        let filename = "\(prefix)-\(UUID().uuidString).jpg"
        let url = Self.imagesURL.appendingPathComponent(filename)
        do {
            try FileManager.default.createDirectory(at: Self.imagesURL, withIntermediateDirectories: true)
            try jpeg.write(to: url, options: .atomic)
            if let existingPath {
                deleteImageIfNeeded(path: existingPath)
            }
            return url.path
        } catch {
            print("Image save error: \(error)")
            return existingPath
        }
    }

    private func deleteImageIfNeeded(path: String?) {
        guard let path else { return }
        try? FileManager.default.removeItem(atPath: path)
    }

    private static var dataURL: URL {
        let root = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        return root.appendingPathComponent("NyanGohan/store.json")
    }

    private static var imagesURL: URL {
        dataURL.deletingLastPathComponent().appendingPathComponent("Images")
    }

    private static func loadSnapshot(from url: URL) -> AppSnapshot? {
        guard let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder.appDecoder().decode(AppSnapshot.self, from: data)
    }
}

private extension JSONEncoder {
    func encoded<T: Encodable>(_ value: T) throws -> Data {
        outputFormatting = [.prettyPrinted, .sortedKeys]
        dateEncodingStrategy = .iso8601
        return try encode(value)
    }
}

private extension JSONDecoder {
    static func appDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}

private extension AppSnapshot {
    static let sample = AppSnapshot(
        cats: [
            CatProfile(
                name: "つむぎ",
                birthday: Calendar.current.date(from: DateComponents(year: 2021, month: 3, day: 15)) ?? .now,
                weight: 4.2,
                isNeutered: true,
                imagePath: nil,
                memo: "甘えん坊で食いしん坊です。",
                createdAt: .now,
                updatedAt: .now
            ),
            CatProfile(
                name: "みかん",
                birthday: Calendar.current.date(from: DateComponents(year: 2025, month: 1, day: 2)) ?? .now,
                weight: 3.8,
                isNeutered: true,
                imagePath: nil,
                memo: "食べるペースがゆっくり。",
                createdAt: .now,
                updatedAt: .now
            )
        ],
        foods: [
            FoodItem(name: "モグニャンキャットフード", calorieValue: 370, calorieUnit: .per100g, imagePath: nil, memo: "メインで与えているドライフード。", createdAt: .now, updatedAt: .now),
            FoodItem(name: "ニュートロ ナチュラルチョイス", calorieValue: 375, calorieUnit: .per100g, imagePath: nil, memo: "", createdAt: .now, updatedAt: .now),
            FoodItem(name: "シーバ デュオ 香りのまぐろ味", calorieValue: 85, calorieUnit: .per100g, imagePath: nil, memo: "", createdAt: .now, updatedAt: .now),
            FoodItem(name: "ウェルネス チキン&サーモン", calorieValue: 112, calorieUnit: .per100g, imagePath: nil, memo: "", createdAt: .now, updatedAt: .now)
        ],
        histories: [],
        premiumUnlocked: false
    )
}

import Foundation
import SwiftUI

enum CalorieUnit: String, CaseIterable, Codable, Identifiable {
    case per100g = "kcal / 100g"
    case perGram = "kcal / g"
    case perKilogram = "kcal / kg"

    var id: String { rawValue }

    func kcalPerGram(for value: Double) -> Double {
        switch self {
        case .per100g:
            return value / 100
        case .perGram:
            return value
        case .perKilogram:
            return value / 1000
        }
    }
}

struct CatProfile: Identifiable, Codable, Equatable, Hashable {
    var id = UUID()
    var name: String
    var birthday: Date
    var weight: Double
    var isNeutered: Bool
    var imagePath: String?
    var memo: String
    var createdAt: Date
    var updatedAt: Date

    var ageComponents: DateComponents {
        Calendar.current.dateComponents([.year, .month], from: birthday, to: .now)
    }

    var ageInMonths: Int {
        let years = ageComponents.year ?? 0
        let months = ageComponents.month ?? 0
        return max(0, years * 12 + months)
    }

    var ageDescription: String {
        let years = ageInMonths / 12
        let months = ageInMonths % 12
        if years == 0 {
            return "\(months)ヶ月"
        }
        return months == 0 ? "\(years)歳" : "\(years)歳\(months)ヶ月"
    }

    var neuterDescription: String {
        isNeutered ? "避妊・去勢済み" : "未避妊・未去勢"
    }

    var coefficient: Double {
        switch ageInMonths {
        case ..<4:
            return 3.0
        case 4..<12:
            return 2.0
        case 120...:
            return isNeutered ? 1.1 : 1.2
        case 84...:
            return isNeutered ? 1.1 : 1.2
        default:
            return isNeutered ? 1.2 : 1.4
        }
    }
}

struct FoodItem: Identifiable, Codable, Equatable {
    var id = UUID()
    var name: String
    var calorieValue: Double
    var calorieUnit: CalorieUnit
    var imagePath: String?
    var memo: String
    var createdAt: Date
    var updatedAt: Date

    var kcalPerGram: Double {
        calorieUnit.kcalPerGram(for: calorieValue)
    }

    var calorieLabel: String {
        let number = calorieValue == floor(calorieValue) ? String(Int(calorieValue)) : String(format: "%.1f", calorieValue)
        return "\(number) \(calorieUnit.rawValue)"
    }
}

struct CalculationHistory: Identifiable, Codable, Equatable {
    var id = UUID()
    var catId: UUID
    var foodId: UUID
    var requiredCalories: Int
    var feedingAmount: Int
    var calculatedAt: Date
}

struct CalculationResult: Identifiable, Equatable {
    let id = UUID()
    let cat: CatProfile
    let food: FoodItem
    let rer: Double
    let requiredCalories: Int
    let feedingAmount: Int
}

enum PremiumSheetReason: String, Identifiable {
    case catLimit
    case foodLimit
    case historyLimit
    case manual

    var id: String { rawValue }

    var title: String {
        switch self {
        case .catLimit:
            return "猫の登録数"
        case .foodLimit:
            return "ご飯の登録数"
        case .historyLimit:
            return "履歴の保存件数"
        case .manual:
            return "プレミアム"
        }
    }
}

struct AppSnapshot: Codable {
    var cats: [CatProfile]
    var foods: [FoodItem]
    var histories: [CalculationHistory]
    var premiumUnlocked: Bool
}

enum FeedCalculator {
    static func calculate(cat: CatProfile, food: FoodItem) -> CalculationResult? {
        guard cat.weight > 0, food.kcalPerGram > 0 else { return nil }
        let rer = (cat.weight * 30) + 70
        let der = rer * cat.coefficient
        let grams = der / food.kcalPerGram
        return CalculationResult(
            cat: cat,
            food: food,
            rer: rer,
            requiredCalories: Int(der.rounded()),
            feedingAmount: Int(grams.rounded())
        )
    }
}

enum AppTheme {
    static let blush = Color(hex: "F56F8E")
    static let blushDark = Color(hex: "E64C73")
    static let cream = Color(hex: "FFF9F6")
    static let sand = Color(hex: "F6E8DF")
    static let text = Color(hex: "402C2B")
    static let subtext = Color(hex: "8A6F70")
    static let line = Color(hex: "EAD8D3")
    static let success = Color(hex: "5F9D76")
}

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        self.init(
            red: Double((rgb >> 16) & 0xFF) / 255,
            green: Double((rgb >> 8) & 0xFF) / 255,
            blue: Double(rgb & 0xFF) / 255
        )
    }
}

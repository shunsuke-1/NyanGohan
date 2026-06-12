import SwiftUI

struct CalculatorView: View {
    @EnvironmentObject private var store: AppStore

    var body: some View {
        AppBackground {
            ScrollView {
                VStack(spacing: 20) {
                    ScreenSection(title: "猫を選択してください") {
                        if let selectedCat = store.selectedCat {
                            Menu {
                                ForEach(store.cats) { cat in
                                    Button(cat.name) { store.selectedCatID = cat.id }
                                }
                            } label: {
                                SelectionCard(
                                    title: selectedCat.name,
                                    subtitle: "\(selectedCat.ageDescription)  |  \(selectedCat.neuterDescription)",
                                    detail: "\(String(format: "%.1f", selectedCat.weight))kg",
                                    imagePath: selectedCat.imagePath,
                                    placeholder: "pawprint.fill"
                                )
                            }
                        } else {
                            EmptyStateView(icon: "pawprint", title: "猫を登録してください", description: "計算するには猫プロフィールが必要です。")
                        }
                    }

                    ScreenSection(title: "ご飯を選択してください") {
                        if let selectedFood = store.selectedFood {
                            Menu {
                                ForEach(store.foods) { food in
                                    Button(food.name) { store.selectedFoodID = food.id }
                                }
                            } label: {
                                SelectionCard(
                                    title: selectedFood.name,
                                    subtitle: selectedFood.calorieLabel,
                                    detail: "",
                                    imagePath: selectedFood.imagePath,
                                    placeholder: "takeoutbag.and.cup.and.straw.fill",
                                    rounded: false
                                )
                            }
                        } else {
                            EmptyStateView(icon: "takeoutbag.and.cup.and.straw", title: "ご飯を登録してください", description: "フード情報を登録すると適正量を計算できます。")
                        }
                    }

                    Button {
                        store.calculateCurrentSelection()
                    } label: {
                        Label("計算する", systemImage: "plus.forwardslash.minus")
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .disabled(store.selectedCat == nil || store.selectedFood == nil)

                    if let result = store.latestResult {
                        ScreenSection(title: "計算結果") {
                            CardContainer {
                                HStack(spacing: 12) {
                                    MetricView(title: "必要カロリー", value: "\(result.requiredCalories)", unit: "kcal / 日")
                                    MetricView(title: "適正量", value: "\(result.feedingAmount)", unit: "g / 日")
                                }
                                Button("履歴に保存") {
                                    store.saveLatestResultToHistory()
                                }
                                .buttonStyle(SecondaryOutlineButtonStyle())
                            }
                        }
                    }
                }
                .padding(20)
            }
        }
        .navigationTitle("計算")
    }
}

private struct SelectionCard: View {
    let title: String
    let subtitle: String
    let detail: String
    let imagePath: String?
    let placeholder: String
    var rounded: Bool = true

    var body: some View {
        CardContainer {
            HStack(spacing: 14) {
                StoredImageView(path: imagePath, size: 64, placeholder: placeholder, rounded: rounded)
                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(AppTheme.text)
                    Text(subtitle)
                        .font(.footnote)
                        .foregroundStyle(AppTheme.subtext)
                    if !detail.isEmpty {
                        Text(detail)
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(AppTheme.text)
                    }
                }
                Spacer()
                Image(systemName: "chevron.up.chevron.down")
                    .font(.footnote.weight(.bold))
                    .foregroundStyle(AppTheme.blush)
            }
        }
    }
}

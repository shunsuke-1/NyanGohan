import SwiftUI

struct HistoryView: View {
    @EnvironmentObject private var store: AppStore
    @State private var selectedHistory: CalculationHistory?

    var body: some View {
        AppBackground {
            ScrollView {
                VStack(spacing: 16) {
                    if store.histories.isEmpty {
                        EmptyStateView(icon: "clock.arrow.circlepath", title: "履歴はまだありません", description: "計算結果を保存するとここに表示されます。")
                    } else {
                        ForEach(store.histories) { history in
                            Button {
                                selectedHistory = history
                            } label: {
                                HistoryRow(history: history)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(20)
            }
        }
        .navigationTitle("履歴")
        .sheet(item: $selectedHistory) { history in
            HistoryDetailView(history: history)
                .environmentObject(store)
        }
    }
}

private struct HistoryRow: View {
    @EnvironmentObject private var store: AppStore
    let history: CalculationHistory

    var body: some View {
        let details = store.historyDetails(for: history)
        CardContainer {
            HStack(alignment: .top, spacing: 12) {
                StoredImageView(path: details.0?.imagePath, size: 54, placeholder: "pawprint.fill")
                VStack(alignment: .leading, spacing: 6) {
                    Text(history.calculatedAt.formatted(date: .numeric, time: .shortened))
                        .font(.caption)
                        .foregroundStyle(AppTheme.subtext)
                    Text(details.0?.name ?? "削除済みの猫")
                        .font(.headline)
                    Text(details.1?.name ?? "削除済みのご飯")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.subtext)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 8) {
                    Text("\(history.requiredCalories) kcal/日")
                        .font(.headline)
                        .foregroundStyle(AppTheme.blush)
                    Text("\(history.feedingAmount) g/日")
                        .font(.headline)
                        .foregroundStyle(AppTheme.blushDark)
                }
            }
        }
    }
}

struct HistoryDetailView: View {
    @EnvironmentObject private var store: AppStore
    let history: CalculationHistory

    var body: some View {
        NavigationStack {
            AppBackground {
                ScrollView {
                    let details = store.historyDetails(for: history)
                    VStack(spacing: 18) {
                        if let cat = details.0 {
                            CardContainer {
                                HStack(spacing: 14) {
                                    StoredImageView(path: cat.imagePath, size: 72, placeholder: "pawprint.fill")
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text(cat.name)
                                            .font(.headline)
                                        Text(cat.ageDescription)
                                            .font(.subheadline)
                                        Text("\(cat.weight, specifier: "%.1f")kg")
                                            .font(.footnote)
                                            .foregroundStyle(AppTheme.subtext)
                                    }
                                    Spacer()
                                }
                            }
                        }

                        if let food = details.1 {
                            CardContainer {
                                HStack(spacing: 14) {
                                    StoredImageView(path: food.imagePath, size: 72, placeholder: "takeoutbag.and.cup.and.straw.fill", rounded: false)
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text(food.name)
                                            .font(.headline)
                                        Text(food.calorieLabel)
                                            .font(.subheadline)
                                    }
                                    Spacer()
                                }
                            }
                        }

                        CardContainer {
                            MetricView(title: "必要カロリー", value: "\(history.requiredCalories)", unit: "kcal / 日")
                            MetricView(title: "適正量", value: "\(history.feedingAmount)", unit: "g / 日")
                        }

                        CardContainer {
                            Text("計算日時")
                                .font(.headline)
                            Text(history.calculatedAt.formatted(date: .complete, time: .shortened))
                                .font(.subheadline)
                                .foregroundStyle(AppTheme.subtext)
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("計算結果")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

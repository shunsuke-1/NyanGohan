import PhotosUI
import SwiftUI

struct FoodsView: View {
    @EnvironmentObject private var store: AppStore
    @State private var editingFood: FoodItem?
    @State private var showingNewFood = false

    var body: some View {
        AppBackground {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(store.foods) { food in
                        Button {
                            editingFood = food
                        } label: {
                            FoodRow(food: food)
                        }
                        .buttonStyle(.plain)
                    }

                    Button {
                        if store.foods.count >= store.foodLimit {
                            store.activePremiumSheet = .foodLimit
                        } else {
                            showingNewFood = true
                        }
                    } label: {
                        CardContainer {
                            VStack(spacing: 10) {
                                Image(systemName: "plus")
                                    .font(.title3.weight(.bold))
                                    .foregroundStyle(AppTheme.blush)
                                Text("ご飯を追加")
                                    .font(.headline)
                                    .foregroundStyle(AppTheme.blush)
                                Text(store.premiumUnlocked ? "登録数は無制限です" : "無料版は 5 件まで")
                                    .font(.footnote)
                                    .foregroundStyle(AppTheme.subtext)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                        }
                    }
                    .buttonStyle(.plain)
                }
                .padding(20)
            }
        }
        .navigationTitle("ご飯")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    if store.foods.count >= store.foodLimit {
                        store.activePremiumSheet = .foodLimit
                    } else {
                        showingNewFood = true
                    }
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(AppTheme.blush)
                }
            }
        }
        .sheet(item: $editingFood) { food in
            FoodEditorView(editing: food)
                .environmentObject(store)
        }
        .sheet(isPresented: $showingNewFood) {
            FoodEditorView(editing: nil)
                .environmentObject(store)
        }
    }
}

private struct FoodRow: View {
    let food: FoodItem

    var body: some View {
        CardContainer {
            HStack(spacing: 14) {
                StoredImageView(path: food.imagePath, size: 66, placeholder: "takeoutbag.and.cup.and.straw.fill", rounded: false)
                VStack(alignment: .leading, spacing: 6) {
                    Text(food.name)
                        .font(.headline)
                        .multilineTextAlignment(.leading)
                    Text(food.calorieLabel)
                        .font(.subheadline.weight(.medium))
                    if !food.memo.isEmpty {
                        Text(food.memo)
                            .font(.footnote)
                            .foregroundStyle(AppTheme.subtext)
                            .lineLimit(2)
                    }
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(AppTheme.subtext)
            }
        }
    }
}

struct FoodEditorView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss
    let editing: FoodItem?

    @State private var draft: FoodDraft
    @State private var photoItem: PhotosPickerItem?
    @State private var existingImagePath: String?
    @State private var showingDeleteAlert = false

    init(editing: FoodItem?) {
        self.editing = editing
        _draft = State(initialValue: FoodDraft(food: editing))
        _existingImagePath = State(initialValue: editing?.imagePath)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("基本情報") {
                    TextField("商品名", text: $draft.name)
                    TextField("カロリー数値", text: $draft.calorieText)
                        .keyboardType(.decimalPad)
                }

                Section("単位") {
                    Picker("単位", selection: $draft.calorieUnit) {
                        ForEach(CalorieUnit.allCases) { unit in
                            Text(unit.rawValue).tag(unit)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("写真") {
                    PhotoPickerField(item: $photoItem, imageData: draft.imageData, existingPath: existingImagePath, placeholder: "takeoutbag.and.cup.and.straw.fill", rounded: false)
                        .listRowBackground(Color.clear)
                }

                Section("メモ") {
                    TextField("メモを入力", text: $draft.memo, axis: .vertical)
                        .lineLimit(4, reservesSpace: true)
                }

                if editing != nil {
                    Section {
                        Button("このご飯を削除する", role: .destructive) {
                            showingDeleteAlert = true
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(AppTheme.cream)
            .navigationTitle(editing == nil ? "ご飯の登録" : "ご飯の編集")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("キャンセル") { dismiss() }
                        .foregroundStyle(AppTheme.blush)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("保存") {
                        Task {
                            await store.saveFood(draft, editing: editing)
                            dismiss()
                        }
                    }
                    .foregroundStyle(AppTheme.blush)
                    .disabled(draft.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || Double(draft.calorieText) == nil)
                }
            }
            .alert("このご飯を削除しますか？", isPresented: $showingDeleteAlert) {
                Button("削除", role: .destructive) {
                    if let editing {
                        store.deleteFood(editing)
                        dismiss()
                    }
                }
                Button("キャンセル", role: .cancel) {}
            }
            .task(id: photoItem) {
                guard let photoItem, let data = try? await photoItem.loadTransferable(type: Data.self) else { return }
                draft.imageData = data
                existingImagePath = nil
            }
        }
    }
}

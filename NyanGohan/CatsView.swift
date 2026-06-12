import PhotosUI
import SwiftUI

struct CatsView: View {
    @EnvironmentObject private var store: AppStore
    @State private var editorTarget: CatProfile?
    @State private var showingNewCat = false

    var body: some View {
        AppBackground {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(store.cats) { cat in
                        NavigationLink(value: cat) {
                            CatRow(cat: cat)
                        }
                        .buttonStyle(.plain)
                    }

                    Button {
                        if store.cats.count >= store.catLimit {
                            store.activePremiumSheet = .catLimit
                        } else {
                            showingNewCat = true
                        }
                    } label: {
                        CardContainer {
                            VStack(spacing: 10) {
                                Image(systemName: "plus")
                                    .font(.title3.weight(.bold))
                                    .foregroundStyle(AppTheme.blush)
                                Text("猫を追加")
                                    .font(.headline)
                                    .foregroundStyle(AppTheme.blush)
                                Text(store.premiumUnlocked ? "登録数は無制限です" : "無料版は 2 匹まで")
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
        .navigationTitle("猫")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    if store.cats.count >= store.catLimit {
                        store.activePremiumSheet = .catLimit
                    } else {
                        showingNewCat = true
                    }
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(AppTheme.blush)
                }
            }
        }
        .navigationDestination(for: CatProfile.self) { cat in
            CatDetailView(cat: cat)
        }
        .sheet(item: $editorTarget) { cat in
            CatEditorView(editing: cat)
                .environmentObject(store)
        }
        .sheet(isPresented: $showingNewCat) {
            CatEditorView(editing: nil)
                .environmentObject(store)
        }
        .safeAreaInset(edge: .bottom) {
            Color.clear.frame(height: 8)
        }
    }
}

private struct CatRow: View {
    let cat: CatProfile

    var body: some View {
        CardContainer {
            HStack(spacing: 14) {
                StoredImageView(path: cat.imagePath, size: 72, placeholder: "pawprint.fill")
                VStack(alignment: .leading, spacing: 6) {
                    Text(cat.name)
                        .font(.headline)
                    Text("\(cat.ageDescription)  (\(cat.neuterDescription))")
                        .font(.footnote)
                        .foregroundStyle(AppTheme.subtext)
                    Text("\(cat.weight, specifier: "%.1f") kg")
                        .font(.subheadline.weight(.medium))
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(AppTheme.subtext)
            }
        }
    }
}

struct CatDetailView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss
    let cat: CatProfile
    @State private var showingDeleteAlert = false
    @State private var editingTarget: CatProfile?

    private var currentCat: CatProfile? {
        store.cats.first(where: { $0.id == cat.id })
    }

    var body: some View {
        AppBackground {
            ScrollView {
                if let cat = currentCat {
                    VStack(spacing: 18) {
                        StoredImageView(path: cat.imagePath, size: 140, placeholder: "pawprint.fill")
                            .padding(.top, 8)

                        VStack(spacing: 8) {
                            Text(cat.name)
                                .font(.system(size: 34, weight: .bold, design: .rounded))
                            Text(cat.ageDescription)
                                .font(.title3.weight(.medium))
                            Text(cat.neuterDescription)
                                .font(.subheadline)
                                .foregroundStyle(AppTheme.subtext)
                        }

                        CardContainer {
                            DetailRow(title: "誕生日", value: cat.birthday.formatted(date: .long, time: .omitted))
                            DetailRow(title: "年齢", value: cat.ageDescription)
                            DetailRow(title: "現在の体重", value: "\(String(format: "%.1f", cat.weight)) kg")
                            DetailRow(title: "避妊・去勢", value: cat.isNeutered ? "済み" : "未")
                            DetailRow(title: "メモ", value: cat.memo.isEmpty ? "未入力" : cat.memo)
                        }

                        Button("この猫を削除する", role: .destructive) {
                            showingDeleteAlert = true
                        }
                        .buttonStyle(SecondaryOutlineButtonStyle())
                    }
                    .padding(20)
                }
            }
        }
        .navigationTitle("猫の詳細")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("編集") {
                    editingTarget = currentCat
                }
                .foregroundStyle(AppTheme.blush)
            }
        }
        .alert("この猫を削除しますか？", isPresented: $showingDeleteAlert) {
            Button("削除", role: .destructive) {
                if let currentCat {
                    store.deleteCat(currentCat)
                    dismiss()
                }
            }
            Button("キャンセル", role: .cancel) {}
        }
        .sheet(item: $editingTarget) { cat in
            CatEditorView(editing: cat)
                .environmentObject(store)
        }
    }
}

private struct DetailRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack(alignment: .top) {
            Text(title)
                .foregroundStyle(AppTheme.subtext)
            Spacer()
            Text(value)
                .multilineTextAlignment(.trailing)
        }
        .font(.subheadline)
    }
}

struct CatEditorView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss
    let editing: CatProfile?

    @State private var draft: CatDraft
    @State private var photoItem: PhotosPickerItem?
    @State private var existingImagePath: String?

    init(editing: CatProfile?) {
        self.editing = editing
        _draft = State(initialValue: CatDraft(cat: editing))
        _existingImagePath = State(initialValue: editing?.imagePath)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    PhotoPickerField(item: $photoItem, imageData: draft.imageData, existingPath: existingImagePath, placeholder: "pawprint.fill", rounded: true)
                        .listRowBackground(Color.clear)
                }

                Section("基本情報") {
                    TextField("名前", text: $draft.name)
                    DatePicker("誕生日", selection: $draft.birthday, displayedComponents: .date)
                        .environment(\.locale, Locale(identifier: "ja_JP"))
                    TextField("現在の体重(kg)", text: $draft.weightText)
                        .keyboardType(.decimalPad)
                    Toggle("避妊・去勢済み", isOn: $draft.isNeutered)
                }

                Section("メモ") {
                    TextField("性格や特徴などを入力", text: $draft.memo, axis: .vertical)
                        .lineLimit(4, reservesSpace: true)
                }
            }
            .scrollContentBackground(.hidden)
            .background(AppTheme.cream)
            .navigationTitle(editing == nil ? "猫の登録" : "猫の編集")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("キャンセル") { dismiss() }
                        .foregroundStyle(AppTheme.blush)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("保存") {
                        Task {
                            await store.saveCat(draft, editing: editing)
                            dismiss()
                        }
                    }
                    .foregroundStyle(AppTheme.blush)
                    .disabled(draft.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || Double(draft.weightText) == nil)
                }
            }
            .task(id: photoItem) {
                guard let photoItem, let data = try? await photoItem.loadTransferable(type: Data.self) else { return }
                draft.imageData = data
                existingImagePath = nil
            }
        }
    }
}

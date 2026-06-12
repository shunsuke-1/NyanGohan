import PhotosUI
import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            NavigationStack { CalculatorView() }
                .tabItem {
                    Label("計算", systemImage: "plus.forwardslash.minus")
                }

            NavigationStack { CatsView() }
                .tabItem {
                    Label("猫", systemImage: "pawprint")
                }

            NavigationStack { FoodsView() }
                .tabItem {
                    Label("ご飯", systemImage: "takeoutbag.and.cup.and.straw")
                }

            NavigationStack { HistoryView() }
                .tabItem {
                    Label("履歴", systemImage: "clock")
                }

            NavigationStack { SettingsView() }
                .tabItem {
                    Label("設定", systemImage: "gearshape")
                }
        }
        .tint(AppTheme.blush)
    }
}

struct AppBackground<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color.white, AppTheme.cream], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            content
        }
        .foregroundStyle(AppTheme.text)
    }
}

struct ScreenSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(.headline)
                .foregroundStyle(AppTheme.text)
            content
        }
    }
}

struct CardContainer<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            content
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(AppTheme.line, lineWidth: 1)
        )
        .shadow(color: AppTheme.blush.opacity(0.08), radius: 16, y: 8)
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: [AppTheme.blush, AppTheme.blushDark],
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                in: RoundedRectangle(cornerRadius: 16, style: .continuous)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
    }
}

struct SecondaryOutlineButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(AppTheme.blush)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(.white, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(AppTheme.blush, lineWidth: 1.5)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
    }
}

struct StoredImageView: View {
    let path: String?
    var imageData: Data? = nil
    let size: CGFloat
    let placeholder: String
    var rounded: Bool = true

    var body: some View {
        if rounded {
            imageContent
                .frame(width: size, height: size)
                .clipShape(Circle())
                .overlay(Circle().stroke(AppTheme.line, lineWidth: 1))
        } else {
            imageContent
                .frame(width: size, height: size)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(AppTheme.line, lineWidth: 1))
        }
    }

    @ViewBuilder
    private var imageContent: some View {
        if let imageData, let uiImage = UIImage(data: imageData) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
        } else if let path, let uiImage = UIImage(contentsOfFile: path) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
        } else {
            LinearGradient(colors: [AppTheme.sand, Color.white], startPoint: .topLeading, endPoint: .bottomTrailing)
                .overlay(
                    Image(systemName: placeholder)
                        .font(.system(size: size * 0.34, weight: .medium))
                        .foregroundStyle(AppTheme.blush.opacity(0.8))
                )
        }
    }
}

struct MetricView: View {
    let title: String
    let value: String
    let unit: String

    var body: some View {
        VStack(spacing: 10) {
            Text(title)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(AppTheme.subtext)
            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text(value)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                Text(unit)
                    .font(.callout.weight(.medium))
                    .foregroundStyle(AppTheme.subtext)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .background(AppTheme.cream, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

struct EmptyStateView: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        CardContainer {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 28))
                    .foregroundStyle(AppTheme.blush)
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.subtext)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
        }
    }
}

struct PhotoPickerField: View {
    @Binding var item: PhotosPickerItem?
    let imageData: Data?
    let existingPath: String?
    let placeholder: String
    let rounded: Bool
    @State private var isPhotoPickerPresented = false

    var body: some View {
        VStack(spacing: 12) {
            StoredImageView(path: existingPath, imageData: imageData, size: 96, placeholder: placeholder, rounded: rounded)
            Button {
                isPhotoPickerPresented = true
            } label: {
                Text("写真を変更")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppTheme.blush)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 8)
                    .background(.white, in: Capsule())
                    .overlay(Capsule().stroke(AppTheme.blush, lineWidth: 1))
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity)
        .photosPicker(isPresented: $isPhotoPickerPresented, selection: $item, matching: .images)
    }
}

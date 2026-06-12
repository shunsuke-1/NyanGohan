import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var store: AppStore

    var body: some View {
        AppBackground {
            ScrollView {
                VStack(spacing: 18) {
                    CardContainer {
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "crown.fill")
                                .font(.title2)
                                .foregroundStyle(.orange)
                            VStack(alignment: .leading, spacing: 8) {
                                Text("プレミアム")
                                    .font(.title3.weight(.bold))
                                Text(store.premiumUnlocked ? "すべての機能が利用できます" : "猫・ご飯・履歴の登録数制限を解除します")
                                    .font(.subheadline)
                                    .foregroundStyle(AppTheme.subtext)
                            }
                        }

                        if store.premiumUnlocked {
                            Text("プレミアム利用中")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .fill(AppTheme.success)
                                )
                        } else {
                            Button("プレミアムを購入する（買い切り ¥500）") {
                                store.showPremium()
                            }
                            .buttonStyle(PrimaryButtonStyle())
                        }
                    }

                    CardContainer {
                        NavigationLink {
                            CautionView()
                        } label: {
                            SettingsRow(title: "利用上の注意")
                        }
                        .buttonStyle(.plain)

                        NavigationLink {
                            FAQView()
                        } label: {
                            SettingsRow(title: "よくある質問")
                        }
                        .buttonStyle(.plain)

                        NavigationLink {
                            PrivacyPolicyView()
                        } label: {
                            SettingsRow(title: "プライバシーポリシー")
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(20)
            }
        }
        .navigationTitle("設定")
    }
}

private struct SettingsRow: View {
    let title: String

    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(AppTheme.text)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.footnote.weight(.bold))
                .foregroundStyle(AppTheme.subtext)
        }
        .padding(.vertical, 6)
    }
}

struct CautionView: View {
    var body: some View {
        AppBackground {
            ScrollView {
                VStack(spacing: 18) {
                    CardContainer {
                        VStack(spacing: 16) {
                            HStack(spacing: 20) {
                                PetBadge(icon: "cat.fill", tint: Color(hex: "D6925A"))
                                PetBadge(icon: "pawprint.fill", tint: Color(hex: "8F8A95"))
                            }
                            Text("本アプリは、愛猫の健康管理のサポートを目的としたものであり、獣医師の診断や治療に代わるものではありません。")
                                .font(.body)
                                .multilineTextAlignment(.center)
                                .lineSpacing(6)
                        }
                    }

                    TitledBulletCard(
                        title: "ご利用にあたって",
                        items: [
                            "本アプリの計算結果は、一般的な栄養学にもとづく目安です。",
                            "猫の個体差、健康状態、運動量、環境によって適正量は変わることがあります。",
                            "体調の変化や体重の増減が見られる場合は、獣医師にご相談ください。",
                            "子猫、妊娠・授乳期、持病のある猫では、特に獣医師の指導を受けてください。",
                            "フードの切り替えは、少しずつ行ってください。"
                        ]
                    )

                    TitledBulletCard(
                        title: "免責事項",
                        items: [
                            "本アプリの利用によって生じたいかなる損害についても、開発者は責任を負いません。"
                        ]
                    )
                }
                .padding(20)
            }
        }
        .navigationTitle("利用上の注意")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct FAQView: View {
    @State private var expandedIDs: Set<Int> = [0]

    private let items: [FAQItem] = [
        .init(question: "どのフードを選べばいいですか？", answer: "アプリで計算するフードは、愛猫が普段食べているフードを選択してください。フードの切り替え時は、新しいフードで計算し直してください。"),
        .init(question: "ウェットフードも計算できますか？", answer: "はい、できます。パッケージに記載されているカロリーを入力してください。水分量が多いウェットフードは、ドライフードより多くの量が必要になります。"),
        .init(question: "おやつは計算に含まれますか？", answer: "いいえ、含まれません。おやつは1日の必要カロリーの10％以内に抑えることが推奨されています。"),
        .init(question: "体重が変わったらどうすればいいですか？", answer: "猫のプロフィールで体重を更新し、計算をやり直してください。定期的な体重測定をおすすめします。"),
        .init(question: "子猫やシニア猫でも使えますか？", answer: "はい、使えます。年齢に応じた係数を自動で適用して計算します。特別なケアが必要な場合は、獣医師にご相談ください。")
    ]

    var body: some View {
        AppBackground {
            ScrollView {
                VStack(spacing: 14) {
                    ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                        CardContainer {
                            Button {
                                if expandedIDs.contains(index) {
                                    expandedIDs.remove(index)
                                } else {
                                    expandedIDs.insert(index)
                                }
                            } label: {
                                HStack(alignment: .top, spacing: 12) {
                                    Text("Q.")
                                        .font(.headline.weight(.bold))
                                        .foregroundStyle(AppTheme.blush)
                                    Text(item.question)
                                        .font(.headline)
                                        .multilineTextAlignment(.leading)
                                    Spacer()
                                    Image(systemName: expandedIDs.contains(index) ? "chevron.up" : "chevron.down")
                                        .font(.footnote.weight(.bold))
                                        .foregroundStyle(AppTheme.subtext)
                                }
                            }
                            .buttonStyle(.plain)

                            if expandedIDs.contains(index) {
                                Divider()
                                    .overlay(AppTheme.line)
                                HStack(alignment: .top, spacing: 12) {
                                    Text("A.")
                                        .font(.headline.weight(.bold))
                                        .foregroundStyle(AppTheme.text)
                                    Text(item.answer)
                                        .font(.body)
                                        .foregroundStyle(AppTheme.text)
                                        .lineSpacing(6)
                                }
                            }
                        }
                    }
                }
                .padding(20)
            }
        }
        .navigationTitle("よくある質問")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ContactView: View {
    var body: some View {
        AppBackground {
            ScrollView {
                VStack(spacing: 18) {
                    CardContainer {
                        Text("ご意見・ご要望・不具合のご報告など、お気軽にお問い合わせください。")
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                    }

                    CardContainer {
                        Link(destination: URL(string: "mailto:support@nyangohan.app")!) {
                            HStack(spacing: 16) {
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(AppTheme.cream)
                                    .frame(width: 60, height: 60)
                                    .overlay(
                                        Image(systemName: "envelope")
                                            .font(.title2)
                                            .foregroundStyle(AppTheme.blush)
                                    )

                                VStack(alignment: .leading, spacing: 6) {
                                    Text("メールで問い合わせる")
                                        .font(.headline)
                                        .foregroundStyle(AppTheme.text)
                                    Text("support@nyangohan.app")
                                        .font(.subheadline)
                                        .foregroundStyle(AppTheme.subtext)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(AppTheme.subtext)
                            }
                        }
                        .buttonStyle(.plain)
                    }

                    TitledActionCard(
                        title: "お問い合わせの前に",
                        description: "よくある質問もぜひご確認ください。解決方法が見つかる場合があります。",
                        buttonTitle: "よくある質問を見る",
                        destination: FAQView()
                    )

                    TitledBulletCard(
                        title: "返信について",
                        items: [
                            "通常、3営業日以内にご返信いたします。",
                            "土日祝日を挟む場合は、返信が遅れることがあります。"
                        ]
                    )

                    HStack {
                        Spacer()
                        VStack(spacing: 8) {
                            Image(systemName: "heart.fill")
                                .foregroundStyle(AppTheme.blush)
                            PetBadge(icon: "cat.fill", tint: Color(hex: "D9B39A"))
                        }
                        Spacer()
                    }
                }
                .padding(20)
            }
        }
        .navigationTitle("お問い合わせ")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct PrivacyPolicyView: View {
    var body: some View {
        AppBackground {
            ScrollView {
                VStack(spacing: 14) {
                    PrivacySection(
                        number: "1.",
                        title: "収集する情報",
                        content: "本アプリでは、以下の情報を端末内に保存します。",
                        bullets: [
                            "猫のプロフィール情報（名前、誕生日、体重など）",
                            "フードの情報（商品名、カロリーなど）",
                            "計算履歴"
                        ],
                        footer: "これらの情報は、お客様の端末内のみに保存され、外部に送信されることはありません。"
                    )

                    PrivacySection(
                        number: "2.",
                        title: "情報の利用目的",
                        content: "保存した情報は、以下の目的で利用します。",
                        bullets: [
                            "適正給与量の計算",
                            "アプリの機能提供と改善"
                        ]
                    )

                    PrivacySection(
                        number: "3.",
                        title: "情報の管理",
                        content: "お客様は、アプリ内の設定や各データの編集・削除機能を通じて、ご自身の情報を管理できます。"
                    )

                    PrivacySection(
                        number: "4.",
                        title: "第三者提供",
                        content: "本アプリは、お客様の同意なく第三者に情報を提供することはありません。"
                    )

                    PrivacySection(
                        number: "5.",
                        title: "プライバシーポリシーの変更",
                        content: "本ポリシーの内容は、必要に応じて変更されることがあります。変更後は、本アプリ内でお知らせします。"
                    )

                    HStack {
                        Spacer()
                        Text("制定日：2024年5月20日")
                            .font(.footnote)
                            .foregroundStyle(AppTheme.subtext)
                    }
                    .padding(.top, 6)
                }
                .padding(20)
            }
        }
        .navigationTitle("プライバシーポリシー")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct PremiumView: View {
    @EnvironmentObject private var store: AppStore
    @EnvironmentObject private var purchaseManager: PurchaseManager
    @Environment(\.dismiss) private var dismiss
    let reason: PremiumSheetReason

    var body: some View {
        NavigationStack {
            AppBackground {
                VStack(spacing: 20) {
                    Spacer(minLength: 12)

                    Image(systemName: "crown.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(.orange)

                    VStack(spacing: 8) {
                        Text("プレミアムにアップグレード")
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                        Text(reason == .manual ? "すべての機能を制限なく利用できます" : "\(reason.title) の上限に達しました")
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.subtext)
                    }

                    CardContainer {
                        PremiumFeatureRow(title: "猫の登録数", value: "無制限")
                        PremiumFeatureRow(title: "ご飯の登録数", value: "無制限")
                        PremiumFeatureRow(title: "履歴の保存件数", value: "無制限")
                    }

                    Button {
                        Task {
                            await purchaseManager.purchase(using: store)
                        }
                    } label: {
                        VStack(spacing: 4) {
                            Text("買い切り")
                                .font(.subheadline.weight(.medium))
                            Text("¥500")
                                .font(.system(size: 34, weight: .bold, design: .rounded))
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle())

                    Button {
                        Task {
                            await purchaseManager.restorePurchases(using: store)
                        }
                    } label: {
                        Text("購入を復元する")
                    }
                    .buttonStyle(SecondaryOutlineButtonStyle())

                    if let purchaseMessage = purchaseManager.purchaseMessage {
                        Text(purchaseMessage)
                            .font(.footnote)
                            .foregroundStyle(AppTheme.subtext)
                            .multilineTextAlignment(.center)
                    }
                    Spacer()
                }
                .padding(20)
            }
            .navigationTitle("プレミアム")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("閉じる") { dismiss() }
                        .foregroundStyle(AppTheme.blush)
                }
            }
        }
    }
}

private struct PremiumFeatureRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(AppTheme.success)
            Text(title)
            Spacer()
            Text(value)
                .foregroundStyle(AppTheme.subtext)
        }
        .font(.subheadline)
    }
}

private struct PetBadge: View {
    let icon: String
    let tint: Color

    var body: some View {
        Circle()
            .fill(tint.opacity(0.18))
            .frame(width: 88, height: 88)
            .overlay(
                Image(systemName: icon)
                    .font(.system(size: 34))
                    .foregroundStyle(tint)
            )
    }
}

private struct TitledBulletCard: View {
    let title: String
    let items: [String]

    var body: some View {
        CardContainer {
            Text(title)
                .font(.headline)
                .foregroundStyle(AppTheme.blush)

            VStack(alignment: .leading, spacing: 10) {
                ForEach(items, id: \.self) { item in
                    HStack(alignment: .top, spacing: 8) {
                        Text("•")
                        Text(item)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.text)
                }
            }
        }
    }
}

private struct TitledActionCard<Destination: View>: View {
    let title: String
    let description: String
    let buttonTitle: String
    let destination: Destination

    var body: some View {
        CardContainer {
            Text(title)
                .font(.headline)

            Text(description)
                .font(.subheadline)
                .foregroundStyle(AppTheme.text)
                .lineSpacing(5)

            NavigationLink {
                destination
            } label: {
                HStack {
                    Text(buttonTitle)
                        .font(.headline)
                        .foregroundStyle(AppTheme.text)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(AppTheme.subtext)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 18)
                .background(AppTheme.cream, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .buttonStyle(.plain)
        }
    }
}

private struct PrivacySection: View {
    let number: String
    let title: String
    let content: String
    var bullets: [String] = []
    var footer: String? = nil

    var body: some View {
        CardContainer {
            HStack(spacing: 4) {
                Text(number)
                Text(title)
            }
            .font(.headline)
            .foregroundStyle(AppTheme.blush)

            Text(content)
                .font(.subheadline)
                .lineSpacing(5)

            if !bullets.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(bullets, id: \.self) { bullet in
                        HStack(alignment: .top, spacing: 8) {
                            Text("•")
                            Text(bullet)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .font(.subheadline)
                    }
                }
            }

            if let footer {
                Text(footer)
                    .font(.subheadline)
                    .lineSpacing(5)
            }
        }
    }
}

private struct FAQItem {
    let question: String
    let answer: String
}

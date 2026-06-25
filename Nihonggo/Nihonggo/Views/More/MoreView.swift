import SwiftUI

struct MoreView: View {
    @ObservedObject var progressService: ProgressService
    @EnvironmentObject private var languageSettings: LanguageSettings

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    NavigationLink {
                        AIAssistantView()
                    } label: {
                        MoreNavigationCard(
                            title: languageSettings.language.text(.aiTitle),
                            subtitle: languageSettings.language.text(.aiLanguageNote),
                            systemImage: "bubble.left.and.bubble.right.fill"
                        )
                    }
                    .buttonStyle(.plain)

                    NavigationLink {
                        ProfileView(progressService: progressService)
                    } label: {
                        MoreNavigationCard(
                            title: languageSettings.language.text(.profileTitle),
                            subtitle: languageSettings.language.text(.xpProgress),
                            systemImage: "person.crop.circle.fill"
                        )
                    }
                    .buttonStyle(.plain)

                    AppCard {
                        Text(languageSettings.language.text(.languageTitle))
                            .font(.title2)
                            .bold()
                        Text(languageSettings.language.text(.languageSubtitle))
                            .font(.body)

                        VStack(spacing: 10) {
                            ForEach(AppLanguage.allCases) { language in
                                Button {
                                    languageSettings.language = language
                                } label: {
                                    HStack {
                                        Text(label(for: language))
                                            .font(.headline)
                                            .bold()
                                        Spacer()
                                        if languageSettings.language == language {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundStyle(AppTheme.toriiRed)
                                        }
                                    }
                                    .padding()
                                    .foregroundStyle(AppTheme.sumiInk)
                                    .background(languageSettings.language == language ? AppTheme.sakuraBlush : AppTheme.washiWhite)
                                    .overlay {
                                        RoundedRectangle(cornerRadius: AppTheme.cardRadius)
                                            .stroke(AppTheme.sumiInk, lineWidth: AppTheme.borderWidth)
                                    }
                                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardRadius))
                                }
                                .buttonStyle(.plain)
                                .accessibilityLabel(label(for: language))
                            }
                        }
                    }

                    AppCard {
                        Label(languageSettings.language.text(.aiLanguageNote), systemImage: "bubble.left.and.bubble.right.fill")
                            .font(.headline)
                    }
                }
                .padding()
            }
            .navigationTitle(languageSettings.language.text(.moreTitle))
            .appScreenBackground()
        }
    }

    private func label(for language: AppLanguage) -> String {
        switch language {
        case .indonesia:
            return languageSettings.language.text(.languageIndonesia)
        case .chineseSimplified:
            return languageSettings.language.text(.languageChinese)
        case .english:
            return languageSettings.language.text(.languageEnglish)
        }
    }
}

private struct MoreNavigationCard: View {
    let title: String
    let subtitle: String
    let systemImage: String

    var body: some View {
        AppCard {
            HStack(spacing: 14) {
                Image(systemName: systemImage)
                    .font(.title2)
                    .foregroundStyle(AppTheme.toriiRed)
                    .frame(width: 34)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .bold()
                    Text(subtitle)
                        .font(.body)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.headline)
                    .foregroundStyle(AppTheme.sumiInk)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(title)
    }
}

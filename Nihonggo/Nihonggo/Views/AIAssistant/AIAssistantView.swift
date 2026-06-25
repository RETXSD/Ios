import SwiftUI

struct AIAssistantView: View {
    @StateObject private var viewModel = AIAssistantViewModel()
    @EnvironmentObject private var languageSettings: LanguageSettings

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.messages) { message in
                                ChatBubble(message: message, language: languageSettings.language)
                                    .id(message.id)
                            }
                            if let errorMessage = viewModel.errorMessage {
                                AppCard {
                                    Text(errorMessage)
                                        .font(.headline)
                                }
                            }
                        }
                        .padding()
                    }
                    .onChange(of: viewModel.messages.count) { _ in
                        if let last = viewModel.messages.last {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }

                HStack(spacing: 10) {
                    TextField(languageSettings.language.text(.aiPlaceholder), text: $viewModel.draft, axis: .vertical)
                        .lineLimit(1...4)
                        .padding(12)
                        .background(AppTheme.washiWhite)
                        .overlay {
                            RoundedRectangle(cornerRadius: AppTheme.cardRadius)
                                .stroke(AppTheme.sumiInk, lineWidth: AppTheme.borderWidth)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardRadius))

                    Button(action: {
                        Task { await viewModel.send(language: languageSettings.language) }
                    }) {
                        Label(languageSettings.language.text(.send), systemImage: "paperplane.fill")
                    }
                    .labelStyle(.iconOnly)
                    .frame(width: 44, height: 44)
                    .foregroundStyle(AppTheme.washiWhite)
                    .background(AppTheme.toriiRed)
                    .overlay {
                        Circle().stroke(AppTheme.sumiInk, lineWidth: AppTheme.borderWidth)
                    }
                    .clipShape(Circle())
                    .flatShadow()
                    .disabled(viewModel.isSending)
                }
                .padding()
                .background(AppTheme.tatamiCream)
            }
            .navigationTitle(languageSettings.language.text(.aiTitle))
            .appScreenBackground()
            .onAppear {
                viewModel.updateGreeting(language: languageSettings.language)
            }
            .onChange(of: languageSettings.language) { newLanguage in
                viewModel.updateGreeting(language: newLanguage)
            }
        }
    }
}

private struct ChatBubble: View {
    let message: ChatMessage
    let language: AppLanguage

    var body: some View {
        HStack {
            if message.role == .user {
                Spacer(minLength: 40)
            }

            Text(message.content)
                .font(.body)
                .padding()
                .foregroundStyle(AppTheme.sumiInk)
                .background(message.role == .user ? AppTheme.sakuraBlush : AppTheme.washiWhite)
                .overlay {
                    RoundedRectangle(cornerRadius: AppTheme.cardRadius)
                        .stroke(AppTheme.sumiInk, lineWidth: AppTheme.borderWidth)
                }
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardRadius))
                .flatShadow()

            if message.role != .user {
                Spacer(minLength: 40)
            }
        }
        .accessibilityLabel(message.role == .user ? language.text(.yourMessage) : language.text(.tutorMessage))
        .accessibilityValue(message.content)
    }
}

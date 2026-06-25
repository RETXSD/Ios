import SwiftUI

struct DictionaryView: View {
    @StateObject private var viewModel = DictionaryViewModel()
    @StateObject private var audioService = AudioService()
    @EnvironmentObject private var languageSettings: LanguageSettings

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.entries) { entry in
                    Button {
                        viewModel.select(entry)
                    } label: {
                        HStack(spacing: 12) {
                            Text(entry.character)
                                .font(.system(.title, design: .serif))
                                .bold()
                                .foregroundStyle(AppTheme.toriiRed)
                                .frame(width: 54)
                            VStack(alignment: .leading, spacing: 4) {
                                Text(entry.reading)
                                    .font(.headline)
                                    .foregroundStyle(AppTheme.sumiInk)
                                Text(entry.meaning)
                                    .font(.body)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            AppBadge(entry.jlpt, color: AppTheme.kinkakuGold)
                            AudioButton(text: entry.character, audioService: audioService)
                        }
                        .padding(.vertical, 6)
                    }
                    .listRowBackground(AppTheme.tatamiCream)
                    .buttonStyle(.plain)
                    .accessibilityLabel("\(entry.character), \(entry.reading), \(entry.meaning)")
                }
            }
            .scrollContentBackground(.hidden)
            .background(AppTheme.tatamiCream)
            .navigationTitle(languageSettings.language.text(.dictionaryTitle))
            .searchable(text: $viewModel.query, prompt: languageSettings.language.text(.dictionarySearchPrompt))
            .onSubmit(of: .search) {
                Task { await viewModel.search() }
            }
            .task {
                await viewModel.load()
            }
            .sheet(item: $viewModel.selectedEntry) { entry in
                DictionaryDetailView(entry: entry, audioService: audioService, language: languageSettings.language)
            }
        }
    }
}

private struct DictionaryDetailView: View {
    let entry: DictionaryEntry
    @ObservedObject var audioService: AudioService
    let language: AppLanguage

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    AppCard {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 10) {
                                Text(entry.character)
                                    .font(.system(.largeTitle, design: .serif))
                                    .bold()
                                    .foregroundStyle(AppTheme.toriiRed)
                                Text(entry.reading)
                                    .font(.title3)
                                    .bold()
                                Text(entry.meaning)
                                AppBadge(entry.jlpt, color: AppTheme.kinkakuGold)
                            }
                            Spacer()
                            AudioButton(text: entry.character, audioService: audioService)
                        }
                    }

                    ForEach(entry.examples) { example in
                        AppCard {
                            Text(example.jp)
                                .font(.title3)
                                .bold()
                            Text(example.reading)
                                .font(.headline)
                            Text(example.en)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle(language.text(.detailTitle))
            .appScreenBackground()
        }
    }
}

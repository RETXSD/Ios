import SwiftUI

struct OnboardingView: View {
    let onStart: () -> Void
    @EnvironmentObject private var languageSettings: LanguageSettings

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                AppCard {
                    Text(languageSettings.language.text(.onboardingHeadline))
                        .font(.title2)
                        .bold()
                    Text(languageSettings.language.text(.onboardingBody))
                        .font(.body)
                    AppBadge(languageSettings.language.text(.n5Unlocked), color: AppTheme.sakuraBlush, systemImage: "lock.open.fill")
                }

                AppCard {
                    Label(languageSettings.language.text(.structuredLessons), systemImage: "rectangle.stack.fill")
                    Label(languageSettings.language.text(.deviceAudio), systemImage: "speaker.wave.2.fill")
                    Label(languageSettings.language.text(.onDeviceScan), systemImage: "camera.viewfinder")
                }

                AppButton(languageSettings.language.text(.startLearning), systemImage: "arrow.right.circle.fill", action: onStart)
            }
            .padding()
        }
        .appScreenBackground()
        .navigationTitle("KanaLearn")
    }
}

import SwiftUI

struct CoachPreviewCard: View {
    let cameraStatus: PermissionStatus

    var body: some View {
        FitnessCard {
            VStack(alignment: .leading, spacing: 14) {
                Label("Form Coach", systemImage: "camera.viewfinder")
                    .font(.headline)
                    .foregroundStyle(FitnessTheme.secondary)

                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.black)
                        .aspectRatio(4 / 5, contentMode: .fit)

                    VStack(spacing: 12) {
                        Image(systemName: "figure.strengthtraining.traditional")
                            .font(.largeTitle)
                            .foregroundStyle(FitnessTheme.gold)
                            .accessibilityHidden(true)

                        Text("Camera preview will appear here after permission is configured.")
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                }

                LabeledContent("Camera", value: cameraStatus.rawValue)
                    .foregroundStyle(.white, FitnessTheme.secondary)
            }
        }
    }
}

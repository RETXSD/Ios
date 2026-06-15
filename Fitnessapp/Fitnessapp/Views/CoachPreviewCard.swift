import AVFoundation
import SwiftUI

struct CoachPreviewCard: View {
    let cameraStatus: PermissionStatus
    let session: AVCaptureSession
    let isRunning: Bool
    let selectedPosition: CameraPosition
    let liveRepCount: Int
    let skeleton: PoseSkeleton?
    @Binding var selectedExercise: String
    let exercises: [ExerciseCatalogItem]
    let startAction: () -> Void
    let stopAction: () -> Void
    let switchCameraAction: () -> Void

    private var selectedExerciseItem: ExerciseCatalogItem? {
        exercises.first { $0.name == selectedExercise }
    }

    var body: some View {
        FitnessCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Label("Form Coach", systemImage: "camera.viewfinder")
                        .font(.headline)
                        .foregroundStyle(FitnessTheme.primary)

                    Spacer()

                    Text(selectedPosition.rawValue)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(FitnessTheme.ink)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .background(FitnessTheme.primary, in: Capsule())
                }

                ZStack {
                    CameraPreviewView(
                        session: session,
                        cameraPosition: selectedPosition,
                        skeleton: isRunning ? skeleton : nil
                    )
                        .opacity(isRunning ? 1 : 0)

                    if !isRunning {
                        Color.black

                        VStack(spacing: 12) {
                            Image(systemName: "figure.strengthtraining.traditional")
                                .font(.largeTitle)
                                .foregroundStyle(FitnessTheme.primary)
                                .accessibilityHidden(true)

                            Text(cameraStatus == .authorized ? "Start the camera to begin form feedback." : "Allow camera access to use form feedback.")
                                .font(.body)
                                .multilineTextAlignment(.center)
                                .foregroundStyle(FitnessTheme.textMuted)
                        }
                        .padding()
                    }
                }
                .aspectRatio(4 / 5, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(FitnessTheme.border, lineWidth: 1)
                }

                HStack(alignment: .center, spacing: 12) {
                    Picker("Exercise", selection: $selectedExercise) {
                        ForEach(exercises) { exercise in
                            Text(exercise.name).tag(exercise.name)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(FitnessTheme.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(liveRepCount)")
                            .font(.system(.title2, design: .rounded).bold())
                            .foregroundStyle(FitnessTheme.ink)

                        Text("reps")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(FitnessTheme.ink.opacity(0.72))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .frame(minWidth: 74)
                    .background(FitnessTheme.primary, in: RoundedRectangle(cornerRadius: FitnessTheme.controlRadius))
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Live repetition count \(liveRepCount)")
                }

                if let selectedExerciseItem {
                    CoachExerciseGuideCard(exercise: selectedExerciseItem)
                }

                HStack(spacing: 10) {
                    Button(action: isRunning ? stopAction : startAction) {
                        Label(isRunning ? "Stop" : "Start", systemImage: isRunning ? "stop.fill" : "play.fill")
                    }
                    .buttonStyle(FitnessPrimaryButtonStyle())

                    Button(action: switchCameraAction) {
                        Image(systemName: "arrow.triangle.2.circlepath.camera")
                            .frame(width: 48, height: 52)
                    }
                    .buttonStyle(FitnessSecondaryButtonStyle())
                    .disabled(!isRunning)
                    .accessibilityLabel("Switch camera")
                }

                LabeledContent("Camera", value: cameraStatus.rawValue)
                    .foregroundStyle(FitnessTheme.text, FitnessTheme.textMuted)
            }
        }
    }
}

private struct CoachExerciseGuideCard: View {
    let exercise: ExerciseCatalogItem

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: iconName)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(FitnessTheme.primary)
                    .frame(width: 34, height: 34)
                    .background(FitnessTheme.primaryTint, in: RoundedRectangle(cornerRadius: FitnessTheme.controlRadius))
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 5) {
                    Text("How to do \(exercise.name)")
                        .font(.subheadline.bold())
                        .foregroundStyle(FitnessTheme.text)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(exercise.instructions)
                        .font(.caption)
                        .foregroundStyle(FitnessTheme.textMuted)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            HStack(spacing: 8) {
                MetricPill(exercise.intensity.rawValue.capitalized, systemImage: "speedometer")
                MetricPill(exercise.level.rawValue.capitalized, systemImage: "chart.bar.fill")
                MetricPill("\(Int(exercise.kcalPerMinute)) kcal/min", systemImage: "flame.fill")
            }

            if !exercise.bodyFocus.isEmpty {
                Text("Focus: \(exercise.bodyFocus.map { $0.capitalized }.joined(separator: ", "))")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(FitnessTheme.primary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(12)
        .background(FitnessTheme.surface, in: RoundedRectangle(cornerRadius: FitnessTheme.controlRadius))
        .overlay {
            RoundedRectangle(cornerRadius: FitnessTheme.controlRadius)
                .stroke(FitnessTheme.border, lineWidth: 1)
        }
        .accessibilityElement(children: .combine)
    }

    private var iconName: String {
        switch exercise.category {
        case .cardio:
            return "figure.run"
        case .strength:
            return "figure.strengthtraining.traditional"
        case .core:
            return "figure.core.training"
        case .fullBody:
            return "flame.fill"
        case .mobility:
            return "figure.flexibility"
        case .recovery:
            return "leaf.fill"
        }
    }
}

import CoreMedia
import SwiftUI

struct CoachView: View {
    let cameraStatus: PermissionStatus

    @StateObject private var cameraManager = CameraSessionManager()
    @State private var selectedExercise = ExerciseCatalogService.defaultExercises.first?.name ?? "Squats"
    @State private var exercises = ExerciseCatalogService.defaultExercises
    @State private var feedback: FormFeedback?
    @State private var errorMessage: String?
    @State private var isAnalyzingFrame = false
    @State private var sessionSummaries: [String: CoachExerciseSessionSummary] = [:]
    @State private var lastFeedbackAt: Date?
    @State private var lastFeedbackExercise: String?

    private let analyzer = ExerciseFormAnalyzer()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    CoachPreviewCard(
                        cameraStatus: cameraManager.permissionStatus,
                        session: cameraManager.session,
                        isRunning: cameraManager.isRunning,
                        selectedPosition: cameraManager.selectedPosition,
                        liveRepCount: liveRepCount,
                        selectedExercise: $selectedExercise,
                        exercises: exercises,
                        startAction: startCamera,
                        stopAction: stopCamera,
                        switchCameraAction: switchCamera
                    )
                    CoachFeedbackCard(feedback: feedback, errorMessage: errorMessage)
                    CoachSessionSummaryCard(summaries: sortedSessionSummaries)
                }
                .padding()
            }
            .background { FitnessTheme.pageBackground }
            .navigationTitle("Coach")
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(FitnessTheme.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .task {
                _ = await cameraManager.requestCameraAccess()
                installFrameHandler()
            }
            .onDisappear {
                cameraManager.stopSession()
                resetFeedbackClock()
            }
            .onChange(of: selectedExercise) { _ in
                resetFeedbackClock()
            }
        }
    }

    private var liveRepCount: Int {
        let key = normalizedExerciseName(selectedExercise)
        return sessionSummaries[key]?.repCount ?? feedbackForSelectedExercise?.repCount ?? 0
    }

    private var feedbackForSelectedExercise: FormFeedback? {
        guard normalizedExerciseName(feedback?.exerciseName ?? "") == normalizedExerciseName(selectedExercise) else {
            return nil
        }

        return feedback
    }

    private var sortedSessionSummaries: [CoachExerciseSessionSummary] {
        sessionSummaries.values.sorted { lhs, rhs in
            lhs.exerciseName.localizedCaseInsensitiveCompare(rhs.exerciseName) == .orderedAscending
        }
    }

    private func startCamera() {
        Task {
            do {
                errorMessage = nil
                installFrameHandler()
                try await cameraManager.startSession()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    private func stopCamera() {
        cameraManager.stopSession()
        resetFeedbackClock()
    }

    private func switchCamera() {
        Task {
            do {
                errorMessage = nil
                try await cameraManager.switchCamera()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    private func installFrameHandler() {
        cameraManager.sampleBufferHandler = { sampleBuffer in
            Task { @MainActor in
                await analyzeFrame(sampleBuffer)
            }
        }
    }

    @MainActor
    private func analyzeFrame(_ sampleBuffer: CMSampleBuffer) async {
        guard cameraManager.isRunning, !isAnalyzingFrame else {
            return
        }

        isAnalyzingFrame = true
        defer { isAnalyzingFrame = false }

        do {
            let newFeedback = try await analyzer.analyzeFrame(sampleBuffer, exercise: selectedExercise)
            feedback = newFeedback
            updateSessionSummary(with: newFeedback)
            errorMessage = nil
        } catch ExerciseFormAnalyzerError.noBodyPoseDetected {
            errorMessage = "Move into frame so Vision can detect your body pose."
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func updateSessionSummary(with feedback: FormFeedback) {
        let now = Date()
        let exerciseName = feedback.exerciseName
        let key = normalizedExerciseName(exerciseName)
        let elapsed: TimeInterval

        if lastFeedbackExercise == key, let lastFeedbackAt {
            elapsed = min(max(now.timeIntervalSince(lastFeedbackAt), 0), 2)
        } else {
            elapsed = 0
        }

        let exercise = exercises.first {
            normalizedExerciseName($0.name) == key
        }
        let kcalPerMinute = exercise?.kcalPerMinute ?? 0
        var summary = sessionSummaries[key] ?? CoachExerciseSessionSummary(
            id: key,
            exerciseName: exercise?.name ?? exerciseName,
            repCount: 0,
            durationSeconds: 0,
            kcalPerMinute: kcalPerMinute
        )

        summary.repCount = max(summary.repCount, feedback.repCount)
        summary.durationSeconds += elapsed
        summary.kcalPerMinute = kcalPerMinute
        sessionSummaries[key] = summary
        lastFeedbackAt = now
        lastFeedbackExercise = key
    }

    private func resetFeedbackClock() {
        lastFeedbackAt = nil
        lastFeedbackExercise = nil
    }

    private func normalizedExerciseName(_ name: String) -> String {
        name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
}

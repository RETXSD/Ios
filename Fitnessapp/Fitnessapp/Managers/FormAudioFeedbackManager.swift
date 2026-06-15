import AVFoundation
import Foundation

@MainActor
final class FormAudioFeedbackManager: ObservableObject {
    private let synthesizer = AVSpeechSynthesizer()
    private var lastCue: String?
    private var lastSpokenAt: Date?
    private let cooldownSeconds: TimeInterval
    private let minimumScoreForSilence: Double

    init(cooldownSeconds: TimeInterval = 4, minimumScoreForSilence: Double = 0.78) {
        self.cooldownSeconds = cooldownSeconds
        self.minimumScoreForSilence = minimumScoreForSilence
    }

    func speakCorrectionIfNeeded(for feedback: FormFeedback) {
        guard let cue = voiceCue(for: feedback) else {
            return
        }

        let now = Date()
        if cue == lastCue,
           let lastSpokenAt,
           now.timeIntervalSince(lastSpokenAt) < cooldownSeconds {
            return
        }

        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .word)
        }

        configureAudioSession()

        let utterance = AVSpeechUtterance(string: cue)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.48
        utterance.pitchMultiplier = 1.02
        utterance.volume = 1
        synthesizer.speak(utterance)

        lastCue = cue
        lastSpokenAt = now
    }

    func reset() {
        lastCue = nil
        lastSpokenAt = nil
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
    }

    private func voiceCue(for feedback: FormFeedback) -> String? {
        if feedback.confidence < 0.5 {
            return "Move back a little. Keep your whole body in the camera frame."
        }

        if let issue = feedback.detectedIssues.first {
            return cue(forIssue: issue, exerciseName: feedback.exerciseName)
        }

        guard feedback.score < minimumScoreForSilence else {
            return nil
        }

        return cue(forMessage: feedback.message, exerciseName: feedback.exerciseName)
    }

    private func configureAudioSession() {
        let session = AVAudioSession.sharedInstance()

        do {
            try session.setCategory(.playback, mode: .spokenAudio, options: [.duckOthers])
            try session.setActive(true, options: [])
        } catch {
            #if DEBUG
            print("Voice coach audio session failed: \(error.localizedDescription)")
            #endif
        }
    }

    private func cue(forIssue issue: String, exerciseName: String) -> String {
        let normalizedIssue = issue.lowercased()
        let normalizedExercise = exerciseName.lowercased()

        if normalizedIssue.contains("knee") || normalizedIssue.contains("knees") {
            return "Keep your knees from caving in. Track them over your toes."
        }

        if normalizedIssue.contains("range") {
            if normalizedExercise.contains("squat") || normalizedExercise.contains("lunge") || normalizedExercise.contains("burpee") {
                return "Bend your knees deeper, then stand tall again."
            }

            if normalizedExercise.contains("push") {
                return "Lower your chest closer to the floor. Keep your body straight."
            }

            if normalizedExercise.contains("plank") {
                return "Lift your hips slightly and keep your body in one line."
            }

            return "Use a fuller range of motion before counting the rep."
        }

        if normalizedIssue.contains("confidence") || normalizedIssue.contains("visible") {
            return "Your body is not fully visible. Move into the camera frame."
        }

        return cue(forMessage: issue, exerciseName: exerciseName)
    }

    private func cue(forMessage message: String, exerciseName: String) -> String {
        let normalizedMessage = message.lowercased()
        let normalizedExercise = exerciseName.lowercased()

        if normalizedMessage.contains("frame") || normalizedMessage.contains("visible") {
            return "Move fully into the camera frame."
        }

        if normalizedMessage.contains("sink lower") || normalizedMessage.contains("lower") {
            if normalizedExercise.contains("squat") || normalizedExercise.contains("lunge") || normalizedExercise.contains("burpee") {
                return "Go lower and keep your knees tracking over your toes."
            }

            if normalizedExercise.contains("push") {
                return "Lower your body more and keep your core tight."
            }
        }

        if normalizedMessage.contains("body straight") || normalizedMessage.contains("one line") || normalizedMessage.contains("aligned") {
            return "Keep your body straight and your core tight."
        }

        if normalizedMessage.contains("hips") {
            return "Adjust your hips. Do not let them drop or lift too high."
        }

        return "Fix your body position and repeat the movement slowly."
    }
}

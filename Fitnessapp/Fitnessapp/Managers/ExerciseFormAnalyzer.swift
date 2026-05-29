import AVFoundation
import Foundation
import Vision

enum ExerciseFormAnalyzerError: Error {
    case missingImageBuffer
    case noBodyPoseDetected
}

final class ExerciseFormAnalyzer {
    private let analyzerActor = BodyPoseAnalyzerActor()

    func analyzeFrame(_ sampleBuffer: CMSampleBuffer, exercise: String) async throws -> FormFeedback {
        try await analyzerActor.analyzeFrame(sampleBuffer, exercise: exercise)
    }
}

private actor BodyPoseAnalyzerActor {
    private struct CounterState {
        var count = 0
        var phase: MovementPhase = .unknown
        var lastSide: MovementSide?
    }

    private enum MovementPhase {
        case unknown
        case up
        case down
        case open
        case closed
        case leftDrive
        case rightDrive
    }

    private enum MovementSide {
        case left
        case right
    }

    private struct CounterResult {
        let count: Int
        let message: String
        let extraIssues: [ExerciseFormIssue]
    }

    private let minimumConfidence: Float = 0.5
    private var counters: [String: CounterState] = [:]

    func analyzeFrame(_ sampleBuffer: CMSampleBuffer, exercise: String) throws -> FormFeedback {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            throw ExerciseFormAnalyzerError.missingImageBuffer
        }

        let request = VNDetectHumanBodyPoseRequest()
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up, options: [:])
        try handler.perform([request])

        guard let observation = request.results?.first else {
            throw ExerciseFormAnalyzerError.noBodyPoseDetected
        }

        return try feedback(from: observation, exercise: exercise)
    }

    private func feedback(from observation: VNHumanBodyPoseObservation, exercise: String) throws -> FormFeedback {
        let points = try observation.recognizedPoints(.all)
        let confidentPoints = points.values.filter { $0.confidence >= minimumConfidence }
        let confidence = averageConfidence(for: confidentPoints)
        let exerciseKey = normalizedExerciseName(exercise)
        let currentCount = counters[exerciseKey]?.count ?? 0

        guard confidence >= minimumConfidence else {
            return FormFeedback(
                exerciseName: exercise,
                score: 0.35,
                confidence: Double(confidence),
                repCount: currentCount,
                message: "Move fully into frame so the coach can read your form.",
                detectedIssues: [ExerciseFormIssue.lowConfidence.rawValue]
            )
        }

        let counter = counterResult(for: exerciseKey, points: points)
        var issues = detectedIssues(in: points, exerciseKey: exerciseKey)
        issues.append(contentsOf: counter.extraIssues)

        let score = scoreForIssues(issues, confidence: confidence)
        let message = issues.isEmpty
            ? counter.message
            : issues.first?.rawValue ?? counter.message

        return FormFeedback(
            exerciseName: exercise,
            score: score,
            confidence: Double(confidence),
            repCount: counter.count,
            message: message,
            detectedIssues: issues.map(\.rawValue)
        )
    }

    private func counterResult(
        for exerciseKey: String,
        points: [VNHumanBodyPoseObservation.JointName: VNRecognizedPoint]
    ) -> CounterResult {
        switch exerciseKey {
        case "push-ups", "pushups", "push up", "push-up":
            return angleCounter(
                key: exerciseKey,
                points: points,
                first: (.leftShoulder, .rightShoulder),
                middle: (.leftElbow, .rightElbow),
                last: (.leftWrist, .rightWrist),
                downAngle: 95,
                upAngle: 155,
                downMessage: "Lower until your elbows bend, then press back up.",
                upMessage: "Push-up counted. Keep your body straight."
            )

        case "squats", "squat", "lunges", "lunge", "burpees", "burpee":
            return angleCounter(
                key: exerciseKey,
                points: points,
                first: (.leftHip, .rightHip),
                middle: (.leftKnee, .rightKnee),
                last: (.leftAnkle, .rightAnkle),
                downAngle: 110,
                upAngle: 160,
                downMessage: "Sink lower with knees tracking over toes.",
                upMessage: "Rep counted. Stand tall and keep control."
            )

        case "sit-ups", "situps", "sit up", "sit-up":
            return angleCounter(
                key: exerciseKey,
                points: points,
                first: (.leftShoulder, .rightShoulder),
                middle: (.leftHip, .rightHip),
                last: (.leftKnee, .rightKnee),
                downAngle: 95,
                upAngle: 140,
                downMessage: "Curl up toward your knees.",
                upMessage: "Sit-up counted. Lower with control.",
                countWhenMovingDown: true
            )

        case "jumping-jacks", "jumping jacks", "jumping jack":
            return jumpingJackCounter(key: exerciseKey, points: points)

        case "mountain-climbers", "mountain climbers", "mountain climber":
            return mountainClimberCounter(key: exerciseKey, points: points)

        case "plank":
            return plankFeedback(key: exerciseKey, points: points)

        default:
            let count = counters[exerciseKey]?.count ?? 0
            return CounterResult(
                count: count,
                message: "Pose detected. Choose push-ups, squats, lunges, sit-ups, jumping jacks, mountain climbers, burpees, or plank for rep feedback.",
                extraIssues: []
            )
        }
    }

    private func angleCounter(
        key: String,
        points: [VNHumanBodyPoseObservation.JointName: VNRecognizedPoint],
        first: (VNHumanBodyPoseObservation.JointName, VNHumanBodyPoseObservation.JointName),
        middle: (VNHumanBodyPoseObservation.JointName, VNHumanBodyPoseObservation.JointName),
        last: (VNHumanBodyPoseObservation.JointName, VNHumanBodyPoseObservation.JointName),
        downAngle: Double,
        upAngle: Double,
        downMessage: String,
        upMessage: String,
        countWhenMovingDown: Bool = false
    ) -> CounterResult {
        guard let angle = bestSideAngle(first: first, middle: middle, last: last, in: points) else {
            return CounterResult(
                count: counters[key]?.count ?? 0,
                message: "Keep the full working side visible to count reps.",
                extraIssues: [.lowConfidence]
            )
        }

        var state = counters[key] ?? CounterState()
        let previousPhase = state.phase

        if angle <= downAngle {
            state.phase = .down
            if countWhenMovingDown && previousPhase == .up {
                state.count += 1
            }
        } else if angle >= upAngle {
            state.phase = .up
            if !countWhenMovingDown && previousPhase == .down {
                state.count += 1
            }
        }

        counters[key] = state

        let message: String
        switch state.phase {
        case .down:
            message = downMessage
        case .up:
            message = upMessage
        default:
            message = "Keep moving through the full range of motion."
        }

        let issues: [ExerciseFormIssue] = angle > downAngle && angle < upAngle ? [.limitedRangeOfMotion] : []
        return CounterResult(count: state.count, message: message, extraIssues: issues)
    }

    private func jumpingJackCounter(
        key: String,
        points: [VNHumanBodyPoseObservation.JointName: VNRecognizedPoint]
    ) -> CounterResult {
        guard
            let leftWrist = confidentPoint(.leftWrist, in: points),
            let rightWrist = confidentPoint(.rightWrist, in: points),
            let leftShoulder = confidentPoint(.leftShoulder, in: points),
            let rightShoulder = confidentPoint(.rightShoulder, in: points),
            let leftAnkle = confidentPoint(.leftAnkle, in: points),
            let rightAnkle = confidentPoint(.rightAnkle, in: points),
            let leftHip = confidentPoint(.leftHip, in: points),
            let rightHip = confidentPoint(.rightHip, in: points)
        else {
            return CounterResult(count: counters[key]?.count ?? 0, message: "Keep arms and feet visible.", extraIssues: [.lowConfidence])
        }

        var state = counters[key] ?? CounterState()
        let previousPhase = state.phase
        let handsUp = leftWrist.location.y > leftShoulder.location.y && rightWrist.location.y > rightShoulder.location.y
        let ankleDistance = abs(leftAnkle.location.x - rightAnkle.location.x)
        let hipDistance = max(abs(leftHip.location.x - rightHip.location.x), 0.05)
        let feetWide = ankleDistance > hipDistance * 1.45

        if handsUp && feetWide {
            state.phase = .open
        } else if !handsUp && !feetWide {
            state.phase = .closed
            if previousPhase == .open {
                state.count += 1
            }
        }

        counters[key] = state
        return CounterResult(
            count: state.count,
            message: state.phase == .open ? "Open position detected. Return to center." : "Jumping jack counted when arms and feet return together.",
            extraIssues: []
        )
    }

    private func mountainClimberCounter(
        key: String,
        points: [VNHumanBodyPoseObservation.JointName: VNRecognizedPoint]
    ) -> CounterResult {
        guard
            let leftKnee = confidentPoint(.leftKnee, in: points),
            let rightKnee = confidentPoint(.rightKnee, in: points),
            let leftHip = confidentPoint(.leftHip, in: points),
            let rightHip = confidentPoint(.rightHip, in: points)
        else {
            return CounterResult(count: counters[key]?.count ?? 0, message: "Keep hips and knees in frame.", extraIssues: [.lowConfidence])
        }

        var state = counters[key] ?? CounterState()
        let leftDrive = leftKnee.location.y > leftHip.location.y + 0.08
        let rightDrive = rightKnee.location.y > rightHip.location.y + 0.08

        if leftDrive, state.lastSide != .left {
            state.count += 1
            state.lastSide = .left
            state.phase = .leftDrive
        } else if rightDrive, state.lastSide != .right {
            state.count += 1
            state.lastSide = .right
            state.phase = .rightDrive
        }

        counters[key] = state
        return CounterResult(
            count: state.count,
            message: "Drive knees toward your chest one at a time.",
            extraIssues: []
        )
    }

    private func plankFeedback(
        key: String,
        points: [VNHumanBodyPoseObservation.JointName: VNRecognizedPoint]
    ) -> CounterResult {
        let issues = hasSaggingPlank(in: points) ? [ExerciseFormIssue.limitedRangeOfMotion] : []
        return CounterResult(
            count: counters[key]?.count ?? 0,
            message: issues.isEmpty ? "Plank detected. Keep hips, shoulders, and ankles aligned." : "Lift your hips and keep your body in one line.",
            extraIssues: issues
        )
    }

    private func detectedIssues(
        in points: [VNHumanBodyPoseObservation.JointName: VNRecognizedPoint],
        exerciseKey: String
    ) -> [ExerciseFormIssue] {
        var issues: [ExerciseFormIssue] = []

        if ["squats", "squat", "lunges", "lunge", "burpees", "burpee"].contains(exerciseKey), hasKneeCollapse(in: points) {
            issues.append(.kneesCavingIn)
        }

        return issues
    }

    private func hasKneeCollapse(in points: [VNHumanBodyPoseObservation.JointName: VNRecognizedPoint]) -> Bool {
        guard
            let leftKnee = confidentPoint(.leftKnee, in: points),
            let rightKnee = confidentPoint(.rightKnee, in: points),
            let leftAnkle = confidentPoint(.leftAnkle, in: points),
            let rightAnkle = confidentPoint(.rightAnkle, in: points)
        else {
            return false
        }

        let kneeDistance = abs(leftKnee.location.x - rightKnee.location.x)
        let ankleDistance = abs(leftAnkle.location.x - rightAnkle.location.x)
        return ankleDistance > 0 && kneeDistance < ankleDistance * 0.65
    }

    private func hasSaggingPlank(in points: [VNHumanBodyPoseObservation.JointName: VNRecognizedPoint]) -> Bool {
        guard
            let shoulder = averagePoint(.leftShoulder, .rightShoulder, in: points),
            let hip = averagePoint(.leftHip, .rightHip, in: points),
            let ankle = averagePoint(.leftAnkle, .rightAnkle, in: points)
        else {
            return false
        }

        let expectedHipY = (shoulder.y + ankle.y) / 2
        return abs(hip.y - expectedHipY) > 0.16
    }

    private func bestSideAngle(
        first: (VNHumanBodyPoseObservation.JointName, VNHumanBodyPoseObservation.JointName),
        middle: (VNHumanBodyPoseObservation.JointName, VNHumanBodyPoseObservation.JointName),
        last: (VNHumanBodyPoseObservation.JointName, VNHumanBodyPoseObservation.JointName),
        in points: [VNHumanBodyPoseObservation.JointName: VNRecognizedPoint]
    ) -> Double? {
        let left = sideAngle(first: first.0, middle: middle.0, last: last.0, in: points)
        let right = sideAngle(first: first.1, middle: middle.1, last: last.1, in: points)

        switch (left, right) {
        case let (left?, right?):
            return (left.confidence >= right.confidence ? left.angle : right.angle)
        case let (left?, nil):
            return left.angle
        case let (nil, right?):
            return right.angle
        default:
            return nil
        }
    }

    private func sideAngle(
        first: VNHumanBodyPoseObservation.JointName,
        middle: VNHumanBodyPoseObservation.JointName,
        last: VNHumanBodyPoseObservation.JointName,
        in points: [VNHumanBodyPoseObservation.JointName: VNRecognizedPoint]
    ) -> (angle: Double, confidence: Float)? {
        guard
            let firstPoint = confidentPoint(first, in: points),
            let middlePoint = confidentPoint(middle, in: points),
            let lastPoint = confidentPoint(last, in: points)
        else {
            return nil
        }

        let confidence = (firstPoint.confidence + middlePoint.confidence + lastPoint.confidence) / 3
        return (
            angleBetween(first: firstPoint.location, middle: middlePoint.location, last: lastPoint.location),
            confidence
        )
    }

    private func confidentPoint(
        _ jointName: VNHumanBodyPoseObservation.JointName,
        in points: [VNHumanBodyPoseObservation.JointName: VNRecognizedPoint]
    ) -> VNRecognizedPoint? {
        guard let point = points[jointName], point.confidence >= minimumConfidence else {
            return nil
        }

        return point
    }

    private func averagePoint(
        _ left: VNHumanBodyPoseObservation.JointName,
        _ right: VNHumanBodyPoseObservation.JointName,
        in points: [VNHumanBodyPoseObservation.JointName: VNRecognizedPoint]
    ) -> CGPoint? {
        guard let leftPoint = confidentPoint(left, in: points), let rightPoint = confidentPoint(right, in: points) else {
            return nil
        }

        return CGPoint(
            x: (leftPoint.location.x + rightPoint.location.x) / 2,
            y: (leftPoint.location.y + rightPoint.location.y) / 2
        )
    }

    private func averageConfidence(for points: [VNRecognizedPoint]) -> Float {
        guard !points.isEmpty else { return 0 }
        let total = points.reduce(Float(0)) { $0 + $1.confidence }
        return total / Float(points.count)
    }

    private func scoreForIssues(_ issues: [ExerciseFormIssue], confidence: Float) -> Double {
        let penalty = Double(Set(issues).count) * 0.18
        return min(max(Double(confidence) - penalty, 0), 1)
    }

    private func angleBetween(first: CGPoint, middle: CGPoint, last: CGPoint) -> Double {
        let firstVector = CGVector(dx: first.x - middle.x, dy: first.y - middle.y)
        let secondVector = CGVector(dx: last.x - middle.x, dy: last.y - middle.y)

        let dotProduct = firstVector.dx * secondVector.dx + firstVector.dy * secondVector.dy
        let firstMagnitude = sqrt(firstVector.dx * firstVector.dx + firstVector.dy * firstVector.dy)
        let secondMagnitude = sqrt(secondVector.dx * secondVector.dx + secondVector.dy * secondVector.dy)

        guard firstMagnitude > 0, secondMagnitude > 0 else { return 180 }

        let cosine = min(max(dotProduct / (firstMagnitude * secondMagnitude), -1), 1)
        return Double(acos(cosine) * 180 / CGFloat.pi)
    }

    private func normalizedExerciseName(_ exercise: String) -> String {
        exercise
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
    }
}

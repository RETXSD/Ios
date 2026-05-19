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
    private let minimumConfidence: Float = 0.5
    private var repCount = 0

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

        guard confidence >= minimumConfidence else {
            return FormFeedback(
                exerciseName: exercise,
                score: 0.35,
                confidence: Double(confidence),
                repCount: repCount,
                message: "Move fully into frame so the coach can read your form.",
                detectedIssues: [ExerciseFormIssue.lowConfidence.rawValue]
            )
        }

        let issues = detectedIssues(in: points)
        let score = scoreForIssues(issues, confidence: confidence)
        repCount = estimatedRepCount(from: points, currentCount: repCount)

        let message = issues.isEmpty
            ? "Good alignment. Keep your movement controlled."
            : issues.first?.rawValue ?? "Keep your form steady."

        return FormFeedback(
            exerciseName: exercise,
            score: score,
            confidence: Double(confidence),
            repCount: repCount,
            message: message,
            detectedIssues: issues.map(\.rawValue)
        )
    }

    private func detectedIssues(in points: [VNHumanBodyPoseObservation.JointName: VNRecognizedPoint]) -> [ExerciseFormIssue] {
        var issues: [ExerciseFormIssue] = []

        if hasKneeCollapse(in: points) {
            issues.append(.kneesCavingIn)
        }

        if hasLimitedRangeOfMotion(in: points) {
            issues.append(.limitedRangeOfMotion)
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

    private func hasLimitedRangeOfMotion(in points: [VNHumanBodyPoseObservation.JointName: VNRecognizedPoint]) -> Bool {
        guard
            let leftHip = confidentPoint(.leftHip, in: points),
            let leftKnee = confidentPoint(.leftKnee, in: points),
            let leftAnkle = confidentPoint(.leftAnkle, in: points)
        else {
            return false
        }

        let kneeAngle = angleBetween(first: leftHip.location, middle: leftKnee.location, last: leftAnkle.location)
        return kneeAngle > 165
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

    private func averageConfidence(for points: [VNRecognizedPoint]) -> Float {
        guard !points.isEmpty else { return 0 }
        let total = points.reduce(Float(0)) { $0 + $1.confidence }
        return total / Float(points.count)
    }

    private func scoreForIssues(_ issues: [ExerciseFormIssue], confidence: Float) -> Double {
        let penalty = Double(issues.count) * 0.18
        return min(max(Double(confidence) - penalty, 0), 1)
    }

    private func estimatedRepCount(
        from points: [VNHumanBodyPoseObservation.JointName: VNRecognizedPoint],
        currentCount: Int
    ) -> Int {
        guard
            let leftWrist = confidentPoint(.leftWrist, in: points),
            let leftShoulder = confidentPoint(.leftShoulder, in: points)
        else {
            return currentCount
        }

        return leftWrist.location.y > leftShoulder.location.y ? max(currentCount, 1) : currentCount
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
}

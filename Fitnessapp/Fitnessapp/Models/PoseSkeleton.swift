import CoreGraphics
import Foundation

struct PoseSkeleton: Equatable {
    let joints: [PoseJoint]

    func point(named name: PoseJointName) -> CGPoint? {
        joints.first { $0.name == name }?.point
    }
}

struct PoseJoint: Identifiable, Equatable {
    let id: PoseJointName
    let name: PoseJointName
    let point: CGPoint
    let confidence: Double

    init(name: PoseJointName, point: CGPoint, confidence: Double) {
        self.id = name
        self.name = name
        self.point = point
        self.confidence = confidence
    }
}

enum PoseJointName: String, CaseIterable {
    case leftWrist
    case rightWrist
    case leftElbow
    case rightElbow
    case leftShoulder
    case rightShoulder
    case leftHip
    case rightHip
    case leftKnee
    case rightKnee
    case leftAnkle
    case rightAnkle
}

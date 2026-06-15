import AVFoundation
import SwiftUI

struct CameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession
    let cameraPosition: CameraPosition
    let skeleton: PoseSkeleton?

    func makeUIView(context: Context) -> CameraPreviewUIView {
        let view = CameraPreviewUIView()
        view.previewLayer.session = session
        view.previewLayer.videoGravity = .resizeAspectFill
        view.updateCameraPosition(cameraPosition)
        view.updateSkeleton(skeleton)
        return view
    }

    func updateUIView(_ uiView: CameraPreviewUIView, context: Context) {
        if uiView.previewLayer.session !== session {
            uiView.previewLayer.session = session
        }

        uiView.updateCameraPosition(cameraPosition)
        uiView.updateSkeleton(skeleton)
    }
}

final class CameraPreviewUIView: UIView {
    private let skeletonLineLayer = CAShapeLayer()
    private var jointLayers: [CALayer] = []
    private var currentSkeleton: PoseSkeleton?
    private var currentCameraPosition: CameraPosition = .front

    private let limbConnections: [(PoseJointName, PoseJointName)] = [
        (.leftWrist, .leftElbow),
        (.leftElbow, .leftShoulder),
        (.rightWrist, .rightElbow),
        (.rightElbow, .rightShoulder),
        (.leftShoulder, .rightShoulder),
        (.leftShoulder, .leftHip),
        (.rightShoulder, .rightHip),
        (.leftHip, .rightHip),
        (.leftHip, .leftKnee),
        (.leftKnee, .leftAnkle),
        (.rightHip, .rightKnee),
        (.rightKnee, .rightAnkle)
    ]

    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }

    var previewLayer: AVCaptureVideoPreviewLayer {
        layer as! AVCaptureVideoPreviewLayer
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureSkeletonLayer()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureSkeletonLayer()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        skeletonLineLayer.frame = bounds
        drawSkeleton()
    }

    func updateSkeleton(_ skeleton: PoseSkeleton?) {
        currentSkeleton = skeleton
        drawSkeleton()
    }

    func updateCameraPosition(_ position: CameraPosition) {
        currentCameraPosition = position

        if let connection = previewLayer.connection {
            connection.videoOrientation = .portrait
            if connection.isVideoMirroringSupported {
                connection.isVideoMirrored = position == .front
            }
        }

        drawSkeleton()
    }

    private func configureSkeletonLayer() {
        skeletonLineLayer.frame = bounds
        skeletonLineLayer.fillColor = UIColor.clear.cgColor
        skeletonLineLayer.strokeColor = UIColor(FitnessTheme.primary.opacity(0.88)).cgColor
        skeletonLineLayer.lineWidth = 3
        skeletonLineLayer.lineCap = .round
        skeletonLineLayer.lineJoin = .round
        layer.addSublayer(skeletonLineLayer)
    }

    private func drawSkeleton() {
        jointLayers.forEach { $0.removeFromSuperlayer() }
        jointLayers = []

        guard let currentSkeleton else {
            skeletonLineLayer.path = nil
            return
        }

        let path = UIBezierPath()
        for connection in limbConnections {
            guard
                let first = currentSkeleton.point(named: connection.0),
                let second = currentSkeleton.point(named: connection.1)
            else {
                continue
            }

            path.move(to: layerPoint(fromVisionPoint: first))
            path.addLine(to: layerPoint(fromVisionPoint: second))
        }
        skeletonLineLayer.path = path.cgPath

        for joint in currentSkeleton.joints {
            addJointLayer(for: joint)
        }
    }

    private func addJointLayer(for joint: PoseJoint) {
        let point = layerPoint(fromVisionPoint: joint.point)
        let size = jointSize(for: joint)
        let jointLayer = CAShapeLayer()
        jointLayer.frame = CGRect(
            x: point.x - size / 2,
            y: point.y - size / 2,
            width: size,
            height: size
        )
        jointLayer.path = UIBezierPath(ovalIn: CGRect(origin: .zero, size: CGSize(width: size, height: size))).cgPath
        jointLayer.fillColor = jointColor(for: joint).cgColor
        jointLayer.strokeColor = UIColor.black.withAlphaComponent(0.78).cgColor
        jointLayer.lineWidth = 1.5
        jointLayer.shadowColor = UIColor(FitnessTheme.glow).cgColor
        jointLayer.shadowRadius = 5
        jointLayer.shadowOpacity = 1
        jointLayer.shadowOffset = .zero
        layer.addSublayer(jointLayer)
        jointLayers.append(jointLayer)
    }

    private func layerPoint(fromVisionPoint point: CGPoint) -> CGPoint {
        let captureDevicePoint = CGPoint(x: point.x, y: 1 - point.y)
        return previewLayer.layerPointConverted(fromCaptureDevicePoint: captureDevicePoint)
    }

    private func jointColor(for joint: PoseJoint) -> UIColor {
        switch joint.name {
        case .leftKnee, .rightKnee:
            return UIColor(FitnessTheme.gold)
        case .leftWrist, .rightWrist, .leftElbow, .rightElbow:
            return UIColor(FitnessTheme.info)
        default:
            return UIColor(FitnessTheme.primary)
        }
    }

    private func jointSize(for joint: PoseJoint) -> CGFloat {
        switch joint.name {
        case .leftKnee, .rightKnee, .leftWrist, .rightWrist:
            return 13
        default:
            return 10
        }
    }
}

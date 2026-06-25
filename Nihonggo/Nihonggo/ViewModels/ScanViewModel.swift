import Combine
import Foundation

@MainActor
final class ScanViewModel: ObservableObject {
    @Published var selectedMode: ScanMode = .character
    @Published private(set) var result: ScanResult?
    @Published private(set) var isProcessing = false
    @Published private(set) var errorMessage: String?

    let cameraViewModel = CameraViewModel()

    private var cancellables = Set<AnyCancellable>()

    init() {
        cameraViewModel.$scanResult.assign(to: &$result)
        cameraViewModel.$isProcessing.assign(to: &$isProcessing)
        cameraViewModel.$errorMessage.assign(to: &$errorMessage)
    }

    func prepareCamera() async {
        await cameraViewModel.requestCameraAccess()
        cameraViewModel.startSession()
    }

    func capture() async {
        await cameraViewModel.capture(mode: selectedMode)
    }
}

import AVFoundation
import SwiftUI

struct ScanView: View {
    @StateObject private var viewModel = ScanViewModel()
    @StateObject private var audioService = AudioService()
    @EnvironmentObject private var languageSettings: LanguageSettings
    @Environment(\.openURL) private var openURL

    var body: some View {
        NavigationStack {
            VStack(spacing: 14) {
                Picker(languageSettings.language.text(.scanMode), selection: $viewModel.selectedMode) {
                    ForEach(ScanMode.allCases) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .accessibilityLabel(languageSettings.language.text(.scanMode))

                CameraPreviewView(session: viewModel.cameraViewModel.session)
                    .frame(minHeight: 280)
                    .overlay {
                        RoundedRectangle(cornerRadius: AppTheme.cardRadius)
                            .stroke(AppTheme.sumiInk, lineWidth: AppTheme.borderWidth)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardRadius))
                    .padding(.horizontal)

                if let result = viewModel.result {
                    AppCard {
                        HStack {
                            Text(result.detectedText)
                                .font(.system(.largeTitle, design: .serif))
                                .bold()
                                .foregroundStyle(AppTheme.toriiRed)
                            Spacer()
                            ConfidenceBadge(confidence: result.confidence)
                            AudioButton(text: result.detectedText, audioService: audioService)
                        }
                        if let meaning = result.meaning {
                            Text(meaning)
                        }
                        if result.isLowConfidence {
                            AppBadge(languageSettings.language.text(.lowConfidence), color: AppTheme.toriiRed, systemImage: "xmark.octagon.fill")
                        }
                    }
                    .padding(.horizontal)
                }

                if let errorMessage = viewModel.errorMessage {
                    AppCard {
                        Text(localizedScanError(errorMessage))
                            .font(.headline)
                        if viewModel.cameraViewModel.canOpenSettings, let url = viewModel.cameraViewModel.settingsURL() {
                            AppButton(languageSettings.language.text(.openSettings), systemImage: "gearshape.fill", style: .secondary) {
                                openURL(url)
                            }
                        }
                    }
                    .padding(.horizontal)
                }

                AppButton(viewModel.isProcessing ? languageSettings.language.text(.scanning) : languageSettings.language.text(.capture), systemImage: "camera.fill") {
                    Task { await viewModel.capture() }
                }
                .disabled(viewModel.isProcessing)
                .padding()
            }
            .navigationTitle(languageSettings.language.text(.scanTitle))
            .appScreenBackground()
            .task {
                await viewModel.prepareCamera()
            }
            .onDisappear {
                viewModel.cameraViewModel.stopSession()
            }
        }
    }

    private func localizedScanError(_ message: String) -> String {
        if message.localizedStandardContains("JapaneseCharClassifier") {
            return languageSettings.language.text(.scanModelMissing)
        }
        if message.localizedStandardContains("kamera") || message.localizedStandardContains("camera") {
            return languageSettings.language.text(.scanCameraDenied)
        }
        return languageSettings.language.text(.scanGenericError)
    }
}

private struct CameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        context.coordinator.previewLayer = previewLayer
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.previewLayer?.session = session
        context.coordinator.previewLayer?.frame = uiView.bounds
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    final class Coordinator {
        var previewLayer: AVCaptureVideoPreviewLayer?
    }
}

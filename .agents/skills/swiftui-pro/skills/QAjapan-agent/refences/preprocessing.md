# Preprocessing Reference — Image Pipeline

Used by: visionml-agent

## Full Pipeline

```
UIImage (from camera)
    → crop to character bounding box (Vision)
    → convert to grayscale
    → resize to 64x64px
    → normalize pixel values (0–1)
    → CVPixelBuffer
    → CoreML input
```

## UIImage → Grayscale CVPixelBuffer

```swift
extension UIImage {
    func toGrayscalePixelBuffer(size: CGSize) -> CVPixelBuffer? {
        let attrs: [CFString: Any] = [
            kCVPixelBufferCGImageCompatibilityKey: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey: true
        ]

        var pixelBuffer: CVPixelBuffer?
        CVPixelBufferCreate(
            kCFAllocatorDefault,
            Int(size.width),
            Int(size.height),
            kCVPixelFormatType_OneComponent8,  // grayscale
            attrs as CFDictionary,
            &pixelBuffer
        )

        guard let buffer = pixelBuffer else { return nil }

        CVPixelBufferLockBaseAddress(buffer, [])
        defer { CVPixelBufferUnlockBaseAddress(buffer, []) }

        let context = CGContext(
            data: CVPixelBufferGetBaseAddress(buffer),
            width: Int(size.width),
            height: Int(size.height),
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
            space: CGColorSpaceCreateDeviceGray(),
            bitmapInfo: CGImageAlphaInfo.none.rawValue
        )

        context?.draw(self.cgImage!, in: CGRect(origin: .zero, size: size))
        return buffer
    }
}
```

## Contrast Enhancement (Optional)

If scan environment is low contrast (faint pencil on white paper), apply contrast boost before grayscale:

```swift
func enhanceContrast(_ image: UIImage) -> UIImage {
    guard let ciImage = CIImage(image: image) else { return image }
    let filter = CIFilter(name: "CIColorControls")!
    filter.setValue(ciImage, forKey: kCIInputImageKey)
    filter.setValue(1.5, forKey: kCIInputContrastKey)   // boost contrast
    filter.setValue(0.0, forKey: kCIInputBrightnessKey)
    guard let output = filter.outputImage else { return image }
    return UIImage(ciImage: output)
}
```

## Rules

- Always resize to exactly 64x64 — model rejects other sizes
- Always use `kCVPixelFormatType_OneComponent8` for grayscale (1 channel, 8-bit)
- Always run preprocessing on background thread
- Never pass color (RGB) image to model — grayscale only
- Apply contrast enhancement before grayscale if confidence is consistently low
- Never modify the original `UIImage` — always work on a copy

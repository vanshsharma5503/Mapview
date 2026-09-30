import CoreGraphics
import UIKit

struct ColoringPixelBuffer: Equatable, Sendable {
    let width: Int
    let height: Int
    var bytes: [UInt8]

    init(width: Int, height: Int, bytes: [UInt8]) {
        self.width = width
        self.height = height
        self.bytes = bytes
    }

    init(image: UIImage, maximumDimension: Int = 768) throws {
        guard let source = image.cgImage else { throw ColoringEngineError.invalidImage }
        let scale = min(1, Double(maximumDimension) / Double(max(source.width, source.height)))
        width = max(1, Int(Double(source.width) * scale))
        height = max(1, Int(Double(source.height) * scale))
        bytes = Array(repeating: 0, count: width * height * 4)

        guard let context = CGContext(
            data: &bytes,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else {
            throw ColoringEngineError.unableToCreateBitmap
        }

        context.interpolationQuality = .high
        context.draw(source, in: CGRect(x: 0, y: 0, width: width, height: height))
    }

    nonisolated func rgba(at index: Int) -> (red: UInt8, green: UInt8, blue: UInt8, alpha: UInt8) {
        let offset = index * 4
        return (bytes[offset], bytes[offset + 1], bytes[offset + 2], bytes[offset + 3])
    }
}

extension UIImage {
    convenience init?(pixelBuffer: ColoringPixelBuffer) {
        let data = Data(pixelBuffer.bytes)
        guard let provider = CGDataProvider(data: data as CFData),
              let image = CGImage(
                width: pixelBuffer.width,
                height: pixelBuffer.height,
                bitsPerComponent: 8,
                bitsPerPixel: 32,
                bytesPerRow: pixelBuffer.width * 4,
                space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue),
                provider: provider,
                decode: nil,
                shouldInterpolate: true,
                intent: .defaultIntent
              ) else { return nil }
        self.init(cgImage: image)
    }
}

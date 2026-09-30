import UIKit

enum ColoringRenderer {
    static func render(
        source: ColoringPixelBuffer,
        boundaryMap: [Bool],
        colorLayer: [UInt32]
    ) -> UIImage? {
        var output = source

        for index in 0..<colorLayer.count {
            let offset = index * 4
            if boundaryMap[index] {
                let sourcePixel = source.rgba(at: index)
                output.bytes[offset] = sourcePixel.red
                output.bytes[offset + 1] = sourcePixel.green
                output.bytes[offset + 2] = sourcePixel.blue
                output.bytes[offset + 3] = max(sourcePixel.alpha, 220)
            } else if colorLayer[index] != 0 {
                let color = colorLayer[index]
                output.bytes[offset] = UInt8((color >> 24) & 0xFF)
                output.bytes[offset + 1] = UInt8((color >> 16) & 0xFF)
                output.bytes[offset + 2] = UInt8((color >> 8) & 0xFF)
                output.bytes[offset + 3] = UInt8(color & 0xFF)
            } else {
                output.bytes[offset] = 255
                output.bytes[offset + 1] = 255
                output.bytes[offset + 2] = 255
                output.bytes[offset + 3] = 255
            }
        }

        return UIImage(pixelBuffer: output)
    }
}

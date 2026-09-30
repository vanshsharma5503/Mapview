import UIKit

protocol ColoringImageLoading {
    func image(named name: String) -> UIImage?
}

struct ColoringImageLoader: ColoringImageLoading {
    func image(named name: String) -> UIImage? {
        UIImage(named: name)
    }
}

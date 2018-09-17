import CoreGraphics
import UIKit

/// A `UIImage` category used for vision detection.
extension UIImage {
    /// Returns a scaled image to the given size.
    ///
    /// - Parameter size: Maximum size of the returned image.
    /// - Return: Image scaled according to the give size or `nil` if image resize fails.
    public func scaledImage(withSize size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // Attempt to convert the scaled image to PNG or JPEG data to preserve the bitmap info.
        guard let image = scaledImage else { return nil }
        let imageData = UIImagePNGRepresentation(image) ??
            UIImageJPEGRepresentation(image, Constants.jpegCompressionQuality)
        return imageData.map { UIImage(data: $0) } ?? nil
    }
}

// MARK: - Constants

private enum Constants {
    static let jpegCompressionQuality: CGFloat = 0.8
}

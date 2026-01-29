//
//  UIImage+Split.swift
//  BibleStories
//
//  Utility for splitting images into left and right halves for book spread effect.
//

import UIKit

extension UIImage {
    /// Returns the left half of the image
    func leftHalf() -> UIImage? {
        guard let cgImage = self.cgImage else { return nil }

        let halfWidth = cgImage.width / 2
        let cropRect = CGRect(x: 0, y: 0, width: halfWidth, height: cgImage.height)

        guard let croppedCGImage = cgImage.cropping(to: cropRect) else { return nil }

        return UIImage(cgImage: croppedCGImage, scale: self.scale, orientation: self.imageOrientation)
    }

    /// Returns the right half of the image
    func rightHalf() -> UIImage? {
        guard let cgImage = self.cgImage else { return nil }

        let halfWidth = cgImage.width / 2
        let cropRect = CGRect(x: halfWidth, y: 0, width: cgImage.width - halfWidth, height: cgImage.height)

        guard let croppedCGImage = cgImage.cropping(to: cropRect) else { return nil }

        return UIImage(cgImage: croppedCGImage, scale: self.scale, orientation: self.imageOrientation)
    }
}

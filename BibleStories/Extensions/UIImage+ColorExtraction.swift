//
//  UIImage+ColorExtraction.swift
//  BibleStories
//
//  Extracts dominant color from image edges for spine coloring.
//

import SwiftUI
import UIKit

extension UIImage {
    /// Fallback color when extraction fails (warm brown for book spine)
    private static let fallbackSpineColor = Color(red: 0.4, green: 0.25, blue: 0.15)

    /// Darkening factor for extracted color to create spine shadow effect
    private static let spineColorDarkening: CGFloat = 0.85

    /// Extracts the average color from the left edge of the image (for book spine)
    /// - Parameter sampleWidth: Fraction of image width to sample (0.0-1.0, default 0.1 = 10%)
    /// - Returns: A slightly darkened Color suitable for book spine rendering
    func dominantColorFromLeftEdge(sampleWidth: CGFloat = 0.1) -> Color {
        // Validate and clamp sample width
        let clampedSampleWidth = min(max(sampleWidth, 0.01), 1.0)

        guard let cgImage = self.cgImage else {
            return Self.fallbackSpineColor
        }

        let width = cgImage.width
        let height = cgImage.height
        let samplePixelWidth = max(1, Int(CGFloat(width) * clampedSampleWidth))

        guard let croppedImage = cgImage.cropping(to: CGRect(x: 0, y: 0, width: samplePixelWidth, height: height)) else {
            return Self.fallbackSpineColor
        }

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue

        guard let context = CGContext(
            data: nil,
            width: 1,
            height: 1,
            bitsPerComponent: 8,
            bytesPerRow: 4,
            space: colorSpace,
            bitmapInfo: bitmapInfo
        ) else {
            return Self.fallbackSpineColor
        }

        context.draw(croppedImage, in: CGRect(x: 0, y: 0, width: 1, height: 1))

        guard let data = context.data else {
            return Self.fallbackSpineColor
        }

        let pointer = data.bindMemory(to: UInt8.self, capacity: 4)
        let r = CGFloat(pointer[0]) / 255.0
        let g = CGFloat(pointer[1]) / 255.0
        let b = CGFloat(pointer[2]) / 255.0

        return Color(
            red: r * Self.spineColorDarkening,
            green: g * Self.spineColorDarkening,
            blue: b * Self.spineColorDarkening
        )
    }
}

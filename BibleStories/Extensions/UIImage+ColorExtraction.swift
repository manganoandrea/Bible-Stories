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

    /// Extracts the dominant color from the image edges (for adaptive frame)
    /// Samples all four edges and averages the colors for a balanced frame color
    /// - Parameter sampleWidth: Fraction of image dimension to sample (default 0.1 = 10%)
    /// - Returns: A Color suitable for frame/border rendering
    func dominantColorFromEdges(sampleWidth: CGFloat = 0.1) -> Color {
        guard let cgImage = self.cgImage else {
            return Self.fallbackSpineColor
        }

        let width = cgImage.width
        let height = cgImage.height
        let samplePixelWidth = max(1, Int(CGFloat(min(width, height)) * sampleWidth))

        // Sample regions: top, bottom, left, right edges
        let regions: [CGRect] = [
            CGRect(x: 0, y: 0, width: width, height: samplePixelWidth),                    // Top
            CGRect(x: 0, y: height - samplePixelWidth, width: width, height: samplePixelWidth), // Bottom
            CGRect(x: 0, y: 0, width: samplePixelWidth, height: height),                   // Left
            CGRect(x: width - samplePixelWidth, y: 0, width: samplePixelWidth, height: height)  // Right
        ]

        var totalR: CGFloat = 0
        var totalG: CGFloat = 0
        var totalB: CGFloat = 0
        var sampleCount: CGFloat = 0

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue

        for region in regions {
            guard let croppedImage = cgImage.cropping(to: region),
                  let context = CGContext(
                    data: nil,
                    width: 1,
                    height: 1,
                    bitsPerComponent: 8,
                    bytesPerRow: 4,
                    space: colorSpace,
                    bitmapInfo: bitmapInfo
                  ) else { continue }

            context.draw(croppedImage, in: CGRect(x: 0, y: 0, width: 1, height: 1))

            guard let data = context.data else { continue }

            let pointer = data.bindMemory(to: UInt8.self, capacity: 4)
            totalR += CGFloat(pointer[0]) / 255.0
            totalG += CGFloat(pointer[1]) / 255.0
            totalB += CGFloat(pointer[2]) / 255.0
            sampleCount += 1
        }

        guard sampleCount > 0 else {
            return Self.fallbackSpineColor
        }

        // Average and slightly saturate the color for a more vibrant frame
        let avgR = totalR / sampleCount
        let avgG = totalG / sampleCount
        let avgB = totalB / sampleCount

        // Boost saturation slightly for more vibrant frames
        let maxComponent = max(avgR, avgG, avgB)
        let minComponent = min(avgR, avgG, avgB)
        let saturationBoost: CGFloat = 1.2

        let adjustedR = minComponent + (avgR - minComponent) * saturationBoost
        let adjustedG = minComponent + (avgG - minComponent) * saturationBoost
        let adjustedB = minComponent + (avgB - minComponent) * saturationBoost

        return Color(
            red: min(1.0, adjustedR),
            green: min(1.0, adjustedG),
            blue: min(1.0, adjustedB)
        )
    }
}

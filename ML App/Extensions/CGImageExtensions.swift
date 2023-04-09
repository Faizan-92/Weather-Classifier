//
//  CGImageExtensions.swift
//  ML App
//
//  Created by Faizan Memon on 09/04/23.
//

import Foundation
import CoreGraphics
import CoreVideo

extension CGImage {
    var pixelBuffer: CVPixelBuffer? {
        var pixelBuffer: CVPixelBuffer? = nil
        let options: NSDictionary = [:]

        let width =  self.width
        let height = self.height
        let bytesPerRow = self.bytesPerRow

        let dataFromImageDataProvider = CFDataCreateMutableCopy(
            kCFAllocatorDefault,
            0,
            self.dataProvider!.data
        )

        CVPixelBufferCreateWithBytes(
            kCFAllocatorDefault,
            width,
            height,
            kCVPixelFormatType_32ARGB,
            CFDataGetMutableBytePtr(dataFromImageDataProvider),
            bytesPerRow,
            nil,
            nil,
            options,
            &pixelBuffer
        )
        return pixelBuffer;
    }
}

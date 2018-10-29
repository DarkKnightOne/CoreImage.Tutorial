//
//  ViewController.swift
//  coreimage.detect.face
//
//  Created by zhang.wenhai on 2018/10/29.
//  Copyright © 2018 com.niupai. All rights reserved.
//

import UIKit
import CoreImage

class ViewController: UIViewController {
    let context = CIContext()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let image = UIImage(named: "face")!
        let ciImage = CIImage(cgImage: image.cgImage!)
        let features = testFaceDetect(inputImage: ciImage)
        
        for f in features {
            let faceFeature = f as! CIFaceFeature
            print("type:\(faceFeature.type), bounds:\(faceFeature.bounds)")
            
            let cropImage = cropFaceTest(image: ciImage, in: f.bounds)
            let cgImage = context.createCGImage(cropImage, from: cropImage.extent)
            let uiImage = UIImage(cgImage: cgImage!)
            print("")
        }
    }

}

extension ViewController {
    @discardableResult
    private func testFaceDetect(inputImage: CIImage) -> [CIFeature] {
        let opts = [CIDetectorAccuracy : CIDetectorAccuracyHigh]
        let detector = CIDetector(ofType: CIDetectorTypeFace, context: context, options: opts)
        
        guard let features = detector?.features(in: inputImage) else {
            print("Not found face in image.")
            return []
        }
        return features
    }
    
    private func cropFaceTest(image: CIImage, in rect: CGRect) -> CIImage {
        let colorFilter = CIFilter(name: "CIPhotoEffectProcess", parameters: [kCIInputImageKey:image])!
        let bloomImage = colorFilter.outputImage!.applyingFilter("CIBloom",
                                                                 parameters: [
                                                                    kCIInputRadiusKey: 10.0,
                                                                    kCIInputIntensityKey: 1.0])
        return bloomImage.cropped(to: rect)
    }
}

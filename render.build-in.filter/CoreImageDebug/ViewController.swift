//
//  ViewController.swift
//  CoreImageDebug
//
//  Created by zhang.wenhai on 2018/10/23.
//  Copyright © 2018 com.niupai. All rights reserved.
//

import UIKit
import CoreImage
import GLKit
import OpenGLES.ES2

private let USEGLKVIEWRENDER = true

class ViewController: UIViewController {
    private var imageView = UIImageView()
    private var brightnessFilter: CIFilter?
    private var inputImage: CIImage!
    private let eaglContext = EAGLContext(api: .openGLES2)!
    private lazy var context = CIContext(eaglContext: eaglContext)
    
    private let slider = UISlider()

    private var glkView: GLKView?
    private var glkViewDrawableRect: CGRect!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 读取CIImage
        let imgPath = Bundle.main.path(forResource: "IMG_6876", ofType: "JPG")!
        let inputImage = CIImage(contentsOf: URL(fileURLWithPath: imgPath))!
        self.inputImage = inputImage
        
        // 创建CIFilter
        let filter = CIFilter.init(name: "CIColorControls")!
        // 设置InputImage
        filter.setValue(inputImage, forKey: kCIInputImageKey)
        // 设置亮度
        filter.setValue(0.3, forKey: kCIInputBrightnessKey)
        self.brightnessFilter = filter
        
        // 设置ImageView
        if USEGLKVIEWRENDER {
            let imgSize = CGSize(width: 3024.0, height: 4032.0)
            let glkViewHeight: CGFloat = imgSize.height * self.view.bounds.width / imgSize.width
            let glkViewSize = CGSize(width: self.view.bounds.width, height: glkViewHeight)
            let glkViewPos = CGPoint(x: 0, y: (self.view.bounds.height - glkViewHeight) / 2.0)

            let glkView = GLKView(frame: CGRect(origin: glkViewPos, size: glkViewSize), context: eaglContext)
            self.glkView = glkView
            self.view.addSubview(glkView)
            glkView.bindDrawable()
            
            glkViewDrawableRect = CGRect(origin: .zero, size: CGSize(width: glkView.drawableWidth, height: glkView.drawableHeight))
            context.draw(filter.outputImage!, in: glkViewDrawableRect, from: inputImage.extent)
            glkView.display()
            
            view.addSubview(slider)
            slider.frame = CGRect(x: 20, y: 40, width: view.bounds.width - 40, height: 60)
            slider.value = 0.3
            slider.minimumValue = -1.0
            slider.maximumValue = 1.0
            slider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
        }
        else {
            view.addSubview(imageView)
            imageView.frame = view.bounds
            imageView.contentMode = .scaleAspectFit
            
            // 读取OutputImage
            guard let outputImage = filter.outputImage else {
                return
            }
            // 将OutputImage转换为UIImage
            let cgImage = context.createCGImage(outputImage, from: inputImage.extent)
            let uiImage = UIImage(cgImage: cgImage!)
            imageView.image = uiImage
        }
    }
    
    @objc private func sliderValueChanged(_ sender: UISlider) {
        print("slider: \(sender.value)")
        brightnessFilter?.setValue(sender.value, forKey: kCIInputBrightnessKey)
        if let outputImage = brightnessFilter?.outputImage {
            context.draw(outputImage, in: glkViewDrawableRect, from: inputImage.extent)
            glkView?.display()
        }
    }
}



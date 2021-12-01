//
//  ViewController.swift
//  DaltoPipette
//
//  Created by Cyril Leblanc & Claire Bonnard on 18/11/2021.
//

import UIKit

//classe pixel
class Pixel {
    var r: Int
    var g: Int
    var b: Int
    
    init(r: UInt8, g: UInt8, b: UInt8) {
        self.r = Int(r)
        self.g = Int(g)
        self.b = Int(b)
    }

    var couleur = [ "rouge": [255, 0, 0],
                    "bleu": [0, 0, 255],
                    "vert": [0, 255, 0],
                    "brun": [91, 60, 17],
                    "orange": [237, 127, 16],
                    "rose": [253, 108, 158],
                    "marron": [141, 64, 36],
                    "lavande": [150, 131, 236],
                    "turquoise": [37, 253, 233],
                    "fushia": [253, 63, 146],
                    "vert kaki": [121, 137, 51],
                    "bleu canard": [4, 139, 154],
                    "sable": [255, 203, 96],
                    "azur": [0, 127, 255],
                    "vert pomme": [159, 232, 85],
                    "jaune": [255, 255, 0],
                    "violet": [102, 0, 153],
                    "vert argile": [131, 166, 151]
                    ]
    
    func dico() -> String {
        var color: String = "none"
        if r >= 230 && g >= 230 && b >= 230 {
            color = "blanc"
        }
        else if r <= 70 && g <= 70 && b <= 70 || r+g+b <= 80 {
            color = "noir"
        }
        else if abs(r-g) <= 10 && abs(r-b) <= 10 {
            color = "gris"
            let moy = r + g + b
            if moy > 558 {
                color = color + " clair"
            }
            else if moy < 309 {
                color = color + " foncé"
            }
        }
        else {
            var min = 765
            for (key, codeRGB) in couleur {
                for _ in couleur {
                    let diff = abs(r - codeRGB[0]) + abs(g - codeRGB[1]) + abs(b - codeRGB[2])
                    if diff < min {
                        color = key
                        min = diff
                    }
                }
            }
        }
        return color
    }
    func getR() -> CGFloat {
        var red: CGFloat
        red = CGFloat(r) / 255
        return red
    }
    func getG() -> CGFloat {
        var green: CGFloat
        green = CGFloat(g) / 255
        return green
    }
    func getB() -> CGFloat {
        var blue: CGFloat
        blue = CGFloat(b) / 255
        return blue
    }

}


// ACCUEIL
class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func choosePicture() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        self.present(imagePicker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let image = info[.originalImage] as! UIImage
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
            
            
            // Go to next view controller "Page Pipette"
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let nextVC = storyboard.instantiateViewController(withIdentifier: "ViewControllerPipette") as! ViewControllerPipette
            nextVC.image = image
            self.navigationController?.pushViewController(nextVC, animated: true)
        }
    }
    
}



// PIPETTE
class ViewControllerPipette: UIViewController{
    
    var image: UIImage!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var colorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(getPixel(sender:)))
        tap.numberOfTapsRequired = 1
        view.addGestureRecognizer(tap)
    }
    
    @IBAction func retour(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func zone(_ sender: Any) {
        print("zone")
    }
    @IBAction func point(_ sender: Any) {
        print("point")
    }
    
    @objc func getPixel(sender: UITapGestureRecognizer){
        let touchPoint = sender.location(in: self.imageView)
        
        let colorResult = self.imageView.image?.cgImage?.colors(p: CGPoint(x: touchPoint.x, y: touchPoint.y))
        
        print(colorResult, Pixel(r: UInt8(colorResult!.red), g: UInt8(colorResult!.green), b: UInt8(colorResult!.blue)).dico())
        
        let pix: Pixel = Pixel(r: UInt8(colorResult!.red), g: UInt8(colorResult!.green), b: UInt8(colorResult!.blue))
        
        self.colorLabel.text = pix.dico()
        
        
        self.colorLabel.backgroundColor = UIColor.init(red: pix.getR(), green: pix.getG(), blue: pix.getB(), alpha: 1)
        
        let DynamicView = UIView(frame: CGRect(x: self.imageView.frame.origin.x + touchPoint.x, y: self.imageView.frame.origin.y + touchPoint.y, width: 5, height: 5))
        DynamicView.layer.cornerRadius = 2.5
        DynamicView.layer.borderWidth = 2.5
        //self.view.addSubview(DynamicView)
    }
}
extension UIImage {
    func getPixelColor(pos: CGPoint) -> Pixel {
        
        let pixelData = self.cgImage!.dataProvider!.data
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        
        let pixelInfo: Int = ((Int(pos.y)) * Int(pos.x)) * 4
        
        return Pixel(r: data[pixelInfo], g: data[pixelInfo+1], b: data[pixelInfo+2])
    }
}

extension CGImage {
    func colors(p: CGPoint) -> (red: Int, green: Int, blue: Int)? {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let bitsPerComponent = 8
        let bitmapInfo: UInt32 = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue

        guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo),
            let ptr = context.data?.assumingMemoryBound(to: UInt8.self) else {
            return nil
        }

        context.draw(self, in: CGRect(x: 0, y: 0, width: width, height: height))

        let i = bytesPerRow * Int(p.y) + bytesPerPixel * Int(p.x)
        
        let r = (Int(ptr[i]))
        let g = (Int(ptr[i + 1]))
        let b = (Int(ptr[i + 2]))
        
        return (red: r, green: g, blue: b)
    }
}

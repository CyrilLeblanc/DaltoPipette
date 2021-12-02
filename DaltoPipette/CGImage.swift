//
//  CGImage.swift
//  DaltoPipette
//
//  Created by Claire Bonnard on 02/12/2021.
//

import UIKit


extension CGImage {
    
    // renvoie le code rgb pour une position XY
    func getColorAt(x: CGFloat, y: CGFloat) -> (red: Int, green: Int, blue: Int)? {
        return self.getColorAt(i: 4 * width * Int(y) + 4 * Int(x))
    }
    
    // renvoie la couleur en fonction de son index dans le tableau de CGColor
    func getColorAt(i: Int) -> (red: Int, green: Int, blue: Int)? {
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
        
        let r = (Int(ptr[i]))
        let g = (Int(ptr[i + 1]))
        let b = (Int(ptr[i + 2]))
        
        return (red: r, green: g, blue: b)
    }
    
    // renvoie 3 tableaux contenant les RGBs de la zone à rogner
    func crop(zone: CGRect) -> (red: Array<Int>, green: Array<Int>, blue: Array<Int>)?
    {
        var red: Array<Int> = []
        var green: Array<Int> = []
        var blue: Array<Int> = []
        
        var i: CLong = 0
        
        while i < 194000 {
            //        for i in 0...960000 {
            //        for i in 0...(height * width){
            let iHeight: Int = Int(i) / width
            let iWidth: Int = Int(i) / height
            print(i)
            if (iHeight >= Int(zone.minY) && iHeight <= Int(zone.maxY) && iWidth >= Int(zone.minX) && iWidth <= Int(zone.maxX)){
                print(iHeight, ">=", Int(zone.minY), iHeight, "<=", Int(zone.maxY), iWidth, ">=", Int(zone.minX), iWidth, "<=", Int(zone.maxX))
                let color = getColorAt(i: Int(i))
                
                red.append(color!.red)
                green.append(color!.green)
                blue.append(color!.blue)
            }
            i += 1
        }
        return (red: red, green: green, blue: blue)
    }
}

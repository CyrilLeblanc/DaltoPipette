//
//  Pixel.swift
//  DaltoPipette
//
//  Created by Claire Bonnard on 02/12/2021.
//

import UIKit

//classe pixel
class Pixel {
    var r: Int
    var g: Int
    var b: Int
    
    
    //on prend en argument de classe des UInt8 il converti tout seul en Int
    init(r: UInt8, g: UInt8, b: UInt8) {
        self.r = Int(r)
        self.g = Int(g)
        self.b = Int(b)
    }
    
    //Dictionnaire des couleurs reconnaissables
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
    
    //methode à appeler pour rendre le nom de la couleur
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

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


// ACCUEIL
class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var selectPicture: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //censé faire des bords arrondis au bouton de selection de l'image (mais ça ne fonctionne pas...) :'(
        self.selectPicture?.layer.cornerRadius = 10
        self.selectPicture?.clipsToBounds = true
    }
    
    
    //Permet d'afficher le sélecteur d'image depuis la galerie
    @IBAction func choosePicture() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        self.present(imagePicker, animated: true)
    }
    
    
    //récupère l'image et passe à la page suivante ! :)
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
    var mode: String!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var colorLabel: UILabel!
    @IBOutlet weak var zoneButton: UIImageView!
    @IBOutlet weak var pipetteButton: UIImageView!
    var tap1: CGPoint!
    var tap2: CGPoint!
    
    
    //données initiales de la page dont l'image transférée depuis la page précédente
    override func viewDidLoad() {
        super.viewDidLoad()
        mode = "pipette"
        pipetteButton.isHighlighted = true
        imageView.image = image
        
        //tap la position où l'on clique sur l'image
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleClick(sender:)))
        tap.numberOfTapsRequired = 1
        view.addGestureRecognizer(tap)
    }
    
    //retour à la page accueil/précédente
    @IBAction func retour(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func zone(_ sender: Any) {
        pipetteButton.isHighlighted = false
        zoneButton.isHighlighted = true;
        mode = "zone"
        
        image.cgImage?.cropping(to: CGRect(x: 10, y: 10, width: 50, height: 50))
        
    }
    @IBAction func point(_ sender: Any) {
        pipetteButton.isHighlighted = true
        zoneButton.isHighlighted = false;
        mode = "pipette"
    }
    
    func setDetectedColor(name: String, pixel: Pixel){
        //écrit le nom de la couleur dans le label
        self.colorLabel.text = name
        //remplace le fond du label par la couleur détectée
        self.colorLabel.backgroundColor = UIColor.init(red: pixel.getR(), green: pixel.getG(), blue: pixel.getB(), alpha: 1)
    }
    
    // gère le click sur l'image
    @objc func handleClick(sender: UITapGestureRecognizer){
        let touchPoint = sender.location(in: self.imageView)
        if (mode == "pipette"){
            // ==== Dans le mode PIPETTE
            
            let colorResult = self.imageView.image?.cgImage?.colors(p: CGPoint(x: touchPoint.x, y: touchPoint.y))
            let pix: Pixel = Pixel(r: UInt8(colorResult!.red), g: UInt8(colorResult!.green), b: UInt8(colorResult!.blue))
            
            // met à jour l'affichage en mettant le nom de la couleur
            self.setDetectedColor(name: pix.dico(), pixel: pix)
            
            //DynamicView affiche un point noir où l'on clique
            let DynamicView = UIView(frame: CGRect(x: self.imageView.frame.origin.x + touchPoint.x, y: self.imageView.frame.origin.y + touchPoint.y, width: 5, height: 5))
            DynamicView.layer.cornerRadius = 2.5
            DynamicView.layer.borderWidth = 2.5
            //self.view.addSubview(DynamicView)
        } else if (mode == "zone"){
            // === Dans le mode ZONE
            if (tap1 == nil){
                // Pour le premier point
                tap1 = CGPoint(x: touchPoint.x, y: touchPoint.y)
            } else {
                // Pour le second point
                tap2 = CGPoint(x: touchPoint.x, y: touchPoint.y)
                print("pt1 : ", tap1.x, tap1.y, "\tpt2:", tap2.x, tap2.y)
                
                // TODO : récupérer la zone définie et récupérer la couleur moyenne pour l'afficher avec la méthode setDetectedColor()
                
                // créer le tableau de CGColor pour la zone donnée
                var nbColor: Int = 0
                
                // déterminer la moyenne
                
                tap1 = nil
                tap2 = nil
            }
        }
    }
}

extension CGImage {
    
    //renvoie le code rgb pour une position (CGPoint donnée)
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

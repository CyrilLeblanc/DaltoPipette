//
//  ViewControllerPipette.swift
//  DaltoPipette
//
//  Created by Claire Bonnard on 02/12/2021.
//

import UIKit
import AVFoundation

// PIPETTE
class ViewControllerPipette: UIViewController, AVSpeechSynthesizerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var image: UIImage!
    var mode: String!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var colorLabel: UILabel!
    @IBOutlet weak var zoneButton: UIImageView!
    @IBOutlet weak var pipetteButton: UIImageView!
    var tap1: CGPoint!
    var tap2: CGPoint!
    let synthesizer = AVSpeechSynthesizer()
    
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
    
    //Sélectionner une nouvelle image
    @IBAction func selectionImage(_sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        self.present(imagePicker, animated: true)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
            let image = info[.originalImage] as! UIImage
            self.imageView.image = image
        }
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
    
    func setDetectedColor(pixel: Pixel){
        //écrit le nom de la couleur dans le label
        self.colorLabel.text = pixel.dico()
        //remplace le fond du label par la couleur détectée
        self.colorLabel.backgroundColor = UIColor.init(red: pixel.getR(), green: pixel.getG(), blue: pixel.getB(), alpha: 1)
        
        let utterance = AVSpeechUtterance(string: pixel.dico())
        utterance.voice = AVSpeechSynthesisVoice(language: "fr-FR")
        synthesizer.speak(utterance)
    }
    
    // gère le click sur l'image
    @objc func handleClick(sender: UITapGestureRecognizer){
        let touchPoint = sender.location(in: self.imageView)
        if (mode == "pipette"){
            // ==== Dans le mode PIPETTE
            
            let colorResult = self.imageView.image?.cgImage?.getColorAt(x: touchPoint.x, y: touchPoint.y)
            let pix: Pixel = Pixel(r: UInt8(colorResult!.red), g: UInt8(colorResult!.green), b: UInt8(colorResult!.blue))
            
            // met à jour l'affichage en mettant le nom de la couleur
            self.setDetectedColor(pixel: pix)
            
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
                // créer le tableau de RGB pour la zone donnée
                let colors = image.cgImage?.crop(zone: CGRect(x: tap1.x, y: tap1.y, width: (tap2.x - tap1.x), height: (tap2.y - tap1.y)))
                print("test")
                setDetectedColor(pixel: Pixel(r: UInt8(AverageColor(colors: colors!.red)), g: UInt8(AverageColor(colors: colors!.green)), b: UInt8(AverageColor(colors: colors!.blue))))
                
                // déterminer la moyenne
                tap1 = nil
                tap2 = nil
            }
        }
    }
    
    func AverageColor(colors: Array<Int>) -> Int{
        var sum = 0
        for color in colors{
            sum += color
        }
        return Int(sum / (colors.count + 1))
    }
    
    
}

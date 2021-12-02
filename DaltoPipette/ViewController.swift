//
//  ViewController.swift
//  DaltoPipette
//
//  Created by Cyril Leblanc & Claire Bonnard on 18/11/2021.
//

import UIKit

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





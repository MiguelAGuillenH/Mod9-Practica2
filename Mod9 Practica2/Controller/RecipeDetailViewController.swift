//
//  RecipeDetailViewController.swift
//  Mod9 Practica2
//
//  Created by MAGH on 04/07/24.
//

import UIKit

class RecipeDetailViewController: UIViewController {
    
    //UI Variables
    @IBOutlet weak var recipeImage: UIImageView!
    @IBOutlet weak var recipeName: UILabel!
    @IBOutlet weak var recipeIngredients: UILabel!
    @IBOutlet weak var recipeDirections: UILabel!
    
    //Recipe shown
    var recipe: Recipe?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Background
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame.size = view.frame.size
        gradientLayer.colors = [UIColor(named: "AccentColor")!.withAlphaComponent(0.0).cgColor, UIColor(named: "AccentColor")!.cgColor]
        view.layer.insertSublayer(gradientLayer, at: 0)

        if (recipe != nil){
            recipeName.text = recipe!.name
            recipeIngredients.text = recipe!.ingredients
            recipeDirections.text = recipe!.directions
            
            if let libraryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let fileUrl = libraryUrl.appending(path: recipe!.img)
                recipeImage.image = UIImage(contentsOfFile: fileUrl.path())
            }
        }
    }

}

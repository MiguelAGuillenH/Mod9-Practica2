//
//  AddRecipeViewController.swift
//  Mod9 Practica2
//
//  Created by MAGH on 06/07/24.
//

import UIKit

class AddRecipeViewController: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    //UI Variables
    @IBOutlet weak var recipeName: UITextField!
    @IBOutlet weak var recipeIngredients: UITextView!
    @IBOutlet weak var recipeDirections: UITextView!
    @IBOutlet weak var recipeImage: UIImageView!
    @IBOutlet weak var saveButton: UIButton!
    
    //Recipe
    var newRecipe: Recipe?
    
    //Image Picker
    var ipc: UIImagePickerController!
    var imageName: String!
    var dateFormatter: DateFormatter!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //UI Configuration
        recipeName.becomeFirstResponder()
        recipeIngredients.delegate = self
        recipeDirections.delegate = self
        
        //Date formatter configuration
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd_HHmmss"
    }
    
    //MARK: UI Events
    
    @IBAction func recipeNameChanged(_ sender: UITextField) {
        saveButton.isEnabled = validateFields()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        saveButton.isEnabled = validateFields()
    }
    
    @IBAction func cameraButtonTapped(_ sender: UIButton) {
        ipc = UIImagePickerController()
        ipc.delegate = self
        ipc.sourceType = .photoLibrary
        ipc.allowsEditing = true
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            //Damos al usuario la opción de elegir entre la cámara y la librería
            let alert = UIAlertController(title: "Origen de la foto", message: "Desea obtener la imagen a través de...", preferredStyle: .alert)
            let action1 = UIAlertAction(title: "Cámara", style: .default) { alertAction in
                self.ipc.sourceType = .camera
                self.present(self.ipc, animated: true)
            }
            let action2 = UIAlertAction(title: "Galería", style: .cancel) { alertAction in
                self.present(self.ipc, animated: true)
            }
            alert.addAction(action1)
            alert.addAction(action2)
            
            self.present(alert, animated: true)
        } else {
            self.present(ipc, animated: true)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let imagen = info[.editedImage] as? UIImage {
            recipeImage.image = imagen
        }
        picker.dismiss(animated: true)
        saveButton.isEnabled = validateFields()
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    //MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if type(of: segue.destination) == RecipesViewController.self {
            saveImage(recipeImage.image!)
            newRecipe = Recipe(
                directions: recipeDirections.text,
                ingredients: recipeIngredients.text,
                name: recipeName.text!,
                img: imageName
            )
        }
    }
    
    //MARK: Custom functions
    
    func validateFields() -> Bool {
        return !(recipeName.text!.trim().isEmpty) &&
            !(recipeIngredients.text.trim().isEmpty) &&
            !(recipeDirections.text.trim().isEmpty) &&
            recipeImage.image != UIImage(systemName: "photo")
    }
    
    func saveImage(_ img: UIImage) {
        if let libraryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            imageName = "Drink_\(dateFormatter.string(from: Date.now)).jpg"
            let fileUrl = libraryUrl.appending(path: imageName)
            let bytes = img.jpegData(compressionQuality: 0.5)
            do {
                try bytes?.write(to: fileUrl, options: .atomic)
            } catch {
                showErrorAlert(message: "Error al almacenar imagen.\n\(error.localizedDescription)", buttonTitle: "Reintentar") {_ in
                    self.saveImage(img)
                }
            }
        }
    }
    
}

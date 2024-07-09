//
//  ViewController.swift
//  Mod9 Practica2
//
//  Created by DISMOV on 01/07/24.
//

import UIKit

class RecipesViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    //UI Variables
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var recipesListView: UICollectionView!
    @IBOutlet var emptyRecipesView: UIView!
    
    //Internet Monitor
    let internetMonitor = InternetMonitor()
    
    //Recipes variables
    var recipesManager: RecipesManager?
    var currentRecipe: Recipe?
    
    //Constants for JSON file download and storage
    let jsonDownloadUrlString = "http://janzelaznog.com/DDAM/iOS/drinks.json"
    var libraryUrl: URL!
    var jsonFileUrl: URL!

    //MARK: ViewController Events
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //Set up CollectionView
        recipesListView.dataSource = self
        recipesListView.delegate = self
        
        //Obtain JSON file URL
        jsonFileConfig()
        
        //Download file if it doesn't exist, otherwise get recipes
        if !FileManager().fileExists(atPath: jsonFileUrl.path) {
            downloadJsonFile()
        } else {
            getRecipes()
        }
        
    }
    
    //MARK: CollectionView functions
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        recipesManager?.countRecipes() ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? RecipeCell
        if recipesManager != nil {
            let recipe = recipesManager!.getRecipe(at: indexPath.row)
            cell?.recipeName.text = recipe.name
            
            //Background
            let backgroundView = UIView()
            let gradientLayer = CAGradientLayer()
            gradientLayer.frame.size = cell!.frame.size
            gradientLayer.colors = [UIColor(named: "AccentColor")!.withAlphaComponent(0.0).cgColor, UIColor(named: "AccentColor")!.cgColor]
            backgroundView.layer.addSublayer(gradientLayer)
            cell?.backgroundView = backgroundView
            //cell?.layer.borderColor = UIColor.gray.cgColor
            //cell?.layer.borderWidth = 1
            
            //Image
            let imageFileUrl = libraryUrl.appendingPathComponent(recipe.img)
            if FileManager().fileExists(atPath: imageFileUrl.path) {
                cell?.recipeImage.image = UIImage(contentsOfFile: imageFileUrl.path())
            } else {
                downloadRecipeImage(recipe.img){
                    cell?.recipeImage.image = UIImage(contentsOfFile: imageFileUrl.path())
                }
            }
        }
        
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        currentRecipe = recipesManager!.getRecipe(at: indexPath.row)
        performSegue(withIdentifier: "showRecipeSegue", sender: self)
    }
    
    //MARK: UI Events
    
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "addRecipeSegue", sender: self)
    }
    
    //MARK: Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showRecipeSegue"{
            let destination = segue.destination as! RecipeDetailViewController
            destination.recipe = currentRecipe
        }
    }
    
    //Unwind segue
    @IBAction func saveButtonUnwindToRecipesViewController(_ segue: UIStoryboardSegue) {
        let source = segue.source as! AddRecipeViewController
        if let newRecipe = source.newRecipe {
            recipesManager?.createRecipe(newRecipe)
            recipesManager?.saveRecipes()
            
            //Reload table view
            recipesListView.reloadData()
            updateUI()
        }
    }

    //MARK: Custom functions
    
    func jsonFileConfig() {
        do {
            if let url = URL(string: jsonDownloadUrlString) {
                libraryUrl = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                jsonFileUrl = libraryUrl.appendingPathComponent(url.lastPathComponent)
            }
        } catch {
            self.showErrorAlert(message: "Ocurrió un error al obtener dirección del archivo.\n\(error.localizedDescription)", buttonTitle: "Reintentar") { buttonAction in
                self.jsonFileConfig()
            }
        }
    }
    
    func downloadJsonFile() {
        if internetMonitor.isConnected { //&& internetMonitor.connType == "Wi-Fi"
            if let url = URL(string: jsonDownloadUrlString) {
                activityIndicatorView.startAnimating()
                
                let request = URLRequest(url: url)
                let session = URLSession(configuration: URLSessionConfiguration.ephemeral)
                let task = session.dataTask(with: request) { data, response, error in
                    DispatchQueue.main.async {
                        self.activityIndicatorView.stopAnimating()
                        
                        if error != nil {
                            self.showErrorAlert(message: "Ocurrió un error al descargar el archivo.\n\(error!.localizedDescription)", buttonTitle: "Reintentar") { buttonAction in
                                self.downloadJsonFile()
                            }
                        } else if data == nil {
                            self.showErrorAlert(message: "Ocurrió un error al descargar el archivo.", buttonTitle: "Reintentar") { buttonAction in
                                self.downloadJsonFile()
                            }
                        } else {
                            //Save file
                            self.saveJsonFile(data!)
                            
                            //If successful, get recipes
                            if FileManager().fileExists(atPath: self.jsonFileUrl.path) {
                                self.getRecipes()
                            }
                        }
                    }
                }
                task.resume()
            }
        } else {
            showErrorAlert(message: "Se requiere una conexión a Internet via Wi-Fi para continuar.", buttonTitle: "Reintentar") { buttonAction in
                self.downloadJsonFile()
            }
        }
    }
    
    func saveJsonFile(_ data: Data) {
        do {
            try data.write(to: jsonFileUrl)
        } catch {
            self.showErrorAlert(message: "Ocurrió un error al guardar el archivo.\n\(error.localizedDescription)", buttonTitle: "Reintentar") { buttonAction in
                self.saveJsonFile(data)
            }
        }
    }
    
    func getRecipes() {
        recipesManager = RecipesManager(jsonFileUrl)
        recipesManager!.loadRecipes()
        recipesListView.reloadData()
        updateUI()
    }
    
    func updateUI() {
        if recipesManager!.countRecipes() == 0 {
            emptyRecipesView.isHidden = false
            recipesListView.backgroundView = emptyRecipesView
        }else{
            emptyRecipesView.isHidden = true
        }
    }
    
    func downloadRecipeImage(_ img: String, completion: (() -> Void)?) {
        if internetMonitor.isConnected { //&& internetMonitor.connType == "Wi-Fi"
            let imageDownloadUrlString = "http://janzelaznog.com/DDAM/iOS/drinksimages/" + img
            if let url = URL(string: imageDownloadUrlString) {
                let request = URLRequest(url: url)
                let session = URLSession(configuration: URLSessionConfiguration.ephemeral)
                let task = session.dataTask(with: request) { data, response, error in
                    DispatchQueue.main.async {
                        if error != nil {
                            self.showErrorAlert(message: "Ocurrió un error al descargar la imagen.\n\(error!.localizedDescription)", buttonTitle: "Reintentar") { buttonAction in
                                self.downloadRecipeImage(img, completion: completion)
                            }
                        } else if data == nil {
                            self.showErrorAlert(message: "Ocurrió un error al descargar la imagen.", buttonTitle: "Reintentar") { buttonAction in
                                self.downloadRecipeImage(img, completion: completion)
                            }
                        } else {
                            //Save file
                            self.saveRecipeImage(img: img, data: data!, completion: completion)
                        }
                    }
                }
                task.resume()
            }
        } else {
            showErrorAlert(message: "Se requiere una conexión a Internet via Wi-Fi para continuar.", buttonTitle: "Reintentar") { buttonAction in
                self.downloadRecipeImage(img, completion: completion)
            }
        }
    }
    
    func saveRecipeImage(img: String, data: Data, completion: (() -> Void)?) {
        let imageFileUrl = libraryUrl.appendingPathComponent(img)
        do {
            try data.write(to: imageFileUrl)
        } catch {
            self.showErrorAlert(message: "Ocurrió un error al guardar la imagen.\n\(error.localizedDescription)", buttonTitle: "Reintentar") { buttonAction in
                self.saveRecipeImage(img: img, data: data, completion: completion)
            }
        }
        
        //If successful, call completion
        if FileManager().fileExists(atPath: imageFileUrl.path) {
            if completion != nil {
                completion!()
            }
        }
    }

}


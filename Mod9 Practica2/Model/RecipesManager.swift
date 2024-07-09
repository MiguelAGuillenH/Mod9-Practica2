//
//  RecipesManager.swift
//  Mod9 Practica2
//
//  Created by DISMOV on 03/07/24.
//

import Foundation

class RecipesManager {
    
    private var recipes: [Recipe] = []
    private var fileUrl: URL
    
    init(_ jsonFileUrl: URL) {
        self.fileUrl = jsonFileUrl
    }
    
    func createRecipe(_ recipe: Recipe) {
        recipes.append(recipe)
    }
    
    func deleteRecipe(at index: Int) {
        recipes.remove(at: index)
    }
    
    func getRecipes() -> [Recipe] {
        return recipes
    }
    
    func getRecipe(at index: Int) -> Recipe {
        return recipes[index]
    }
    
    func countRecipes() -> Int {
        return recipes.count
    }
    
    func saveRecipes() {
        do {
            let jsonData = try JSONEncoder().encode(recipes)
            FileManager.default.createFile(atPath: fileUrl.path(), contents: jsonData)
        }catch let error {
            print("Error al guardar drinks.json. ", error.localizedDescription)
        }
    }
    
    func loadRecipes() {
        if (FileManager.default.fileExists(atPath: fileUrl.path())) {
            do{
                let jsonData = FileManager.default.contents(atPath: fileUrl.path())
                recipes = try JSONDecoder().decode([Recipe].self, from: jsonData!)
            }catch let error{
                print("Error al leer drinks.json. ",error)
            }
        }else{
            print("El archivo drinks.json no existe.")
        }
            
        
    }
    
}

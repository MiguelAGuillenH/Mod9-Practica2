//
//  ViewControllerExtension.swift
//  Mod9 Practica2
//
//  Created by MAGH on 01/07/24.
//

import Foundation
import UIKit

extension UIViewController {
    
    func showErrorAlert(message: String, buttonTitle: String, buttonAction: ((UIAlertAction) -> Void)?) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let ac1 = UIAlertAction(title: buttonTitle, style: .default, handler: buttonAction)
        alert.addAction(ac1)
        self.present(alert, animated: true)
    }
    
}

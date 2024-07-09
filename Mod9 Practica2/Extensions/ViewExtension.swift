//
//  ViewExtension.swift
//  Mod9 Practica2
//
//  Created by MAGH on 06/07/24.
//

import Foundation
import UIKit

public extension UIView {
    
    @IBInspectable var cornerRadius: CGFloat {
        set { layer.cornerRadius = newValue }
        get { layer.cornerRadius }
    }
    
    @IBInspectable var masksToBounds: Bool {
        set { layer.masksToBounds = newValue }
        get { layer.masksToBounds }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        set { layer.borderWidth = newValue }
        get { layer.borderWidth }
    }
    
    @IBInspectable var borderColor: UIColor? {
        set { layer.borderColor = newValue?.cgColor }
        get { layer.borderColor?.UIColor }
    }
    
}

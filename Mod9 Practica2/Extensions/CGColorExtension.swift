//
//  CGColorExtension.swift
//  Notas2
//
//  Created by MAGH on 23/04/24.
//

import Foundation
import UIKit

public extension CGColor {
    var UIColor: UIKit.UIColor {
        return UIKit.UIColor(cgColor: self)
    }
}

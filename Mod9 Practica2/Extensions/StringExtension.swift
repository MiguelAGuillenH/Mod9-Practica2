//
//  StringExtension.swift
//  Notas2
//
//  Created by MAGH on 24/04/24.
//

import Foundation

public extension String {
    func trim() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

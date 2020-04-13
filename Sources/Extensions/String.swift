//
//  String.swift
//  
//
//  Created by Alsey Coleman Miller on 4/12/20.
//

import Foundation

internal extension String {
    
    func begins(with other: String) -> Bool {
        guard let range = self.range(of: other)
            else { return false }
        return range.lowerBound == self.startIndex
    }
    
    func ends(with other: String) -> Bool {
        guard let range = self.range(of: other)
            else { return false }
        return range.upperBound == self.endIndex
    }
}

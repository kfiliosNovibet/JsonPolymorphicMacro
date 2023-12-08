//
//  File.swift
//  
//
//  Created by Kostas Filios on 8/12/23.
//

import Foundation

public final class ExtraCustomCodingKey {
    let paramName: String
    let paramCodingKey: String
    let type: Decodable.Type
    
    public init(paramName: String, paramCodingKey: String, type: Decodable.Type) {
        self.paramName = paramName
        self.paramCodingKey = paramCodingKey
        self.type = type
    }
    
}

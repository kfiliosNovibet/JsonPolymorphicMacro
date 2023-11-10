//
//  JsonPolymorphicTypeData.swift
//
//
//  Created by Kostas Filios on 10/11/23.
//

import Foundation

public final class JsonPolymorphicTypeData<T> {
    let polyMorphickey: String
    let polyMorphicContent: String
    let decodingTypes: [String: Decodable.Type]
    let decodableType: T.Type
    
    public init(key: String, polyVarName: String, decodableParentType: T.Type, decodingTypes: [String : Decodable.Type]) {
        self.polyMorphickey = key
        self.polyMorphicContent = polyVarName
        self.decodingTypes = decodingTypes
        self.decodableType = decodableParentType
    }
    
}

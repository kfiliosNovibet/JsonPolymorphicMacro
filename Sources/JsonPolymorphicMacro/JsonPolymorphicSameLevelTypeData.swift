//
//  JsonPolymorphicSameLevelTypeData.swift
//
//
//  Created by Kostas Filios on 30/11/23.
//

import Foundation

public final class JsonPolymorphicSameLevelTypeData<T> {
    let polyMorphickey: String
    let dummyDecoder: Decodable.Type
    let polyMorphicContent: String
    let decodingTypes: [String: Decodable.Type]
    let decodableType: T.Type
    
    public init(key: String, dummyDecoder: Decodable.Type, polyVarName: String, decodableParentType: T.Type, decodingTypes: [String : Decodable.Type]) {
        self.dummyDecoder = dummyDecoder
        self.polyMorphickey = key
        self.polyMorphicContent = polyVarName
        self.decodingTypes = decodingTypes
        self.decodableType = decodableParentType
    }
    
}

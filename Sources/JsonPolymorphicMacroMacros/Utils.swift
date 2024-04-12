//
//  File.swift
//  
//
//  Created by Kostas Filios on 30/10/23.
//

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

enum DataClassTypes: String {
    case jsonPolymorphicTypeData = "JsonPolymorphicTypeData"
    case jsonPolymorphicSameLevelTypeData = "JsonPolymorphicSameLevelTypeData"
    
}

public typealias ExtraCustomCodingKeys = (paramName: String, paramCodingKey: String, type: String)

typealias PolyData = (data: [String:[String:[String:String]]], decodableParentTypeInst: String, 
                      decodableDataType: String, polyVarName: String, isDummyArray: Bool, extraCodingKeys: [ExtraCustomCodingKeys])

final class Utils {
    static func decodeExpansion(
        of attribute: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) -> [PolyData]? {
        guard case let .argumentList(arguments) = attribute.arguments
        else {
            context.diagnose(JsonPolymorphicMacroDiagnostic.noArgument.diagnose(at: attribute))
            return nil
        }
        var isTupleClassed = false
        guard let args = arguments.as(LabeledExprListSyntax.self)?.first?.expression.as(TupleExprSyntax.self) else {
            context.diagnose(JsonPolymorphicMacroDiagnostic.generic(message: "JsonPolymorphicKeys needs tuple input, please check parentheses").diagnose(at: attribute))
            return nil
        }
        let className = getClassDataName(of: args, attachedTo: declaration, in: context)
        switch (className) {
        case DataClassTypes.jsonPolymorphicTypeData.rawValue, DataClassTypes.jsonPolymorphicSameLevelTypeData.rawValue:
            isTupleClassed = true
        default :
            isTupleClassed = false
        }
        
        //            context.diagnose(CodingKeysMacroDiagnostic.invalidArgument.diagnose(at: attribute))
        if  isTupleClassed {
            switch (className) {
            case DataClassTypes.jsonPolymorphicTypeData.rawValue:
                return handleClass(of: args, attachedTo: declaration, in: context)
            case DataClassTypes.jsonPolymorphicSameLevelTypeData.rawValue:
                return handleSameLevelClass(of: args, attachedTo: declaration, in: context)
            default:
                context.diagnose(JsonPolymorphicMacroDiagnostic.invalidArgument.diagnose(at: attribute))
                return nil
            }
           
        }
        
        guard let modelType = args.elements.last?
            .as(LabeledExprSyntax.self)?
            .expression
            .as(MemberAccessExprSyntax.self)?
            .base?
            .as(DeclReferenceExprSyntax.self)?
            .baseName.text else { return nil }
        guard let jsonExp = args
            .elements
            .first?
            .as(LabeledExprSyntax.self)?
            .expression
            .as(DictionaryExprSyntax.self)
        else  {
            return nil
        }
        
        var returnKeysData: [String:[String:[String:String]]] = [:]
//        jsonKeysExp.forEach { exp in
//            guard let jsonExp = exp.expression.as(DictionaryExprSyntax.self) else { return }
            guard let jsonDict = jsonExp.content.as(DictionaryElementListSyntax.self) else { return nil }
            //TODO we can recheck here for many json polymorphic keys
            guard let jsonKeyStrExp = jsonDict.first?.key.as(StringLiteralExprSyntax.self) else { return nil }
            guard let jsoKey = jsonKeyStrExp.segments.first?.as(StringSegmentSyntax.self)?.content.text else { return nil }
            guard let jsonKeyModelMapExp = jsonDict.first?.value.as(DictionaryExprSyntax.self)?.content.as(DictionaryElementListSyntax.self) else { return nil }
            print("========== PolyKey \(jsoKey) ================")
            jsonKeyModelMapExp.forEach { jsonKeyModel in
                var variableDecod: [String:[String:String]] = [:]
                guard let polyDict = jsonKeyModel.as(DictionaryElementSyntax.self) else { return }
                guard let jsonPolymorphicParamKey = polyDict.key
                    .as(StringLiteralExprSyntax.self)?
                    .segments.first?
                    .as(StringSegmentSyntax.self)?
                    .content
                    .text else { return }
                guard let jsonMapExp = jsonKeyModel.value
                    .as(DictionaryExprSyntax.self)?
                    .content
                    .as(DictionaryElementListSyntax.self) else { return }
                print("========== Param -> \(jsonPolymorphicParamKey) ================")
                var modelTypes: [String:String] = [:]
                jsonMapExp.forEach { dictElement in
                    guard let decodableKey = dictElement.key
                        .as(StringLiteralExprSyntax.self)?
                        .segments.first?
                        .as(StringSegmentSyntax.self)?
                        .content.text else { return }
                    guard let decodableModelName = dictElement.value
                        .as(MemberAccessExprSyntax.self)?
                        .base?
                        .as(DeclReferenceExprSyntax.self)?
                        .baseName.text else { return }
                    modelTypes[decodableKey] = decodableModelName
                    print("\(decodableKey):\(decodableModelName)")
                }
                variableDecod[jsonPolymorphicParamKey] = modelTypes
                returnKeysData[jsoKey] = variableDecod
            }
            print("==========================")
//        }
        return [(returnKeysData, modelType, "Dict", "", false, [])]
    }
    
    private static func getClassDataName( of attributes: TupleExprSyntax,
                                          attachedTo declaration: some DeclGroupSyntax,
                                          in context: some MacroExpansionContext
                                      ) -> String? {
        
        return attributes
            .elements
            .first?
            .expression
            .as(FunctionCallExprSyntax.self)?
            .calledExpression.as(DeclReferenceExprSyntax.self)?
            .baseName
            .text
        
    }
    
    private static func handleClass(
            of attributes: TupleExprSyntax,
            attachedTo declaration: some DeclGroupSyntax,
            in context: some MacroExpansionContext
        ) -> [PolyData]? {
            var returnArray = [PolyData]()
            attributes.elements.forEach { item in
                var returnKeysData: [String:[String:[String:String]]] = [:]
                var decodableParentType: String? = nil
                var polyVarName: String = ""
                guard (item
                    .as(LabeledExprSyntax.self)?
                    .expression
                    .as(FunctionCallExprSyntax.self)?
                    .arguments) != nil else {
                        context.diagnose(JsonPolymorphicMacroDiagnostic
                            .generic(message: "should have a list of JsonPolymorphicSameLevelTypeData as input type" )
                            .diagnose(at: item))
                    return }
                guard let keyArg = item.as(LabeledExprSyntax.self)?.expression.as(FunctionCallExprSyntax.self)?.arguments.first(where: {$0.label?.text == "key"}) else {
                    context.diagnose(JsonPolymorphicMacroDiagnostic
                        .nonexistentSingleProperty(propertyName: "key")
                        .diagnose(at: item))
                    return
                }
                guard let key = keyArg.getStringValue() else {
                    context.diagnose(JsonPolymorphicMacroDiagnostic
                        .generic(message: "should have a list of JsonPolymorphicSameLevelTypeData as input type" )
                        .diagnose(at: keyArg))
                    return }
                guard let polyVarNameArg = item.as(LabeledExprSyntax.self)?.expression.as(FunctionCallExprSyntax.self)?.arguments.first(where: {$0.label?.text == "polyVarName"}) else {
                    context.diagnose(JsonPolymorphicMacroDiagnostic
                        .nonexistentSingleProperty(propertyName: "polyVarName")
                        .diagnose(at: item))
                    return
                }
                guard let polyVarNameInst = polyVarNameArg.getStringValue() else {
                    context.diagnose(JsonPolymorphicMacroDiagnostic
                        .wrongPropertyType(propertyName: "polyVarName", propertyType: "String")
                        .diagnose(at: polyVarNameArg))
                    return
                }
                polyVarName = polyVarNameInst
                guard let decodableParentTypeArg = item.as(LabeledExprSyntax.self)?.expression.as(FunctionCallExprSyntax.self)?.arguments.first(where: {$0.label?.text == "decodableParentType"}) else {
                    context.diagnose(JsonPolymorphicMacroDiagnostic
                        .nonexistentSingleProperty(propertyName: "decodableParentType")
                        .diagnose(at: item))
                    return
                }
                guard let decodableParentTypeInst = decodableParentTypeArg.getTypeValue() else { return }
                decodableParentType = decodableParentTypeInst
                guard let decodingTypesArgs = item.as(LabeledExprSyntax.self)?.expression.as(FunctionCallExprSyntax.self)?.arguments.first(where: {$0.label?.text == "decodingTypes"})?.expression.as(DictionaryExprSyntax.self) else {
                    context.diagnose(JsonPolymorphicMacroDiagnostic
                        .nonexistentSingleProperty(propertyName: "decodingTypes")
                        .diagnose(at: polyVarNameArg))
                    return
                }
                guard let decodingTypes = decodingTypesArgs.getModelsDict() else {
                        context.diagnose(JsonPolymorphicMacroDiagnostic
                            .wrongPropertyType(propertyName: "decodingTypes", propertyType: "[String:Decodable.Type] ")
                            .diagnose(at: polyVarNameArg))
                        return
                }
                guard !(decodingTypes.isEmpty) else {
                        context.diagnose(JsonPolymorphicMacroDiagnostic
                            .wrongPropertyType(propertyName: "decodingTypes", propertyType: "[String:Decodable.Type] and not empty [:]")
                            .diagnose(at: polyVarNameArg))
                    return
                }
                returnKeysData[key] = [polyVarName : decodingTypes]
                guard let decodableParentTypeInst = decodableParentType else { return }
                let extraCodingKeysArg = item.as(LabeledExprSyntax.self)?.expression.as(FunctionCallExprSyntax.self)?.arguments.first(where: {$0.label?.text == "extraCustomCodingKeys"})
                let extraCodingKeys = extraCodingKeysArg?.getExtraCodingKeys() ?? [ExtraCustomCodingKeys]()
                let returnData = (returnKeysData, decodableParentTypeInst, "JsonPolymorphicTypeData", "", false, extraCodingKeys)
                returnArray.append(returnData)
            }
            return returnArray
        }
    
    private static func handleSameLevelClass(
            of attributes: TupleExprSyntax,
            attachedTo declaration: some DeclGroupSyntax,
            in context: some MacroExpansionContext
        ) -> [PolyData]? {
            var returnArray = [PolyData]()
            attributes.elements.forEach { item in
                var returnKeysData: [String:[String:[String:String]]] = [:]
                var decodableParentType: String? = nil
                var polyVarName: String = ""
                guard (item
                    .as(LabeledExprSyntax.self)?
                    .expression
                    .as(FunctionCallExprSyntax.self)?
                    .arguments) != nil else {
                        context.diagnose(JsonPolymorphicMacroDiagnostic
                            .generic(message: "should have a list of JsonPolymorphicTypeData as input type" )
                            .diagnose(at: item))
                    return }
                guard let keyArg = item.as(LabeledExprSyntax.self)?.expression.as(FunctionCallExprSyntax.self)?.arguments.first(where: {$0.label?.text == "key"}) else {
                    context.diagnose(JsonPolymorphicMacroDiagnostic
                        .nonexistentSingleProperty(propertyName: "key")
                        .diagnose(at: item))
                    return
                }
                guard let key = keyArg.getStringValue() else {
                    context.diagnose(JsonPolymorphicMacroDiagnostic
                        .generic(message: "should have a list of JsonPolymorphicTypeData as input type" )
                        .diagnose(at: keyArg))
                    return }
                guard let dummyDecoderNameArg = item.as(LabeledExprSyntax.self)?.expression.as(FunctionCallExprSyntax.self)?.arguments.first(where: {$0.label?.text == "dummyDecoder"}) else {
                    context.diagnose(JsonPolymorphicMacroDiagnostic
                        .nonexistentSingleProperty(propertyName: "dummyDecoder")
                        .diagnose(at: item))
                    return
                }
                let isArray = dummyDecoderNameArg.isArrayType()
                var dummyDecoderName: String?
                if (dummyDecoderNameArg.isArrayType()) {
                    guard dummyDecoderNameArg.getElements()?.count == 1 else {
                        context.diagnose(JsonPolymorphicMacroDiagnostic
                            .generic(message: "dummyDecoder should have an array but with one type of data [T.self], NOT [T.self, K.self]")
                            .diagnose(at: dummyDecoderNameArg))
                        return
                    }
                    dummyDecoderName = dummyDecoderNameArg.getElements()?.first?.expression.as(DeclReferenceExprSyntax.self)?.baseName.text
                }
                if dummyDecoderName == nil {
                    guard let dummyDecoderNameInst = dummyDecoderNameArg.getTypeValue() else {
                        context.diagnose(JsonPolymorphicMacroDiagnostic
                            .wrongPropertyType(propertyName: "dummyDecoder", propertyType: "String")
                            .diagnose(at: dummyDecoderNameArg))
                        return
                    }
                    dummyDecoderName = dummyDecoderNameInst
                }
                guard let polyVarNameArg = item.as(LabeledExprSyntax.self)?.expression.as(FunctionCallExprSyntax.self)?.arguments.first(where: {$0.label?.text == "polyVarName"}) else {
                    context.diagnose(JsonPolymorphicMacroDiagnostic
                        .nonexistentSingleProperty(propertyName: "polyVarName")
                        .diagnose(at: item))
                    return
                }
                guard let polyVarNameInst = polyVarNameArg.getStringValue() else {
                    context.diagnose(JsonPolymorphicMacroDiagnostic
                        .wrongPropertyType(propertyName: "polyVarName", propertyType: "String")
                        .diagnose(at: polyVarNameArg))
                    return
                }
                polyVarName = polyVarNameInst
                guard let decodableParentTypeArg = item.as(LabeledExprSyntax.self)?.expression.as(FunctionCallExprSyntax.self)?.arguments.first(where: {$0.label?.text == "decodableParentType"}) else {
                    context.diagnose(JsonPolymorphicMacroDiagnostic
                        .nonexistentSingleProperty(propertyName: "decodableParentType")
                        .diagnose(at: item))
                    return
                }
                guard let decodableParentTypeInst = decodableParentTypeArg.getTypeValue() else { return }
                decodableParentType = decodableParentTypeInst
                guard let decodingTypesArgs = item.as(LabeledExprSyntax.self)?.expression.as(FunctionCallExprSyntax.self)?.arguments.first(where: {$0.label?.text == "decodingTypes"})?.expression.as(DictionaryExprSyntax.self) else {
                    context.diagnose(JsonPolymorphicMacroDiagnostic
                        .nonexistentSingleProperty(propertyName: "decodingTypes")
                        .diagnose(at: dummyDecoderNameArg))
                    return
                }
                guard let decodingTypes = decodingTypesArgs.getModelsDict() else {
                        context.diagnose(JsonPolymorphicMacroDiagnostic
                            .wrongPropertyType(propertyName: "decodingTypes", propertyType: "[String:Decodable.Type] ")
                            .diagnose(at: dummyDecoderNameArg))
                        return
                }
                guard !(decodingTypes.isEmpty) else {
                        context.diagnose(JsonPolymorphicMacroDiagnostic
                            .wrongPropertyType(propertyName: "decodingTypes", propertyType: "[String:Decodable.Type] and not empty [:]")
                            .diagnose(at: dummyDecoderNameArg))
                        return
                    }
                returnKeysData[key] = [dummyDecoderName! : decodingTypes]
                guard let decodableParentTypeInst = decodableParentType else { return }
                let extraCodingKeysArg = item.as(LabeledExprSyntax.self)?.expression.as(FunctionCallExprSyntax.self)?.arguments.first(where: {$0.label?.text == "extraCustomCodingKeys"})
                let extraCodingKeys = extraCodingKeysArg?.getExtraCodingKeys() ?? [ExtraCustomCodingKeys]()
                let returnData = (returnKeysData, decodableParentTypeInst, "JsonPolymorphicSameLevelTypeData", polyVarName, isArray, extraCodingKeys)
                returnArray.append(returnData)
            }
            return returnArray
        }
}

fileprivate extension ArrayExprSyntax {
    var stringArray: [String]? {
        elements.reduce(into: [String]()) { result, element in
            guard let string = element.expression.as(StringLiteralExprSyntax.self) else {
                return
            }
            result.append(string.rawValue)
        }
    }
}

fileprivate extension StringLiteralExprSyntax {
    var rawValue: String {
        segments
            .compactMap { $0.as(StringSegmentSyntax.self) }
            .map(\.content.text)
            .joined()
    }
}

fileprivate extension LabeledExprSyntax {
    func getStringValue() -> String? {
        return self.expression.as(StringLiteralExprSyntax.self)?.segments.first?.as(StringSegmentSyntax.self)?.content.text
    }
    
    func getTypeValue() -> String? {
        return self.expression.as(MemberAccessExprSyntax.self)?.base?.as(DeclReferenceExprSyntax.self)?.baseName.text
    }
    
    func isArrayType() -> Bool {
        return self.expression.as(MemberAccessExprSyntax.self)?.base?.as(ArrayExprSyntax.self) != nil
    }
    
    func getElements() -> ArrayElementListSyntax? {
        return self.expression.as(MemberAccessExprSyntax.self)?.base?.as(ArrayExprSyntax.self)?.elements
    }
    
    func getExtraCodingKeys() -> [ExtraCustomCodingKeys] {
        var extraCodingKeys = [ExtraCustomCodingKeys]()
        self.expression.as(ArrayExprSyntax.self)?.elements.forEach({ element in
            let args = element.expression.as(FunctionCallExprSyntax.self)?.arguments
            guard let paramName = args?.first(where: {$0.label?.text == "paramName"})?.as(LabeledExprSyntax.self)?.getStringValue() else { return }
            guard let paramCodingKey = args?.first(where: {$0.label?.text == "paramCodingKey"})?.as(LabeledExprSyntax.self)?.getStringValue() else { return }
            guard let decodingType = args?.first(where: {$0.label?.text == "type"})?.as(LabeledExprSyntax.self)?.getTypeValue() else { return }
            extraCodingKeys.append((paramName, paramCodingKey, decodingType))
        })
        return extraCodingKeys
    }
}

fileprivate extension DictionaryExprSyntax {
    func getModelsDict() -> [String: String]? {
        guard let elements = content.as(DictionaryElementListSyntax.self) else {
            return nil
        }

        return elements.reduce(into: [String: String]()) { result, element in
            guard let key = element.key.as(StringLiteralExprSyntax.self),
                  let value = element.value.as(MemberAccessExprSyntax.self)?.base?.as(DeclReferenceExprSyntax.self)?.baseName.text
            else {
                return
            }
            result.updateValue(value, forKey: key.rawValue)
        }
    }
}

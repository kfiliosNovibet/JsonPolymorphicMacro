//
//  File.swift
//  
//
//  Created by Kostas Filios on 30/10/23.
//

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public extension JsonPolymorphicMacro {
    static func decodeExpansion(
        of attribute: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) -> ([String:[String:[String:String]]], String)? {
        guard case let .argumentList(arguments) = attribute.argument
        else {
            context.diagnose(JsonPolymorphicMacroDiagnostic.noArgument.diagnose(at: attribute))
            return nil
        }

        guard let structDecl = declaration.as(StructDeclSyntax.self) else {
            context.diagnose(JsonPolymorphicMacroDiagnostic.requiresStructOrClass.diagnose(at: attribute))
            return nil
        }
//            context.diagnose(CodingKeysMacroDiagnostic.invalidArgument.diagnose(at: attribute))
        if let array = arguments
            .as(LabeledExprListSyntax.self)?
            .first?.expression
            .as(ArrayExprSyntax.self) {
           return handleClass(of: array, attachedTo: declaration, in: context)
        }
        guard let args = attribute.arguments?
            .as(LabeledExprListSyntax.self)?
            .first?
            .expression
            .as(TupleExprSyntax.self) else {
            return nil
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
        return (returnKeysData, modelType)
    }
    
    private static func handleClass (
            of attributes: ArrayExprSyntax,
            attachedTo declaration: some DeclGroupSyntax,
            in context: some MacroExpansionContext
        ) -> ([String:[String:[String:String]]], String)? {
            guard attributes
                .elements
                .first?
                .as(ArrayElementSyntax.self)?
                .expression
                .as(FunctionCallExprSyntax.self)?
                .calledExpression
                .as(DeclReferenceExprSyntax.self)?
                .baseName
                .text == "JsonPolymorphicTypeData" else {
                context.diagnose(JsonPolymorphicMacroDiagnostic
                    .generic(message: "should have a list of JsonPolymorphicTypeData as input type" )
                    .diagnose(at: attributes))
                return nil
            }
            var returnKeysData: [String:[String:[String:String]]] = [:]
            var decodableParentType: String? = nil
            attributes.elements.forEach { item in
                guard (item
                    .as(ArrayElementSyntax.self)?
                    .expression
                    .as(FunctionCallExprSyntax.self)?
                    .arguments) != nil else {
                        context.diagnose(JsonPolymorphicMacroDiagnostic
                            .generic(message: "should have a list of JsonPolymorphicTypeData as input type" )
                            .diagnose(at: item))
                    return }
                guard let keyArg = item.as(ArrayElementSyntax.self)?.expression.as(FunctionCallExprSyntax.self)?.arguments.first(where: {$0.label?.text == "key"}) else {
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
                guard let polyVarNameArg = item.as(ArrayElementSyntax.self)?.expression.as(FunctionCallExprSyntax.self)?.arguments.first(where: {$0.label?.text == "polyVarName"}) else {
                    context.diagnose(JsonPolymorphicMacroDiagnostic
                        .nonexistentSingleProperty(propertyName: "polyVarName")
                        .diagnose(at: item))
                    return
                }
                guard let polyVarName = polyVarNameArg.getStringValue() else {
                    context.diagnose(JsonPolymorphicMacroDiagnostic
                        .wrongPropertyType(propertyName: "polyVarName", propertyType: "String")
                        .diagnose(at: polyVarNameArg))
                    return
                }
                guard let decodableParentTypeArg = item.as(ArrayElementSyntax.self)?.expression.as(FunctionCallExprSyntax.self)?.arguments.first(where: {$0.label?.text == "decodableParentType"}) else {
                    context.diagnose(JsonPolymorphicMacroDiagnostic
                        .nonexistentSingleProperty(propertyName: "decodableParentType")
                        .diagnose(at: item))
                    return
                }
                guard let decodableParentTypeInst = decodableParentTypeArg.getTypeValue() else { return }
                decodableParentType = decodableParentTypeInst
                guard let decodingTypesArgs = item.as(ArrayElementSyntax.self)?.expression.as(FunctionCallExprSyntax.self)?.arguments.first(where: {$0.label?.text == "decodingTypes"})?.expression.as(DictionaryExprSyntax.self) else {
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
            }
            guard let decodableParentTypeInst = decodableParentType else { return nil }
            return (returnKeysData, decodableParentTypeInst)
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
}

fileprivate extension DictionaryExprSyntax {
    func getModelsDict() -> [String: String]? {
        guard let elements = content.as(DictionaryElementListSyntax.self) else {
            return nil
        }

        return elements.reduce(into: [String: String]()) { result, element in
            guard let key = element.keyExpression.as(StringLiteralExprSyntax.self),
                  let value = element.valueExpression.as(MemberAccessExprSyntax.self)?.base?.as(DeclReferenceExprSyntax.self)?.baseName.text
            else {
                return
            }
            result.updateValue(value, forKey: key.rawValue)
        }
    }
}

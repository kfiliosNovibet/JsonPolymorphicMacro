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
//            context.diagnose(CodingKeysMacroDiagnostic.noArgument.diagnose(at: attribute))
            return nil
        }

        guard let structDecl = declaration.as(StructDeclSyntax.self) else {
//            context.diagnose(CodingKeysMacroDiagnostic.requiresStruct.diagnose(at: attribute))
            return nil
        }
//            context.diagnose(CodingKeysMacroDiagnostic.invalidArgument.diagnose(at: attribute))
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

fileprivate extension DictionaryExprSyntax {
    var stringDictionary: [String: String]? {
        guard let elements = content.as(DictionaryElementListSyntax.self) else {
            return nil
        }

        return elements.reduce(into: [String: String]()) { result, element in
            guard let key = element.keyExpression.as(StringLiteralExprSyntax.self),
                  let value = element.valueExpression.as(StringLiteralExprSyntax.self)
            else {
                return
            }
            result.updateValue(value.rawValue, forKey: key.rawValue)
        }
    }
}

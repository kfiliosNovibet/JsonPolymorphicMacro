import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros


/// Implementation of the `stringify` macro, which takes an expression
/// of any type and produces a tuple containing the value of that expression
/// and the source code that produced the value. For example
///
///     #stringify(x + y)
///
///  will expand to
///
///     (x + y, "x + y")
///

public struct StringifyMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) -> ExprSyntax {
        guard let argument = node.argumentList.first?.expression else {
            fatalError("compiler bug: the macro does not have any arguments")
        }
        
        return "(\(argument), \(literal: argument.description))"
    }
}

enum StructInitError: CustomStringConvertible, Error {
    case onlyApplicableToStruct
    
    var description: String {
        switch self {
        case .onlyApplicableToStruct: return "@StructInit can only be applied to a structure"
        }
    }
}

public struct JsonPolymorphicMacro: MemberMacro {
    public static func expansion<
        Declaration: DeclGroupSyntax, Context: MacroExpansionContext
    >(
        of node: AttributeSyntax,
        providingMembersOf declaration: Declaration,
        in context: Context
    ) throws -> [DeclSyntax] {        
        
        guard let structDecl = declaration.as(StructDeclSyntax.self) else {
            throw StructInitError.onlyApplicableToStruct
        }
        
        let members = structDecl.memberBlock.members
        let variableDecl = members.compactMap { $0.decl.as(VariableDeclSyntax.self) }
        let variablesName = variableDecl.compactMap { $0.bindings.first?.pattern }
        let variablesType = variableDecl.compactMap { $0.bindings.first?.typeAnnotation?.type }
        
        guard let (polyMorphicData, dataGenericType) = decodeExpansion(of: node, attachedTo: declaration, in: context) else {
            return []
        }
//        return []
//        let properties = getProperties(decl: structDecl)
        
        //TODO handle here for more polymorphic params
        guard let polymorphicParamData = polyMorphicData.first?.value.first else {
            //TODO promt here error
            return[]
        }
        /**polymorphicParamData -> ["$type":
                                ["content": [  "Empty" :  "EmptyResponse",
                                          "Single" : "SingleResponse",
                                          "Many" : "ListResponse",
                                          "WhatElse" : "WhatEverResponse"]]]
            dataGenericType ->  "Response"    
         **/
        let polymorphicVariableSet = "let \(polymorphicParamData.key): \(dataGenericType)?"
        var codeBlockGen: [DeclSyntax] = [DeclSyntax(stringLiteral: polymorphicVariableSet)]
        let polyKey = polyMorphicData.first!.key
        let polyKeyLocalVariable = polyKey.first?.isLetter == true ? polyKey : String(polyKey.dropFirst())
        let jsonPolyKeyVariable = "let \(polyKeyLocalVariable): String?"
        codeBlockGen.append(DeclSyntax(stringLiteral: jsonPolyKeyVariable))
        // MARK:  Coding Keys Enum block
        var parameters = variablesName
                    .map { variable in
                        return  "case \(variable)"
                    }
                    .joined(separator: "\n") 
        parameters.append("\n")
        parameters.append("case \(polyKeyLocalVariable) = \"\(polyKey)\"")
        parameters.append("case \(polymorphicParamData.key)")
        let enumBlock = """
            enum CodingKeys: String, CodingKey {
                \(parameters)
            }
            """
        codeBlockGen.append(DeclSyntax(stringLiteral: enumBlock))
        // MARK:  Init block
        var initBlock = CodeBlockItemListSyntax()
        initBlock.append(CodeBlockItemSyntax("let values = try decoder.container(keyedBy: CodingKeys.self)"))
        for (name, type) in zip(variablesName, variablesType) {
            //Here we handle
            // SimpleValue (Int, String etc)
            var finalType = type.as(IdentifierTypeSyntax.self)?.name.text
            // SimpleValue? (Int, String etc)
            if (finalType == nil && type.as(OptionalTypeSyntax.self) != nil) {
                finalType = type.as(OptionalTypeSyntax.self)?.wrappedType.as(IdentifierTypeSyntax.self)?.name.text
                // [SimpleValue]? (Int, String etc)
                let internalOptionalType = type.as(OptionalTypeSyntax.self)?.wrappedType
                if (finalType == nil && internalOptionalType?.as(ArrayTypeSyntax.self) != nil) {
                    finalType = handleArray(internalOptionalType!.as(ArrayTypeSyntax.self)!)
                }
                
                // [Key: SimpleValue]?
                if (finalType == nil && internalOptionalType?.as(DictionaryTypeSyntax.self) != nil) {
                    finalType = handleDict(internalOptionalType?.as(DictionaryTypeSyntax.self))
                }
            }
            
            // [SimpleValue] (Int, String etc)
            if (finalType == nil && type.as(ArrayTypeSyntax.self) != nil) {
                finalType = handleArray(type.as(ArrayTypeSyntax.self)!)
            }
            
            // [Key: SimpleValue]
            if (finalType == nil && type.as(DictionaryTypeSyntax.self) != nil) {
                finalType = handleDict(type.as(DictionaryTypeSyntax.self))
            }
            initBlock.append(CodeBlockItemSyntax("self.\(name) = try values.decodeIfPresent(\(raw: finalType!).self, forKey: .\(raw: name))"))
        }
        //Add any change here to make key deserialize more dynamic
        initBlock.append(CodeBlockItemSyntax("self.\(raw: polyKeyLocalVariable) = try values.decodeIfPresent(String.self, forKey: .\(raw:polyKeyLocalVariable))"))
        guard let modelTypes = polyMorphicData.first?.value.first?.value else {
            //TODO show error
            return []
        }
        var switchCaseSynt = SwitchCaseListSyntax()
        modelTypes.keys.sorted().forEach { key in
            let value = modelTypes[key]!
            let caseBlock = SwitchCaseSyntax("case \"\(raw: key)\":", statementsBuilder: {
                CodeBlockItemSyntax("\(raw: polymorphicParamData.key) = try values.decodeIfPresent(\(raw: value).self, forKey: .\(raw: polymorphicParamData.key))")
            })
            switchCaseSynt.append(SwitchCaseListSyntax.Element.init(caseBlock))
            
//            initBlock.append(CodeBlockItemSyntax("case \(raw: key) :"))
//            initBlock.append(CodeBlockItemSyntax("  \(raw: polyKeyLocalVariable) = try values.decodeIfPresent(\(raw: value).self, forKey: .\(raw: polyKeyLocalVariable))"))
        }
        let defaultCase = SwitchCaseSyntax("default:", statementsBuilder: {
            CodeBlockItemSyntax("\(raw: polymorphicParamData.key) = nil")
        })
        switchCaseSynt.append(SwitchCaseListSyntax.Element.init(defaultCase))
        do {
            let switchSynt = try SwitchExprSyntax.init("switch self.\(raw: polyKeyLocalVariable)", casesBuilder: {switchCaseSynt})
            initBlock.append(CodeBlockItemSyntax.init(item: .init(switchSynt)))
        } catch let error {
            //TODO throw  error
            throw error
        }
        let initializer = try InitializerDeclSyntax(JsonPolymorphicMacro.generateInitialCode(variablesName: variablesName,
                                                                                             variablesType: variablesType,
                                                                                             polyMorphicData: polyMorphicData)) { initBlock }
        
        codeBlockGen.append(DeclSyntax(initializer))
//        return []
        return codeBlockGen
    }
    
    public static func generateInitialCode(variablesName: [PatternSyntax],
                                           variablesType: [TypeSyntax],
                                           polyMorphicData: [String:[String:[String:String]]]) -> SyntaxNodeString {
        let initialCode: String = "init(from decoder: Decoder) throws "
        //        for (name, type) in zip(variablesName, variablesType) {
        //            initialCode += "\(name): \(type), "
        //        }
        //        initialCode = String(initialCode.dropLast(2))
        //        initialCode += ")"
        return SyntaxNodeString(stringLiteral: initialCode)
    }
    
    
    private static func getProperties(decl: StructDeclSyntax) -> [String] {
        var properties = [String]()
        
        for decl in decl.memberBlock.members.map(\.decl) {
            if let variableDecl = decl.as(VariableDeclSyntax.self) {
                properties.append(
                    contentsOf: variableDecl.bindings.compactMap { $0.pattern.as(IdentifierPatternSyntax.self)?.identifier.text }
                )
            }
        }
        
        return properties
    }
    
    
    private static func handleArray(_ arrayTypeSyntax: ArrayTypeSyntax) -> String {
        var internalType = arrayTypeSyntax.element.as(IdentifierTypeSyntax.self)?.name.text
        if (internalType == nil && arrayTypeSyntax.element.as(OptionalTypeSyntax.self)?.wrappedType.as(IdentifierTypeSyntax.self) != nil) {
            // [SimpleValue?]? (Int, String etc)
            internalType = arrayTypeSyntax.element.as(OptionalTypeSyntax.self)?.wrappedType.as(IdentifierTypeSyntax.self)?.name.text
            internalType! += "?"
        }
        return "[\(internalType!)]"
    }
    
    private static func handleDict(_ dictionaryTypeSyntax: DictionaryTypeSyntax?) -> String {
        let keyType = dictionaryTypeSyntax?.key.as(IdentifierTypeSyntax.self)?.name.text
        var valueType = dictionaryTypeSyntax?.value.as(IdentifierTypeSyntax.self)?.name.text
        if (valueType == nil && dictionaryTypeSyntax?.value.as(OptionalTypeSyntax.self)?.wrappedType.as(IdentifierTypeSyntax.self) != nil) {
            // [Key: SimpleValue?]?
            valueType = dictionaryTypeSyntax?.value.as(OptionalTypeSyntax.self)?.wrappedType.as(IdentifierTypeSyntax.self)?.name.text
            valueType! += "?"
        }
        return "[\(keyType!):\(valueType!)]"
    }
}

@main
struct JsonPolymorphicMacroPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        StringifyMacro.self,
        JsonPolymorphicMacro.self,
    ]
}

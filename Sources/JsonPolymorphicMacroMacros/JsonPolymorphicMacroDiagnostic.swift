//
//  JsonPolymorphicMacroDiagnostic.swift
//
//
//  Created by Kostas Filios on 10/11/23.
//

import Foundation
import SwiftSyntax
import SwiftDiagnostics

public enum JsonPolymorphicMacroDiagnostic {
    case generic(message: String)
    case wrongPropertyType(propertyName: String, propertyType: String)
    case nonexistentSingleProperty(propertyName: String)
    case nonexistentProperty(structName: String, propertyName: String)
    case noArgument
    case requiresStructOrClass
    case invalidArgument
}

extension JsonPolymorphicMacroDiagnostic: DiagnosticMessage {
    func diagnose(at node: some SyntaxProtocol) -> Diagnostic {
            Diagnostic(node: Syntax(node), message: self)
        }

        public var message: String {
            switch self {
            case let .generic(message):
                return "JsonPolymorphicMacro error: \(message)"
                
            case let .wrongPropertyType(propertyName, propertyType):
                return "Property \(propertyName) should be \(propertyType)"
                
            case let .nonexistentSingleProperty(propertyName):
                return "Cannot find property \(propertyName)"
                
            case let .nonexistentProperty(structName, propertyName):
                return "Property \(propertyName) does not exist in \(structName)"

            case .noArgument:
                return "Cannot find argument"

            case .requiresStructOrClass:
                return "'JsonPolymorphicMacro' macro can only be applied to Decodable, Struct or Class."

            case .invalidArgument:
                return "Invalid Argument"
            }
        }

        public var severity: DiagnosticSeverity { .error }

        public var diagnosticID: MessageID {
            MessageID(domain: "Swift", id: "CodingKeysMacro.\(self)")
        }
}

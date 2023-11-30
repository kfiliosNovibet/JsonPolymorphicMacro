//
//  JsonPolymorphicMacroPlugin.swift
//  
//
//  Created by Kostas Filios on 30/11/23.
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

@main
struct JsonPolymorphicMacroPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        JsonPolymorphicMacro.self
    ]
}

import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(JsonPolymorphicMacroMacros)
import JsonPolymorphicMacroMacros

let testMacros: [String: Macro.Type] = [
    "stringify": StringifyMacro.self,
    "JsonPolymorphicKeys": JsonPolymorphicMacro.self
]
#endif

final class JsonPolymorphicMacroTests: XCTestCase {
//    func testMacro() throws {
//        #if canImport(JsonPolymorphicMacroMacros)
//        assertMacroExpansion(
//            """
//            #stringify(a + b)
//            """,
//            expandedSource: """
//            (a + b, "a + b")
//            """,
//            macros: testMacros
//        )
//        #else
//        throw XCTSkip("macros are only supported when running tests for the host platform")
//        #endif
//    }
    
    
    func testJsonPolymporphicMacro() throws {
        #if canImport(JsonPolymorphicMacroMacros)
        assertMacroExpansion(
            """
            @JsonPolymorphicKeys((["$type": ["content" : ["Empty":EmptyResponse.self,
                                                          "Single":SingleResponse.self,
                                                          "Many":ListResponse.self]]], Response.self))
            struct Test: Decodable {
                let name: String
                let a: String
            }

            """,
            expandedSource: """
            struct Test: Decodable {
                let name: String
                let a: String

                let content: Response

                let type: String

                enum CodingKeys: String, CodingKey {
                    case name
                    case a
                    case type = "$type"
                }

                init(from decoder: Decoder) throws  {
                    self.name =  try values.decodeIfPresent(String.self, forKey: .name)
                    self.a =  try values.decodeIfPresent(String.self, forKey: .a)
                    self.type =  try values.decodeIfPresent(String.self, forKey: .type)
                    switch type {
                    case Empty
                        content = try values.decodeIfPresent(EmptyResponse.self, forKey: .type)
                    case Many
                        content = try values.decodeIfPresent(ListResponse.self, forKey: .type)
                    case Single
                        content = try values.decodeIfPresent(SingleResponse.self, forKey: .type)
                    }
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

//    func testMacroWithStringLiteral() throws {
//        #if canImport(JsonPolymorphicMacroMacros)
//        assertMacroExpansion(
//            #"""
//            #stringify("Hello, \(name)")
//            """#,
//            expandedSource: #"""
//            ("Hello, \(name)", #""Hello, \(name)""#)
//            """#,
//            macros: testMacros
//        )
//        #else
//        throw XCTSkip("macros are only supported when running tests for the host platform")
//        #endif
//    }
}

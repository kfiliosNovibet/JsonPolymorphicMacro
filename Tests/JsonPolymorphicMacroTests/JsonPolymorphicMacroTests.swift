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
            struct EmptyResponse: Decodable, Response {
                let success: Bool
            }

            struct SingleResponse: Decodable, Response {
                let name: String
                let success: Bool
            }

            struct ListResponse: Decodable, Response {
                let name: [String]
                let success: Bool
            }


            @JsonPolymorphicKeys(["$type": ["content" : ["Empty":EmptyResponse.self,
                                                         "Single":SingleResponse.self,
                                                         "Many":ListResponse.self]]])
            struct Test: Decodable {
                let name: String
                let a: String
            }

            """,
            expandedSource: """
            init(name: String, a: String) {
                self.name = name
                self.a = a
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

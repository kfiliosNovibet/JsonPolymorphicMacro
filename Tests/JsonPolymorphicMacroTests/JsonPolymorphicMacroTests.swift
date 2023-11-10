import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(JsonPolymorphicMacroMacros)
import JsonPolymorphicMacroMacros

let testMacros: [String: Macro.Type] = [
    "JsonPolymorphicKeys": JsonPolymorphicMacro.self
]
#endif

final class JsonPolymorphicMacroTests: XCTestCase {
    
    func testJsonPolymporphicDicOptional() throws {
        #if canImport(JsonPolymorphicMacroMacros)
        assertMacroExpansion(
            """
            @JsonPolymorphicKeys([JsonPolymorphicTypeData(key: "type", polyVarName: "content",
                                                          decodableParentType: Response.self,
                                                          decodingTypes: ["Telephones":TelephoneResponse.self,
                                                                          "Adresses":AdressesResponse.self])])
            struct PolyResponse: Decodable {
                let cities: [String:String?]?
            }

            """,
            expandedSource: """
            struct PolyResponse: Decodable {
                let cities: [String:String?]?

                let content: Response?

                let type: String?

                enum CodingKeys: String, CodingKey {
                    case cities
                    case type = "type"
                    case content
                }

                init(from decoder: Decoder) throws  {
                    let values = try decoder.container(keyedBy: CodingKeys.self)
                    self.cities = try values.decodeIfPresent([String: String?].self, forKey: .cities)
                    self.type = try values.decodeIfPresent(String.self, forKey: .type)
                    switch self.type {
                    case "Adresses":
                        content = try values.decodeIfPresent(AdressesResponse.self, forKey: .content)
                    case "Telephones":
                        content = try values.decodeIfPresent(TelephoneResponse.self, forKey: .content)
                    default:
                        content = nil
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
    
    func testJsonPolymporphicDic() throws {
        #if canImport(JsonPolymorphicMacroMacros)
        assertMacroExpansion(
            """
            @JsonPolymorphicKeys([JsonPolymorphicTypeData(key: "type", polyVarName: "content",
                                                          decodableParentType: Response.self,
                                                          decodingTypes: ["Telephones":TelephoneResponse.self,
                                                                          "Adresses":AdressesResponse.self])])
            struct PolyResponse: Decodable {
                let cities: [String:String]?
            }

            """,
            expandedSource: """
            struct PolyResponse: Decodable {
                let cities: [String:String]?

                let content: Response?

                let type: String?

                enum CodingKeys: String, CodingKey {
                    case cities
                    case type = "type"
                    case content
                }

                init(from decoder: Decoder) throws  {
                    let values = try decoder.container(keyedBy: CodingKeys.self)
                    self.cities = try values.decodeIfPresent([String: String].self, forKey: .cities)
                    self.type = try values.decodeIfPresent(String.self, forKey: .type)
                    switch self.type {
                    case "Adresses":
                        content = try values.decodeIfPresent(AdressesResponse.self, forKey: .content)
                    case "Telephones":
                        content = try values.decodeIfPresent(TelephoneResponse.self, forKey: .content)
                    default:
                        content = nil
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
    
    func testJsonPolymporphicArray() throws {
        #if canImport(JsonPolymorphicMacroMacros)
        assertMacroExpansion(
            """
            @JsonPolymorphicKeys([JsonPolymorphicTypeData(key: "type", polyVarName: "content",
                                                          decodableParentType: Response.self,
                                                          decodingTypes: ["Telephones":TelephoneResponse.self,
                                                                          "Adresses":AdressesResponse.self])])
            struct PolyResponse {
                let cities: [String]?
            }

            """,
            expandedSource: """
            struct PolyResponse {
                let cities: [String]?

                let content: Response?

                let type: String?

                enum CodingKeys: String, CodingKey {
                    case cities
                    case type = "type"
                    case content
                }

                init(from decoder: Decoder) throws  {
                    let values = try decoder.container(keyedBy: CodingKeys.self)
                    self.cities = try values.decodeIfPresent([String].self, forKey: .cities)
                    self.type = try values.decodeIfPresent(String.self, forKey: .type)
                    switch self.type {
                    case "Adresses":
                        content = try values.decodeIfPresent(AdressesResponse.self, forKey: .content)
                    case "Telephones":
                        content = try values.decodeIfPresent(TelephoneResponse.self, forKey: .content)
                    default:
                        content = nil
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
    
    func testJsonPolymporphicOptionalArray() throws {
        #if canImport(JsonPolymorphicMacroMacros)
        assertMacroExpansion(
            """
            @JsonPolymorphicKeys([JsonPolymorphicTypeData(key: "type", polyVarName: "content",
                                                          decodableParentType: Response.self,
                                                          decodingTypes: ["Telephones":TelephoneResponse.self,
                                                                          "Adresses":AdressesResponse.self])])
            struct PolyResponse {
                let cities: [String?]?
            }

            """,
            expandedSource: """
            struct PolyResponse {
                let cities: [String?]?

                let content: Response?

                let type: String?

                enum CodingKeys: String, CodingKey {
                    case cities
                    case type = "type"
                    case content
                }

                init(from decoder: Decoder) throws  {
                    let values = try decoder.container(keyedBy: CodingKeys.self)
                    self.cities = try values.decodeIfPresent([String?].self, forKey: .cities)
                    self.type = try values.decodeIfPresent(String.self, forKey: .type)
                    switch self.type {
                    case "Adresses":
                        content = try values.decodeIfPresent(AdressesResponse.self, forKey: .content)
                    case "Telephones":
                        content = try values.decodeIfPresent(TelephoneResponse.self, forKey: .content)
                    default:
                        content = nil
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
    
    
    func testJsonPolymporphicMacro() throws {
        #if canImport(JsonPolymorphicMacroMacros)
        assertMacroExpansion(
            """
            @JsonPolymorphicKeys((["$type": ["content" : ["Empty":EmptyResponse.self,
                                                          "Single":SingleResponse.self,
                                                          "Many":ListResponse.self]]], Response.self))
            struct Test: Decodable {
                let name: String?
                let a: String?
            }

            """,
            expandedSource: """
            struct Test: Decodable {
                let name: String?
                let a: String?

                let content: Response?

                let type: String?

                enum CodingKeys: String, CodingKey {
                    case name
                    case a
                    case type = "$type"
                    case content
                }

                init(from decoder: Decoder) throws  {
                    let values = try decoder.container(keyedBy: CodingKeys.self)
                    self.name = try values.decodeIfPresent(String.self, forKey: .name)
                    self.a = try values.decodeIfPresent(String.self, forKey: .a)
                    self.type = try values.decodeIfPresent(String.self, forKey: .type)
                    switch self.type {
                    case "Empty":
                        content = try values.decodeIfPresent(EmptyResponse.self, forKey: .content)
                    case "Many":
                        content = try values.decodeIfPresent(ListResponse.self, forKey: .content)
                    case "Single":
                        content = try values.decodeIfPresent(SingleResponse.self, forKey: .content)
                    default:
                        content = nil
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
    
    func testJsonPolymporphicMacroClass() throws {
        #if canImport(JsonPolymorphicMacroMacros)
        assertMacroExpansion(
            """
            @JsonPolymorphicKeys([JsonPolymorphicTypeData(key: "$type", polyVarName: "content",
                                                                 decodableParentType: Response.self,
                                                                 decodingTypes: ["Empty":EmptyResponse.self,
                                                                                 "Single":SingleResponse.self,
                                                                                 "Many":ListResponse.self,
                                                                                 "WhatElse":WhatEverResponse.self])])
            struct Test: Decodable {
                let name: String?
                let a: String?
            }

            """,
            expandedSource: """
            struct Test: Decodable {
                let name: String?
                let a: String?

                let content: Response?

                let type: String?

                enum CodingKeys: String, CodingKey {
                    case name
                    case a
                    case type = "$type"
                    case content
                }

                init(from decoder: Decoder) throws  {
                    let values = try decoder.container(keyedBy: CodingKeys.self)
                    self.name = try values.decodeIfPresent(String.self, forKey: .name)
                    self.a = try values.decodeIfPresent(String.self, forKey: .a)
                    self.type = try values.decodeIfPresent(String.self, forKey: .type)
                    switch self.type {
                    case "Empty":
                        content = try values.decodeIfPresent(EmptyResponse.self, forKey: .content)
                    case "Many":
                        content = try values.decodeIfPresent(ListResponse.self, forKey: .content)
                    case "Single":
                        content = try values.decodeIfPresent(SingleResponse.self, forKey: .content)
                    case "WhatElse":
                        content = try values.decodeIfPresent(WhatEverResponse.self, forKey: .content)
                    default:
                        content = nil
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
}

import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(JsonPolymorphicMacroMacros)
import JsonPolymorphicMacroMacros

let testSameLevelMacros: [String: Macro.Type] = [
    "JsonPolymorphicKeys": JsonPolymorphicMacro.self
]
#endif

final class JsonPolymorphicMacroSameLevelTest: XCTestCase {
    
    func testJsonPolymporphicClass() throws {
        #if canImport(JsonPolymorphicMacroMacros)
        assertMacroExpansion(
            """
            protocol BetslipBaseState: Decodable {}

            struct DummyBetslipState: Decodable {
                let type: String?
                
                enum CodingKeys: String, CodingKey {
                    case type = "$type"
                }
                
                init(from decoder: Decoder) throws {
                    let container = try decoder.container(keyedBy: CodingKeys.self)
                    self.type = try container.decodeIfPresent(String.self, forKey: .type)
                }
            }

            struct BetslipStateEmpty: BetslipBaseState {
                
            }

            struct BetslipStateInput: BetslipBaseState {
                let selections: [BetslipSelection]?
                let combinations: [BetslipCombination]?
                let changesDetected: Bool?
                let betContextModes: [BetContextMode]?
                
            }

            struct BetslipSelection: Decodable {}
            struct BetslipCombination: Decodable {}
            struct BetContextMode: Decodable {}


            @JsonPolymorphicKeys((JsonPolymorphicSameLevelTypeData(key: "$type",
                                                                   dummyDecoder: DummyBetslipState.self,
                                                                   polyVarName: "state",
                                                                   decodableParentType: BetslipBaseState.self,
                                                                   decodingTypes: ["Empty":BetslipStateEmpty.self,
                                                                                   "Input":BetslipStateInput.self])))
            struct BetslipResponseTest: Decodable {
                let id: String?
            }

            """,
            expandedSource: """
            protocol BetslipBaseState: Decodable {}

            struct DummyBetslipState: Decodable {
                let type: String?
                
                enum CodingKeys: String, CodingKey {
                    case type = "$type"
                }
                
                init(from decoder: Decoder) throws {
                    let container = try decoder.container(keyedBy: CodingKeys.self)
                    self.type = try container.decodeIfPresent(String.self, forKey: .type)
                }
            }

            struct BetslipStateEmpty: BetslipBaseState {
                
            }

            struct BetslipStateInput: BetslipBaseState {
                let selections: [BetslipSelection]?
                let combinations: [BetslipCombination]?
                let changesDetected: Bool?
                let betContextModes: [BetContextMode]?
                
            }

            struct BetslipSelection: Decodable {}
            struct BetslipCombination: Decodable {}
            struct BetContextMode: Decodable {}
            struct BetslipResponseTest: Decodable {
                let id: String?

                let state: BetslipBaseState?

                enum CodingKeys: String, CodingKey {
                    case id
                    case state = "state"
                }

                init(from decoder: Decoder) throws  {
                    let values = try decoder.container(keyedBy: CodingKeys.self)
                    self.id = try values.decodeIfPresent(String.self, forKey: .id)
                    let dummyModelstate = try values.decodeIfPresent(DummyBetslipState.self, forKey: .state)
                    switch dummyModelstate?.type {
                    case "Empty":
                        state = try values.decodeIfPresent(BetslipStateEmpty.self, forKey: .state)
                    case "Input":
                        state = try values.decodeIfPresent(BetslipStateInput.self, forKey: .state)
                    default:
                        state = nil
                    }
                }
            }
            """,
            macros: testSameLevelMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    
//    func testJsonPolymporphicArrayClass() throws {
//        #if canImport(JsonPolymorphicMacroMacros)
//        assertMacroExpansion(
//            """
//            protocol BetslipBaseState: Decodable {}
//            protocol BetslipBaseSelection: Decodable {}
//
//            struct DummyBetslipState: Decodable {
//                let type: String?
//                
//                enum CodingKeys: String, CodingKey {
//                    case type = "$type"
//                }
//                
//                init(from decoder: Decoder) throws {
//                    let container = try decoder.container(keyedBy: CodingKeys.self)
//                    self.type = try container.decodeIfPresent(String.self, forKey: .type)
//                }
//            }
//
//            struct BetslipStateEmpty: BetslipBaseState {}
//
//            struct BetslipSelection: Decodable {}
//            struct BetslipCombination: Decodable {}
//            struct BetContextMode: Decodable {}
//            struct BetslipSingleSelection: BetslipBaseSelection {}
//            struct BetslipMultipleSelection: BetslipBaseSelection {}
//
//            @JsonPolymorphicKeys([JsonPolymorphicSameLevelTypeData(key: "$type",
//                                                                   dummyDecoder: [DummyBetslipState].self,
//                                                                   polyVarName: "selections",
//                                                                   decodableParentType: BetslipBaseState.self,
//                                                                   decodingTypes: ["Selection.Single":BetslipSingleSelection.self,
//                                                                                   "Selection.Mutliple":BetslipMultipleSelection.self])])
//            struct BetslipStateInputTest: BetslipBaseState {
//                let changesDetected: Bool?
//                let betContextModes: [BetContextMode]?
//                let combinations: [BetslipCombination]?
//                
//            }
//            """,
//            expandedSource: """
//            protocol BetslipBaseState: Decodable {}
//
//            struct DummyBetslipState: Decodable {
//                let type: String?
//                
//                enum CodingKeys: String, CodingKey {
//                    case type = "$type"
//                }
//                
//                init(from decoder: Decoder) throws {
//                    let container = try decoder.container(keyedBy: CodingKeys.self)
//                    self.type = try container.decodeIfPresent(String.self, forKey: .type)
//                }
//            }
//
//            struct BetslipStateEmpty: BetslipBaseState {
//                
//            }
//
//            struct BetslipStateInput: BetslipBaseState {
//                let selections: [BetslipSelection]?
//                let combinations: [BetslipCombination]?
//                let changesDetected: Bool?
//                let betContextModes: [BetContextMode]?
//                
//            }
//
//            struct BetslipSelection: Decodable {}
//            struct BetslipCombination: Decodable {}
//            struct BetContextMode: Decodable {}
//            struct BetslipResponseTest: Decodable {
//                let id: String?
//
//                let state: BetslipBaseState?
//
//                enum CodingKeys: String, CodingKey {
//                    case id
//                    case state = "state"
//                }
//
//                init(from decoder: Decoder) throws  {
//                    let values = try decoder.container(keyedBy: CodingKeys.self)
//                    self.id = try values.decodeIfPresent(String.self, forKey: .id)
//                    let dummyModel = try values.decodeIfPresent(DummyBetslipState.self, forKey: .state)
//                    switch dummyModel?.type {
//                    case "Empty":
//                        state = try values.decodeIfPresent(BetslipStateEmpty.self, forKey: .state)
//                    case "Input":
//                        state = try values.decodeIfPresent(BetslipStateInput.self, forKey: .state)
//                    default:
//                        state = nil
//                    }
//                }
//            }
//            """,
//            macros: testSameLevelMacros
//        )
//        #else
//        throw XCTSkip("macros are only supported when running tests for the host platform")
//        #endif
//    }
    
    func testJsonPolymporphicManyArrayClass() throws {
        #if canImport(JsonPolymorphicMacroMacros)
        assertMacroExpansion(
            """
            protocol BetslipBaseState: Decodable {}
            protocol BetslipBaseSelection: Decodable {}
            protocol BetslipBaseCombination: Decodable {}

            struct DummyBetslipState: Decodable {
                let type: String?
                
                enum CodingKeys: String, CodingKey {
                    case type = "$type"
                }
                
                init(from decoder: Decoder) throws {
                    let container = try decoder.container(keyedBy: CodingKeys.self)
                    self.type = try container.decodeIfPresent(String.self, forKey: .type)
                }
            }

            struct BetslipStateEmpty: BetslipBaseState {}

            struct BetslipSelection: Decodable {}
            struct BetslipCombination: Decodable {}
            struct BetslipSingleCombination: BetslipBaseCombination {}
            struct BetslipMutlipleCombination: BetslipBaseCombination {}
            struct BetslipMultipleCombination: Decodable {}
            struct BetContextMode: Decodable {}
            struct BetslipSingleSelection: BetslipBaseSelection {}
            struct BetslipMultipleSelection: BetslipBaseSelection {}


            @JsonPolymorphicKeys((JsonPolymorphicSameLevelTypeData(key: "$type",
                                                                   dummyDecoder: [DummyBetslipState].self,
                                                                   polyVarName: "selections",
                                                                   decodableParentType: BetslipBaseSelection.self,
                                                                   decodingTypes: ["Selection.Single":BetslipSingleSelection.self,
                                                                                   "Selection.Mutliple":BetslipMultipleSelection.self]),
                                  JsonPolymorphicSameLevelTypeData(key: "$type",
                                                                   dummyDecoder: [DummyBetslipState].self,
                                                                   polyVarName: "combinations",
                                                                   decodableParentType: BetslipBaseCombination.self,
                                                                   decodingTypes: ["Selection.Single":BetslipSingleCombination.self,
                                                                                   "Selection.Mutliple":BetslipMultipleCombination.self])))
            struct BetslipStateInputTestMulti: BetslipBaseState {
                let changesDetected: Bool?
                let betContextModes: [BetContextMode]?
                
            }
            """,
            expandedSource: """
            protocol BetslipBaseState: Decodable {}

            struct DummyBetslipState: Decodable {
                let type: String?
                
                enum CodingKeys: String, CodingKey {
                    case type = "$type"
                }
                
                init(from decoder: Decoder) throws {
                    let container = try decoder.container(keyedBy: CodingKeys.self)
                    self.type = try container.decodeIfPresent(String.self, forKey: .type)
                }
            }

            struct BetslipStateEmpty: BetslipBaseState {
                
            }

            struct BetslipStateInput: BetslipBaseState {
                let selections: [BetslipSelection]?
                let combinations: [BetslipCombination]?
                let changesDetected: Bool?
                let betContextModes: [BetContextMode]?
                
            }

            struct BetslipSelection: Decodable {}
            struct BetslipCombination: Decodable {}
            struct BetContextMode: Decodable {}
            struct BetslipResponseTest: Decodable {
                let id: String?

                let state: BetslipBaseState?

                enum CodingKeys: String, CodingKey {
                    case id
                    case state = "state"
                }

                init(from decoder: Decoder) throws  {
                    let values = try decoder.container(keyedBy: CodingKeys.self)
                    self.id = try values.decodeIfPresent(String.self, forKey: .id)
                    let dummyModel = try values.decodeIfPresent(DummyBetslipState.self, forKey: .state)
                    switch dummyModel?.type {
                    case "Empty":
                        state = try values.decodeIfPresent(BetslipStateEmpty.self, forKey: .state)
                    case "Input":
                        state = try values.decodeIfPresent(BetslipStateInput.self, forKey: .state)
                    default:
                        state = nil
                    }
                }
            }
            """,
            macros: testSameLevelMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
//    func testJsonPolymporphicDicOptional() throws {
//        #if canImport(JsonPolymorphicMacroMacros)
//        assertMacroExpansion(
//            """
//            @JsonPolymorphicKeys([JsonPolymorphicTypeData(key: "type", polyVarName: "content",
//                                                          decodableParentType: Response.self,
//                                                          decodingTypes: ["Telephones":TelephoneResponse.self,
//                                                                          "Adresses":AdressesResponse.self])])
//            struct PolyResponse: Decodable {
//                let cities: [String:String?]?
//            }
//
//            """,
//            expandedSource: """
//            struct PolyResponse: Decodable {
//                let cities: [String:String?]?
//
//                let content: Response?
//
//                let type: String?
//
//                enum CodingKeys: String, CodingKey {
//                    case cities
//                    case type = "type"
//                    case content
//                }
//
//                init(from decoder: Decoder) throws  {
//                    let values = try decoder.container(keyedBy: CodingKeys.self)
//                    self.cities = try values.decodeIfPresent([String: String?].self, forKey: .cities)
//                    self.type = try values.decodeIfPresent(String.self, forKey: .type)
//                    switch self.type {
//                    case "Adresses":
//                        content = try values.decodeIfPresent(AdressesResponse.self, forKey: .content)
//                    case "Telephones":
//                        content = try values.decodeIfPresent(TelephoneResponse.self, forKey: .content)
//                    default:
//                        content = nil
//                    }
//                }
//            }
//            """,
//            macros: testMacros
//        )
//        #else
//        throw XCTSkip("macros are only supported when running tests for the host platform")
//        #endif
//    }
//    
//    func testJsonPolymporphicDic() throws {
//        #if canImport(JsonPolymorphicMacroMacros)
//        assertMacroExpansion(
//            """
//            @JsonPolymorphicKeys([JsonPolymorphicTypeData(key: "type", polyVarName: "content",
//                                                          decodableParentType: Response.self,
//                                                          decodingTypes: ["Telephones":TelephoneResponse.self,
//                                                                          "Adresses":AdressesResponse.self])])
//            struct PolyResponse: Decodable {
//                let cities: [String:String]?
//            }
//
//            """,
//            expandedSource: """
//            struct PolyResponse: Decodable {
//                let cities: [String:String]?
//
//                let content: Response?
//
//                let type: String?
//
//                enum CodingKeys: String, CodingKey {
//                    case cities
//                    case type = "type"
//                    case content
//                }
//
//                init(from decoder: Decoder) throws  {
//                    let values = try decoder.container(keyedBy: CodingKeys.self)
//                    self.cities = try values.decodeIfPresent([String: String].self, forKey: .cities)
//                    self.type = try values.decodeIfPresent(String.self, forKey: .type)
//                    switch self.type {
//                    case "Adresses":
//                        content = try values.decodeIfPresent(AdressesResponse.self, forKey: .content)
//                    case "Telephones":
//                        content = try values.decodeIfPresent(TelephoneResponse.self, forKey: .content)
//                    default:
//                        content = nil
//                    }
//                }
//            }
//            """,
//            macros: testMacros
//        )
//        #else
//        throw XCTSkip("macros are only supported when running tests for the host platform")
//        #endif
//    }
//    
//    func testJsonPolymporphicArray() throws {
//        #if canImport(JsonPolymorphicMacroMacros)
//        assertMacroExpansion(
//            """
//            @JsonPolymorphicKeys([JsonPolymorphicTypeData(key: "type", polyVarName: "content",
//                                                          decodableParentType: Response.self,
//                                                          decodingTypes: ["Telephones":TelephoneResponse.self,
//                                                                          "Adresses":AdressesResponse.self])])
//            struct PolyResponse {
//                let cities: [String]?
//            }
//
//            """,
//            expandedSource: """
//            struct PolyResponse {
//                let cities: [String]?
//
//                let content: Response?
//
//                let type: String?
//
//                enum CodingKeys: String, CodingKey {
//                    case cities
//                    case type = "type"
//                    case content
//                }
//
//                init(from decoder: Decoder) throws  {
//                    let values = try decoder.container(keyedBy: CodingKeys.self)
//                    self.cities = try values.decodeIfPresent([String].self, forKey: .cities)
//                    self.type = try values.decodeIfPresent(String.self, forKey: .type)
//                    switch self.type {
//                    case "Adresses":
//                        content = try values.decodeIfPresent(AdressesResponse.self, forKey: .content)
//                    case "Telephones":
//                        content = try values.decodeIfPresent(TelephoneResponse.self, forKey: .content)
//                    default:
//                        content = nil
//                    }
//                }
//            }
//            """,
//            macros: testMacros
//        )
//        #else
//        throw XCTSkip("macros are only supported when running tests for the host platform")
//        #endif
//    }
//    
//    func testJsonPolymporphicOptionalArray() throws {
//        #if canImport(JsonPolymorphicMacroMacros)
//        assertMacroExpansion(
//            """
//            @JsonPolymorphicKeys([JsonPolymorphicTypeData(key: "type", polyVarName: "content",
//                                                          decodableParentType: Response.self,
//                                                          decodingTypes: ["Telephones":TelephoneResponse.self,
//                                                                          "Adresses":AdressesResponse.self])])
//            struct PolyResponse {
//                let cities: [String?]?
//            }
//
//            """,
//            expandedSource: """
//            struct PolyResponse {
//                let cities: [String?]?
//
//                let content: Response?
//
//                let type: String?
//
//                enum CodingKeys: String, CodingKey {
//                    case cities
//                    case type = "type"
//                    case content
//                }
//
//                init(from decoder: Decoder) throws  {
//                    let values = try decoder.container(keyedBy: CodingKeys.self)
//                    self.cities = try values.decodeIfPresent([String?].self, forKey: .cities)
//                    self.type = try values.decodeIfPresent(String.self, forKey: .type)
//                    switch self.type {
//                    case "Adresses":
//                        content = try values.decodeIfPresent(AdressesResponse.self, forKey: .content)
//                    case "Telephones":
//                        content = try values.decodeIfPresent(TelephoneResponse.self, forKey: .content)
//                    default:
//                        content = nil
//                    }
//                }
//            }
//            """,
//            macros: testMacros
//        )
//        #else
//        throw XCTSkip("macros are only supported when running tests for the host platform")
//        #endif
//    }
//    
//    
//    func testJsonPolymporphicMacro() throws {
//        #if canImport(JsonPolymorphicMacroMacros)
//        assertMacroExpansion(
//            """
//            @JsonPolymorphicKeys((["$type": ["content" : ["Empty":EmptyResponse.self,
//                                                          "Single":SingleResponse.self,
//                                                          "Many":ListResponse.self]]], Response.self))
//            struct Test: Decodable {
//                let name: String?
//                let a: String?
//            }
//
//            """,
//            expandedSource: """
//            struct Test: Decodable {
//                let name: String?
//                let a: String?
//
//                let content: Response?
//
//                let type: String?
//
//                enum CodingKeys: String, CodingKey {
//                    case name
//                    case a
//                    case type = "$type"
//                    case content
//                }
//
//                init(from decoder: Decoder) throws  {
//                    let values = try decoder.container(keyedBy: CodingKeys.self)
//                    self.name = try values.decodeIfPresent(String.self, forKey: .name)
//                    self.a = try values.decodeIfPresent(String.self, forKey: .a)
//                    self.type = try values.decodeIfPresent(String.self, forKey: .type)
//                    switch self.type {
//                    case "Empty":
//                        content = try values.decodeIfPresent(EmptyResponse.self, forKey: .content)
//                    case "Many":
//                        content = try values.decodeIfPresent(ListResponse.self, forKey: .content)
//                    case "Single":
//                        content = try values.decodeIfPresent(SingleResponse.self, forKey: .content)
//                    default:
//                        content = nil
//                    }
//                }
//            }
//
//            """,
//            macros: testMacros
//        )
//        #else
//        throw XCTSkip("macros are only supported when running tests for the host platform")
//        #endif
//    }
//    
//    func testJsonPolymporphicMacroClass() throws {
//        #if canImport(JsonPolymorphicMacroMacros)
//        assertMacroExpansion(
//            """
//            @JsonPolymorphicKeys([JsonPolymorphicTypeData(key: "$type", polyVarName: "content",
//                                                                 decodableParentType: Response.self,
//                                                                 decodingTypes: ["Empty":EmptyResponse.self,
//                                                                                 "Single":SingleResponse.self,
//                                                                                 "Many":ListResponse.self,
//                                                                                 "WhatElse":WhatEverResponse.self])])
//            struct Test: Decodable {
//                let name: String?
//                let a: String?
//            }
//
//            """,
//            expandedSource: """
//            struct Test: Decodable {
//                let name: String?
//                let a: String?
//
//                let content: Response?
//
//                let type: String?
//
//                enum CodingKeys: String, CodingKey {
//                    case name
//                    case a
//                    case type = "$type"
//                    case content
//                }
//
//                init(from decoder: Decoder) throws  {
//                    let values = try decoder.container(keyedBy: CodingKeys.self)
//                    self.name = try values.decodeIfPresent(String.self, forKey: .name)
//                    self.a = try values.decodeIfPresent(String.self, forKey: .a)
//                    self.type = try values.decodeIfPresent(String.self, forKey: .type)
//                    switch self.type {
//                    case "Empty":
//                        content = try values.decodeIfPresent(EmptyResponse.self, forKey: .content)
//                    case "Many":
//                        content = try values.decodeIfPresent(ListResponse.self, forKey: .content)
//                    case "Single":
//                        content = try values.decodeIfPresent(SingleResponse.self, forKey: .content)
//                    case "WhatElse":
//                        content = try values.decodeIfPresent(WhatEverResponse.self, forKey: .content)
//                    default:
//                        content = nil
//                    }
//                }
//            }
//            """,
//            macros: testMacros
//        )
//        #else
//        throw XCTSkip("macros are only supported when running tests for the host platform")
//        #endif
//    }
}

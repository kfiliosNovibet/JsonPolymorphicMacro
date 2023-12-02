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
    
    
    func testJsonPolymporphicArrayClass() throws {
        #if canImport(JsonPolymorphicMacroMacros)
        assertMacroExpansion(
            """
            protocol BetslipBaseState: Decodable {}
            protocol BetslipBaseSelection: Decodable {}

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
            struct BetContextMode: Decodable {}
            struct BetslipSingleSelection: BetslipBaseSelection {}
            struct BetslipMultipleSelection: BetslipBaseSelection {}

            @JsonPolymorphicKeys((JsonPolymorphicSameLevelTypeData(key: "$type",
                                                                   dummyDecoder: [DummyBetslipState].self,
                                                                   polyVarName: "selections",
                                                                   decodableParentType: BetslipBaseState.self,
                                                                   decodingTypes: ["Selection.Single":BetslipSingleSelection.self,
                                                                                   "Selection.Mutliple":BetslipMultipleSelection.self])))
            struct BetslipStateInputTest: BetslipBaseState {
                let changesDetected: Bool?
                let betContextModes: [BetContextMode]?
                let combinations: [BetslipCombination]?
                
            }
            """,
            expandedSource: """
            protocol BetslipBaseState: Decodable {}
            protocol BetslipBaseSelection: Decodable {}

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
            struct BetContextMode: Decodable {}
            struct BetslipSingleSelection: BetslipBaseSelection {}
            struct BetslipMultipleSelection: BetslipBaseSelection {}
            struct BetslipStateInputTest: BetslipBaseState {
                let changesDetected: Bool?
                let betContextModes: [BetContextMode]?
                let combinations: [BetslipCombination]?



                private (set) var selections: [BetslipBaseState]?

                enum CodingKeys: String, CodingKey {
                    case changesDetected
                    case betContextModes
                    case combinations
                    case selections = "selections"
                }

                init(from decoder: Decoder) throws  {
                    let values = try decoder.container(keyedBy: CodingKeys.self)
                    self.changesDetected = try values.decodeIfPresent(Bool.self, forKey: .changesDetected)
                    self.betContextModes = try values.decodeIfPresent([BetContextMode].self, forKey: .betContextModes)
                    self.combinations = try values.decodeIfPresent([BetslipCombination].self, forKey: .combinations)
                    let dummyModelselections = try values.decodeIfPresent([DummyBetslipState].self, forKey: .selections)
                    var selectionsInstance: [BetslipBaseState] = []
                    try dummyModelselections?.forEach({ item in
                    switch item.type {
                    case "Selection.Mutliple":
                        var selectionsContainer = try values.nestedUnkeyedContainer(forKey: .selections)
                        let instance = try BetslipMultipleSelection.init(from: selectionsContainer.superDecoder())
                        selectionsInstance.append(instance)
                    case "Selection.Single":
                        var selectionsContainer = try values.nestedUnkeyedContainer(forKey: .selections)
                        let instance = try BetslipSingleSelection.init(from: selectionsContainer.superDecoder())
                        selectionsInstance.append(instance)
                    default:
                        selections = nil
                    }})
                    self.selections = selectionsInstance
                }
                
            }
            """,
            macros: testSameLevelMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
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
            struct BetslipStateInputTestMulti: BetslipBaseState {
                let changesDetected: Bool?
                let betContextModes: [BetContextMode]?



                private (set) var selections: [BetslipBaseSelection]?

                private (set) var combinations: [BetslipBaseCombination]?

                enum CodingKeys: String, CodingKey {
                    case changesDetected
                    case betContextModes
                    case selections = "selections"
                    case combinations = "combinations"
                }

                init(from decoder: Decoder) throws  {
                    let values = try decoder.container(keyedBy: CodingKeys.self)
                    self.changesDetected = try values.decodeIfPresent(Bool.self, forKey: .changesDetected)
                    self.betContextModes = try values.decodeIfPresent([BetContextMode].self, forKey: .betContextModes)
                    let dummyModelselections = try values.decodeIfPresent([DummyBetslipState].self, forKey: .selections)
                    var selectionsInstance: [BetslipBaseSelection] = []
                    try dummyModelselections?.forEach({ item in
                    switch item.type {
                    case "Selection.Mutliple":
                        var selectionsContainer = try values.nestedUnkeyedContainer(forKey: .selections)
                        let instance = try BetslipMultipleSelection.init(from: selectionsContainer.superDecoder())
                        selectionsInstance.append(instance)
                    case "Selection.Single":
                        var selectionsContainer = try values.nestedUnkeyedContainer(forKey: .selections)
                        let instance = try BetslipSingleSelection.init(from: selectionsContainer.superDecoder())
                        selectionsInstance.append(instance)
                    default:
                        selections = nil
                    }})
                    self.selections = selectionsInstance
                    let dummyModelcombinations = try values.decodeIfPresent([DummyBetslipState].self, forKey: .combinations)
                    var combinationsInstance: [BetslipBaseCombination] = []
                    try dummyModelcombinations?.forEach({ item in
                    switch item.type {
                    case "Selection.Mutliple":
                        var selectionsContainer = try values.nestedUnkeyedContainer(forKey: .combinations)
                        let instance = try BetslipMultipleCombination.init(from: selectionsContainer.superDecoder())
                        combinationsInstance.append(instance)
                    case "Selection.Single":
                        var selectionsContainer = try values.nestedUnkeyedContainer(forKey: .combinations)
                        let instance = try BetslipSingleCombination.init(from: selectionsContainer.superDecoder())
                        combinationsInstance.append(instance)
                    default:
                        combinations = nil
                    }})
                    self.combinations = combinationsInstance
                }
                
            }
            """,
            macros: testSameLevelMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testJsonPolymporphicArrayAndSingleClass() throws {
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
                                                                   dummyDecoder: DummyBetslipState.self,
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
            struct BetslipStateInputTestMulti: BetslipBaseState {
                let changesDetected: Bool?
                let betContextModes: [BetContextMode]?



                let selections: BetslipBaseSelection?

                private (set) var combinations: [BetslipBaseCombination]?

                enum CodingKeys: String, CodingKey {
                    case changesDetected
                    case betContextModes
                    case selections = "selections"
                    case combinations = "combinations"
                }

                init(from decoder: Decoder) throws  {
                    let values = try decoder.container(keyedBy: CodingKeys.self)
                    self.changesDetected = try values.decodeIfPresent(Bool.self, forKey: .changesDetected)
                    self.betContextModes = try values.decodeIfPresent([BetContextMode].self, forKey: .betContextModes)
                    let dummyModelselections = try values.decodeIfPresent(DummyBetslipState.self, forKey: .selections)
                    switch dummyModelselections?.type {
                    case "Selection.Mutliple":
                        selections = try values.decodeIfPresent(BetslipMultipleSelection.self, forKey: .selections)
                    case "Selection.Single":
                        selections = try values.decodeIfPresent(BetslipSingleSelection.self, forKey: .selections)
                    default:
                        selections = nil
                    }
                    let dummyModelcombinations = try values.decodeIfPresent([DummyBetslipState].self, forKey: .combinations)
                    var combinationsInstance: [BetslipBaseCombination] = []
                    try dummyModelcombinations?.forEach({ item in
                    switch item.type {
                    case "Selection.Mutliple":
                        var selectionsContainer = try values.nestedUnkeyedContainer(forKey: .combinations)
                        let instance = try BetslipMultipleCombination.init(from: selectionsContainer.superDecoder())
                        combinationsInstance.append(instance)
                    case "Selection.Single":
                        var selectionsContainer = try values.nestedUnkeyedContainer(forKey: .combinations)
                        let instance = try BetslipSingleCombination.init(from: selectionsContainer.superDecoder())
                        combinationsInstance.append(instance)
                    default:
                        combinations = nil
                    }})
                    self.combinations = combinationsInstance
                }
                
            }
            """,
            macros: testSameLevelMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}

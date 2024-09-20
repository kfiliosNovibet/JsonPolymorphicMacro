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
                    self.id = try? values.decodeIfPresent(String.self, forKey: .id)
                    let dummyModelstate = try? values.decodeIfPresent(DummyBetslipState.self, forKey: .state)
                    switch dummyModelstate?.type {
                    case "Empty":
                        state = try? values.decodeIfPresent(BetslipStateEmpty.self, forKey: .state)
                    case "Input":
                        state = try? values.decodeIfPresent(BetslipStateInput.self, forKey: .state)
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
            struct BetslipStateInputTest: BetslipBaseState {
                let changesDetected: Bool?
                let betContextModes: [BetContextMode]?
                let combinations: [BetslipCombination]?



                private(set) var selections: [BetslipBaseState]?

                enum CodingKeys: String, CodingKey {
                    case changesDetected
                    case betContextModes
                    case combinations
                    case selections = "selections"
                }

                init(from decoder: Decoder) throws  {
                    let values = try decoder.container(keyedBy: CodingKeys.self)
                    self.changesDetected = try? values.decodeIfPresent(Bool.self, forKey: .changesDetected)
                    self.betContextModes = try? values.decodeIfPresent([BetContextMode].self, forKey: .betContextModes)
                    self.combinations = try? values.decodeIfPresent([BetslipCombination].self, forKey: .combinations)
                    let dummyModelselections = try? values.decodeIfPresent([DummyBetslipState].self, forKey: .selections)
                    var selectionsInstance: [BetslipBaseState] = []
                    if var nestedContainerselections = try? values.nestedUnkeyedContainer(forKey: .selections) {
                    while !nestedContainerselections.isAtEnd {
                    let dummyItem = dummyModelselections? [nestedContainerselections.currentIndex]
                    switch dummyItem?.type {
                    case "Selection.Mutliple":
                        if let instance = try? nestedContainerselections.decode(BetslipMultipleSelection.self) {
                        selectionsInstance.append(instance)}
                    case "Selection.Single":
                        if let instance = try? nestedContainerselections.decode(BetslipSingleSelection.self) {
                        selectionsInstance.append(instance)}
                    default:
                        _ = try? nestedContainerselections.decode(DummyBetslipState.self)
                        selections = nil
                    }}}
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
            struct BetslipStateInputTestMulti: BetslipBaseState {
                let changesDetected: Bool?
                let betContextModes: [BetContextMode]?



                private(set) var selections: [BetslipBaseSelection]?

                private(set) var combinations: [BetslipBaseCombination]?

                enum CodingKeys: String, CodingKey {
                    case changesDetected
                    case betContextModes
                    case selections = "selections"
                    case combinations = "combinations"
                }

                init(from decoder: Decoder) throws  {
                    let values = try decoder.container(keyedBy: CodingKeys.self)
                    self.changesDetected = try? values.decodeIfPresent(Bool.self, forKey: .changesDetected)
                    self.betContextModes = try? values.decodeIfPresent([BetContextMode].self, forKey: .betContextModes)
                    let dummyModelselections = try? values.decodeIfPresent([DummyBetslipState].self, forKey: .selections)
                    var selectionsInstance: [BetslipBaseSelection] = []
                    if var nestedContainerselections = try? values.nestedUnkeyedContainer(forKey: .selections) {
                    while !nestedContainerselections.isAtEnd {
                    let dummyItem = dummyModelselections? [nestedContainerselections.currentIndex]
                    switch dummyItem?.type {
                    case "Selection.Mutliple":
                        if let instance = try? nestedContainerselections.decode(BetslipMultipleSelection.self) {
                        selectionsInstance.append(instance)}
                    case "Selection.Single":
                        if let instance = try? nestedContainerselections.decode(BetslipSingleSelection.self) {
                        selectionsInstance.append(instance)}
                    default:
                        _ = try? nestedContainerselections.decode(DummyBetslipState.self)
                        selections = nil
                    }}}
                    self.selections = selectionsInstance
                    let dummyModelcombinations = try? values.decodeIfPresent([DummyBetslipState].self, forKey: .combinations)
                    var combinationsInstance: [BetslipBaseCombination] = []
                    if var nestedContainercombinations = try? values.nestedUnkeyedContainer(forKey: .combinations) {
                    while !nestedContainercombinations.isAtEnd {
                    let dummyItem = dummyModelcombinations? [nestedContainercombinations.currentIndex]
                    switch dummyItem?.type {
                    case "Selection.Mutliple":
                        if let instance = try? nestedContainercombinations.decode(BetslipMultipleCombination.self) {
                        combinationsInstance.append(instance)}
                    case "Selection.Single":
                        if let instance = try? nestedContainercombinations.decode(BetslipSingleCombination.self) {
                        combinationsInstance.append(instance)}
                    default:
                        _ = try? nestedContainercombinations.decode(DummyBetslipState.self)
                        combinations = nil
                    }}}
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
            struct BetslipStateInputTestMulti: BetslipBaseState {
                let changesDetected: Bool?
                let betContextModes: [BetContextMode]?



                let selections: BetslipBaseSelection?

                private(set) var combinations: [BetslipBaseCombination]?

                enum CodingKeys: String, CodingKey {
                    case changesDetected
                    case betContextModes
                    case selections = "selections"
                    case combinations = "combinations"
                }

                init(from decoder: Decoder) throws  {
                    let values = try decoder.container(keyedBy: CodingKeys.self)
                    self.changesDetected = try? values.decodeIfPresent(Bool.self, forKey: .changesDetected)
                    self.betContextModes = try? values.decodeIfPresent([BetContextMode].self, forKey: .betContextModes)
                    let dummyModelselections = try? values.decodeIfPresent(DummyBetslipState.self, forKey: .selections)
                    switch dummyModelselections?.type {
                    case "Selection.Mutliple":
                        selections = try? values.decodeIfPresent(BetslipMultipleSelection.self, forKey: .selections)
                    case "Selection.Single":
                        selections = try? values.decodeIfPresent(BetslipSingleSelection.self, forKey: .selections)
                    default:
                        selections = nil
                    }
                    let dummyModelcombinations = try? values.decodeIfPresent([DummyBetslipState].self, forKey: .combinations)
                    var combinationsInstance: [BetslipBaseCombination] = []
                    if var nestedContainercombinations = try? values.nestedUnkeyedContainer(forKey: .combinations) {
                    while !nestedContainercombinations.isAtEnd {
                    let dummyItem = dummyModelcombinations? [nestedContainercombinations.currentIndex]
                    switch dummyItem?.type {
                    case "Selection.Mutliple":
                        if let instance = try? nestedContainercombinations.decode(BetslipMultipleCombination.self) {
                        combinationsInstance.append(instance)}
                    case "Selection.Single":
                        if let instance = try? nestedContainercombinations.decode(BetslipSingleCombination.self) {
                        combinationsInstance.append(instance)}
                    default:
                        _ = try? nestedContainercombinations.decode(DummyBetslipState.self)
                        combinations = nil
                    }}}
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
    
    func testJsonPolymporphicArrayClassSingleExtraKey() throws {
        #if canImport(JsonPolymorphicMacroMacros)
        assertMacroExpansion(
            """
            @JsonPolymorphicKeys((JsonPolymorphicSameLevelTypeData(key: "$type",
                                                                   dummyDecoder: [DummyBetslipState].self,
                                                                   polyVarName: "selections",
                                                                   decodableParentType: BetslipBaseSelection.self,
                                                                   decodingTypes: ["Selection.Single":BetslipSingleSelection.self,
                                                                                   "Selection.Mutliple":BetslipMultipleSelection.self],
                                                                   extraCustomCodingKeys: [ExtraCustomCodingKeys(paramName: "type", paramCodingKey:"$type", type: String.self)])))
            struct BetslipStateInputTest: BetslipBaseState {
                let changesDetected: Bool?
                let betContextModes: [BetContextMode]?
                let combinations: [BetslipCombination]?
                
            }
            """,
            expandedSource: """
            struct BetslipStateInputTest: BetslipBaseState {
                let changesDetected: Bool?
                let betContextModes: [BetContextMode]?
                let combinations: [BetslipCombination]?



                private(set) var selections: [BetslipBaseSelection]?

                let type: String?

                enum CodingKeys: String, CodingKey {
                    case changesDetected
                    case betContextModes
                    case combinations
                    case selections = "selections"
                    case type = "$type"
                }

                init(from decoder: Decoder) throws  {
                    let values = try decoder.container(keyedBy: CodingKeys.self)
                    self.changesDetected = try? values.decodeIfPresent(Bool.self, forKey: .changesDetected)
                    self.betContextModes = try? values.decodeIfPresent([BetContextMode].self, forKey: .betContextModes)
                    self.combinations = try? values.decodeIfPresent([BetslipCombination].self, forKey: .combinations)
                    self.type = try? values.decodeIfPresent(String.self, forKey: .type)
                    let dummyModelselections = try? values.decodeIfPresent([DummyBetslipState].self, forKey: .selections)
                    var selectionsInstance: [BetslipBaseSelection] = []
                    if var nestedContainerselections = try? values.nestedUnkeyedContainer(forKey: .selections) {
                    while !nestedContainerselections.isAtEnd {
                    let dummyItem = dummyModelselections? [nestedContainerselections.currentIndex]
                    switch dummyItem?.type {
                    case "Selection.Mutliple":
                        if let instance = try? nestedContainerselections.decode(BetslipMultipleSelection.self) {
                        selectionsInstance.append(instance)}
                    case "Selection.Single":
                        if let instance = try? nestedContainerselections.decode(BetslipSingleSelection.self) {
                        selectionsInstance.append(instance)}
                    default:
                        _ = try? nestedContainerselections.decode(DummyBetslipState.self)
                        selections = nil
                    }}}
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
    
    func testJsonPolymporphicArrayClassManyExtraKeys() throws {
        #if canImport(JsonPolymorphicMacroMacros)
        assertMacroExpansion(
            """
            @JsonPolymorphicKeys((JsonPolymorphicSameLevelTypeData(key: "$type",
                                                                   dummyDecoder: [DummyBetslipState].self,
                                                                   polyVarName: "selections",
                                                                   decodableParentType: BetslipBaseSelection.self,
                                                                   decodingTypes: ["Selection.Single":BetslipSingleSelection.self,
                                                                                   "Selection.Mutliple":BetslipMultipleSelection.self],
                                                                   extraCustomCodingKeys: [ExtraCustomCodingKeys(paramName: "type", paramCodingKey:"$type", type: String.self), ExtraCustomCodingKeys(paramName: "newType", paramCodingKey:"$newType", type: String.self), ExtraCustomCodingKeys(paramName: "oldType", paramCodingKey:"$oldType", type: String.self)]))
            struct BetslipStateInputTest: BetslipBaseState {
                let changesDetected: Bool?
                let betContextModes: [BetContextMode]?
                let combinations: [BetslipCombination]?
                
            }
            """,
            expandedSource: """
            struct BetslipStateInputTest: BetslipBaseState {
                let changesDetected: Bool?
                let betContextModes: [BetContextMode]?
                let combinations: [BetslipCombination]?



                private(set) var selections: [BetslipBaseSelection]?

                let type: String?

                let newType: String?

                let oldType: String?

                enum CodingKeys: String, CodingKey {
                    case changesDetected
                    case betContextModes
                    case combinations
                    case selections = "selections"
                    case type = "$type"
                    case newType = "$newType"
                    case oldType = "$oldType"
                }

                init(from decoder: Decoder) throws  {
                    let values = try decoder.container(keyedBy: CodingKeys.self)
                    self.changesDetected = try? values.decodeIfPresent(Bool.self, forKey: .changesDetected)
                    self.betContextModes = try? values.decodeIfPresent([BetContextMode].self, forKey: .betContextModes)
                    self.combinations = try? values.decodeIfPresent([BetslipCombination].self, forKey: .combinations)
                    self.type = try? values.decodeIfPresent(String.self, forKey: .type)
                    self.newType = try? values.decodeIfPresent(String.self, forKey: .newType)
                    self.oldType = try? values.decodeIfPresent(String.self, forKey: .oldType)
                    let dummyModelselections = try? values.decodeIfPresent([DummyBetslipState].self, forKey: .selections)
                    var selectionsInstance: [BetslipBaseSelection] = []
                    if var nestedContainerselections = try? values.nestedUnkeyedContainer(forKey: .selections) {
                    while !nestedContainerselections.isAtEnd {
                    let dummyItem = dummyModelselections? [nestedContainerselections.currentIndex]
                    switch dummyItem?.type {
                    case "Selection.Mutliple":
                        if let instance = try? nestedContainerselections.decode(BetslipMultipleSelection.self) {
                        selectionsInstance.append(instance)}
                    case "Selection.Single":
                        if let instance = try? nestedContainerselections.decode(BetslipSingleSelection.self) {
                        selectionsInstance.append(instance)}
                    default:
                        _ = try? nestedContainerselections.decode(DummyBetslipState.self)
                        selections = nil
                    }}}
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
}

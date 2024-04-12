import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(JsonPolymorphicMacroMacros)
import JsonPolymorphicMacroMacros
#endif

final class JsonPolymorphicMacroErrorTest: XCTestCase {
    
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


            @JsonPolymorphicKeys(JsonPolymorphicSameLevelTypeData(key: "$type",
                                                                   dummyDecoder: DummyBetslipState.self,
                                                                   polyVarName: "state",
                                                                   decodableParentType: BetslipBaseState.self,
                                                                   decodingTypes: ["Empty":BetslipStateEmpty.self,
                                                                                   "Input":BetslipStateInput.self]))
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
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: "JsonPolymorphicMacro error: JsonPolymorphicKeys needs tuple input, please check parentheses", line: 33, column: 1)
            ],
            macros: testSameLevelMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}

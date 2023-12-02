//
//  DecodeSameLevelSwitch.swift
//
//
//  Created by Kostas Filios on 30/11/23.
//

import Foundation
import JsonPolymorphicMacro

final class DecodeSameLevelSwitch {
    
    private let jsonData = "{\"$type\":\"BlueBrown.Betslips.Shared.BetslipModel, BlueBrown.Betslips.Shared\",\"id\":\"1179396354229665792\",\"player\":{\"$type\":\"Anonymous\",\"currencySysname\":\"EUR\",\"oddsRepresentation\":\"Decimal\",\"oddsChangeStrategy\":\"Reject\"},\"state\":{\"$type\":\"Input\",\"selections\":[{\"$type\":\"Selection.Single\",\"betInstanceState\":{\"betInstanceId\":\"2653913426\",\"marketInstanceId\":\"107434685\",\"marketId\":10131,\"marketSysname\":\"SOCCER_MATCH_RESULT_PRELIVE\",\"code\":\"1\",\"modifier\":null,\"offerCaption\":\"Τελικό Αποτέλεσμα\",\"offerBetCaption\":\"DONT REMOVE THIS\",\"previousSelectedOdds\":{\"price\":{\"value\":2.25,\"text\":\"2.25\"},\"isOffered\":true,\"isSuspended\":false,\"timeStamp\":\"2023-11-27T13:40:13.5555Z\"},\"selectedOdds\":{\"price\":{\"value\":2.25,\"text\":\"2.25\"},\"isOffered\":true,\"isSuspended\":false,\"timeStamp\":\"2023-11-27T13:40:13.5555Z\"},\"currentOdds\":{\"price\":{\"value\":2.25,\"text\":\"2.25\"},\"isOffered\":true,\"isSuspended\":false,\"timeStamp\":\"2023-11-27T13:40:13.5555Z\"}},\"id\":\"4877d41f-a662-41af-9919-a8bb857a254d\",\"betContextId\":\"4915942\",\"competitionHistoryBetContextId\":\"3490931\",\"competitionId\":\"4320\",\"betContextCaption\":\"DONT REMOVE THIS - DONT TOUCH THIS\",\"competitionContextSysname\":\"SOCCER\",\"betContextTypeSysname\":\"EVENT_HISTORY\",\"betContextState\":{\"isInPlay\":false,\"isLive\":false,\"isActive\":true},\"competitorsCaptions\":{\"$type\":\"TeamMatch\",\"homeTeamCaption\":\"DONT REMOVE THIS\",\"awayTeamCaption\":\"DONT TOUCH THIS\"},\"isBanker\":false,\"isActive\":true,\"isAwayAtHome\":false,\"errors\":[]}],\"combinations\":[{\"$type\":\"Combination.Single\",\"selectionId\":\"4877d41f-a662-41af-9919-a8bb857a254d\",\"id\":\"0a12ee84-db68-4fa1-87c8-b394aef26a46\",\"errors\":[],\"prices\":{\"current\":{\"value\":2.25,\"text\":\"2.25\"},\"previous\":{\"value\":2.25,\"text\":\"2.25\"}},\"financials\":{\"cost\":0,\"payout\":0,\"bonus\":null,\"tax\":0,\"taxBonus\":0,\"settlementSchemeId\":\"23\"},\"freeBet\":null,\"amount\":null}],\"changesDetected\":false,\"totals\":{\"cost\":0,\"payout\":0,\"tax\":0,\"taxBonus\":0,\"bonus\":0}},\"betContextModes\":[],\"settings\":{\"maxSelections\":20,\"betBuilderMinItems\":2,\"betBuilderMaxItems\":12}}"
    
    func decode() {
        let test = try! JSONDecoder().decode(BetslipResponse.self, from: jsonData.data(using: .utf8)!)
        print(test.self)
        
        let test2 = try! JSONDecoder().decode(BetslipResponseTest.self, from: jsonData.data(using: .utf8)!)
        print(test2.self)
    }
}

struct BetslipResponse: Decodable {
    let id: String?
    let state: BetslipBaseState?
    
    enum CodingKeys: String, CodingKey {
        case id
        case player
        case betContextModes
        case state
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(String.self, forKey: .id)
        let tempState = try container.decodeIfPresent(DummyBetslipState.self, forKey: .state)

        guard let tempState else {
            self.state = try container.decodeIfPresent(BetslipStateEmpty.self, forKey: .state)
            return
        }
        switch tempState.type {
        case "Empty":
            self.state = try container.decodeIfPresent(BetslipStateEmpty.self, forKey: .state)
        case "Input":
            self.state = try container.decodeIfPresent(BetslipStateInputTestMulti.self, forKey: .state)
        default:
            self.state = try container.decodeIfPresent(BetslipStateEmpty.self, forKey: .state)
        }
    }
}



@JsonPolymorphicKeys((JsonPolymorphicSameLevelTypeData(key: "$type",
                                                       dummyDecoder: DummyBetslipState.self,
                                                       polyVarName: "state",
                                                       decodableParentType: BetslipBaseState.self,
                                                       decodingTypes: ["Empty":BetslipStateEmpty.self,
                                                                       "Input":BetslipStateInputTestMulti.self])))
struct BetslipResponseTest: Decodable {
    let id: String?
}

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
                                                       decodingTypes: ["Combination.Single":BetslipSingleCombination.self,
                                                                       "Combination.Multiple":BetslipMutlipleCombination.self])))
struct BetslipStateInputTestMulti: BetslipBaseState {
    let changesDetected: Bool?
    let betContextModes: [BetContextMode]?
    
}

//struct BetslipStateInput: BetslipBaseState {
//    var selections: [BetslipBaseSelection]?
//    let combinations: [BetslipCombination]?
//    let changesDetected: Bool?
//    let betContextModes: [BetContextMode]?
//    
//        enum CodingKeys: String, CodingKey {
//            case selections
//            case combinations
//            case changesDetected
//            case betContextModes
//        }
//    
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        
//        let dummyselections = try container.decodeIfPresent([DummyBetslipState].self, forKey: .selections)
//        self.combinations = try container.decodeIfPresent([BetslipCombination].self, forKey: .combinations)
//        self.changesDetected = try container.decodeIfPresent(Bool.self, forKey: .changesDetected)
//        self.betContextModes = try container.decodeIfPresent([BetContextMode].self, forKey: .betContextModes)
// 
//        var selections = [BetslipBaseSelection]()
//        try dummyselections?.forEach({ selection in
//            switch selection.type {
//            case "Selection.Single":
//                var selectionsContainer = try container.nestedUnkeyedContainer(forKey: .selections)
//                let instance = try BetslipSingleSelection.init(from: selectionsContainer.superDecoder())
//                selections.append(instance)
//            case "Selection.Mutliple":
//                var selectionsContainer = try container.nestedUnkeyedContainer(forKey: .selections)
//                let instance = try BetslipSingleSelection.init(from: selectionsContainer.superDecoder())
//                selections.append(instance)
//            default:
//                break
//            }
//        })
//        self.selections = selections
//    }
//}



@JsonPolymorphicKeys((JsonPolymorphicSameLevelTypeData(key: "$type",
                                                       dummyDecoder: [DummyBetslipState].self,
                                                       polyVarName: "selections",
                                                       decodableParentType: BetslipBaseSelection.self,
                                                       decodingTypes: ["Selection.Single":BetslipSingleSelection.self,
                                                                       "Selection.Mutliple":BetslipMultipleSelection.self])))
struct BetslipStateInputTest: BetslipBaseState {
    let changesDetected: Bool?
    let betContextModes: [BetContextMode]?
    let combinations: [BetslipCombination]?
    
}

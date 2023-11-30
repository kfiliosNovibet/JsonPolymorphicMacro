import JsonPolymorphicMacro
import Foundation

let  decodeSameLevelSwitch = DecodeSameLevelSwitch()
decodeSameLevelSwitch.decode()

protocol Response: Decodable {
}

struct EmptyResponse: Response {
    let success: Bool}

struct SingleResponse: Response {
    let success: Bool
    let name: String
}

struct ListResponse: Response {
    let name: [String]
    let success: Bool
}

struct WhatEverResponse: Response {
    let sirName: String
    let success: Bool
}

@JsonPolymorphicKeys((["$type": ["content" : ["Empty":EmptyResponse.self,
                                              "Single":SingleResponse.self,
                                              "Many":ListResponse.self,
                                              "WhatElse":WhatEverResponse.self]]], Response.self))
struct Test: Decodable {
    let name: String?
    let a: String?
}


@JsonPolymorphicKeys([JsonPolymorphicTypeData(key: "$type", polyVarName: "content",
                                              decodableParentType: Response.self,
                                              decodingTypes: ["Empty":EmptyResponse.self,
                                                              "Single":SingleResponse.self,
                                                              "Many":ListResponse.self,
                                                              "WhatElse":WhatEverResponse.self])])
struct Test2: Decodable {
    let name: String?
    let a: String?
}

struct TelephoneResponse: Response {
    let number: [String]
}

struct AdressesResponse: Response {
    let adresses: [Address]
}

struct Address: Response {
    let number: String
    let street: String
}


@JsonPolymorphicKeys([JsonPolymorphicTypeData(key: "type", polyVarName: "content",
                                              decodableParentType: Response.self,
                                              decodingTypes: ["Telephones":TelephoneResponse.self,
                                                              "Adresses":AdressesResponse.self])])
struct PolyResponse: Decodable {
    let cities: [String]?
}

let test = try! JSONDecoder().decode(Test.self, from: "{ \"$type\": \"Single\", \"content\": { \"success\" : true, \"name\" :\"John\"}}".data(using: .utf8)!)
print("The name is: \((test.content as? SingleResponse)?.name ?? "")")

let test2 = try! JSONDecoder().decode(Test2.self, from: "{ \"$type\": \"Empty\", \"content\": { \"success\" : true, \"name\" :\"John\"}}".data(using: .utf8)!)
print("The name is: \(test2.type ?? "")")


let testTelephoneArray = try! JSONDecoder().decode(PolyResponse.self, from: "{ \"type\": \"Telephones\", \"cities\":[\"Athens\", \"Krakow\", \"Catania\"]  ,\"content\": { \"number\" : [\"2103722001\", \"48224202020\", \"095580014\"]}}".data(using: .utf8)!)
print("The name is: \((testTelephoneArray.content as? TelephoneResponse)?.number ?? [""])")

let testAdressesArray = try! JSONDecoder().decode(PolyResponse.self, from: "{\"type\" : \"Adresses\",\"cities\" : [\"Athens\", \"Krakow\", \"Catania\"],\"content\": {\"adresses\": [{\"number\": \"12\", \"street\": \"Ermou\"}, {\"number\": \"12\", \"street\": \"Ermou\"}, {\"number\": \"12\", \"street\": \"Ermou\"}]}}".data(using: .utf8)!)
print("The name is: \((testAdressesArray.content as? AdressesResponse)?.adresses ?? [])")

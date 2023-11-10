import JsonPolymorphicMacro
import Foundation

protocol Response: Decodable {
    var success: Bool { get }
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

let test = try! JSONDecoder().decode(Test.self, from: "{ \"$type\": \"Single\", \"content\": { \"success\" : true, \"name\" :\"John\"}}".data(using: .utf8)!)
print("The name is: \((test.content as? SingleResponse)?.name ?? "")")

let test2 = try! JSONDecoder().decode(Test2.self, from: "{ \"$type\": \"Empty\", \"content\": { \"success\" : true, \"name\" :\"John\"}}".data(using: .utf8)!)
print("The name is: \(test2.type ?? "")")

//test.
var a = 17
let b = 25

let (result, code) = #stringify(a + b)

print("The value \(a) was produced by the code \"\(b)\"")

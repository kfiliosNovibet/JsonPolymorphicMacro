import JsonPolymorphicMacro
import Foundation

protocol Response: Decodable {}

struct EmptyResponse: Response {
    let success: Bool
}

struct SingleResponse: Response {
    let name: String
    let success: Bool
}

struct ListResponse: Response {
    let name: [String]
    let success: Bool
}

@JsonPolymorphicKeys((["$type": ["content" : ["Empty":EmptyResponse.self,
                                              "Single":SingleResponse.self,
                                              "Many":ListResponse.self]]], Response.self))
struct Test: Decodable {
    let name: String?
    let a: String?
}

//
//@CodingKeys(["a": CodableTest])
var a = 17
let b = 25

let (result, code) = #stringify(a + b)

print("The value \(a) was produced by the code \"\(b)\"")

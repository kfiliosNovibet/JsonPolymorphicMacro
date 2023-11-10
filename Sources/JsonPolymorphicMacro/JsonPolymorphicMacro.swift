// The Swift Programming Language
// https://docs.swift.org/swift-book


//([String:[String:[String:Decodable.Type]]], Decodable.Type) ->
// (["jsonKeyForPolymorfism",["jsonPolyMorficVariableKey": ["jsonKeyForPolymorfism":DecodableModel]]], DecodableModelTypesConformer)
@attached(member, names: arbitrary)
@available(*, deprecated, message: "Use instead JsonPolymorphicKeys[JsonPolymorphicTypeData]")
public macro JsonPolymorphicKeys<T>(_ type: ([String:[String:[String:Decodable.Type]]], T)) = #externalMacro(module: "JsonPolymorphicMacroMacros", type: "JsonPolymorphicMacro")

@attached(member, names: arbitrary)
public macro JsonPolymorphicKeys<Decodable>(_ type: ([JsonPolymorphicTypeData<Decodable>])) = #externalMacro(module: "JsonPolymorphicMacroMacros", type: "JsonPolymorphicMacro")

// The Swift Programming Language
// https://docs.swift.org/swift-book

/// A macro that produces both a value and a string containing the
/// source code that generated the value. For example,
///
///     #stringify(x + y)
///
/// produces a tuple `(x + y, "x + y")`.
@freestanding(expression)
public macro stringify<T>(_ value: T) -> (T, String) = #externalMacro(module: "JsonPolymorphicMacroMacros", type: "StringifyMacro")

//([String:[String:[String:Decodable.Type]]], Decodable.Type) ->
// (["jsonKeyForPolymorfism",["jsonPolyMorficVariableKey": ["jsonKeyForPolymorfism":DecodableModel]]], DecodableModelTypesConformer)
@attached(member, names: arbitrary)
public macro JsonPolymorphicKeys<T>(_ type: ([String:[String:[String:Decodable.Type]]], T)) = #externalMacro(module: "JsonPolymorphicMacroMacros", type: "JsonPolymorphicMacro")

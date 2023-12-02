// The Swift Programming Language
// https://docs.swift.org/swift-book


//([String:[String:[String:Decodable.Type]]], Decodable.Type) ->
// (["jsonKeyForPolymorfism",["jsonPolyMorficVariableKey": ["jsonKeyForPolymorfism":DecodableModel]]], DecodableModelTypesConformer)
@attached(member, names: arbitrary)
@available(*, deprecated, message: "Use instead JsonPolymorphicKeys[JsonPolymorphicTypeData]")
public macro JsonPolymorphicKeys<T>(_ type: ([String:[String:[String:Decodable.Type]]], T)) = #externalMacro(module: "JsonPolymorphicMacroMacros", type: "JsonPolymorphicMacro")

@attached(member, names: arbitrary)
public macro JsonPolymorphicKeys<Decodable>(_ type: ((JsonPolymorphicTypeData<Decodable>))) = #externalMacro(module: "JsonPolymorphicMacroMacros", type: "JsonPolymorphicMacro")

// 1 Param Macro
@attached(member, names: arbitrary)
public macro JsonPolymorphicKeys<T>(_ type: ((JsonPolymorphicSameLevelTypeData<T>))) = #externalMacro(module: "JsonPolymorphicMacroMacros", type: "JsonPolymorphicMacro")

// 2 Params Macro
@attached(member, names: arbitrary)
public macro JsonPolymorphicKeys<T, K>(_ type: (JsonPolymorphicSameLevelTypeData<T>, JsonPolymorphicSameLevelTypeData<K>)) = #externalMacro(module: "JsonPolymorphicMacroMacros", type: "JsonPolymorphicMacro")

// 3 Params Macro
@attached(member, names: arbitrary)
public macro JsonPolymorphicKeys<T, K, M>(_ type: (JsonPolymorphicSameLevelTypeData<T>, JsonPolymorphicSameLevelTypeData<K>, JsonPolymorphicSameLevelTypeData<M>)) = #externalMacro(module: "JsonPolymorphicMacroMacros", type: "JsonPolymorphicMacro")

// 4 Params Macro
@attached(member, names: arbitrary)
public macro JsonPolymorphicKeys<T, K, M, N>(_ type: (JsonPolymorphicSameLevelTypeData<T>, JsonPolymorphicSameLevelTypeData<K>, JsonPolymorphicSameLevelTypeData<M>, JsonPolymorphicSameLevelTypeData<N>)) = #externalMacro(module: "JsonPolymorphicMacroMacros", type: "JsonPolymorphicMacro")

// 5 Params Macro
@attached(member, names: arbitrary)
public macro JsonPolymorphicKeys<T, K, M, N, Y>(_ type: (JsonPolymorphicSameLevelTypeData<T>, JsonPolymorphicSameLevelTypeData<K>, JsonPolymorphicSameLevelTypeData<M>, JsonPolymorphicSameLevelTypeData<N>, JsonPolymorphicSameLevelTypeData<Y>)) = #externalMacro(module: "JsonPolymorphicMacroMacros", type: "JsonPolymorphicMacro")

// 6 Params Macro
@attached(member, names: arbitrary)
public macro JsonPolymorphicKeys<T, K, M, N, Y, O>(_ type: (JsonPolymorphicSameLevelTypeData<T>, JsonPolymorphicSameLevelTypeData<K>, JsonPolymorphicSameLevelTypeData<M>, JsonPolymorphicSameLevelTypeData<N>, JsonPolymorphicSameLevelTypeData<Y>, JsonPolymorphicSameLevelTypeData<O>)) = #externalMacro(module: "JsonPolymorphicMacroMacros", type: "JsonPolymorphicMacro")

// If need more please add them bellow 

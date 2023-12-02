// The Swift Programming Language
// https://docs.swift.org/swift-book


//([String:[String:[String:Decodable.Type]]], Decodable.Type) ->
// (["jsonKeyForPolymorfism",["jsonPolyMorficVariableKey": ["jsonKeyForPolymorfism":DecodableModel]]], DecodableModelTypesConformer)
@attached(member, names: arbitrary)
@available(*, deprecated, message: "Use instead JsonPolymorphicKeys[JsonPolymorphicTypeData]")
public macro JsonPolymorphicKeys<T>(_ type: ([String:[String:[String:Decodable.Type]]], T)) = #externalMacro(module: "JsonPolymorphicMacroMacros", type: "JsonPolymorphicMacro")

// 1 Param Macro
@attached(member, names: arbitrary)
public macro JsonPolymorphicKeys<T>(_ type: ((JsonPolymorphicTypeData<T>))) = #externalMacro(module: "JsonPolymorphicMacroMacros", type: "JsonPolymorphicMacro")

// 2 Params Macro
@attached(member, names: arbitrary)
public macro JsonPolymorphicKeys<T, K>(_ type: ((JsonPolymorphicTypeData<T>, JsonPolymorphicTypeData<K>))) = #externalMacro(module: "JsonPolymorphicMacroMacros", type: "JsonPolymorphicMacro")

// 3 Params Macro
@attached(member, names: arbitrary)
public macro JsonPolymorphicKeys<T, K, M>(_ type: (JsonPolymorphicTypeData<T>, JsonPolymorphicTypeData<K>, JsonPolymorphicTypeData<M>)) = #externalMacro(module: "JsonPolymorphicMacroMacros", type: "JsonPolymorphicMacro")

// 4 Params Macro
@attached(member, names: arbitrary)
public macro JsonPolymorphicKeys<T, K, M, N>(_ type: (JsonPolymorphicTypeData<T>, JsonPolymorphicTypeData<K>, JsonPolymorphicTypeData<M>, JsonPolymorphicTypeData<N>)) = #externalMacro(module: "JsonPolymorphicMacroMacros", type: "JsonPolymorphicMacro")

// 5 Params Macro
@attached(member, names: arbitrary)
public macro JsonPolymorphicKeys<T, K, M, N, Y>(_ type: (JsonPolymorphicTypeData<T>, JsonPolymorphicTypeData<K>, JsonPolymorphicTypeData<M>, JsonPolymorphicTypeData<N>, JsonPolymorphicTypeData<Y>)) = #externalMacro(module: "JsonPolymorphicMacroMacros", type: "JsonPolymorphicMacro")

// 6 Params Macro
@attached(member, names: arbitrary)
public macro JsonPolymorphicKeys<T, K, M, N, Y, O>(_ type: (JsonPolymorphicTypeData<T>, JsonPolymorphicTypeData<K>, JsonPolymorphicTypeData<M>, JsonPolymorphicTypeData<N>, JsonPolymorphicTypeData<Y>, JsonPolymorphicTypeData<O>)) = #externalMacro(module: "JsonPolymorphicMacroMacros", type: "JsonPolymorphicMacro")

// If need more please add them bellow


//// Polymorphic Array types below

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


///  Before you move forward and add more generic combinations please keep in mind that maybe this is going to be an abuse
///  and in my opinion please rethought your backend services responses because with so much polymorphism you are going to have
///  P(n,k) = n!/(n-k)! -> this leads to many algebraic data analysis models
